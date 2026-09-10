import 'package:demandium_provider/feature/booking_details/model/bookings_details_model.dart';

class BookingContactHelper {
  static bool canShowContactDetails(BookingDetailsContent bookingDetails) {
    final status = bookingDetails.bookingStatus;
    return status == 'accepted' || status == 'ongoing' || status == 'completed';
  }

  static String maskPhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return '**********';
    }
    if (phone.length <= 4) {
      return '*' * phone.length;
    }
    return '${'*' * (phone.length - 4)}${phone.substring(phone.length - 4)}';
  }

  static String maskAddress(String? address) {
    if (address == null || address.isEmpty) {
      return 'accept_booking_to_view_contact_details';
    }
    return 'accept_booking_to_view_contact_details';
  }
}
