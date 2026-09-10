import 'package:demandium_provider/feature/booking_details/widget/repeat_booking/repeat_booking_details.dart';
import 'package:demandium_provider/feature/booking_details/widget/repeat_booking/repeat_booking_service_log.dart';
import 'package:demandium_provider/utils/core_export.dart';
import 'package:get/get.dart';

class RepeatBookingDetailsScreen extends StatefulWidget {
  final String bookingId;
  final String? fromPage;

  const RepeatBookingDetailsScreen({
    super.key,
    required this.bookingId,
    this.fromPage,
  });

  @override
  State<RepeatBookingDetailsScreen> createState() => _RepeatBookingDetailsScreenState();
}

class _RepeatBookingDetailsScreenState extends State<RepeatBookingDetailsScreen> with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    Get.find<BookingDetailsController>().resetBookingDetailsValue(resetBookingDetails: true);
    Get.find<BookingDetailsController>().getBookingDetails(widget.bookingId);
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      onPopInvoked: () {
        if (widget.fromPage == 'fromNotification') {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(
          title: 'repeat_booking_details'.tr,
          onBackPressed: () {
            if (widget.fromPage == 'fromNotification') {
              Get.offAllNamed(RouteHelper.getInitialRoute());
            } else {
              Get.back();
            }
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 45,
                width: Get.width,
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.7), width: 1),
                  ),
                ),
                child: TabBar(
                  controller: tabController,
                  unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                  indicatorColor: Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).primaryColorLight,
                  labelStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                  tabs: [
                    Tab(text: 'booking_details'.tr),
                    Tab(text: 'service_log'.tr),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    RepeatBookingDetailsWidget(
                      bookingId: widget.bookingId,
                      tabController: tabController,
                      isSubBooking: false,
                    ),
                    RepeatBookingServiceLogWidget(bookingId: widget.bookingId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
