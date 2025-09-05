import 'package:cloud_functions/cloud_functions.dart';

Future<String> createFirebaseCustomToken({
  required String loginType,
  required String accessToken,
}) async {
  final instance = FirebaseFunctions.instanceFor(region: 'asia-northeast1');

  final result =
      await instance.httpsCallable(loginType).call<dynamic>(accessToken);

  return getFirebaseTokenIfResultDataIsMap(result);
}

String getFirebaseTokenIfResultDataIsMap(HttpsCallableResult<dynamic> result) {
  var token = '';

  if (result.data is Map) {
    token = result.data['firebase_token'].toString();
  }
  return token;
}
