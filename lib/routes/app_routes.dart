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
import '../features/carbon_tracker/screens/usage_details_screen.dart';
import '../features/challenges/screens/challenges_screen.dart';
import '../features/challenges/controllers/challenges_controller.dart';
import '../features/chatbot/screens/chatbot_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/list/screens/list_screen.dart';
import '../features/messages/screens/messages_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/setup/screens/setup_screen.dart';
import '../features/setup/controllers/setup_controller.dart';
import '../features/social/screens/leaderboard_screen.dart';
import '../features/social/screens/friends_screen.dart';
import '../features/splash/splash_screen.dart';

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
  leaderboard,
  friends,
  setup,
  usageDetails,
  challenges,
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
        GetPage(
          name: getRouteName(AppRoute.setup),
          page: () => SetupScreen(),
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
          binding: BindingsBuilder(() {
            Get.lazyPut<SetupController>(() => SetupController());
          }),
        ),
        GetPage(
          name: getRouteName(AppRoute.usageDetails),
          page: () => const UsageDetailsScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: AppAnimations.medium,
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: getRouteName(AppRoute.challenges),
          page: () {
            print('DEBUG: Building ChallengesScreen page');
            try {
              return const ChallengesScreen();
            } catch (e) {
              print('DEBUG: Error creating ChallengesScreen: $e');
              print('DEBUG: Stack trace: ${StackTrace.current}');
              rethrow;
            }
          },
          transition: Transition.rightToLeft,
          transitionDuration: AppAnimations.medium,
          middlewares: [AuthMiddleware()],
          binding: BindingsBuilder(() {
            print('DEBUG: Registering ChallengesController binding');
            try {
              // Create and register the controller permanently
              if (!Get.isRegistered<ChallengesController>()) {
                Get.put<ChallengesController>(ChallengesController(), permanent: true);
                print('DEBUG: ChallengesController registered permanently');
              } else {
                print('DEBUG: ChallengesController was already registered');
              }
            } catch (e) {
              print('DEBUG: Error in ChallengesController binding: $e');
              print('DEBUG: Stack trace: ${StackTrace.current}');
            }
          }),
        ),
      ];

  /// Get the route name as a string for a given AppRoute
  static String getRouteName(AppRoute route) {
    print('DEBUG: Getting route name for: $route');
    String routeName;
    
    switch (route) {
      case AppRoute.splash:
        routeName = '/splash';
        break;
      case AppRoute.login:
        routeName = '/login';
        break;
      case AppRoute.signup:
        routeName = '/signup';
        break;
      case AppRoute.forgotPassword:
        routeName = '/forgot-password';
        break;
      case AppRoute.home:
        routeName = '/home';
        break;
      case AppRoute.profile:
        routeName = '/profile';
        break;
      case AppRoute.settings:
        routeName = '/settings';
        break;
      case AppRoute.list:
        routeName = '/list';
        break;
      case AppRoute.calendar:
        routeName = '/calendar';
        break;
      case AppRoute.analytics:
        routeName = '/analytics';
        break;
      case AppRoute.messages:
        routeName = '/messages';
        break;
      case AppRoute.chatbot:
        routeName = '/chatbot';
        break;
      case AppRoute.leaderboard:
        routeName = '/leaderboard';
        break;
      case AppRoute.friends:
        routeName = '/friends';
        break;
      case AppRoute.setup:
        routeName = '/setup';
        break;
      case AppRoute.usageDetails:
        routeName = '/usage-details';
        break;
      case AppRoute.challenges:
        routeName = '/challenges';
        break;
      default:
        routeName = '/';
        break;
    }
    print('DEBUG: Resolved route name: $routeName');
    return routeName;
  }
}

/// Binding for authentication related dependencies
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // This will be handled by the controller
  }
}
