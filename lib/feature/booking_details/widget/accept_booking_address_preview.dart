import 'package:demandium_provider/helper/booking_contact_helper.dart';
import 'package:demandium_provider/utils/core_export.dart';

class AcceptBookingAddressPreview extends StatelessWidget {
  final String? serviceLocation;
  final String? address;

  const AcceptBookingAddressPreview({
    super.key,
    required this.serviceLocation,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    if (!BookingContactHelper.isCustomerLocation(serviceLocation)) {
      return const SizedBox.shrink();
    }

    final displayAddress = address?.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.location_on_rounded,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'service_address'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  (displayAddress != null && displayAddress.isNotEmpty)
                      ? displayAddress
                      : 'address_not_found'.tr,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
