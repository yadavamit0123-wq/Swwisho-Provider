import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';
import 'package:demandium_provider/feature/html/model/pages_model.dart';

class HtmlViewController extends GetxController implements GetxService{
  final HtmlRepository htmlRepository;
  HtmlViewController({required this.htmlRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _loadFailed = false;
  bool get loadFailed => _loadFailed;
  String ? _htmlPage;
  String? get htmlPage => _htmlPage;
  PagesContent? _pagesContent;
  PagesContent? get pagesContent => _pagesContent;

  Future<void> getPagesContent({bool forceReload = false}) async {
    if (_pagesContent != null && !forceReload) {
      return;
    }
    _isLoading = true;
    _loadFailed = false;
    update();
    try {
      Response response = await htmlRepository.getPagesContent();
      if(response.statusCode == 200){
        _pagesContent = PagesContent.fromJson(response.body['content']);
        _loadFailed = false;
      }else{
        _loadFailed = true;
        ApiChecker.checkApi(response);
      }
    } catch (_) {
      _loadFailed = true;
    } finally {
      _isLoading = false;
      update();
    }
  }
}
