import 'package:demandium_provider/utils/core_export.dart';
import 'package:get/get.dart';

class ReviewLinearChart extends StatelessWidget {
  final Rating rating;
  const ReviewLinearChart({super.key,required this.rating});

  @override
  Widget build(BuildContext context) {

    double fiveStar = 0.0, fourStar = 0.0, threeStar = 0.0,twoStar = 0.0, oneStar = 0.0;
    final groups = rating.ratingGroupCount ?? [];
    final ratingCount = rating.ratingCount ?? 0;
    for(int i =0 ; i< groups.length; i++)
    {
      final reviewRating = groups[i].reviewRating ?? 0;
      if(reviewRating == 1){
        oneStar = (reviewRating * ratingCount) / 100;
      }
      if(reviewRating == 2){
        twoStar = (reviewRating * ratingCount) / 100;
      }
      if(reviewRating == 3){
        threeStar = (reviewRating * ratingCount) / 100;
      }
      if(reviewRating == 4){
        fourStar = (reviewRating * ratingCount) / 100;
      }
      if(reviewRating == 5){
        fiveStar = (reviewRating * ratingCount) / 100;
      }
    }
    return Column(
      children: [
        ProgressBar(
          title: 'excellent'.tr,
          color: const Color(0xFF69B469),
          percent: fiveStar,
        ),
        ProgressBar(
          title: 'good'.tr,
          color: const Color(0xFFB0DC4B),
          percent: fourStar,
        ),
        ProgressBar(
          title: 'average'.tr,
          color: const Color(0xFFFFC700),
          percent: threeStar,
        ),
        ProgressBar(
          title: 'below_average'.tr,
          color: const Color(0xFFF7A41E),
          percent: twoStar,
        ),
        ProgressBar(
          title: 'poor'.tr,
          color: const Color(0xFFFF2828),
          percent: oneStar,
        ),
      ],
    );
  }
}
