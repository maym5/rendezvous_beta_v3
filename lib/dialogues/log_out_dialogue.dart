import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/widgets/gradient_button.dart';

import '../constants.dart';
import '../models/users.dart';
import '../pages/intro_page.dart';
import '../pages/sign_up_page.dart';
import '../services/authentication.dart';

Widget buildPopUpDialogue(Animation<double> animation, BuildContext context, {required List<Widget> children, double? height}) {
  final curvedValue = Curves.easeInOutBack.transform(animation.value) - 1.0;
  return Transform(
    transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(0),
        content: Container(
          height: height ?? 250,
          width: 120,
          decoration: const BoxDecoration(
            color: kPopUpColor,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
    ),
  );
}

class LogOutDialogue extends StatelessWidget {
  LogOutDialogue({Key? key, required this.animation}) : super(key: key);
  final Animation<double> animation;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) => buildPopUpDialogue(animation,
      context,
      children: [
        Text("Are you sure you want to log out?", textAlign: TextAlign.center, style: kTextStyle),
        const SizedBox(
          height: 10,
        ),
        Center(
          child: GradientButton(
            title: 'Yes',
            onPressed: () async {
              await logOut();
              UserData.resetUserData();
              Navigator.pushNamed(context, IntroPage.id);
            },
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Center(
          child: GradientButton(
            title: 'No',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ]
  );
}
