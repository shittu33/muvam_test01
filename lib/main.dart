import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:muvam_test01/model/location.dart' as l;
import 'package:muvam_test01/providers/location_provider.dart';
import 'package:muvam_test01/providers/locations_provider.dart';
import 'package:provider/provider.dart';

import 'services/locations.dart';

void main() {

  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }

  runApp(MultiProvider(providers: [
    ListenableProvider(create: (_) => LocationProvider()),
    ListenableProvider(create: (_) => LocationsProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movam Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Location _location = Location();

  late GoogleMapController _controller;

  final CameraPosition initialPosition = const CameraPosition(
      target: LatLng(6.508770368877927, 3.355813127619282), zoom: 18);

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;


    Provider.of<LocationProvider>(context, listen: false)
        .fetchLocation((position) {
      _moveToNewLocation(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 16),
      );
    });

    _location.onLocationChanged.listen((l) {
      Provider.of<LocationProvider>(context, listen: false)
          .updateCurrentLocation(LatLng(l.latitude!, l.longitude!));
    });


    Provider.of<LocationsProvider>(context, listen: false)
        .getLocations();
  }

  CameraPosition _getLocationTarget() {

    var initialCameraPosition;

    if (Provider.of<LocationProvider>(context, listen: false).currentLatLng !=
        null) {
      initialCameraPosition = CameraPosition(
        target: LatLng(
            Provider.of<LocationProvider>(context, listen: false)
                .currentLatLng!
                .latitude,
            Provider.of<LocationProvider>(context, listen: false)
                .currentLatLng!
                .longitude),
        zoom: 0,
      );
    } else {
      initialCameraPosition = initialPosition;
    }
    return initialCameraPosition;
  }


  @override
  Widget build(BuildContext context) {
    var markers = {
      //   Marker(
      //     markerId: MarkerId(_ansr.target.latitude.toString()),
      //     position: _ansr
      //         .target, /*
      // icon:BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/icons/location.png")*/
      //   )
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Movam Test"),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        mapType: MapType.normal,
        initialCameraPosition: _getLocationTarget(),
        // markers: markers,
        onCameraMove: (cameraPosition){

        },
        myLocationEnabled: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLocations(),
        label: const Text('Locations'),
        icon: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  void _moveToNewLocation(cameraPosition) {
    _controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void _showLocations() {

    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            height: 350.0,
            color: Colors.transparent,
            child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0))),
                child: Center(
                  // child:Text("dsaf")
                  child: ListView(
                    children: [
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Locations"),
                        ),
                      ),
                      ...Provider.of<LocationsProvider>(context, listen: true)
                          .locations
                          .map((location) => InkWell(
                              onTap: () => _moveToNewLocation(CameraPosition(
                                  target: LatLng(location.lat!, location.lng!),
                                  zoom: 16)),
                              child: LocationWidget(location: location)))
                    ],
                  ),
                )),
          );
        });
  }
}

class LocationWidget extends StatelessWidget {
  const LocationWidget({
    Key? key,
    required this.location,
  }) : super(key: key);

  final l.Location location;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16)),
        elevation: 1,
        child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 16, horizontal: 0),
            child: ListTile(
              leading: Image.asset(
                "assets/icons/location.png",
                height: 100,
                width: 100,
              ),
              title: Text(location.name!),
              subtitle: Text(
                  location.active! ? "Active" : "InActive"),
            )),
      ),
    );
  }
}
