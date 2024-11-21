class GetResult<T> {
  final T? data;
  final bool isLoading;
  final bool error;

  GetResult({this.data, required this.isLoading, required this.error});
}
