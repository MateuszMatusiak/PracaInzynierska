import 'package:flutter/material.dart';
import 'package:rks/globals.dart';
import 'package:url_launcher/url_launcher.dart';

class WrongVersionPanel extends StatefulWidget {
  const WrongVersionPanel({Key? key}) : super(key: key);

  @override
  State<WrongVersionPanel> createState() => _WrongVersionPanelState();
}


class _WrongVersionPanelState extends State<WrongVersionPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.fromLTRB(40, 40, 40, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Korzystasz z nieaktualnej wersji aplikacji, aby kontynuować musisz ją zaktualizować',
            style: TextStyle(fontSize: 16, color: primaryTextColor),
          ),
          SizedBox(
            height: 20,
          ),
          MaterialButton(
            color: primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            minWidth: double.infinity,
            height: 40,
            onPressed: onGetNewVersion,
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: 20,
                color: primaryTextColor,
              ),
            ),
          )
        ],
      ),
    ));
  }

  void onGetNewVersion() async {
  }
}
