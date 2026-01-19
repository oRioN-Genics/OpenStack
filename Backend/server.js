const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const axios = require("axios");

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;
const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY || "";
const OPENROUTER_MODEL =
  process.env.OPENROUTER_MODEL || "mistralai/mistral-7b-instruct";
const GITHUB_TOKEN = process.env.GITHUB_TOKEN || "";

const GH_HEADERS = {
  Accept: "application/vnd.github+json",
  "User-Agent": "open-stack-backend",
  ...(GITHUB_TOKEN ? { Authorization: `Bearer ${GITHUB_TOKEN}` } : {}),
};

const DEFAULT_LANGUAGES = [
  "Python",
  "JavaScript",
  "TypeScript",
  "Java",
  "Go",
  "C#",
  "C++",
  "Rust",
  "Dart",
  "Ruby",
];

const DEFAULT_TECH_GROUPS = {
  Frontend: ["React", "Flutter", "Vue", "Svelte", "Angular"],
  Backend: ["Node", "Django", "Spring", "Rails", "FastAPI"],
  AI: ["PyTorch", "TensorFlow", "scikit-learn"],
  DevOps: ["Docker", "Kubernetes", "Terraform", "GitHub Actions"],
};

function extractJson(text) {
  const start = text.indexOf("{");
  const end = text.lastIndexOf("}");
  if (start === -1 || end === -1 || end <= start) return null;
  const raw = text.substring(start, end + 1);
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

async function callOpenRouterJson(prompt) {
  if (!OPENROUTER_API_KEY) {
    throw new Error("OPENROUTER_API_KEY is missing.");
  }

  const url = "https://openrouter.ai/api/v1/chat/completions";
  const res = await axios.post(
    url,
    {
      model: OPENROUTER_MODEL,
      messages: [
        { role: "system", content: "Return strictly valid JSON." },
        { role: "user", content: prompt },
      ],
      temperature: 0.4,
    },
    {
      headers: {
        Authorization: `Bearer ${OPENROUTER_API_KEY}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "http://localhost",
        "X-Title": "OpenStack MVP",
      },
    },
  );

  const text = res.data?.choices?.[0]?.message?.content || "";
  if (!text) {
    console.error("OpenRouter returned empty text.");
  }

  const parsed = extractJson(text);
  if (!parsed) {
    console.error("OpenRouter raw response:", text);
    throw new Error("OpenRouter did not return valid JSON.");
  }
  return parsed;
}

function buildFallbackQuery({ languages, difficultyPref, activityDays }) {
  const parts = ["type:issue", "state:open"];

  if (Array.isArray(languages) && languages.length > 0) {
    const joined = languages.map((l) => `language:${l}`).join(" OR ");
    parts.push(`(${joined})`);
  }

  if (difficultyPref === "goodFirst") {
    parts.push('label:"good first issue"');
  } else if (difficultyPref === "helpWanted") {
    parts.push('label:"help wanted"');
  }

  const cutoff = new Date(Date.now() - activityDays * 86400000);
  const iso = cutoff.toISOString().substring(0, 10);
  parts.push(`updated:>=${iso}`);

  return parts.join(" ");
}

function parseIssue(item) {
  const labels = (item.labels || []).map((l) => l.name).filter(Boolean);
  const normalized = labels.map((l) => l.toLowerCase());
  const repoId = extractRepoId(item);

  return {
    id: `${repoId}#${item.number}`,
    title: item.title || "",
    body: item.body || "",
    repoId,
    labels,
    htmlUrl: item.html_url || "",
    goodFirstIssue: normalized.includes("good first issue"),
    helpWanted: normalized.includes("help wanted"),
    createdAt: item.created_at,
  };
}

function extractRepoId(item) {
  const repoUrl = item.repository_url || "";
  if (repoUrl) {
    const parts = repoUrl.split("/");
    return `${parts[parts.length - 2]}/${parts[parts.length - 1]}`;
  }
  const htmlUrl = item.html_url || "";
  if (htmlUrl) {
    const parts = htmlUrl.split("/");
    return `${parts[3]}/${parts[4]}`;
  }
  return "unknown/unknown";
}

async function fetchRepo(owner, name) {
  const url = `https://api.github.com/repos/${owner}/${name}`;
  const res = await axios.get(url, { headers: GH_HEADERS });
  const repo = res.data;
  return {
    id: repo.full_name,
    name: repo.name,
    owner: repo.owner?.login || "",
    stars: repo.stargazers_count || 0,
    license: repo.license?.spdx_id || "",
    archived: !!repo.archived,
    lastCommitAt: repo.pushed_at,
    htmlUrl: repo.html_url,
  };
}

async function summarizeIssue(issue) {
  const prompt = `
Return ONLY JSON with keys: tldr (string), firstPrChecklist (array of strings), difficultyScore (1-5).
Summarize this GitHub issue for a beginner:

Title: ${issue.title}
Body: ${issue.body}
  `.trim();

  try {
    const json = await callOpenRouterJson(prompt);
    return {
      tldr: json.tldr || issue.title,
      firstPrChecklist: Array.isArray(json.firstPrChecklist)
        ? json.firstPrChecklist
        : [],
      difficultyScore: Number(json.difficultyScore) || 3,
    };
  } catch {
    return {
      tldr: issue.title,
      firstPrChecklist: [
        "Read the README",
        "Check CONTRIBUTING.md",
        "Comment on the issue",
        "Open a small PR",
      ],
      difficultyScore: 3,
    };
  }
}

app.post("/ai/languages", async (req, res) => {
  const { domains } = req.body || {};
  const prompt = `
Return ONLY JSON: {"languages":[...]}.
Given these domains: ${JSON.stringify(domains || [])}
Return 8-12 relevant programming languages.
  `.trim();

  try {
    const json = await callOpenRouterJson(prompt);
    const languages = Array.isArray(json.languages)
      ? json.languages
      : DEFAULT_LANGUAGES;
    res.json({ languages });
  } catch (err) {
    console.error("AI /languages error:", err?.message || err);
    res.json({ languages: DEFAULT_LANGUAGES });
  }
});

app.post("/ai/tools", async (req, res) => {
  const { domains, languages } = req.body || {};
  const prompt = `
Return ONLY JSON: {"groups":{"Frontend":[...],"Backend":[...],"AI":[...],"DevOps":[...]}}.
Domains: ${JSON.stringify(domains || [])}
Languages: ${JSON.stringify(languages || [])}
Provide 3-6 tools per group.
  `.trim();

  try {
    const json = await callOpenRouterJson(prompt);
    const groups = json.groups || DEFAULT_TECH_GROUPS;
    res.json({ groups });
  } catch (err) {
    console.error("AI /tools error:", err?.message || err);
    res.json({ groups: DEFAULT_TECH_GROUPS });
  }
});

app.post("/ai/summary", async (req, res) => {
  const { issue } = req.body || {};
  if (!issue || !issue.title) {
    return res.status(400).json({ error: "Missing issue data." });
  }
  const summary = await summarizeIssue(issue);
  res.json({ summary });
});

app.post("/ai/search", async (req, res) => {
  const {
    domains = [],
    languages = [],
    technologies = [],
    confidence,
    contributionStyle,
    difficultyPref = "any",
    activityDays = 180,
    perPage = 12,
  } = req.body || {};

  let query = "";
  try {
    const prompt = `
Return ONLY JSON: {"query":"..."}.
Build a GitHub search query for open issues.
Inputs:
Domains: ${JSON.stringify(domains)}
Languages: ${JSON.stringify(languages)}
Technologies: ${JSON.stringify(technologies)}
Confidence: ${confidence || ""}
Contribution preference: ${contributionStyle || ""}
Difficulty: ${difficultyPref}
Activity window days: ${activityDays}

Constraints:
- Always include: type:issue state:open
- Include updated:>=YYYY-MM-DD for activity window
- If difficulty is goodFirst/helpWanted, include label
- Keep query concise
    `.trim();

    const json = await callOpenRouterJson(prompt);
    query = json.query || "";
  } catch {
    query = "";
  }

  if (!query) {
    query = buildFallbackQuery({
      languages,
      difficultyPref,
      activityDays,
    });
  }

  const ghUrl = "https://api.github.com/search/issues";
  const ghRes = await axios.get(ghUrl, {
    headers: GH_HEADERS,
    params: {
      q: query,
      per_page: perPage,
      sort: "updated",
      order: "desc",
    },
  });

  const items = ghRes.data.items || [];
  const issues = items.map(parseIssue);

  const repoIds = [...new Set(issues.map((i) => i.repoId))];
  const repoMap = {};
  await Promise.all(
    repoIds.map(async (id) => {
      const [owner, name] = id.split("/");
      if (!owner || !name) return;
      try {
        repoMap[id] = await fetchRepo(owner, name);
      } catch {
        repoMap[id] = null;
      }
    }),
  );

  const results = [];
  for (const issue of issues) {
    const repo = repoMap[issue.repoId];
    if (!repo) continue;

    const summary = await summarizeIssue(issue);

    results.push({
      issue,
      repo,
      summary,
      score: 0,
    });
  }

  res.json({ query, results });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Backend running on http://0.0.0.0:${PORT}`);
});
