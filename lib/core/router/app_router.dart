import 'package:go_router/go_router.dart';
import '../../features/lecture/home_screen.dart';
import '../../features/lecture/editor_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/collaboration/join_room_screen.dart';
import '../../features/payment/subscription_screen.dart';
import '../../features/payment/payment_screen.dart';
import '../../features/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/editor',
      builder: (context, state) => const EditorScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/room/:inviteCode',
      builder: (context, state) {
        final inviteCode = state.pathParameters['inviteCode'] ?? '';
        return JoinRoomScreen(inviteCode: inviteCode);
      },
    ),
    GoRoute(
      path: '/subscription',
      builder: (context, state) => const SubscriptionScreen(),
    ),
    GoRoute(
      path: '/payment/:plan',
      builder: (context, state) {
        final plan = state.pathParameters['plan'] ?? 'pro';
        return PaymentScreen(planName: plan);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
