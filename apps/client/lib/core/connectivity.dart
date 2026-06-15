import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity.g.dart';

@Riverpod(keepAlive: true)
Stream<bool> connectivity(ConnectivityRef ref) {
  return Connectivity().onConnectivityChanged.map((connectivityResult) {
    return connectivityResult != ConnectivityResult.none;
  });
}
