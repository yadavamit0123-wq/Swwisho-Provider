import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class BookingRequestListview extends StatelessWidget {
  const BookingRequestListview({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingRequestController>(
      builder: (bookingRequestController) {
        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: Theme.of(context).primaryColorLight,
                backgroundColor: Theme.of(context).cardColor,
                onRefresh: () async {
                  await bookingRequestController.getBookingRequestList(
                    bookingRequestController.bookingStatus,
                    1,
                    reload: true,
                  );
                },
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  controller: bookingRequestController.scrollController,
                  itemCount: bookingRequestController.bookingRequestList?.length,
                  padding: EdgeInsets.only(
                    bottom: bookingRequestController.isLoading ? 0 : Dimensions.paddingSizeLarge * 3,
                  ),
                  itemBuilder: (context, index) => BookingRequestItem(
                    booking: bookingRequestController.bookingRequestList![index],
                  ),
                ),
              ),
            ),
            bookingRequestController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}
