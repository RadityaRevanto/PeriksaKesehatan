import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:periksa_kesehatan/core/di/injection_container.dart' as di;
import 'package:periksa_kesehatan/pages/auth/login/login_page.dart';
import 'package:periksa_kesehatan/presentation/bloc/auth/auth_bloc.dart';
import 'package:periksa_kesehatan/presentation/bloc/auth/auth_event.dart';
import 'package:periksa_kesehatan/presentation/bloc/auth/auth_state.dart';
import 'package:periksa_kesehatan/presentation/bloc/health/health_bloc.dart';
import 'package:periksa_kesehatan/presentation/bloc/education/education_bloc.dart';
import 'package:periksa_kesehatan/widgets/common/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthBloc>()..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (context) => di.sl<HealthBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<EducationBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Periksa Kesehatan',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'),
          Locale('en', 'US'), 
        ],
        locale: const Locale('id', 'ID'),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const BottomNavigation();
            } else if (state is AuthUnauthenticated) {
              return const LoginPage();
            } else {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
