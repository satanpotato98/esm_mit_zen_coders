import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/data/bloc/login.dart';
import 'package:foore/data/http_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_translations.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginBloc _loginBloc;
  final _formKeySendCode = GlobalKey<FormState>();
  final _formKeyLoginWithOtp = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    final httpService = Provider.of<HttpService>(context);
    final authBloc = Provider.of<AuthBloc>(context);
    if (this._loginBloc == null) {
      this._loginBloc = LoginBloc(httpService, authBloc);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    this._loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    onSendCode() {
      if (_formKeySendCode.currentState.validate()) {
        this._loginBloc.sendCode();
      }
    }

    onLoginWithOtp() {
      if (_formKeyLoginWithOtp.currentState.validate()) {
        this._loginBloc.useCode();
      }
    }

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<LoginState>(
            stream: _loginBloc.loginStateObservable,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.isShowOtp) {
                  return loginWithOtp(onLoginWithOtp, snapshot.data);
                } else
                  return sendCode(onSendCode, snapshot.data);
              }
              return Container();
            }),
      ),
    );
  }

  Container sendCode(onSendCode, LoginState state) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 32.0,
      ),
      child: Form(
        key: _formKeySendCode,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 70.0,
              padding: EdgeInsets.only(top: 50.0, bottom: 10.0),
              child: Image(
                image: AssetImage('assets/logo-black.png'),
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Text(
              AppTranslations.of(context).text("login_page_title"),
              style: Theme.of(context).textTheme.headline,
            ),
            const SizedBox(height: 32.0),
            Text(
              AppTranslations.of(context).text("login_page_sub_title"),
              style: Theme.of(context).textTheme.subtitle,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: this._loginBloc.emailEditController,
              style: TextStyle(
                color: Colors.black87,
              ),
              cursorColor: Colors.black87,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: AppTranslations.of(context)
                    .text("login_page_email_address_label"),
              ),
              validator: (String value) {
                return value.length < 1
                    ? AppTranslations.of(context)
                        .text("login_page_email_address_validation")
                    : null;
              },
            ),
            const SizedBox(height: 20),
            RaisedButton(
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
              ),
              onPressed: onSendCode,
              child: Container(
                width: double.infinity,
                child: state.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ))
                    : Text(
                        AppTranslations.of(context)
                            .text("login_page_button_get_otp"),
                        style: Theme.of(context).textTheme.button.copyWith(
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Container(
              width: double.infinity,
              child: Text(
                AppTranslations.of(context)
                    .text("login_page_don't_have_an_account"),
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.center,
              ),
            ),
            FlatButton(
              onPressed: () async {
                const url = 'https://app.foore.in/signup/';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: Container(
                width: double.infinity,
                child: Text(
                  AppTranslations.of(context)
                      .text("login_page_button_create_account"),
                  style: Theme.of(context).textTheme.button.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }

  Container loginWithOtp(onLoginWithOtp, LoginState state) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
      ),
      child: Form(
        key: _formKeyLoginWithOtp,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 70,
              padding: EdgeInsets.only(top: 50, bottom: 10),
              child: Image(
                image: AssetImage('assets/logo-black.png'),
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Text(
              AppTranslations.of(context).text("otp_page_title"),
              style: Theme.of(context).textTheme.headline,
            ),
            const SizedBox(height: 32.0),
            Text(
              'OTP sent to ' + this._loginBloc.emailEditController.text,
              style: Theme.of(context).textTheme.subtitle,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: this._loginBloc.otpEditController,
              style: TextStyle(
                color: Colors.black87,
              ),
              cursorColor: Colors.black87,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: AppTranslations.of(context)
                    .text("otp_page_enter_otp_label"),
              ),
              validator: (String value) {
                return value.length < 1
                    ? AppTranslations.of(context)
                        .text("otp_page_enter_otp_validation")
                    : null;
              },
            ),
            const SizedBox(height: 20),
            RaisedButton(
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
              ),
              onPressed: onLoginWithOtp,
              child: Container(
                width: double.infinity,
                child: state.isSubmitOtp
                    ? Center(
                        child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ))
                    : Text(
                        AppTranslations.of(context)
                            .text("otp_page_button_login"),
                        style: Theme.of(context).textTheme.button.copyWith(
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
