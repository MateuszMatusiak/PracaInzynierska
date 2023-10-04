import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rks/model/user_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globals.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<LoginScreen> {
  final String url = apiUrl;

  String email = "";
  String password = "";
  String _firebaseId = "";

  bool isVisible = false;
  bool isRemember = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: Container(
          alignment: Alignment.topCenter,
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: primaryBackgroundColor,
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryVariantBackgroundColor,
                            shadowColor: Colors.transparent,
                          ),
                          // padding: EdgeInsets.fromLTRB(0, 40, 0, 0const ),
                          child: Text(
                            "Logowanie",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: primaryTextColor,
                                decoration: TextDecoration.underline,
                                decorationColor: primaryTextColor,
                                decorationThickness: 2,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700,
                                fontFamily: "Lato"),
                          )),
                      ElevatedButton(
                          // padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/register');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryVariantBackgroundColor,
                            foregroundColor: Colors.lightBlue,
                            shadowColor: Colors.transparent,
                          ),
                          child: const Text(
                            "Rejestracja",
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700,
                            ),
                          )),
                    ]),
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                    child: TextField(
                        style: TextStyle(color: primaryTextColor),
                        onChanged: (v) => {
                              email = v,
                            },
                        decoration: InputDecoration(
                          labelText: 'email',
                          labelStyle: TextStyle(color: primaryTextColor),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryTextColor),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryTextColor),
                          ),
                        ))),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                    child: TextFormField(
                        style: TextStyle(color: primaryTextColor),
                        onChanged: (v) => {
                              password = v,
                            },
                        obscureText: !isVisible,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isVisible = !isVisible;
                              });
                            },
                            icon: isVisible
                                ? const Icon(Icons.visibility,
                                    color: Colors.black)
                                : const Icon(Icons.visibility_off,
                                    color: Colors.grey),
                          ),
                          labelText: 'hasło',
                          labelStyle: TextStyle(color: primaryTextColor),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryTextColor),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryTextColor),
                          ),
                        ))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                  child: Row(children: [
                    Checkbox(
                      value: isRemember,
                      onChanged: ((value) => setState(() {
                            isRemember = value!;
                          })),
                      side: MaterialStateBorderSide.resolveWith(
                        (Set<MaterialState> states) {
                          return BorderSide(color: primaryTextColor);
                        },
                      ),
                    ),
                    Text("Zapamiętaj mnie",
                        style: TextStyle(color: primaryTextColor)),
                  ]),
                ),
                MaterialButton(
                  height: 40,
                  minWidth: double.infinity,
                  onPressed: () {
                    onLogin();
                  },
                  color: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  child: Text('ZALOGUJ SIĘ',
                      style: TextStyle(color: primaryTextColor)),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 190, 0,
                      0), //to jest po prostu przerwa żeby nie rozjeżdżało się UI bez oauth, po dodaniu po prostu usunąć padding
                )
                // const Padding(
                //     padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                //     child: Text(
                //       "lub zaloguj się przez",
                //       textAlign: TextAlign.start,
                //       style: TextStyle(
                //           fontSize: 20.0,
                //           fontWeight: FontWeight.w700,
                //           fontFamily: "Lato"),
                //     )),
                // SignInButton(
                //   Buttons.FacebookNew,
                //   text: "Facebook",
                //   shape: const StadiumBorder(
                //     //<-- 3. SEE HERE
                //     side: BorderSide(color: Colors.transparent),
                //   ),
                //   onPressed: () {},
                // ),
                // SignInButton(
                //   Buttons.Google,
                //   text: "Google",
                //   shape: const StadiumBorder(
                //     //<-- 3. SEE HERE
                //     side: BorderSide(color: Colors.transparent),
                //   ),
                //   onPressed: () {},
                // )
              ])),
    );
  }

  Future onLogin() async {
    if (email.isNotEmpty && password.isNotEmpty) {
      String deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
      var jsonData = {
        'email': email.trim(),
        'password': password.trim(),
        'deviceToken': deviceToken.trim(),
      };
      final prefs = await SharedPreferences.getInstance();
      try {
        await EasyLoading.show(
          status: 'Logowanie',
          maskType: EasyLoadingMaskType.black,
        );
        var credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
        _firebaseId = credential.user!.uid;
        var response = await dio.post("$url/login",
            data: jsonData,
            options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {'App-Version': appVersion},
            ));
        String token = response.headers.value("authorization")!;
        if (response.statusCode != 200) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Wewnętrzny błąd serwera')));
          return;
        }
        UserDetails user = UserDetails.fromJson(response.data);
        user.token = token;
        user.firebaseId = _firebaseId;

        if (isRemember) {
          await prefs.setString('login', email.trim());
          await prefs.setString('password', password.trim());
        }
        await EasyLoading.dismiss();

        setState(() {
          Navigator.pop(context);
          Navigator.of(context).pushNamed('/menu');
        });
      } on DioError catch (e) {
        await handleLoginException(prefs, e);
      } catch (e) {
        await EasyLoading.dismiss();
      }
    }
  }

  Future<void> handleLoginException(SharedPreferences prefs, DioError e) async {
    await EasyLoading.dismiss();
    await prefs.remove('login');
    await prefs.remove('password');
    if (e.response?.statusCode == 401) {
      String message = e.response?.data['message'];
      if (e.response?.data['user'] != null) {
        UserDetails user = UserDetails.fromJson(e.response?.data['user']);
        String token = (e.response?.headers.value("authorization"))!;
        user.token = token;
        user.firebaseId = _firebaseId;
        if (message.startsWith('Email')) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Musisz aktywować email')));
        } else {
          Navigator.popUntil(context, ModalRoute.withName('/'));
          Navigator.of(context)
              .pushNamed('/updateUserDetails', arguments: [user]);
        }
      } else if (message == 'Bad credentials') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Błędny login lub hasło')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wewnętrzny błąd serwera')));
    }
  }
}
