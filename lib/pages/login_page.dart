import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';


class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool isOtpSent = false;

  final _phone = new MaskedTextController(mask: '+7 (000) 000-00-00');
  final _otp = new TextEditingController();

  final _phoneForm = GlobalKey<FormState>();

  var _phoneFocusNode = new FocusNode();
  var _otpFocusNode = new FocusNode();

  var verificationId;

  FirebaseAuth _fbAuth;
  String _message = "Для входа в приложение введите свой номер телефона с кодом страны (Россия: +7)";

  String _phoneNumber = 'assets/images/phone.svg';

  @override
  void initState() {
    super.initState();
    _fbAuth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              Form(
                key: _phoneForm,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      margin: new EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Для входа в приложение введите свой номер телефона с кодом страны (Россия: +7)',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    new Container(
                      margin: new EdgeInsets.symmetric(horizontal: 20),
                      child: _buildPhoneField(),
                    ),
                    isOtpSent
                        ? _getOtpBox()
                        : SizedBox(
                      height: 30,
                    ),
                    _buildButton(),

                    SizedBox(height: 40),
                    _isLoading
                        ? SizedBox(
                      height: 100,
                      width: 100,
                      child: new CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                          strokeWidth: 5.0),
                    )
                        : SizedBox()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _getOtpBox() {
    return new Column(
      children: <Widget>[
        new Container(
          margin: new EdgeInsets.only(top: 10),
          child: Center(
            child: _buildResetPhone(),
          ),
        ),
        new Text('или', textAlign: TextAlign.center,),
        new Container(
            margin: new EdgeInsets.only(bottom: 20.0),
            child: new Center(
              child: _buildResetOpt(),
            )
        ),
        new Container(
          margin: new EdgeInsets.symmetric(horizontal: 20.0),
          child: _buildOptInputField(),
        ),
      ],
    );
  }

  _sendOtp(checkForm) {
    if (!_isLoading && (checkForm || _phoneForm.currentState.validate())) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');


      setState(() {
        _otp.text = "";
      });
      setState(() {
        _isLoading = true;
      });

      final PhoneVerificationCompleted verificationCompleted =
          (AuthCredential phoneAuthCredential) {
        _fbAuth.signInWithCredential(phoneAuthCredential);

        setState(() {
          Navigator.pushNamed(context, '/home');
          _message = "Sign in suceed!";
          _isLoading = false;
        });
      };

      final PhoneVerificationFailed verificationFailed =
          (AuthException authException) {
        setState(() {
          _message = "${authException.message}";
          _isLoading = false;
        });
      };

      final PhoneCodeSent codeSent =
          (String verificationId, [int forceResendingToken]) async {
        this.verificationId = verificationId;
        setState(() {
          _message =
          "Код подтверждения отправлен на номер:";
          isOtpSent = true;
          _isLoading = false;
          FocusScope.of(context).requestFocus(_otpFocusNode);
        });
      };

      final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
          (String verificationId) {
        this.verificationId = verificationId;
        _isLoading = false;
      };

      _fbAuth.verifyPhoneNumber(
          phoneNumber: _phone.text,
          timeout: Duration(seconds: 60),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    }
  }

  _verifyOtp() async {

//    await new Future.delayed(const Duration(seconds: 3));

    if (!_isLoading && _phoneForm.currentState.validate()) {

      setState(() {
        _isLoading = true;
      });

      SystemChannels.textInput.invokeMethod('TextInput.hide');


      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: _otp.text,
      );

      final FirebaseUser user = (await _fbAuth.signInWithCredential(credential)).user;
      final FirebaseUser currentUser = await _fbAuth.currentUser();
      assert(user.uid == currentUser.uid);

      if (!mounted) return;

      setState(() {
        if (user != null) {
          _message = 'Successfully signed in, uid: ' + user.uid;
        } else {
          _message = 'Sign in failed';
        }
      });

    }

  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _phone.dispose();
    _otp.dispose();
  }

  static showFailureSnackBar({BuildContext context, String message}) {
    Scaffold.of(context).showSnackBar(
        SnackBar(content: Text('$message'), backgroundColor: Colors.red));
  }

  _checkValidation(String value) {
    return value.length < 10
        ? "Пожалуйста, укажите правильный номер!"
        : value[0] == "\+" ? null : "Пожалуйста, укажите код страны (Россия: +7)!";
  }


  Widget _buildButton() {
    return new Container(
      height: 50,
      width: 200,
      child: new FlatButton(
        onPressed: () => isOtpSent ? _verifyOtp() : _sendOtp(false),
        color: Theme.of(context).primaryColor,
        child: new Text(isOtpSent ? "ВОЙТИ" : "ПОЛУЧИТЬ КОД", style: new TextStyle(fontSize: 16, color: Colors.white),),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return new TextFormField(
      controller: _phone,
      focusNode: _phoneFocusNode,
      maxLines: 1,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.phone,
      enabled: !isOtpSent,
      autofocus: false,
      onFieldSubmitted: (term) {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        isOtpSent ? _verifyOtp() : _sendOtp(false);
      },
      decoration: new InputDecoration(
        hintText: '+7 (xxx) xxx-xx-xx',
        prefixIcon: new Icon(Icons.phone, color: Theme.of(context).primaryColor),
      ),
      validator: (value) => value.isEmpty
          ? 'Телефон не может быть пустым'
          : _checkValidation(value),
    );
  }

  Widget _buildOptInputField() {
    return new Container(
      margin: new EdgeInsets.symmetric(horizontal: 20),
      child: new TextFormField(
        controller: _otp,
        focusNode: _otpFocusNode,
        maxLines: 1,
        maxLength: 6,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.number,
        autofocus: false,
        onFieldSubmitted: (term) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          isOtpSent ? _verifyOtp() : _sendOtp(false);
        },
        decoration: new InputDecoration(
          labelText: 'Код',
          hintText: 'Введите 6-значный код подтверждения',
//            prefixIcon: new Icon(
//              Icons.message,
//              color: Colors.black,
//            ),
        ),
        validator: (value) => value.isEmpty
            ? 'Одноразовый пароль не может быть пустым'
            : (value.length != 6 ? 'Пожалуйста, введите 6-значный правильный номер' : null),
      ),
    );
  }

  Widget _buildResetOpt() {
    return new FlatButton(
      child: Text("Отправить код повторно", style: new TextStyle(color: Theme.of(context).primaryColor),),
      onPressed: () {
        _sendOtp(true);
      },
    );
  }

  Widget _buildResetPhone() {
    return new FlatButton(
      child: Text("Сменить номер"),
      onPressed: () {
        setState(() {
          _message =
          "Для входа в приложение введите свой номер телефона с кодом страны (Россия: +7)";
          _otp.text = "";
          isOtpSent = false;
          _isLoading = false;
          FocusScope.of(context).requestFocus(_phoneFocusNode);
        });
      },
    );
  }
}
