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
import '../../features/student/quiz/screens/quiz_catalog_screen.dart';
import '../../features/student/notifications/screens/notification_screen.dart';
import '../../features/student/classroom/screens/student_classroom_list_screen.dart';
import '../../features/student/classroom/screens/student_classroom_detail_screen.dart';
import '../../features/teacher/dashboard/screens/teacher_dashboard_screen.dart';
import '../../features/teacher/dashboard/screens/contest_analytics_screen.dart';
import '../../features/teacher/dashboard/screens/student_submission_detail_screen.dart';
import '../../features/teacher/questions/screens/question_management_screen.dart';
import '../../features/teacher/questions/screens/csv_import_screen.dart';
import '../../features/teacher/settings/screens/teacher_settings_screen.dart';
import '../../features/teacher/subjects/models/subject.dart';
import '../../features/teacher/subjects/screens/subject_management_screen.dart';
import '../../features/teacher/subjects/screens/teacher_contest_list_screen.dart';
import '../../features/teacher/subjects/screens/quiz_management_screen.dart';
import '../../features/teacher/subjects/screens/create_quiz_form.dart';
import '../../features/teacher/subjects/screens/teacher_classroom_detail_screen.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../features/teacher/ai/screens/knowledge_management_screen.dart';
import '../../features/teacher/ai/screens/ai_builder_screen.dart';
import '../../features/teacher/ai/screens/ai_job_detail_screen.dart';

import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_subject_screen.dart';
import '../../features/admin/screens/admin_teacher_screen.dart';
import '../../features/admin/screens/admin_student_screen.dart';
import '../../features/admin/screens/admin_contest_list_screen.dart';
import '../../features/admin/screens/admin_question_list_screen.dart';
import '../../features/admin/screens/admin_settings_screen.dart';
import '../../features/admin/screens/admin_knowledge_screen.dart';
import '../../features/admin/screens/admin_ai_builder_screen.dart';
import '../../features/admin/screens/admin_ai_job_detail_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _studentHomeKey = GlobalKey<NavigatorState>();
final _studentHistoryKey = GlobalKey<NavigatorState>();
final _studentClassroomKey = GlobalKey<NavigatorState>();
final _studentProfileKey = GlobalKey<NavigatorState>();
final _teacherDashboardKey = GlobalKey<NavigatorState>();
final _teacherSubjectsKey = GlobalKey<NavigatorState>();
final _teacherQuestionsKey = GlobalKey<NavigatorState>();
final _teacherSettingsKey = GlobalKey<NavigatorState>();

final _adminDashboardKey = GlobalKey<NavigatorState>();
final _adminSubjectsKey = GlobalKey<NavigatorState>();
final _adminTeachersKey = GlobalKey<NavigatorState>();
final _adminStudentsKey = GlobalKey<NavigatorState>();
final _adminSettingsKey = GlobalKey<NavigatorState>();

class AppRouteNames {
  AppRouteNames._();

  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String roleSelection = 'roles';

  // Student
  static const String studentHome = 'studentHome';
  static const String studentHistory = 'studentHistory';
  static const String studentClassrooms = 'studentClassrooms';
  static const String studentClassroomDetail = 'studentClassroomDetail';
  static const String studentQuizCatalog = 'studentQuizCatalog';
  static const String studentQuiz = 'studentQuiz';
  static const String studentResult = 'studentResult';
  static const String studentLeaderboard = 'studentLeaderboard';
  static const String studentProfile = 'studentProfile';
  static const String studentNotifications = 'studentNotifications';

  // Teacher
  static const String teacherDashboard = 'teacherDashboard';
  static const String teacherSubjects = 'teacherSubjects';
  static const String teacherQuizzes = 'teacherQuizzes';
  static const String teacherCreateQuiz = 'teacherCreateQuiz';
  static const String teacherContestAnalytics = 'teacherContestAnalytics';
  static const String teacherStudentSubmission = 'teacherStudentSubmission';
  static const String teacherQuestions = 'teacherQuestions';
  static const String teacherCsvImport = 'teacherCsvImport';
  static const String teacherKnowledge = 'teacherKnowledge';
  static const String teacherAiBuilder = 'teacherAiBuilder';
  static const String teacherAiJobDetail = 'teacherAiJobDetail';
  static const String teacherContests = 'teacherContests';
  static const String teacherClassroomDetail = 'teacherClassroomDetail';
  static const String teacherSettings = 'teacherSettings';
  
  // Admin
  static const String adminDashboard = 'adminDashboard';
  static const String adminSubjects = 'adminSubjects';
  static const String adminContests = 'adminContests';
  static const String adminQuizzes = 'adminQuizzes';
  static const String adminCreateQuiz = 'adminCreateQuiz';
  static const String adminQuestions = 'adminQuestions';
  static const String adminCsvImport = 'adminCsvImport';
  static const String adminKnowledge = 'adminKnowledge';
  static const String adminAiBuilder = 'adminAiBuilder';
  static const String adminAiJobDetail = 'adminAiJobDetail';
  static const String adminTeachers = 'adminTeachers';
  static const String adminStudents = 'adminStudents';
  static const String adminSettings = 'adminSettings';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      if (isAuthenticated && (state.matchedLocation == '/login' || state.matchedLocation == '/')) {
        if (authState.user?.role == 'TEACHER') return '/teacher/dashboard';
        if (authState.user?.role == 'ADMIN') return '/admin/dashboard';
        return '/student/home';
      }
      return null;
    },

    routes: <RouteBase>[
      GoRoute(path: '/', name: AppRouteNames.welcome, builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/login', name: AppRouteNames.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/roles', name: AppRouteNames.roleSelection, builder: (context, state) => const RoleSelectionScreen()),
      
      // Màn hình Quiz Toàn màn hình
      GoRoute(
        path: '/student/quiz/:contestId',
        name: AppRouteNames.studentQuiz,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => QuizScreen(contestId: state.pathParameters['contestId']!),
      ),
      GoRoute(path: '/student/result', name: AppRouteNames.studentResult, parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const QuizResultScreen()),

      // Thống kê dùng chung
      GoRoute(
        path: '/teacher/analytics/:contestId',
        name: AppRouteNames.teacherContestAnalytics,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ContestAnalyticsScreen(contestId: state.pathParameters['contestId']!),
      ),
      GoRoute(
        path: '/teacher/analytics/:contestId/submissions/:studentId',
        name: AppRouteNames.teacherStudentSubmission,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => StudentSubmissionDetailScreen(
          contestId: state.pathParameters['contestId']!,
          studentId: state.pathParameters['studentId']!,
        ),
      ),

      // Admin Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell, role: 'ADMIN'),
        branches: [
          StatefulShellBranch(
            navigatorKey: _adminDashboardKey,
            routes: [GoRoute(path: '/admin/dashboard', name: AppRouteNames.adminDashboard, builder: (context, state) => const AdminDashboardScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _adminSubjectsKey,
            routes: [
              GoRoute(
                path: '/admin/subjects',
                name: AppRouteNames.adminSubjects,
                builder: (context, state) => const AdminSubjectScreen(),
                routes: [
                  GoRoute(
                    path: ':subjectId/quizzes', 
                    name: AppRouteNames.adminQuizzes,
                    builder: (context, state) {
                      final subjectId = state.pathParameters['subjectId']!;
                      final name = state.uri.queryParameters['name'] ?? 'Môn học';
                      return QuizManagementScreen(subject: Subject(id: subjectId, name: name));
                    },
                    routes: [
                      GoRoute(
                        path: 'create',
                        name: AppRouteNames.adminCreateQuiz,
                        builder: (context, state) => CreateQuizForm(subjectId: state.pathParameters['subjectId']!),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: ':subjectId/contests',
                    name: AppRouteNames.adminContests,
                    builder: (context, state) {
                      final subjectId = state.pathParameters['subjectId']!;
                      final name = state.uri.queryParameters['name'] ?? 'Môn học';
                      return TeacherContestListScreen(subject: Subject(id: subjectId, name: name));
                    },
                    routes: [
                      GoRoute(
                        path: 'questions',
                        name: AppRouteNames.adminQuestions,
                        builder: (context, state) => QuestionManagementScreen(
                          subjectId: state.pathParameters['subjectId'],
                          csvImportRouteName: AppRouteNames.adminCsvImport,
                          subjectsRouteName: AppRouteNames.adminSubjects,
                        ),
                        routes: [
                          GoRoute(path: 'import-csv', name: AppRouteNames.adminCsvImport, builder: (context, state) => const CsvImportScreen()),
                        ],
                      ),
                      GoRoute(path: 'knowledge', name: AppRouteNames.adminKnowledge, builder: (context, state) => KnowledgeManagementScreen(subjectId: state.pathParameters['subjectId']!)),
                      GoRoute(path: 'ai-builder', name: AppRouteNames.adminAiBuilder, builder: (context, state) => AiBuilderScreen(subjectId: state.pathParameters['subjectId']!)),
                      GoRoute(path: 'ai-jobs/:jobId', name: AppRouteNames.adminAiJobDetail, builder: (context, state) => AiJobDetailScreen(subjectId: state.pathParameters['subjectId']!, jobId: state.pathParameters['jobId']!)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(navigatorKey: _adminTeachersKey, routes: [GoRoute(path: '/admin/teachers', name: AppRouteNames.adminTeachers, builder: (context, state) => const AdminTeacherScreen())]),
          StatefulShellBranch(navigatorKey: _adminStudentsKey, routes: [GoRoute(path: '/admin/students', name: AppRouteNames.adminStudents, builder: (context, state) => const AdminStudentScreen())]),
          StatefulShellBranch(navigatorKey: _adminSettingsKey, routes: [GoRoute(path: '/admin/settings', name: AppRouteNames.adminSettings, builder: (context, state) => const AdminSettingsScreen())]),
        ],
      ),

      // Teacher Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell, role: 'TEACHER'),
        branches: [
          StatefulShellBranch(
            navigatorKey: _teacherDashboardKey,
            routes: [GoRoute(path: '/teacher/dashboard', name: AppRouteNames.teacherDashboard, builder: (context, state) => const TeacherDashboardScreen())],
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
                    path: ':subjectId/quizzes',
                    name: AppRouteNames.teacherQuizzes,
                    builder: (context, state) {
                      final subjectId = state.pathParameters['subjectId']!;
                      final name = state.uri.queryParameters['name'] ?? 'Môn học';
                      return QuizManagementScreen(subject: Subject(id: subjectId, name: name));
                    },
                    routes: [
                      GoRoute(
                        path: 'create',
                        name: AppRouteNames.teacherCreateQuiz,
                        builder: (context, state) => CreateQuizForm(subjectId: state.pathParameters['subjectId']!),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: ':subjectId/contests',
                    name: AppRouteNames.teacherContests,
                    builder: (context, state) {
                      final subjectId = state.pathParameters['subjectId']!;
                      final name = state.uri.queryParameters['name'] ?? 'Môn học';
                      return TeacherContestListScreen(subject: Subject(id: subjectId, name: name));
                    },
                    routes: [
                      GoRoute(
                        path: 'questions',
                        name: AppRouteNames.teacherQuestions,
                        builder: (context, state) => QuestionManagementScreen(
                          subjectId: state.pathParameters['subjectId'],
                          csvImportRouteName: AppRouteNames.teacherCsvImport,
                          subjectsRouteName: AppRouteNames.teacherSubjects,
                        ),
                        routes: [
                          GoRoute(path: 'import-csv', name: AppRouteNames.teacherCsvImport, builder: (context, state) => const CsvImportScreen()),
                        ],
                      ),
                      GoRoute(path: 'knowledge', name: AppRouteNames.teacherKnowledge, builder: (context, state) => KnowledgeManagementScreen(subjectId: state.pathParameters['subjectId']!)),
                      GoRoute(path: 'ai-builder', name: AppRouteNames.teacherAiBuilder, builder: (context, state) => AiBuilderScreen(subjectId: state.pathParameters['subjectId']!)),
                      GoRoute(path: 'ai-jobs/:jobId', name: AppRouteNames.teacherAiJobDetail, builder: (context, state) => AiJobDetailScreen(subjectId: state.pathParameters['subjectId']!, jobId: state.pathParameters['jobId']!)),
                      GoRoute(
                        path: 'classrooms/:classroomId',
                        name: AppRouteNames.teacherClassroomDetail,
                        builder: (context, state) => TeacherClassroomDetailScreen(
                          subjectId: state.pathParameters['subjectId']!,
                          classroomId: state.pathParameters['classroomId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _teacherQuestionsKey,
            routes: [GoRoute(path: '/teacher/questions-standalone', name: 'teacherQuestionsStandalone', builder: (context, state) => const QuestionManagementScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _teacherSettingsKey,
            routes: [GoRoute(path: '/teacher/settings', name: AppRouteNames.teacherSettings, builder: (context, state) => const TeacherSettingsScreen())],
          ),
        ],
      ),

      // Student Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell, role: 'STUDENT'),
        branches: [
          StatefulShellBranch(
            navigatorKey: _studentHomeKey,
            routes: [
              GoRoute(
                path: '/student/home',
                name: AppRouteNames.studentHome,
                builder: (context, state) => const StudentHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    name: AppRouteNames.studentNotifications,
                    builder: (context, state) => const NotificationScreen(),
                  ),
                  GoRoute(
                    path: 'leaderboard',
                    name: AppRouteNames.studentLeaderboard,
                    builder: (context, state) => const LeaderboardScreen(),
                  ),
                  GoRoute(
                    path: 'subject/:subjectId/quizzes',
                    name: AppRouteNames.studentQuizCatalog,
                    builder: (context, state) => QuizCatalogScreen(
                      subjectId: state.pathParameters['subjectId']!,
                      subjectName: state.uri.queryParameters['name'] ?? 'Môn học',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(navigatorKey: _studentHistoryKey, routes: [GoRoute(path: '/student/history', name: AppRouteNames.studentHistory, builder: (context, state) => const QuizHistoryScreen())]),
          StatefulShellBranch(
            navigatorKey: _studentClassroomKey, 
            routes: [
              GoRoute(
                path: '/student/classrooms', 
                name: AppRouteNames.studentClassrooms, 
                builder: (context, state) => const StudentClassroomListScreen(),
                routes: [
                  GoRoute(
                    path: ':classroomId',
                    name: AppRouteNames.studentClassroomDetail,
                    builder: (context, state) => StudentClassroomDetailScreen(
                      classroomId: state.pathParameters['classroomId']!,
                    ),
                  ),
                ],
              )
            ]
          ),
          StatefulShellBranch(navigatorKey: _studentProfileKey, routes: [GoRoute(path: '/student/profile', name: AppRouteNames.studentProfile, builder: (context, state) => const StudentProfileScreen())]),
        ],
      ),
    ],
  );
});
