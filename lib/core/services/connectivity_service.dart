import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService {
  final InternetConnectionChecker _checker =
      InternetConnectionChecker.createInstance();

  Stream<bool> get connectivityStream => _checker.onStatusChange.map(
        (status) => status == InternetConnectionStatus.connected,
      );

  Future<bool> checkConnection() async {
    return await _checker.hasConnection;
  }
}
