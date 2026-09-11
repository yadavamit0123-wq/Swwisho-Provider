import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class BookingRequestMenuBar extends StatefulWidget {
  const BookingRequestMenuBar({super.key});

  @override
  State<BookingRequestMenuBar> createState() => _BookingRequestMenuBarState();
}

class _BookingRequestMenuBarState extends State<BookingRequestMenuBar> {
  final BookingRequestController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.menuScrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
    );
    controller.menuScrollController!.scrollToIndex(controller.currentIndex, preferPosition: AutoScrollPosition.middle);
    controller.menuScrollController!.highlight(controller.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
        horizontal: Dimensions.paddingSizeSmall,
      ),
      child: ListView.builder(
        controller: controller.menuScrollController,
        itemCount: controller.bookingRequestStatusList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GetBuilder<BookingRequestController>(builder: (controller) {
            return InkWell(
              onTap: () async {
                controller.updateBookingRequestIndex(index);
                controller.tabController?.animateTo(index);
                await controller.menuScrollController!.scrollToIndex(
                  index,
                  preferPosition: AutoScrollPosition.middle,
                  duration: const Duration(milliseconds: 700),
                );
                await controller.menuScrollController!.highlight(index);
                controller.getBookingRequestList(controller.bookingRequestStatusList[index], 1, reload: true);
              },
              child: AutoScrollTag(
                controller: controller.menuScrollController!,
                key: ValueKey(index),
                index: index,
                child: BookingRequestMenuItem(
                  title: controller.bookingRequestStatusList[index],
                  index: index,
                  bookingCount: controller.bookingCount,
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
