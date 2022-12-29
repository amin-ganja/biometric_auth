library biometric_auth;

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:local_auth_windows/local_auth_windows.dart';

final LocalAuthentication auth = LocalAuthentication();

class BiometricsAuth {
  //check biometrics
  static Future<bool> checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
      return canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      throw Exception(e.message);
    }
  }

  //get biometrics
  static Future<List<BiometricType>> getBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
      return availableBiometrics;
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      throw Exception(e.message);
    }
  }

  //biometrics_auth
  static Future<bool> authenticate(
      {required String localizedReason,
      Iterable<AuthMessages> authMessages = const <AuthMessages>[
        IOSAuthMessages(),
        AndroidAuthMessages(),
        WindowsAuthMessages()
      ],
      bool useErrorDialogs = true,
      bool stickyAuth = false,
      bool sensitiveTransaction = true,
      bool biometricOnly = false}) async {
    final isAvailable = await checkBiometrics();
    bool authenticated = false;
    if (!isAvailable) {
      return false;
    } else {
      try {
        authenticated = await LocalAuthPlatform.instance.authenticate(
          localizedReason: localizedReason,
          authMessages: authMessages,
          options: AuthenticationOptions(
            stickyAuth: stickyAuth,
            sensitiveTransaction: sensitiveTransaction,
            biometricOnly: biometricOnly,
            useErrorDialogs: useErrorDialogs,
          ),
        );
        return authenticated;
      } on PlatformException catch (e) {
        throw Exception(e.message);
      }
    }
  }
}
