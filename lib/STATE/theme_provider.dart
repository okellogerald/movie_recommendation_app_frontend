import 'package:recommendation/source.dart';

class ThemeProvider extends ChangeNotifier {
  String theme = 'Light';

  void toggleThemes() {
    theme = theme == 'Light' ? 'Dark' : 'Light';
    notifyListeners();
  }
}

class ThemesColors {
  String theme;
  //late here means i don't initialize these variables now but will definitely intialize them later.
  late Color scaffoldColor,
      backgroundColor,
      textColor1,
      textColor2,
      logoTextColor,
      buttonInactiveColor,
      iconColor,
      indicatorColor,
      specialButtonColor,
      specialTextColor,
      buttonActiveColor;

  ThemesColors(this.theme) {
    bool lightMode = theme == 'Light' ? true : false;
    scaffoldColor = lightMode ? Color(0xffF2F2F2) : Color(0xff2E2E2E);
    logoTextColor = Color(0xffCDCECD);
    textColor1 = lightMode ? Color(0xff141414) : Color(0xffF2F2F2);
    specialButtonColor = lightMode ? Colors.orange : Colors.orange;
    iconColor = lightMode ? Colors.black87 : Colors.white.withOpacity(.85);
    textColor2 = lightMode ? Colors.white : Colors.black;
    indicatorColor = lightMode ? Colors.black : Colors.white;
    specialTextColor = !lightMode ? Color(0xffFFF3D9) : Color(0xff090F22);
    buttonInactiveColor = lightMode ? Color(0xffBAB9B8) : Color(0xff373737);
    buttonActiveColor = Color(0xffFB3A3D);
    backgroundColor = lightMode ? Color(0xffF2F2F2) : Color(0xff2E2E2E);
  }
}
