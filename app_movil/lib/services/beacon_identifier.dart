import 'package:tecuidamos/utilities/information_constants.dart';

class BeaconIdentifier {
  BeaconIdentifier({this.beaconData = '-'});
  final String beaconData;
  int i = 0;

  String getPlace() {
    for (var i = 0; i < kBeacon.length; i++) {
      if (beaconData.contains(kBeacon[i])) {
        return kPlaceIdentified[i];
      }
    }
    return '-';
  }
}
