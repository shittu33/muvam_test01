import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationProvider extends ChangeNotifier {
  LatLng? currentLatLng;
  var location = Location();
  LatLng? _currentLocation;

  fetchLocation(Function(LatLng position) result) {
    //check if location permission is granted
    location.hasPermission().then((PermissionStatus status) {
      // if not granted you can request permission to use location
      if (status != PermissionStatus.granted) {
        location.requestPermission().then((PermissionStatus status) {
          if (status == PermissionStatus.granted) {
            // if granted you can get location and add it to the stream
            getLocation().then((position) {
              result(position);
              return;
            });
          }
        });
        result(const LatLng(
          6.508770368877927,
          3.355813127619282,
        ));
        return;
      }
      // if granted you can return the location
      getLocation().then((position) {
        result(position);
      });
    });
  }

  Future<LatLng> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = LatLng(
        userLocation.latitude!,
        userLocation.longitude!,
      );
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }
    return _currentLocation ??
        const LatLng(
          6.508770368877927,
          3.355813127619282,
        );
  }

  void updateCurrentLocation(LatLng latLng) {
    currentLatLng = latLng;
    notifyListeners();
  }

  void resetMapProvider() {
    currentLatLng = null;
    notifyListeners();
  }
}
