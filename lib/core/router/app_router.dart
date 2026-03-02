import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/_shell/main_shell.dart';
import '../../features/_shell/role_selection_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/student/history/screens/quiz_history_screen.dart';
import '../../features/student/home/screens/student_home_screen.dart';
import '../../features/student/leaderboard/screens/leaderboard_screen.dart';
import '../../features/student/profile/screens/student_profile_screen.dart';
import '../../features/student/quiz/screens/quiz_result_screen.dart';
import '../../features/student/quiz/screens/quiz_screen.dart';
import '../../features/teacher/dashboard/screens/teacher_dashboard_screen.dart';
import '../../features/teacher/questions/screens/question_management_screen.dart';
import '../../features/welcome/welcome_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _studentHomeKey = GlobalKey<NavigatorState>();
final _studentHistoryKey = GlobalKey<NavigatorState>();
final _studentLeaderboardKey = GlobalKey<NavigatorState>();
final _studentProfileKey = GlobalKey<NavigatorState>();
final _teacherDashboardKey = GlobalKey<NavigatorState>();
final _teacherQuestionsKey = GlobalKey<NavigatorState>();

class AppRouteNames {
  AppRouteNames._();

  static const String welcome = '/';
  static const String login = '/login';
  static const String roleSelection = '/roles';

  // Student
  static const String studentHome = '/student/home';
  static const String studentHistory = '/student/history';
  static const String studentQuiz = 'quiz'; // Relative path
  static const String studentResult = 'result'; // Relative path
  static const String studentLeaderboard = '/student/leaderboard';
  static const String studentProfile = '/student/profile';

  // Teacher
  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherQuestions = '/teacher/questions';
}

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRouteNames.welcome,
    routes: <RouteBase>[
      GoRoute(
        path: AppRouteNames.welcome,
        name: AppRouteNames.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRouteNames.login,
        name: AppRouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRouteNames.roleSelection,
        name: AppRouteNames.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // Student Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell, isStudent: true);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _studentHomeKey,
            routes: [
              GoRoute(
                path: AppRouteNames.studentHome,
                name: AppRouteNames.studentHome,
                builder: (context, state) => const StudentHomeScreen(),
                routes: [
                  GoRoute(
                      path: AppRouteNames.studentQuiz,
                      name: AppRouteNames.studentQuiz,
                      builder: (context, state) => const QuizScreen(),
                      routes: [
                        GoRoute(
                          path: AppRouteNames.studentResult,
                          name: AppRouteNames.studentResult,
                          builder: (context, state) => const QuizResultScreen(),
                        ),
                      ]),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _studentHistoryKey,
            routes: [
              GoRoute(
                path: AppRouteNames.studentHistory,
                name: AppRouteNames.studentHistory,
                builder: (context, state) => const QuizHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _studentLeaderboardKey,
            routes: [
              GoRoute(
                path: AppRouteNames.studentLeaderboard,
                name: AppRouteNames.studentLeaderboard,
                builder: (context, state) => const LeaderboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _studentProfileKey,
            routes: [
              GoRoute(
                path: AppRouteNames.studentProfile,
                name: AppRouteNames.studentProfile,
                builder: (context, state) => const StudentProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Teacher Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell, isStudent: false);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _teacherDashboardKey,
            routes: [
              GoRoute(
                path: AppRouteNames.teacherDashboard,
                name: AppRouteNames.teacherDashboard,
                builder: (context, state) => const TeacherDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/teacher/subjects',
                builder: (context, state) =>
                    const Scaffold(body: Center(child: Text('Môn học'))),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _teacherQuestionsKey,
            routes: [
              GoRoute(
                path: AppRouteNames.teacherQuestions,
                name: AppRouteNames.teacherQuestions,
                builder: (context, state) => const QuestionManagementScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/teacher/settings',
                builder: (context, state) =>
                    const Scaffold(body: Center(child: Text('Cài đặt'))),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
