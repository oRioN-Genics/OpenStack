class Pagination {
  final int page;
  final int perPage;
  const Pagination({this.page = 1, this.perPage = 20});

  Pagination next() => Pagination(page: page + 1, perPage: perPage);
}
