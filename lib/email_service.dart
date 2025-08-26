import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Sends OTP to the given email using Gmail SMTP
Future<void> sendOtpEmail({
  required String email,
  required String otp,
}) async {
  // 1️⃣ Gmail account credentials
  const String username = 'nsivapriya892@gmail.com';
  const String password = 'dqjtlkklkpkztrdh'; // Use App Password, NOT Gmail password

  // 2️⃣ Create SMTP server configuration
  final smtpServer = gmail(username, password);

  // 3️⃣ Create the email message
  final message = Message()
    ..from = Address(username, 'Your App Name')
    ..recipients.add(email)
    ..subject = 'Your OTP Code'
    ..text = 'Hello!\n\nYour OTP code is: $otp\nIt expires in 5 minutes.\n\nThanks!';

  try {
    final sendReport = await send(message, smtpServer);
    print('OTP sent: ${sendReport.toString()}');
  } on MailerException catch (e) {
    print('❌ Email sending failed: $e');
    throw 'Could not send OTP email';
  }
}
