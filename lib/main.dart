import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';
import 'features/auth/presentation/manager/auth_bloc.dart';
import 'features/home/presentation/manager/home_bloc.dart';
import 'features/home/presentation/manager/home_event.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  runApp(const EchoNewsApp());
}

class EchoNewsApp extends StatelessWidget {
  const EchoNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authService: di.sl<AuthService>(),
            firestoreService: di.sl<FirestoreService>(),
          ),
        ),
        BlocProvider(
          create: (context) => di.sl<HomeBloc>()..add(FetchTopStories()),
        ),
      ],
      child: MaterialApp(
        title: 'EchoNews World',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
