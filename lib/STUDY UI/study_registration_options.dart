import 'package:flutter_svg/svg.dart';
import 'package:recommendation/STUDY%20UI/study_registration_phone.dart';
import 'package:recommendation/source.dart';

class StudyRegistrationOptions extends StatefulWidget {
  StudyRegistrationOptions({Key? key}) : super(key: key);

  @override
  _StudyRegistrationOptionsState createState() =>
      _StudyRegistrationOptionsState();
}

class _StudyRegistrationOptionsState extends State<StudyRegistrationOptions> {
  final ValueNotifier<bool> showContinueButton = ValueNotifier<bool>(false);
  final ValueNotifier<String> selectedOption = ValueNotifier<String>('None');
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
              _buildOptions('Phone',  'images/phone.svg'),
              _buildOptions('Google', 'images/google.svg'),
              _buildOptions('Facebook', 'images/facebook.svg'),
              _buildContinueButton(context)
            ],
          )),
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
        text('Registration Methods',
            size: 24, color: Colors.white.withOpacity(.85)),
        SizedBox(height: 20),
        text('Create an account via:',
            family: 'Regular', size: 22, color: Colors.white),
        SizedBox(height: 60)
      ],
    );
  }

  _buildOptions(String option, String icon) {
    return ValueListenableBuilder<String>(
        valueListenable: selectedOption,
        builder: (context, child, snapshot) {
          return Container(
            margin: EdgeInsets.only(bottom: 20),
            child: MaterialButton(
                minWidth: double.maxFinite,
                onPressed: () {
                  selectedOption.value = option;
                  showContinueButton.value = true;
                },
                color: selectedOption.value == option
                    ? Color(0xffF88379)
                    : Colors.white70,
                height: 45,
                child: Row(children: [
                  SizedBox(width: 10),
                  SvgPicture.asset(icon, height: 24, width:24, color:Colors.black),
                //  Icon(icon, color: color,),
                  Expanded(child: Center(child: text(option,family:'Akaya')))
                ])),
          );
        });
  }

  _buildContinueButton(BuildContext context) {
    return Expanded(
        child: ValueListenableBuilder<bool>(
            valueListenable: showContinueButton,
            builder: (context, child, snapshot) {
              if (showContinueButton.value) {
                return ValueListenableBuilder<String>(
                    valueListenable: selectedOption,
                    builder: (context, child, snapshot) {
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MaterialButton(
                              height: 40,
                              minWidth: double.maxFinite,
                              onPressed: () {
                                if (selectedOption.value == 'Phone') {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              StudyRegistrationByPhone()));
                                }
                              },
                              color: Color(0xffECD5BB),
                              child: text('Continue'),
                            ),
                            SizedBox(height: 20),
                          ]);
                    });
              } else {
                return Container();
              }
            }));
  }
}
