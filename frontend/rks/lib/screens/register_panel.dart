import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:rks/model/user_details.dart';

import '../globals.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<RegisterScreen> {
  final String url = "${apiUrl}";

  String email = "";
  String password = "";
  String repeatedPassword = "";
  bool canAdd = false;

  bool isVisible = false;
  bool isEmailValid = false;
  bool isPasswordEightCharacters = false;
  bool hasPasswordOneNumber = false;
  bool repeatedPasswordEquals = false;

  onValidateInput() {
    final numericRegex = RegExp(r'[0-9]');

    setState(() {
      isPasswordEightCharacters = false;
      if (password.length >= 8) isPasswordEightCharacters = true;

      hasPasswordOneNumber = false;
      if (numericRegex.hasMatch(password)) hasPasswordOneNumber = true;

      isEmailValid = false;
      if (EmailValidator.validate(email)) isEmailValid = true;

      repeatedPasswordEquals = false;
      if (password.isNotEmpty && password == repeatedPassword) {
        repeatedPasswordEquals = true;
      }

      canAdd = isPasswordEightCharacters &&
          hasPasswordOneNumber &&
          isEmailValid &&
          repeatedPasswordEquals;
    });
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
                const SizedBox(height: 35),
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
                          child: const Text(
                            "Logowanie",
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700,
                            ),
                          )),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/register');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryVariantBackgroundColor,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            "Rejestracja",
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
                    ]),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                    child: TextFormField(
                        onChanged: (v) => {
                              email = v,
                              onValidateInput(),
                            },
                        style: TextStyle(color: primaryTextColor),
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
                              onValidateInput(),
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
                    child: TextFormField(
                        style: TextStyle(color: primaryTextColor),
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        onChanged: (v) => {
                              repeatedPassword = v,
                              onValidateInput(),
                            },
                        decoration: InputDecoration(
                          labelText: 'powtórz hasło',
                          labelStyle: TextStyle(color: primaryTextColor),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryTextColor),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryTextColor),
                          ),
                        ))),
                const SizedBox(height: 30),
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          color: isEmailValid ? Colors.green : Colors.red,
                          border: isEmailValid
                              ? Border.all(color: Colors.transparent)
                              : Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(50)),
                      child: Center(
                        child: Icon(
                          isEmailValid ? Icons.check : Icons.clear,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Poprawny email",
                      style: TextStyle(color: primaryTextColor),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          color: isPasswordEightCharacters
                              ? Colors.green
                              : Colors.red,
                          border: isPasswordEightCharacters
                              ? Border.all(color: Colors.transparent)
                              : Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(50)),
                      child: Center(
                        child: Icon(
                          isPasswordEightCharacters ? Icons.check : Icons.clear,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text("Hasło musi mieć minimum 8 znaków",
                        style: TextStyle(color: primaryTextColor))
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          color:
                              hasPasswordOneNumber ? Colors.green : Colors.red,
                          border: hasPasswordOneNumber
                              ? Border.all(color: Colors.transparent)
                              : Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(50)),
                      child: Center(
                        child: Icon(
                          hasPasswordOneNumber ? Icons.check : Icons.clear,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text("Hasło musi zawierać cyfrę",
                        style: TextStyle(color: primaryTextColor))
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          color: repeatedPasswordEquals
                              ? Colors.green
                              : Colors.red,
                          border: repeatedPasswordEquals
                              ? Border.all(color: Colors.transparent)
                              : Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(50)),
                      child: Center(
                        child: Icon(
                          repeatedPasswordEquals ? Icons.check : Icons.clear,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text("Powtórzone hasło powinno być identyczne",
                        style: TextStyle(color: primaryTextColor))
                  ],
                ),
                const SizedBox(height: 50),
                MaterialButton(
                  height: 40,
                  minWidth: double.infinity,
                  onPressed: () {
                    onRegister().then((v) async => {
                          EasyLoading.dismiss(),
                          if (v != null)
                            {
                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.popUntil(
                                            context, ModalRoute.withName('/'));
                                        Navigator.pushNamed(context, '/');
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                  content: const Text(
                                      'Teraz należy potwierdzić adres email'),
                                  title: const Text('Rejestracja'),
                                ),
                              ),
                            }
                        });
                  },
                  color: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  child: Text('ZAREJESTRUJ SIĘ',
                      style: TextStyle(color: primaryTextColor)),
                ),
                // const Padding(
                //     padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                //     child: Text(
                //       "lub dołącz przez",
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

  Future<UserDetails?> onRegister() async {
    if (canAdd) {
      UserDetails user = UserDetails(email.trim(), password.trim());

      var jsonData = {
        'email': email.trim(),
        'password': password.trim(),
      };
      try {
        await EasyLoading.show(
          status: 'Tworzenie konta',
          maskType: EasyLoadingMaskType.black,
        );
        var response = await dio.post('$url/register',
            data: jsonData,
            options: Options(
                contentType: "application/json",
                responseType: ResponseType.json,
                headers: {'App-Version': appVersion}));
        if (response.statusCode == 200) {
          user.id = int.parse(response.data);
          await firebaseRegister(user);
          return user;
        }
      } on DioError catch (e) {
        EasyLoading.dismiss();

        if (e.response?.statusCode == 409) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
              content: Text('Podany email jest już użyty'),
              title: const Text('Rejestracja'),
            ),
          );
        } else {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
              content: Text('Wewnętrzny błąd serwera'),
              title: const Text('Rejestracja'),
            ),
          );
        }
      } catch (e) {
        EasyLoading.dismiss();
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
            content: Text('Wewnętrzny błąd serwera'),
            title: const Text('Rejestracja'),
          ),
        );
      }
    }
    return null;
  }

  Future firebaseRegister(UserDetails user) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      user.firebaseId = credential.user!.uid;

      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
            firstName: '',
            id: user.firebaseId.trim(),
            imageUrl: '${userImageUrl}${0}',
            lastName: '',
            metadata: {'databaseId': user.id}),
      );

      if (!mounted) return;
    } catch (e) {
      EasyLoading.dismiss();
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
          content: Text(
            e.toString(),
          ),
          title: const Text('Error'),
        ),
      );
    }
  }
}
