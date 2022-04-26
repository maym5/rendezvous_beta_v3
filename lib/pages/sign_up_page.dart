import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/cloud/authentication.dart';
import 'package:rendezvous_beta_v3/pages/user_edit_page.dart';
import '../widgets/fields/text_input_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/page_background.dart';

class SignUpPage extends StatefulWidget {
  static const id = "sign_up_page";
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  Map<String, String?> errorMessages = {
    "email" : null,
    "password" : null,
    "confirm" : "Passwords don't match"
  };
  Map<String, String?> userInputs = {
    "email" : null,
    "password" : null,
    "confirm" : null
  };
  late bool showErrors;

  bool get passwordsDontMatch => userInputs['password'] != userInputs["confirm"];

  TextInputField get emailField => TextInputField(
    title: "Email",
    onChanged: (email) {
      if (email == "") {
        userInputs['email'] = null;
      } else {
        userInputs["email"] = email;
      }
    },
    showError: (userInputs['email'] == null || errorMessages["email"] != null) && showErrors,
    errorMessage: errorMessages["email"],
  );

  TextInputField get passwordField => TextInputField(
    title: "Password",
    obscureText: true,
    onChanged: (password) {
      if (password == "") {
        userInputs['password'] = null;
      } else {
        userInputs["password"] = password;
      }
    },
    showError: (userInputs['password'] == null || errorMessages['password'] != null) && showErrors,
    errorMessage: errorMessages["password"],
  );

  TextInputField get confirmField => TextInputField(
    title: "Confirm Password",
    obscureText: true,
    onChanged: (confirm) {
      if (confirm == "") {
        userInputs['confirm'] = null;
      } else {
        userInputs["confirm"] = confirm;
      }
    },
    showError: (userInputs['confirm'] == null || passwordsDontMatch) && showErrors,
    errorMessage: errorMessages["confirm"],
  );

  void _setErrorMessages(String result) {
    // TODO: refactor
    switch(result) {
      case 'weak-password':
        setState(() {
          errorMessages["password"] = "This password is too weak";
          errorMessages['email'] = null;
          showErrors = true;
        });
        break;
      case "email-already-in-use":
        setState(() {
          errorMessages['email'] = "That email is already in use";
          errorMessages["password"] = null;
          showErrors = true;
        });
        break;
      case "invalid-email":
        setState(() {
          errorMessages["email"] = "Please enter a valid email";
          errorMessages["password"] = null;
          showErrors = true;
        });
        break;
      default:
        setState(() {
          errorMessages["email"] = result;
          errorMessages["password"] = null;
          showErrors = true;
        });
        break;
    }
  }

  void _onPressed() async {
    if (passwordsDontMatch) {
      setState(() {
        showErrors = true;
      });
    } else {
      for (String? input in userInputs.values) {
        if (input == null) {
          setState(() {
            showErrors = true;
            return;
          });
        }
      }
      var result = await onEmailAndPasswordSignUp(userInputs["email"]!, userInputs["password"]!);
      if (result is User) {
        Navigator.pushNamed(context, UserEditPage.id);
      } else {
        _setErrorMessages(result);
    }
  }}

  @override
  void initState() {
    showErrors = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const SizedBox(height: 25,),
                Container(
                  height: 100,
                  width: 100,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 75,),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    emailField,
                    passwordField,
                    confirmField
                  ],
                ),
                const SizedBox(height: 25,),
                GradientButton(title: "Sign Up", onPressed: _onPressed)
              ],
            ),
          ),
        ),
    );
  }
}

