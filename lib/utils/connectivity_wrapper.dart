import 'package:flutter/material.dart';
import 'package:mentro/core/services/connectivity_service.dart';
import 'package:mentro/utils/offline_screen.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  final ConnectivityService connectivityService = ConnectivityService();

  ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: connectivityService.connectivityStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && !snapshot.data!) {
          return const OfflineScreen();
        }
        return child;
      },
    );
  }
}
