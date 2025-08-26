import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Hashes the given password using SHA-256
String hashPassword(String password) {
  return sha256.convert(utf8.encode(password)).toString();
}

/// Generates a 6-digit OTP as a string
String generateOtp({int length = 6}) {
  final random = Random();
  String otp = '';

  for (int i = 0; i < length; i++) {
    otp += random.nextInt(10).toString(); // each digit 0–9
  }

  return otp;
}

/// Generates a random secure password
String generateRandomPassword({int length = 12}) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
  final random = Random.secure();
  return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
}

