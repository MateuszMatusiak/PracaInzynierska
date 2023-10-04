import 'package:flutter/cupertino.dart';
import 'package:rks/screens/login_panel.dart';
import 'package:rks/screens/register_panel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: const [
        LoginScreen(),
        RegisterScreen(),
      ],
    );
  }
}
