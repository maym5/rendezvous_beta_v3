import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/animations/fade_in_animation.dart';
import 'package:rendezvous_beta_v3/animations/text_fade_in.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/pages/home_page.dart';
import 'package:rendezvous_beta_v3/pages/intro_page.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

import '../models/users.dart';

class LoadingPage extends StatefulWidget {
  static const id = "loading_page";
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late bool _showIndicator;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future load() async {
    await Future.delayed(const Duration(seconds: 4));
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() => _showIndicator = true);
      await UserData().setLocation();
      await UserData().getUserData();
      setState(() => _showIndicator = false);
      Navigator.pushNamed(context, HomePage.id);
    } else {
      Navigator.pushNamed(context, IntroPage.id);
    }
  }

  Widget get _progressIndicator => _showIndicator
      ? const Padding(
        padding: EdgeInsets.only(top: 15),
        child: SizedBox(
            child: CircularProgressIndicator(color: Colors.redAccent),
            height: 40,
            width: 40),
      )
      : Container();

  @override
  void initState() {
    _showIndicator = false;
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeInAnimation(
              delay: 1500,
              verticalOffset: -0.35,
              horizontalOffset: 0,
              child: Container(
                height: 100,
                width: 100,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => kButtonGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: TextFadeIn(
                  text: "Rendezvous", style: kTextStyle.copyWith(fontSize: 50)),
            ),
            _progressIndicator
          ],
        ),
      ),
    );
  }
}
