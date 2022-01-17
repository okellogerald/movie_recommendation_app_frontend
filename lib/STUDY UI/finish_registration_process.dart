import 'package:recommendation/STUDY%20UI/study_ratingpage.dart';
import 'package:recommendation/STUDY%20UI/study_recommendations.dart';
import 'package:recommendation/source.dart';

class FinishRegistrationProcess extends StatefulWidget {
  FinishRegistrationProcess({Key? key}) : super(key: key);

  @override
  _FinishRegistrationProcessState createState() =>
      _FinishRegistrationProcessState();
}

class _FinishRegistrationProcessState extends State<FinishRegistrationProcess> {
  String phoneNumber = '', username = '';

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  getUserDetails() async {
    String sqlPhoneNumber = await sql.getValueFromDatabase('PhoneNumber');
    String sqlUsername = await sql.getValueFromDatabase('Name');
    setState(() {
      phoneNumber = sqlPhoneNumber;
      username = sqlUsername;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF202024),
      body: Container(
        padding: EdgeInsets.all(15),
        child: FutureBuilder(
            future: studyFunction.addUserDetails(
                name: username, phoneNumber: phoneNumber),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: _buildIndicator('saving data ...'),
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                                height: 150,
                                width: 150,
                                margin: EdgeInsets.only(bottom: 60),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 2, color:Color(0xffFB3A3D))),
                                child: Icon(EvaIcons.checkmark,
                                    color: Colors.grey, size: 40)),
                            text('All Done.', color: Colors.white),
                          ],
                        )),
                    Expanded(
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        child: MaterialButton(
                            color: Color(0xffECD5BB),
                            height: 40,
                            minWidth: double.maxFinite,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RecommendationsUI()));
                            },
                            child: text('Start Rating')),
                      ),
                    ),
                  ],
                );
              }
            }),
      ),
    );
  }

  _buildIndicator(String message) {
    return Column(
      children: [
        Expanded(
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Color(0xffFB3A3D)),
              ),
              SizedBox(height: 40),
              text(message, color: Colors.white)
            ])))
      ],
    );
  }
}
