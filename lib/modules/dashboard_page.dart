import 'package:firebase_app_bloc/modules/root/pages/root_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/blocs.dart';
import 'authentication/authentication.dart';

class DashBoardPage extends StatelessWidget {
  const DashBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // return BlocConsumer<AppBloc, AppState>(
    //   listener: (context, state) {
    //     if (state.appStatus == AppStatus.unauthenticated) {
    //       Navigator.pushNamedAndRemoveUntil(context, RouteName.signInPage,
    //           (route) {
    //         debugPrint('route.settings.name: ${route.settings.name}');
    //         debugPrint('ModalRoute: ${ModalRoute.of(context)!.settings.name}');

    //         return route.settings.name == ModalRoute.of(context)!.settings.name
    //             ? true
    //             : false;
    //       });
    //     } else if (state.appStatus == AppStatus.authenticated) {
    //       Navigator.pushNamed(context, RouteName.homePage);
    //     }
    //   },
    //   builder: (context, state) {
    //     return const SplashPage();
    //   },
    // );
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state.appStatus == AppStatus.unknown) {
          return const SplashPage();
        } else if (state.appStatus == AppStatus.unauthenticated) {
          return const SignInPage();
        } else if (state.appStatus == AppStatus.authenticated) {
          return const RootPage();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
