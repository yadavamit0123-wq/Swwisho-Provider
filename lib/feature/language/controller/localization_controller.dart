import 'package:demandium_provider/utils/core_export.dart';
import 'package:get/get.dart';

class LocalizationController extends GetxController implements GetxService {
  late SharedPreferences sharedPreferences;
  late ApiClient apiClient;

  LocalizationController({required this.sharedPreferences, required this.apiClient}) {
    loadCurrentLanguage();
  }


  Locale _locale = Locale(AppConstants.languages[0].languageCode!, AppConstants.languages[0].countryCode);
  bool _isLtr = true;
  List<LanguageModel> _localLanguages = [];

  Locale get locale => _locale;
  bool get isLtr => _isLtr;
  List<LanguageModel> get localLanguages => _localLanguages;

  void setLanguage(Locale locale, {bool isInitial = false}) {
    Get.updateLocale(locale);
    _locale = locale;
    if(_locale.languageCode == 'ar') {
      _isLtr = false;
    }else {
      _isLtr = true;
    }

    try {
    }catch(e) {
      if (kDebugMode) {
        print("");
      }
    }
    saveLanguage(locale);

    apiClient.updateHeader(sharedPreferences.getString(AppConstants.token), locale.languageCode);
    if(Get.find<AuthController>().isLoggedIn()){
      Get.find<BusinessSettingController>().getBookingSettingsDataFromServer();
    }
    Get.find<SplashController>().updateLanguage(isInitial);
    update();
  }

  void loadCurrentLanguage() async {
    _localLanguages = [];
    _localLanguages.addAll(AppConstants.languages);
    filterLanguage(isInitial: true);
    update();
  }

  void saveLanguage(Locale locale) async {
    sharedPreferences.setString(AppConstants.languageCode, locale.languageCode);
    sharedPreferences.setString(AppConstants.countryCode, locale.countryCode ?? '');
  }

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectIndex(int index) {
    _selectedIndex = index;
    update();
  }


  void filterLanguage({bool shouldUpdate = true, bool isChooseLanguage = false, bool isInitial = false}) {
    _localLanguages = [];
    _localLanguages.addAll(AppConstants.languages);

    _selectedIndex = 0;
    final savedCode = sharedPreferences.getString(AppConstants.languageCode);
    for (int index = 0; index < _localLanguages.length; index++) {
      if (_localLanguages[index].languageCode == savedCode) {
        _selectedIndex = index;
        break;
      }
    }

    if (_localLanguages.isNotEmpty) {
      _locale = Locale(
        _localLanguages[_selectedIndex].languageCode!,
        _localLanguages[_selectedIndex].countryCode,
      );
      _isLtr = _locale.languageCode != 'ar';
    }

    if (shouldUpdate) {
      update();
    }
  }
}