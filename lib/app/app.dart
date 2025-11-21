import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kff_owner_admin/app/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:kff_owner_admin/app/screens/dashboard/dashboard_screen.dart';
import 'package:kff_owner_admin/app/screens/login/bloc/login_bloc.dart';
import 'package:kff_owner_admin/app/screens/login/login_screen.dart';
import 'package:kff_owner_admin/app/screens/register/bloc/register_bloc.dart';
import 'package:kff_owner_admin/app/screens/splash/splash_screen.dart';

class KffOwnerAdminApp extends StatelessWidget {
  const KffOwnerAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => RegisterBloc()..add(RegisterLoad())),
        BlocProvider(create: (context) => LoginBloc()..add(LoginLoad())),
      ],
      child: MaterialApp(
        theme: ThemeData(
          // Основной цвет - синий
          primaryColor: const Color(0xFF2563EB),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            primary: const Color(0xFF2563EB),
          ),

          // Цвет для ElevatedButton
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
          ),

          // Цвет для TextButton
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
            ),
          ),

          // Цвет для Checkbox, Radio, Switch
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const Color(0xFF2563EB);
              }
              return null;
            }),
          ),

          // Цвет для иконок
          iconTheme: const IconThemeData(color: Color(0xFF2563EB)),

          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        title: 'Партнерская Dopp.kz',
        home: SplashScreen(),
      ),
    );
  }
}
