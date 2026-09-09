import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class SubCategoryView extends StatelessWidget {

  final List<ServiceSubCategoryModel> subCategoryList;
  const SubCategoryView({super.key, required this.subCategoryList});
  @override
  Widget build(BuildContext context) {
    return subCategoryList.isEmpty &&  !Get.find<ServiceCategoryController>().isSubCategoryLoading ?
    Center(
      child: Text("no_sub_category_found".tr,
        style: robotoMedium.copyWith(
          fontSize: 16,
          color: Theme.of(context).primaryColorLight,
        ),
      ),
    ) : Get.find<ServiceCategoryController>().isSubCategoryLoading ? const SubCategoryItemShimmer() :

    Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveHelper.isTab(context)?2:1,
              mainAxisExtent: 170,
            ),
            controller: Get.find<ServiceCategoryController>().scrollController,
            itemCount: subCategoryList.length,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              int totalService = 0;
              for (var element in subCategoryList[index].services!) {
                if(element.isActive==1){
                  totalService ++;
                }
              }
              return GetBuilder<ServiceCategoryController>(
                builder: (allServiceController) {
                  return Container(
                    margin: const EdgeInsets.fromLTRB(5, 2, 10,8),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                    boxShadow: shadow,
                    borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeExtraSmall))),
                    child: InkWell(
                      onTap: (){
                        Get.to(ServicesScreen(
                          subcategoryModel: allServiceController.serviceSubCategoryList[index],
                          fromPage: 'category',
                          index: index,
                        ));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          const SizedBox(height: Dimensions.paddingSizeSmall,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width:Dimensions.paddingSizeDefault),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CustomImage(
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                  image: '${subCategoryList[index].imageFullPath}',
                                ),
                              ),

                             const SizedBox(width:Dimensions.paddingSizeSmall),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(subCategoryList[index].name.toString(),
                                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height:Dimensions.paddingSizeExtraSmall -2),
                                    Text(subCategoryList[index].description.toString(),
                                      textAlign: TextAlign.justify,
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall-1,
                                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha:0.5),
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width:Dimensions.paddingSizeSmall),
                            ],
                          ),


                           const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                             child: Divider(thickness: 0.5, color: Theme.of(context).hintColor,),
                           ),

                          Row(
                            children: [

                              Expanded(
                                flex: 2,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                      minimumSize: const Size(1, 40),
                                      backgroundColor: Colors.transparent
                                  ),
                                  onPressed: () => Get.to(ServicesScreen(
                                    subcategoryModel: allServiceController.serviceSubCategoryList[index],
                                    fromPage: 'category',
                                    index: index,
                                  )),
                                  child: Text("${'services'.tr} ($totalService)",
                                    style: robotoRegular.copyWith(
                                        fontSize: Get.width < 350 ? Dimensions.fontSizeSmall - 2 : Dimensions.fontSizeDefault,
                                        decoration: TextDecoration.underline, color: Theme.of(context).primaryColorLight,
                                    ),
                                  ),
                                ),
                              ),

                              Expanded(
                                flex: 3,
                                child: GetBuilder<ServiceCategoryController>(
                                  builder: (allService) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                            side:  BorderSide.none,
                                          ),
                                          minimumSize: Size.zero,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                          disabledBackgroundColor: Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha:0.3),
                                          backgroundColor: subCategoryList[index].isSubscribed == 1
                                              ? Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha:0.3)
                                              : Theme.of(context).primaryColor,
                                        ),
                                        onPressed: (subCategoryList[index].isSubscribed == 1 || subCategoryList[index].isSubscribed == 3) ? null : () {
                                          
                                          Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrail){
                                            if(isTrail){
                                              int? isSubscribe = subCategoryList[index].isSubscribed;
                                              showCustomBottomSheet(child: SubscribeUnsubscribeBottomSheet(
                                                isSubscribe: isSubscribe == 1 ? true : false,
                                                subCategoryModel : subCategoryList[index],
                                                index: index, fromPage: 'category',
                                              ),);
                                            }
                                          });

                                        },
                                        child: Text(
                                          subCategoryList[index].isSubscribed == 1
                                              ? "already_subscribed".tr
                                              : subCategoryList[index].isSubscribed == 3 ? 'pending'.tr
                                              : "subscribe".tr,
                                          style: robotoRegular.copyWith(
                                            color:  subCategoryList[index].isSubscribed == 1 ? Theme.of(context).colorScheme.onSecondaryContainer : Colors.white,
                                            fontSize: Get.width < 350 ? Dimensions.fontSizeSmall - 2 : Dimensions.fontSizeSmall,
                                          ),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Get.find<ServiceCategoryController>().isPaginationLoading?
        CircularProgressIndicator(color: Theme.of(context).hoverColor)
            :const SizedBox.shrink()
      ],
   );
  }
}
