import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'secret_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool deviceSupported = false;

  @override
  void initState() {
    super.initState();
  }

  AndroidAuthMessages _androidAuthMessages() {
    return const AndroidAuthMessages(signInTitle: "Autenticação necessária", biometricHint: "Verifique sua indentidade", cancelButton: "Cancelar");
  }

  Future<List<BiometricType>> _initBiometrics() async {
    deviceSupported = await _localAuth.isDeviceSupported();
    List<BiometricType> _availableBiometrics = <BiometricType>[];
    if (deviceSupported) {
      try {
        if (await _localAuth.canCheckBiometrics) {
          _availableBiometrics = await _localAuth.getAvailableBiometrics();
        }
        return _availableBiometrics;
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  Future<void> _auth() async {
    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticate(
        androidAuthStrings: _androidAuthMessages(),
        localizedReason: 'Desbloqueie para acessar a tela secreta!',
        useErrorDialogs: true,
        stickyAuth: true,
      );
      if (authenticated) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SecretScreen()));
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _authOnlyBiometrics() async {
    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticate(
        androidAuthStrings: _androidAuthMessages(),
        localizedReason: 'Desbloqueie para acessar a tela secreta!',
        useErrorDialogs: true,
        stickyAuth: true,
        biometricOnly: true,
      );
      if (authenticated) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SecretScreen()));
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff820ad1),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: FutureBuilder<List<BiometricType>>(
          future: _initBiometrics(),
          builder: (BuildContext context, AsyncSnapshot<List<BiometricType>> snapshot) {
            if (snapshot.hasData) {
              if (!deviceSupported) {
                return const Center(child: Text("Dispositivo não suportado", style: TextStyle(fontSize: 18.0, color: Colors.white)));
              }
              return Center(
                child: Column(
                  children: [
                    const Expanded(child: SizedBox()),
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.asset('assets/nu-icon.png'),
                    ),
                    const Expanded(child: SizedBox()),
                    MaterialButton(
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                      minWidth: double.maxFinite,
                      height: 50.0,
                      onPressed: () async{
                        await _auth();
                      },
                      onLongPress: () async{
                        await _authOnlyBiometrics();
                      },
                      color: Colors.white,
                      child: const Text("Entrar", style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              );
            } else {
              return const Center(
                child: SizedBox(
                  width: 60.0,
                  height: 60.0,
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
