import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';


class ReviewController extends GetxController implements GetxService{
  final ReviewRepo reviewRepo;
  ReviewController({required this.reviewRepo});

  int? _pageSize;
  int _offset = 1;

  int get offset => _offset;
  int? get pageSize => _pageSize;

  bool _isLoading= false;
  bool get isLoading => _isLoading;

  List<Review>? _providerReviewList;
  List<Review>? get providerReviewList => _providerReviewList;

  Rating? _providerRating;
  Rating? get providerRating => _providerRating;


  List<Review>? _serviceReviewList = [];
  List<Review>? get serviceReviewList => _serviceReviewList!;

  Rating? _serviceRating;
  Rating? get serviceRating => _serviceRating;

  final ScrollController scrollController = ScrollController();


  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if(scrollController.position.maxScrollExtent == scrollController.position.pixels) {
        if(_offset < _pageSize! ) {
          getProviderReview(offset+1, isLoading: true);
        }
      }
    });
  }

  Future<void> getProviderReview(int offset,{bool isLoading = false}) async {
    _offset = offset;
    if(isLoading){
      _isLoading = true;
      update();
    }
    try {
      Response response = await reviewRepo.getProviderReviewList(offset);
      if (response.statusCode == 200 && response.body['response_code'] == 'default_200') {
        final content = response.body['content'];
        final reviews = content is Map ? content['reviews'] : null;
        _pageSize = int.tryParse(reviews is Map ? reviews['last_page']?.toString() ?? '' : '') ?? 1;
        if(offset == 1 ){
          _providerReviewList =[];
          _providerRating = null;
        }
        _providerReviewList ??= [];
        final data = reviews is Map ? reviews['data'] : null;
        if (data is List) {
          for (final review in data) {
            try {
              if (review is Map) {
                _providerReviewList!.add(Review.fromJson(Map<String, dynamic>.from(review)));
              }
            } catch (_) {}
          }
        }
        try {
          if (content is Map && content['rating'] is Map) {
            _providerRating = Rating.fromJson(Map<String, dynamic>.from(content['rating']));
          }
        } catch (_) {}
      } else {
        _providerReviewList =[];
        _providerRating = null;
      }
    } catch (_) {
      _providerReviewList ??= [];
    }
    _isLoading = false;
    update();
  }


  Future<void> getServiceReview(String serviceID) async {
    _serviceReviewList =[];
    _serviceRating=null;
    Response response = await reviewRepo.getServiceReviewList(serviceID,1);
    if (response.statusCode == 200 && response.body['response_code'] ==  'default_200') {
      try{
        final data = response.body['content'] is Map ? response.body['content']['reviews'] : null;
        final list = data is Map ? data['data'] : null;
        if (list is List) {
          for (final review in list) {
            try {
              if (review is Map) {
                _serviceReviewList!.add(Review.fromJson(Map<String, dynamic>.from(review)));
              }
            } catch (_) {}
          }
        }
      }catch(error){
        if (kDebugMode) {
          print('error : $error');
        }
      }
      try{
        _serviceRating = Rating.fromJson(response.body['content']['rating']);
      }catch(error){
        if (kDebugMode) {
          print('rating get error : $error');
        }
      }
    } else {
      //ApiChecker.checkApi(response);
    }
  }

  Future<ResponseModel> replyReview ({required String reviewId, required String reviewContent, String? fromPage, String? serviceId}) async {
    _isLoading = true;
    update();
    Response  response = await reviewRepo.replyReview(reviewId: reviewId, reviewContent: reviewContent);
    ResponseModel responseModel;
    if(response.statusCode == 200){
      if (fromPage == "service" && serviceId !=null){
         await getServiceReview(serviceId);
      }else{
        await getProviderReview(1);
      }
      responseModel = ResponseModel(true, "success");
    }else{
      responseModel = ResponseModel(false, response.body['message'] ?? "failed");
    }
    _isLoading = false;
    update();

    return responseModel;
  }

}