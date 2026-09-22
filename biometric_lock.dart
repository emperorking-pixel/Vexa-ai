// biometric_lock.dart
//
// Uses local_auth, which calls Android's actual BiometricPrompt system API
// (fingerprint/face) -- real OS-level security, not the pitch/volume voice
// matching from the original spec, which was not real security.

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricLock extends StatefulWidget {
  final Widget child; // the app, shown only after a successful unlock
  const BiometricLock({super.key, required this.child});

  @override
  State<BiometricLock> createState() => _BiometricLockState();
}

class _BiometricLockState extends State<BiometricLock> with WidgetsBindingObserver {
  final _auth = LocalAuthentication();
  bool _unlocked = false;
  bool _checking = true;
  String? _error;
  bool _biometricsUnavailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _attemptUnlock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-lock whenever the app comes back from the background.
    if (state == AppLifecycleState.resumed && !_checking) {
      setState(() => _unlocked = false);
      _attemptUnlock();
    }
  }

  Future<void> _attemptUnlock() async {
    setState(() { _checking = true; _error = null; });

    final canCheck = await _auth.canCheckBiometrics;
    final isSupported = await _auth.isDeviceSupported();

    if (!canCheck || !isSupported) {
      setState(() {
        _checking = false;
        _biometricsUnavailable = true;
        _error = 'No fingerprint/face unlock is set up on this phone. '
            'Add one in Android Settings > Security to lock this app.';
      });
      return;
    }

    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Unlock Aster',
        options: const AuthenticationOptions(
          biometricOnly: false, // allow device PIN/pattern as fallback too
          stickyAuth: true,
        ),
      );
      setState(() { _unlocked = ok; _checking = false; });
    } catch (e) {
      setState(() {
        _checking = false;
        _error = 'Could not verify: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return widget.child;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fingerprint, size: 64, color: Color(0xFF7C5CFF)),
              const SizedBox(height: 16),
              const Text('Aster is locked', style: TextStyle(color: Colors.white, fontSize: 18)),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF8B93A3), fontSize: 13)),
              ],
              const SizedBox(height: 20),
              if (!_checking)
                ElevatedButton(
                  onPressed: _biometricsUnavailable ? null : _attemptUnlock,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C5CFF)),
                  child: const Text('Try again', style: TextStyle(color: Colors.white)),
                )
              else
                const CircularProgressIndicator(color: Color(0xFF7C5CFF)),
            ],
          ),
        ),
      ),
    );
  }
}
