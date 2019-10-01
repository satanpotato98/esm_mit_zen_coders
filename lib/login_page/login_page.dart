import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/data/bloc/login.dart';
import 'package:foore/data/http_service.dart';

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
    this._loginBloc = LoginBloc(httpService, authBloc);
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
      backgroundColor: Colors.white,
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
        horizontal: 30.0,
      ),
      child: Form(
        key: _formKeySendCode,
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
              'LOGIN',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Please enter your email address linked to Foore.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: this._loginBloc.emailEditController,
              style: TextStyle(
                color: Colors.black87,
              ),
              cursorColor: Colors.black87,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(80, 233, 233, 233),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(
                      color: Colors.white,
                      style: BorderStyle.solid,
                    )),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(
                      color: Colors.white,
                      style: BorderStyle.solid,
                    )),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(
                      color: Colors.white,
                      style: BorderStyle.solid,
                    )),
                labelText: 'Email Address',
                labelStyle: TextStyle(
                  color: Colors.black54,
                ),
              ),
              validator: (String value) {
                return value.length < 1
                    ? 'Please enter a valid email address.'
                    : null;
              },
            ),
            const SizedBox(height: 20),
            RaisedButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0)),
              padding: EdgeInsets.symmetric(
                vertical: 15,
              ),
              elevation: 0,
              color: Colors.blue,
              onPressed: onSendCode,
              child: Container(
                width: double.infinity,
                child: state.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ))
                    : Text(
                        'GET OTP',
                        style: TextStyle(
                          fontSize: 18,
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
                "Don't have an account?",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            FlatButton(
              onPressed: () {},
              child: Container(
                width: double.infinity,
                child: Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 18,
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
              'ENTER OTP',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'OTP sent to ' + this._loginBloc.emailEditController.text,
              style: TextStyle(
                color: Colors.black45,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: this._loginBloc.otpEditController,
              style: TextStyle(
                color: Colors.black87,
              ),
              cursorColor: Colors.black87,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(80, 233, 233, 233),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(
                      color: Colors.white,
                      style: BorderStyle.solid,
                    )),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(
                      color: Colors.white,
                      style: BorderStyle.solid,
                    )),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(
                      color: Colors.white,
                      style: BorderStyle.solid,
                    )),
                labelText: 'Enter OTP',
                labelStyle: TextStyle(
                  color: Colors.black54,
                ),
              ),
              validator: (String value) {
                return value.length < 1 ? 'Please enter a valid otp.' : null;
              },
            ),
            const SizedBox(height: 20),
            RaisedButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0)),
              padding: EdgeInsets.symmetric(
                vertical: 15,
              ),
              elevation: 0,
              color: Colors.blue,
              onPressed: onLoginWithOtp,
              child: Container(
                width: double.infinity,
                child: state.isSubmitOtp
                    ? Center(
                        child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ))
                    : Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 18,
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
                "Didn't receive OTP?",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            FlatButton(
              onPressed: () {
                /*...*/
              },
              child: Container(
                width: double.infinity,
                child: Text(
                  "Resend OTP",
                  style: TextStyle(
                    fontSize: 18,
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
}