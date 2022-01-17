import 'package:recommendation/STUDY%20UI/finish_registration_process.dart';
import 'package:recommendation/source.dart';
import 'package:flutter/foundation.dart';

class StudyPhoneVerification extends StatefulWidget {
  const StudyPhoneVerification();

  @override
  _StudyPhoneVerificationState createState() => _StudyPhoneVerificationState();
}

class _StudyPhoneVerificationState extends State<StudyPhoneVerification> {
  static TextEditingController _controller1 = TextEditingController();
  static TextEditingController _controller2 = TextEditingController();
  static TextEditingController _controller3 = TextEditingController();
  static TextEditingController _controller4 = TextEditingController();
  static TextEditingController _controller5 = TextEditingController();
  static TextEditingController _controller6 = TextEditingController();
  final ValueNotifier<bool> showVerifyButton = ValueNotifier<bool>(false);
  String phoneNumber = '';

  @override
  void initState() {
    _controller1.clear();
    _controller2.clear();
    _controller3.clear();
    _controller4.clear();
    _controller5.clear();
    _controller6.clear();
    getUserDetails();
    super.initState();
  }

  getUserDetails() async {
    String sqlPhoneNumber = await sql.getValueFromDatabase('PhoneNumber');
    setState(() {
      phoneNumber = sqlPhoneNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF202024),
      body: Container(
        padding: EdgeInsets.all(15),
        child: StreamBuilder<String>(
            stream: verifyBloc.phoneVerificationReportStream,
            builder: (context, reportSnapshot) {
              String? event = reportSnapshot.data;
              if (event == report.sendingCode) {
                return sharedWidget.indicator('sending code ...');
              } else if (event == report.codeSent) {
                return Column(
                  children: [
                    _buildTitle(context),
                    _buildVerificationTextFields(),
                    _buildSendNewCode(),
                    _buildVerify(context)
                  ],
                );
              } else if (event == report.verifying) {
                return sharedWidget.indicator('verifying ...');
              } else if (event == report.verified) {
                WidgetsBinding.instance?.addPostFrameCallback(
                  (_) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FinishRegistrationProcess(),
                    ),
                  ),
                );
              } else if (event == report.verificationFailed) {
                verifyBloc.phoneVerificationReportSink.add(report.codeSent);

                WidgetsBinding.instance?.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.white,
                      content: text(
                          'Verification failed! Please fill the code sent in your device correctly.',
                          color: Colors.black54)));
                });
              } else {
                return sharedWidget.indicator('Sending code ...');
              }

              return Container();
            }),
      ),
    );
  }



  _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 50),
        InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(EvaIcons.arrowBack, color: Colors.white)),
        SizedBox(height: 10),
        text('VERIFICATION',
            family: 'Medium', size: 24, color: Colors.white.withOpacity(.85)),
        SizedBox(height: 15),
        text('We sent you a code to verify your number',
            family: 'Regular', size: 20, color: Colors.white.withOpacity(.75)),
        SizedBox(height: 10),
        Row(
          children: [
            text('sent to $phoneNumber',
                family: 'Light', size: 18, color: Colors.white.withOpacity(.7)),
            SizedBox(width: 10),
            text(
              'Wrong Number?',
              family: 'Light',
              color: Color(0xffECD5BB),
              size: 18,
            )
          ],
        ),
        SizedBox(height: 40)
      ],
    );
  }

  _buildSendNewCode() {
    return Column(
      children: [
        SizedBox(height: 45),
        Row(
          children: [
            text('Didn\'t get it?',
                family: 'Light', size: 18, color: Colors.white.withOpacity(.9)),
            SizedBox(width: 10),
            text(
              'Get a new code',
              family: 'Regular',
              color: Color(0xffECD5BB),
              size: 18,
            )
          ],
        ),
      ],
    );
  }

  _buildVerificationTextFields() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
          itemCount: 6,
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return SizedBox(
                height: 50,
                width: 65,
                child: TextField(
                  controller: index == 0
                      ? _controller1
                      : index == 1
                          ? _controller2
                          : index == 2
                              ? _controller3
                              : index == 3
                                  ? _controller4
                                  : index == 4
                                      ? _controller5
                                      : _controller6,
                 
                  style: TextStyle(
                      color: Color(0xffFBE5C0),
                      fontFamily: 'Akaya',
                      fontSize: 22,
                      decoration: TextDecoration.none),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.grey.withOpacity(.1),
                      prefixStyle: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Akaya',
                          fontSize: 18),
                      hintText: '#',
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Akaya',
                          fontSize: 18),
                      focusColor: Colors.red),
                  onChanged: (value) {
                    if (value.length == 1) {
                      if (index == 5) {
                        FocusScope.of(context).unfocus();
                        String value = _controller1.text.trim() +
                            _controller2.text.trim() +
                            _controller3.text.trim() +
                            _controller4.text.trim() +
                            _controller5.text.trim() +
                            _controller6.text.trim();
                        sql.updateDataInDatabase('Otp', value);
                        showVerifyButton.value = true;
                      } else {
                        FocusScope.of(context).nextFocus();
                      }
                    }
                  },
                ));
          }),
    );
  }

  _buildVerify(BuildContext context) {
    return Expanded(
        child: ValueListenableBuilder<bool>(
            valueListenable: showVerifyButton,
            builder: (context, child, snapshot) {
              if (showVerifyButton.value) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MaterialButton(
                        height: 40,
                        minWidth: double.maxFinite,
                        onPressed: () {
                          authFunction.signIn();
                        },
                        color: Color(0xffECD5BB),
                        child: text('Verify'),
                      ),
                    ]);
              } else {
                return Container();
              }
            }));
  }
}
