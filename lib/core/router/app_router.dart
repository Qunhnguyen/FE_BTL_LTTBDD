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
import '../../features/student/notifications/screens/notification_screen.dart';
import '../../features/teacher/dashboard/screens/teacher_dashboard_screen.dart';
import '../../features/teacher/dashboard/screens/contest_analytics_screen.dart';
import '../../features/teacher/dashboard/screens/student_submission_detail_screen.dart';
import '../../features/teacher/questions/screens/question_management_screen.dart';
import '../../features/teacher/questions/screens/csv_import_screen.dart';
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

  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String roleSelection = 'roles';

  // Student
  static const String studentHome = 'studentHome';
  static const String studentHistory = 'studentHistory';
  static const String studentQuiz = 'studentQuiz';
  static const String studentResult = 'studentResult';
  static const String studentLeaderboard = 'studentLeaderboard';
  static const String studentProfile = 'studentProfile';
  static const String studentNotifications = 'studentNotifications';

  // Teacher
  static const String teacherDashboard = 'teacherDashboard';
  static const String teacherSubjects = 'teacherSubjects';
  static const String teacherContests = 'teacherContests';
  static const String teacherContestAnalytics = 'teacherContestAnalytics';
  static const String teacherStudentSubmission = 'teacherStudentSubmission';
  static const String teacherQuestions = 'teacherQuestions';
  static const String teacherCsvImport = 'teacherCsvImport';
  static const String teacherSettings = 'teacherSettings';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isAtWelcome = state.matchedLocation == '/';

      if (isAuthenticated && (isLoggingIn || isAtWelcome)) {
        if (authState.user?.role == 'TEACHER') {
          return '/teacher/dashboard';
        }
        return '/student/home';
      }
      return null;
    },

    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: AppRouteNames.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/roles',
        name: AppRouteNames.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      
      // Màn hình Quiz & Result Toàn màn hình
      GoRoute(
        path: '/student/quiz/:contestId',
        name: AppRouteNames.studentQuiz,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final contestId = state.pathParameters['contestId']!;
          return QuizScreen(contestId: contestId);
        },
      ),
      GoRoute(
        path: '/student/result',
        name: AppRouteNames.studentResult,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const QuizResultScreen(),
      ),

      // Màn hình Thông báo Toàn màn hình
      GoRoute(
        path: '/student/notifications',
        name: AppRouteNames.studentNotifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationScreen(),
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
                path: '/student/home',
                name: AppRouteNames.studentHome,
                builder: (context, state) => const StudentHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _studentHistoryKey,
            routes: [
              GoRoute(
                path: '/student/history',
                name: AppRouteNames.studentHistory,
                builder: (context, state) => const QuizHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _studentLeaderboardKey,
            routes: [
              GoRoute(
                path: '/student/leaderboard',
                name: AppRouteNames.studentLeaderboard,
                builder: (context, state) => const LeaderboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _studentProfileKey,
            routes: [
              GoRoute(
                path: '/student/profile',
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
                path: '/teacher/dashboard',
                name: AppRouteNames.teacherDashboard,
                builder: (context, state) => const TeacherDashboardScreen(),
              ),
              GoRoute(
                path: '/teacher/analytics/:contestId',
                name: AppRouteNames.teacherContestAnalytics,
                builder: (context, state) {
                  final contestId = state.pathParameters['contestId']!;
                  return ContestAnalyticsScreen(contestId: contestId);
                },
                routes: [
                  GoRoute(
                    path: 'submissions/:studentId',
                    name: AppRouteNames.teacherStudentSubmission,
                    builder: (context, state) {
                      final contestId = state.pathParameters['contestId']!;
                      final studentId = state.pathParameters['studentId']!;
                      return StudentSubmissionDetailScreen(
                        contestId: contestId,
                        studentId: studentId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _teacherSubjectsKey,
            routes: [
              GoRoute(
                path: '/teacher/subjects',
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
                path: '/teacher/questions',
                name: AppRouteNames.teacherQuestions,
                builder: (context, state) => const QuestionManagementScreen(),
                routes: [
                  GoRoute(
                    path: 'import-csv',
                    name: AppRouteNames.teacherCsvImport,
                    builder: (context, state) => const CsvImportScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _teacherSettingsKey,
            routes: [
              GoRoute(
                path: '/teacher/settings',
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
