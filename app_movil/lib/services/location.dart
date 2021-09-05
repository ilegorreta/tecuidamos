import 'package:geolocator/geolocator.dart';

class Location {
  double latitude;
  double longitude;

  //Se coloca Future void, porque hay procesos que se deben de realizar, pero que dependen de estos valores tardados.
  Future<void> getCurrentLocationLow() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      print(e);
    }
  }

  Future<void> getCurrentLocationHigh() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      print(e);
    }
  }
}
