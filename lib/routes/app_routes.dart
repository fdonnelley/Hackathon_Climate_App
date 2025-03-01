/// Enum defining the available routes in the application.
///
/// This helps centralize navigation routes and make them type-safe.
import 'package:get/get.dart';

import '../core/animations/app_animations.dart';
import '../core/middleware/auth_middleware.dart';
import '../features/analytics/screens/analytics_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/calendar/screens/calendar_screen.dart';
import '../features/chatbot/screens/chatbot_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/list/screens/list_screen.dart';
import '../features/messages/screens/messages_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/onboarding/controllers/onboarding_controller.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/social/screens/leaderboard_screen.dart';
import '../features/social/screens/friends_screen.dart';

enum AppRoute {
  splash,
  login,
  signup,
  forgotPassword,
  home,
  profile,
  settings,
  list,
  calendar,
  analytics,
  messages,
  chatbot,
  onboarding,
  leaderboard,
  friends,
}

/// Helper class to convert app routes to proper route strings
class AppRoutes {
  /// Private constructor to prevent instantiation
  AppRoutes._();

  /// List of all app pages with their respective routes
  static List<GetPage> get pages => [
        GetPage(
          name: getRouteName(AppRoute.splash),
          page: () => const SplashScreen(),
          transition: Transition.fadeIn,
          transitionDuration: AppAnimations.medium,
        ),
        GetPage(
          name: getRouteName(AppRoute.onboarding),
          page: () => const OnboardingScreen(),
          binding: OnboardingBinding(),
          transition: Transition.fadeIn,
          transitionDuration: AppAnimations.medium,
        ),
        GetPage(
          name: getRouteName(AppRoute.login),
          page: () => const LoginScreen(),
          customTransition: GetPageCustomTransition(
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return AppAnimations.fadeScaleTransition(
                context: context,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
          ),
          transitionDuration: AppAnimations.medium,
          binding: AuthBinding(),
        ),
        GetPage(
          name: getRouteName(AppRoute.signup),
          page: () => const SignupScreen(),
          customTransition: GetPageCustomTransition(
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return AppAnimations.fadeScaleTransition(
                context: context,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
          ),
          transitionDuration: AppAnimations.medium,
        ),
        GetPage(
          name: getRouteName(AppRoute.forgotPassword),
          page: () => const ForgotPasswordScreen(),
          customTransition: GetPageCustomTransition(
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return AppAnimations.fadeScaleTransition(
                context: context,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
          ),
          transitionDuration: AppAnimations.medium,
        ),
        GetPage(
          name: getRouteName(AppRoute.home),
          page: () => const HomeScreen(),
          customTransition: GetPageCustomTransition(
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return AppAnimations.pureSlideTransition(
                context: context,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
                direction: SlideDirection.right,
              );
            },
          ),
          transitionDuration: AppAnimations.medium,
          middlewares: [
            AuthMiddleware(),
          ],
        ),
        GetPage(
          name: getRouteName(AppRoute.profile),
          page: () => const ProfileScreen(),
          customTransition: GetPageCustomTransition(
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return AppAnimations.pureSlideTransition(
                context: context,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
                direction: SlideDirection.right,
              );
            },
          ),
          transitionDuration: AppAnimations.medium,
          middlewares: [
            AuthMiddleware(),
          ],
        ),
        GetPage(
          name: getRouteName(AppRoute.settings),
          page: () => const SettingsScreen(),
          customTransition: GetPageCustomTransition(
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return AppAnimations.pureSlideTransition(
                context: context,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
                direction: SlideDirection.right,
              );
            },
          ),
          transitionDuration: AppAnimations.medium,
          middlewares: [
            AuthMiddleware(),
          ],
        ),
        GetPage(
          name: getRouteName(AppRoute.list),
          page: () => const ListScreen(),
          customTransition: GetPageCustomTransition(
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return AppAnimations.pureSlideTransition(
                context: context,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
                direction: SlideDirection.right,
              );
            },
          ),
          transitionDuration: AppAnimations.medium,
          middlewares: [
            AuthMiddleware(),
          ],
        ),
        GetPage(
          name: getRouteName(AppRoute.calendar),
          page: () => const CalendarScreen(),
          customTransition: GetPageCustomTransition(
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return AppAnimations.pureSlideTransition(
                context: context,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
                direction: SlideDirection.right,
              );
            },
          ),
          transitionDuration: AppAnimations.medium,
          middlewares: [
            AuthMiddleware(),
          ],
        ),
        GetPage(
          name: getRouteName(AppRoute.analytics),
          page: () => const AnalyticsScreen(),
          customTransition: GetPageCustomTransition(
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return AppAnimations.pureSlideTransition(
                context: context,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
                direction: SlideDirection.right,
              );
            },
          ),
          transitionDuration: AppAnimations.medium,
          middlewares: [
            AuthMiddleware(),
          ],
        ),
        GetPage(
          name: getRouteName(AppRoute.messages),
          page: () => const MessagesScreen(),
          customTransition: GetPageCustomTransition(
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return AppAnimations.pureSlideTransition(
                context: context,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
                direction: SlideDirection.right,
              );
            },
          ),
          transitionDuration: AppAnimations.medium,
          middlewares: [
            AuthMiddleware(),
          ],
        ),
        GetPage(
          name: getRouteName(AppRoute.chatbot),
          page: () => const ChatbotScreen(),
          customTransition: GetPageCustomTransition(
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return AppAnimations.pureSlideTransition(
                context: context,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
                direction: SlideDirection.right,
              );
            },
          ),
          transitionDuration: AppAnimations.medium,
          middlewares: [
            AuthMiddleware(),
          ],
        ),
        GetPage(
          name: getRouteName(AppRoute.leaderboard),
          page: () => const LeaderboardScreen(),
          customTransition: GetPageCustomTransition(
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return AppAnimations.pureSlideTransition(
                context: context,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
                direction: SlideDirection.right,
              );
            },
          ),
          transitionDuration: AppAnimations.medium,
          middlewares: [
            AuthMiddleware(),
          ],
        ),
        GetPage(
          name: getRouteName(AppRoute.friends),
          page: () => const FriendsScreen(),
          customTransition: GetPageCustomTransition(
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return AppAnimations.pureSlideTransition(
                context: context,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
                direction: SlideDirection.right,
              );
            },
          ),
          transitionDuration: AppAnimations.medium,
          middlewares: [
            AuthMiddleware(),
          ],
        ),
      ];

  /// Get the route name for a given AppRoute
  static String getRouteName(AppRoute route) {
    switch (route) {
      case AppRoute.splash:
        return '/splash';
      case AppRoute.login:
        return '/login';
      case AppRoute.signup:
        return '/signup';
      case AppRoute.forgotPassword:
        return '/forgot-password';
      case AppRoute.home:
        return '/home';
      case AppRoute.profile:
        return '/profile';
      case AppRoute.settings:
        return '/settings';
      case AppRoute.list:
        return '/list';
      case AppRoute.calendar:
        return '/calendar';
      case AppRoute.analytics:
        return '/analytics';
      case AppRoute.messages:
        return '/messages';
      case AppRoute.chatbot:
        return '/chatbot';
      case AppRoute.onboarding:
        return '/onboarding';
      case AppRoute.leaderboard:
        return '/leaderboard';
      case AppRoute.friends:
        return '/friends';
      default:
        return '/';
    }
  }
}

/// Binding for authentication related dependencies
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Add your authentication related dependencies here
  }
}

/// Binding for onboarding related dependencies
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
