import 'package:demandium_provider/utils/core_export.dart';

class ServiceSearchWidget extends StatelessWidget {
  final String subcategoryId;

  const ServiceSearchWidget({super.key, required this.subcategoryId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceCategoryController>(
      builder: (serviceCategoryController) {
        return TextField(
          controller: serviceCategoryController.searchController,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).textTheme.bodyLarge!.color,
            fontSize: Dimensions.fontSizeDefault,
          ),
          cursorColor: Theme.of(context).hintColor,
          autofocus: false,
          textAlignVertical: TextAlignVertical.center,
          textInputAction: TextInputAction.search,
          onChanged: (text) {
            serviceCategoryController.showSuffixIcon(context, text);
            if (text.isNotEmpty) {
              serviceCategoryController.getSearchedServiceListBasedOnSubcategory(
                subCategoryId: subcategoryId,
                queryText: text.trim(),
              );
            }
          },
          onSubmitted: (text) {
            if (text.isNotEmpty) {
              serviceCategoryController.getSearchedServiceListBasedOnSubcategory(
                subCategoryId: subcategoryId,
                queryText: text.trim(),
              );
            }
            FocusScope.of(context).unfocus();
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 22),
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(10),
                left: Radius.circular(10),
              ),
              borderSide: BorderSide(
                width: 0.5,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(10),
                left: Radius.circular(10),
              ),
              borderSide: BorderSide(
                width: 0.5,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(10),
                left: Radius.circular(10),
              ),
              borderSide: BorderSide(
                width: 0.5,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(10),
                left: Radius.circular(10),
              ),
              borderSide: BorderSide(
                width: 0.5,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
              ),
            ),
            isDense: true,
            hintText: 'search_services'.tr,
            hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).hintColor,
            ),
            filled: true,
            suffixIcon: serviceCategoryController.isActiveSuffixIcon
                ? IconButton(
                    onPressed: () {
                      if (serviceCategoryController.searchController.text.trim().isNotEmpty) {
                        serviceCategoryController.clearSearchController();
                      }
                      FocusScope.of(context).unfocus();
                    },
                    icon: Icon(
                      Icons.cancel_outlined,
                      size: 18,
                      color: Theme.of(context).hintColor,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    child: Icon(
                      Icons.search_outlined,
                      color: Theme.of(context).hintColor,
                      size: 22,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
