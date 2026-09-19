import 'package:demandium_provider/feature/booking_details/model/bookings_details_model.dart';
import 'package:demandium_provider/feature/booking_requests/model/request_model.dart';

class BookingContactHelper {
  static bool canShowContactDetails(BookingDetailsContent bookingDetails) {
    final status = bookingDetails.bookingStatus;
    return status == 'accepted' || status == 'ongoing' || status == 'completed';
  }

  static bool isCustomerLocation(String? serviceLocation) {
    return serviceLocation == 'customer';
  }

  static bool canShowAddress(BookingDetailsContent bookingDetails) {
    if (canShowContactDetails(bookingDetails)) {
      return true;
    }
    return isCustomerLocation(
      bookingDetails.serviceLocation ?? bookingDetails.subBooking?.serviceLocation,
    );
  }

  static bool canShowAddressForRequest(BookingRequestModel booking) {
    return isCustomerLocation(booking.serviceLocation);
  }

  static String? resolveCustomerAddress(BookingDetailsContent bookingDetails) {
    final address = bookingDetails.serviceAddress?.address
        ?? bookingDetails.subBooking?.serviceAddress?.address;
    if (address != null && address.trim().isNotEmpty) {
      return address.trim();
    }
    return null;
  }

  static String? resolveCustomerAddressFromRequest(BookingRequestModel booking) {
    final address = booking.serviceAddress?.address;
    if (address != null && address.trim().isNotEmpty) {
      return address.trim();
    }
    return null;
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
