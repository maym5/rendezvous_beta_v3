import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/pages/verification_page.dart';
import 'package:rendezvous_beta_v3/services/authentication_service.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import '../widgets/fields/text_input_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/page_background.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SignUpPage extends StatefulWidget {
  static const id = "sign_up_page";
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  Map<String, String?> errorMessages = {
    "email": null,
    "password": null,
    "confirm": "Passwords don't match"
  };
  Map<String, String?> userInputs = {
    "email": null,
    "password": null,
    "confirm": null
  };
  late bool showErrors;
  late bool _showSpinner;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool get passwordsDontMatch =>
      userInputs['password'] != userInputs["confirm"];

  TextInputField get emailField => TextInputField(
        title: "Email",
        controller: emailController,
        onChanged: (email) {
          if (email == "") {
            userInputs['email'] = null;
          } else {
            userInputs["email"] = email;
          }
        },
        showError:
            (userInputs['email'] == null || errorMessages["email"] != null) &&
                showErrors,
        errorMessage: errorMessages["email"],
      );

  TextInputField get passwordField => TextInputField(
        title: "Password",
        controller: passwordController,
        obscureText: true,
        onChanged: (password) {
          if (password == "") {
            userInputs['password'] = null;
          } else {
            userInputs["password"] = password;
          }
        },
        showError: (userInputs['password'] == null ||
                errorMessages['password'] != null) &&
            showErrors,
        errorMessage: errorMessages["password"],
      );

  TextInputField get confirmField => TextInputField(
        title: "Confirm Password",
        controller: confirmController,
        obscureText: true,
        onChanged: (confirm) {
          if (confirm == "") {
            userInputs['confirm'] = null;
          } else {
            userInputs["confirm"] = confirm;
          }
        },
        showError:
            (userInputs['confirm'] == null || passwordsDontMatch) && showErrors,
        errorMessage: errorMessages["confirm"],
      );

  AppBar get _appBar => AppBar(
        leading: BackButton(
          color: Colors.redAccent,
          onPressed: _navigateBack,
        ),
      );

  void _handleRegistration() async {
    if (!passwordsDontMatch) {
      setState(() {
        _showSpinner = true;
      });
      if (userInputs["email"] != null && userInputs["password"] != null) {
        emailController.text = userInputs["email"]!;
        passwordController.text = userInputs["password"]!;
        confirmController.text = userInputs["confirm"]!;
         var result = await AuthenticationService().onEmailAndPasswordSignUp(
            userInputs["email"]!, userInputs["password"]!);
        setState(() => _showSpinner = false);
        if (result is String) {
          switch (result) {
            case 'weak-password':
              setState(() {
                errorMessages["password"] = "This password is too weak";
                showErrors = true;
              });
              break;
            case "email-already-in-use":
              setState(() {
                errorMessages["email"] = "That email is already in use";
                showErrors = true;
              });
              break;
            case "invalid-email":
              setState(() {
                errorMessages["email"] = "Please enter a valid email";
                showErrors = true;
              });
              break;
            default:
              setState(() {
                errorMessages["email"] = result;
                showErrors = true;
              });
              break;
          }
        } else {
          Navigator.pushNamed(context, VerificationPage.id);
        }
      } else {
        setState(() {
          _showSpinner = false;
          showErrors = true;
        });
      }
    } else {
      setState(() => showErrors = true);
    }
  }

  @override
  void initState() {
    showErrors = false;
    _showSpinner = false;
    super.initState();
  }

  void _navigateBack() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      appBar: _appBar,
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        color: kDarkTransparent,
        progressIndicator:
            const CircularProgressIndicator(color: Colors.redAccent),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const SizedBox(
                  height: 25,
                ),
                Container(
                  height: 100,
                  width: 100,
                  color: Colors.redAccent,
                ),
                const SizedBox(
                  height: 75,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[emailField, passwordField, confirmField],
                ),
                const SizedBox(
                  height: 25,
                ),
                GradientButton(title: "Sign Up", onPressed: _handleRegistration)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
