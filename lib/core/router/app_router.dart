import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/_shell/main_shell.dart';
import '../../features/_shell/role_selection_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/student/history/screens/quiz_history_screen.dart';
import '../../features/student/home/screens/student_home_screen.dart';
import '../../features/student/leaderboard/screens/leaderboard_screen.dart';
import '../../features/student/profile/screens/student_profile_screen.dart';
import '../../features/student/quiz/screens/quiz_result_screen.dart';
import '../../features/student/quiz/screens/quiz_screen.dart';
import '../../features/teacher/dashboard/screens/teacher_dashboard_screen.dart';
import '../../features/teacher/questions/screens/question_management_screen.dart';
import '../../features/teacher/settings/screens/teacher_settings_screen.dart';
import '../../features/teacher/subjects/models/subject.dart';
import '../../features/teacher/subjects/screens/subject_management_screen.dart';
import '../../features/teacher/subjects/screens/teacher_contest_list_screen.dart';
import '../../features/welcome/welcome_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _studentHomeKey = GlobalKey<NavigatorState>();
final _studentHistoryKey = GlobalKey<NavigatorState>();
final _studentLeaderboardKey = GlobalKey<NavigatorState>();
final _studentProfileKey = GlobalKey<NavigatorState>();
final _teacherDashboardKey = GlobalKey<NavigatorState>();
final _teacherSubjectsKey = GlobalKey<NavigatorState>();
final _teacherQuestionsKey = GlobalKey<NavigatorState>();
final _teacherSettingsKey = GlobalKey<NavigatorState>();

class AppRouteNames {
  AppRouteNames._();

  static const String welcome = '/';
  static const String login = '/login';
  static const String roleSelection = '/roles';

  // Student
  static const String studentHome = '/student/home';
  static const String studentHistory = '/student/history';
  static const String studentQuiz = 'quiz/:contestId';
  static const String studentResult = 'result';
  static const String studentLeaderboard = '/student/leaderboard';
  static const String studentProfile = '/student/profile';

  // Teacher
  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherSubjects = '/teacher/subjects';
  static const String teacherContests = 'contests';
  static const String teacherQuestions = '/teacher/questions';
  static const String teacherSettings = '/teacher/settings';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRouteNames.welcome,
    
    // Logic Redirect tự động
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.matchedLocation == AppRouteNames.login;
      final isAtWelcome = state.matchedLocation == AppRouteNames.welcome;

      if (isAuthenticated && (isLoggingIn || isAtWelcome)) {
        // Tự động điều hướng theo Role nếu đã đăng nhập thành công
        if (authState.user?.role == 'TEACHER') {
          return AppRouteNames.teacherDashboard;
        }
        return AppRouteNames.studentHome;
      }
      return null;
    },

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
                    path: 'quiz/:contestId',
                    name: AppRouteNames.studentQuiz,
                    builder: (context, state) {
                      final contestId = state.pathParameters['contestId']!;
                      return QuizScreen(contestId: contestId);
                    },
                    routes: [
                      GoRoute(
                        path: AppRouteNames.studentResult,
                        name: AppRouteNames.studentResult,
                        builder: (context, state) => const QuizResultScreen(),
                      ),
                    ],
                  ),
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
            navigatorKey: _teacherSubjectsKey,
            routes: [
              GoRoute(
                path: AppRouteNames.teacherSubjects,
                name: AppRouteNames.teacherSubjects,
                builder: (context, state) => const SubjectManagementScreen(),
                routes: [
                  GoRoute(
                    path: ':subjectId/contests',
                    name: AppRouteNames.teacherContests,
                    builder: (context, state) {
                      final subjectId = state.pathParameters['subjectId']!;
                      final subjectName = state.uri.queryParameters['name'] ?? 'Môn học';
                      return TeacherContestListScreen(
                        subject: Subject(id: subjectId, name: subjectName),
                      );
                    },
                  ),
                ],
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
            navigatorKey: _teacherSettingsKey,
            routes: [
              GoRoute(
                path: AppRouteNames.teacherSettings,
                name: AppRouteNames.teacherSettings,
                builder: (context, state) => const TeacherSettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
