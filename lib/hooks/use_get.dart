import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iris/models/get_result.dart';

GetResult<T> useGet<T>(String argument, Future<T> Function(String) function) {
  final isLoading = useState(true);
  final data = useState<T?>(null);
  final error = useState(false);

  useEffect(() {
    isLoading.value = true;
    error.value = false;

    function(argument).then((result) {
      data.value = result;
      isLoading.value = false;
    }).catchError((e) {
      error.value = true;
      isLoading.value = false;
    });

    return () {};
  }, [argument]);

  return GetResult(
    data: data.value,
    isLoading: isLoading.value,
    error: error.value,
  );
}
