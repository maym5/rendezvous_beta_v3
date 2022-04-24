import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/cloud_functions/authentication.dart';
import '../fields/text_input_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/page_background.dart';

class LoginPage extends StatefulWidget {
  static const id = "login_page";
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Map<String, String?> loginInputs = {
    "email" : null,
    "password" : null
  };
  late bool showErrors;


  TextInputField get _emailField => TextInputField(
        title: "Email",
        onChanged: (email) {
          setState(() {
            if (email == "") {
              loginInputs['email'] = null;
            } else {
              loginInputs["email"] = email;
            }
          });
        },
        showError: loginInputs['email'] == null && showErrors,
      );

  TextInputField get _passwordField => TextInputField(
    title: "Password",
    onChanged: (password) {
      setState(() {
        if (password == "") {
          loginInputs['password'] = null;
        } else {
          loginInputs["password"] = password;
        }
      });
    },
    showError: loginInputs['password'] == null && showErrors,
  );

  void _onPressed() async {
    if (loginInputs['password'] != null && loginInputs['email'] != null) {
      var result = await onEmailAndPasswordLogin(loginInputs['email']!, loginInputs['password']!);
      if (result is User) {
        // push discover
      } else {
        // set error message
      }
    } else {
      setState(() => showErrors = true);
    }
  }

  @override
  void initState() {
    showErrors = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: 100,
            width: 100,
            color: Colors.redAccent,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _emailField,
              _passwordField
            ],
          ),
          GradientButton(
              title: "Login",
              onPressed: _onPressed,
          ),
        ],
      ),
    );
  }
}
