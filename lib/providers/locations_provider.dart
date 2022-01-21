import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:muvam_test01/model/location.dart';
import 'package:muvam_test01/services/locations.dart';

class LocationsProvider extends ChangeNotifier {

  List<Location> locations= [];

  LocationsProvider() {

    LocationService().getLocations().then((value) {

        locations = value;

        notifyListeners();

        print("PROVIDER FIRST VALUE");

        print(locations[0].name);
    });
  }
}
