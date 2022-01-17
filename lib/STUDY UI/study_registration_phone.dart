import 'package:recommendation/STATE/rating_bloc.dart';
import 'package:recommendation/STUDY%20UI/study_verification_phone.dart';
import 'package:recommendation/source.dart';

class StudyRegistrationByPhone extends StatefulWidget {
  StudyRegistrationByPhone({Key? key}) : super(key: key);

  @override
  StudyRegistrationByPhoneState createState() =>
      StudyRegistrationByPhoneState();
}

class StudyRegistrationByPhoneState extends State<StudyRegistrationByPhone> {
  @override
  void initState() {
    initializeDatabase();
    super.initState();
  }

  initializeDatabase() async {
    await sql.createDatabase();
    await sql.insertDataIntoDatabase('hello', 'hello', 'hello', 'hello');
  }

  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();
  final ValueNotifier<bool> showSubmitButton = ValueNotifier<bool>(false);
  final ValueNotifier<bool> showPhoneTextfields = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF202024),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            _buildNameTextField(),
            _buildPhoneTextField(),
            _buildSubmit()
          ],
        ),
      ),
    );
  }

  _buildTitle() {
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
        text('REGISTRATION',
            family: 'Medium', size: 24, color: Colors.white.withOpacity(.85)),
        SizedBox(height: 30),
      ],
    );
  }

  _buildNameTextField() {
    return Container(
        height: 70,
        child: TextFormField(
          controller: _controller1,
          autofocus: true,
          style: TextStyle(
              color: Color(0xffFBE5C0),
              fontFamily: 'Akaya',
              fontSize: 22,
              decoration: TextDecoration.none),
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.grey.withOpacity(.2),
              prefixStyle: TextStyle(
                  color: Colors.white, fontFamily: 'Akaya', fontSize: 18),
              hintText: 'Username',
              hintStyle: TextStyle(
                  color: Colors.grey, fontFamily: 'Akaya', fontSize: 18),
              focusColor: Colors.red),
          onEditingComplete: () async {
            showPhoneTextfields.value = true;
            await sql.updateDataInDatabase('Name', _controller1.text);
            FocusScope.of(context).nextFocus();
          },
        ));
  }

  _buildPhoneTextField() {
    return Container(
      height: 50,
      margin: EdgeInsets.only(top: 15),
      child: Row(
        children: [
          Container(
              height: 50,
              alignment: Alignment.center,
              //    color: Colors.grey.withOpacity(.3),
              child: text(
                ' +255 (0) ',
                color: Colors.white.withOpacity(.9),
              )),
          ValueListenableBuilder(
              valueListenable: showPhoneTextfields,
              builder: (context, child, snapshot) {
                if (showPhoneTextfields.value) {
                  return Expanded(
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return SizedBox(
                              height: 50,
                              width: index == 0
                                  ? 85
                                  : index == 1
                                      ? 95
                                      : 135,
                              child: TextFormField(
                                controller: index == 0
                                    ? _controller2
                                    : index == 1
                                        ? _controller3
                                        : _controller4,
                                autofocus: true,
                                style: TextStyle(
                                    color: Color(0xffFBE5C0),
                                    letterSpacing: 10,
                                    fontFamily: 'Akaya',
                                    fontSize: 22,
                                    decoration: TextDecoration.none),
                                textAlign: index == 0
                                    ? TextAlign.center
                                    : TextAlign.start,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(.2),
                                    border: InputBorder.none,
                                    prefixText: index == 0 ? '' : '- ',
                                    prefixStyle: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Akaya',
                                        fontSize: 18),
                                    hintText: index == 0
                                        ? 'XXX'
                                        : index == 1
                                            ? 'XXX'
                                            : 'XXX',
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        letterSpacing: 7,
                                        fontFamily: 'Akaya',
                                        fontSize: 18),
                                    focusColor: Colors.red),
                                onChanged: (value) {
                                  if (value.length == 3) {
                                    if (index == 2) {
                                      FocusScope.of(context).unfocus();
                                      showSubmitButton.value = true;
                                    } else {
                                      FocusScope.of(context).nextFocus();
                                    }
                                  }
                                },
                              ),
                            );
                          }));
                } else {
                  return Expanded(
                    child: Container(
                        color: Colors.grey.withOpacity(.2),
                        height: 50,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 10),
                        child: text('Phone Number',
                            family: 'Akaya', color: Colors.grey, size: 18)),
                  );
                }
              })
        ],
      ),
    );
  }

  _buildSubmit() {
    return Expanded(
        child: ValueListenableBuilder<bool>(
            valueListenable: showSubmitButton,
            builder: (context, child, snapshot) {
              if (showSubmitButton.value) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MaterialButton(
                        height: 40,
                        minWidth: double.maxFinite,
                        onPressed: () async {
                          String phoneNumber = '+255' +
                              _controller2.text.trim() +
                              _controller3.text.trim() +
                              _controller4.text.trim();
                          await sql.updateDataInDatabase(
                              'PhoneNumber', phoneNumber);
                          verifyBloc.phoneVerificationEventsSink
                              .add(PhoneVerificationEvents.start);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      StudyPhoneVerification()));
                        },
                        color: Color(0xffECD5BB),
                        child: text('Submit'),
                      ),
                      SizedBox(height: 5),
                      text(
                          'Submitting means you have read and understood our Privacy Policy',
                          family: 'Light',
                          color: Colors.white70,
                          size: 17),
                      SizedBox(height: 20),
                    ]);
              } else {
                return Container();
              }
            }));
  }
}
