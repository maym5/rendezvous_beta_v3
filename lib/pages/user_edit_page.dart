import 'package:flutter/material.dart';
import '../layouts/page_background.dart';
import '../widgets/profile_view/profile_view.dart';
import '../widgets/user_edit_builder.dart';

class UserEditPage extends StatefulWidget {
  static const id = "user_edit_page";
  const UserEditPage({Key? key}) : super(key: key);

  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  late bool showErrors;

  @override
  void initState() {
    showErrors = false;
    super.initState();
  }

  void onButtonPress() {
    Navigator.pushNamed(context, UserProfile.id);
    setState(() {
      showErrors = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      body: ListView.builder(
          itemCount: UserEditBuilder.itemCount,
          itemBuilder: (context, index) => UserEditBuilder(
              index: index,
              showErrors: showErrors,
              onButtonPress: onButtonPress
          ),
      ),
    );
  }
}
