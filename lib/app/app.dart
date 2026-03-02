import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitsy/app/routes.dart';
import 'package:fitsy/app/theme.dart';
import 'package:fitsy/core/di/injection.dart';
import 'package:fitsy/features/closet/presentation/bloc/closet_bloc.dart';
import 'package:fitsy/features/outfit/presentation/bloc/outfit_bloc.dart';

class FitsyApp extends StatelessWidget {
  const FitsyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ClosetBloc>()),
        BlocProvider(create: (_) => sl<OutfitBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Fitsy',
        theme: FitsyTheme.darkTheme,
        routerConfig: routerConfig,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
