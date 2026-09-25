import 'package:http/http.dart' as http;

/// An [http.Client] that attaches a bearer token to every request.
///
/// Wraps a Google Sign-In access token so any repository can call Drive (or
/// another Google API) without knowing about sign-in itself.
class AuthorizedHttpClient extends http.BaseClient {
  AuthorizedHttpClient(this._accessToken);

  final String _accessToken;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
