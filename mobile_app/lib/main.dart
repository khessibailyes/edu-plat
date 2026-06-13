import 'package:flutter/material.dart';
import 'package:mobile_app/screens/admin_home.dart';
import 'package:mobile_app/screens/login_screen.dart';
import 'package:mobile_app/screens/register_screen.dart';
import 'package:mobile_app/screens/student_home.dart';
import 'package:mobile_app/screens/teacher_home.dart';
import 'package:mobile_app/services/auth_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduPlatform Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routes: {
        '/login':          (context) => const LoginScreen(),
        '/register':       (context) => const RegisterScreen(),
        '/home/student':   (context) => const StudentHome(),
        '/home/teacher':   (context) => const TeacherHome(),
        '/home/admin':     (context) => const AdminHome(),
      },
      home: const SplashScreen(),
    );
  }
}

Widget homeForRole(String? role) {
  switch (role) {
    case 'admin':   return const AdminHome();
    case 'teacher': return const TeacherHome();
    default:        return const StudentHome();
  }
}

void navigateToHome(BuildContext context, String? role) {
  switch (role) {
    case 'admin':
      Navigator.pushReplacementNamed(context, '/home/admin');
      break;
    case 'teacher':
      Navigator.pushReplacementNamed(context, '/home/teacher');
      break;
    default:
      Navigator.pushReplacementNamed(context, '/home/student');
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthStorage.getToken(),
      builder: (context, tokenSnap) {
        if (tokenSnap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (tokenSnap.data == null || tokenSnap.data!.isEmpty) {
          return const LoginScreen();
        }
        return FutureBuilder<String?>(
          future: AuthStorage.getUserRole(),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState != ConnectionState.done) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            return homeForRole(roleSnap.data);
          },
        );
      },
    );
  }
}
