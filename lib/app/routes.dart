import 'package:go_router/go_router.dart';
import 'package:fitsy/app/shell.dart';
import 'package:fitsy/features/closet/presentation/pages/closet_page.dart';
import 'package:fitsy/features/outfit/presentation/pages/outfit_page.dart';

final routerConfig = GoRouter(
  initialLocation: '/closet',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/closet',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ClosetPage(),
          ),
        ),
        GoRoute(
          path: '/outfit',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: OutfitPage(),
          ),
        ),
      ],
    ),
  ],
);
