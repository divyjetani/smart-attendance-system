import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/profile_screen.dart';
import '../presentation/screens/attendance_screen.dart';
import '../presentation/screens/student_subjects_screen.dart';
import '../presentation/screens/subject_detail_screen.dart';
import '../presentation/screens/mark_attendance_screen.dart';
import '../presentation/screens/professor_subjects_screen.dart';
import '../presentation/screens/professor_students_screen.dart';
import '../presentation/screens/student_attendance_detail_screen.dart';
import '../presentation/screens/qr_generator_screen.dart';
import '../presentation/screens/upload_attendance_screen.dart';
import '../presentation/screens/change_device_screen.dart';
import '../presentation/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final isLoggedIn = authState.maybeWhen(
    authenticated: (_, __) => true,
    orElse: () => false,
  );

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splash';
      final isLogin = state.matchedLocation == '/login';
      if (!isLoggedIn && !isSplash && !isLogin) {
        return '/login';
      }
      if (isLoggedIn && isLogin) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/attendance',
        name: 'attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/student-subjects',
        name: 'student-subjects',
        builder: (context, state) => const StudentSubjectsScreen(),
      ),
      GoRoute(
        path: '/subject-detail/:subjectId',
        name: 'subject-detail',
        builder: (context, state) => SubjectDetailScreen(
          subjectId: state.pathParameters['subjectId']!,
        ),
      ),
      GoRoute(
        path: '/mark-attendance',
        name: 'mark-attendance',
        builder: (context, state) => const MarkAttendanceScreen(),
      ),
      GoRoute(
        path: '/professor-subjects',
        name: 'professor-subjects',
        builder: (context, state) => const ProfessorSubjectsScreen(),
      ),
      GoRoute(
        path: '/professor-students/:subjectId',
        name: 'professor-students',
        builder: (context, state) => ProfessorStudentsScreen(
          subjectId: state.pathParameters['subjectId']!,
        ),
      ),
      GoRoute(
        path: '/student-attendance-detail/:studentId/:subjectId',
        name: 'student-attendance-detail',
        builder: (context, state) => StudentAttendanceDetailScreen(
          studentId: state.pathParameters['studentId']!,
          subjectId: state.pathParameters['subjectId']!,
        ),
      ),
      GoRoute(
        path: '/qr-generator/:subjectId',
        name: 'qr-generator',
        builder: (context, state) => QrGeneratorScreen(
          subjectId: state.pathParameters['subjectId']!,
        ),
      ),
      GoRoute(
        path: '/upload-attendance',
        name: 'upload-attendance',
        builder: (context, state) => const UploadAttendanceScreen(),
      ),
      GoRoute(
        path: '/change-device',
        name: 'change-device',
        builder: (context, state) => const ChangeDeviceScreen(),
      ),
    ],
  );
});