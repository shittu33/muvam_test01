import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:muvam_test01/model/location.dart' as l;
import 'package:muvam_test01/providers/location_provider.dart';
import 'package:muvam_test01/providers/locations_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;


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
  BitmapDescriptor? currentLocationIcon;

  BitmapDescriptor? otherLocationIcon;

  final Set<Marker> _markers = {};

  final Location _location = Location();

  late GoogleMapController _controller;

  final CameraPosition initialPosition = const CameraPosition(
      target: LatLng(6.508770368877927, 3.355813127619282), zoom: 18);

  @override
  void initState() {
    super.initState();
    setCustomMarker();
  }

  void setCustomMarker() async {

    currentLocationIcon = BitmapDescriptor.fromBytes(await getBytesFromAsset(
        'assets/icons/walk.png', 70, 70));

    otherLocationIcon = BitmapDescriptor.fromBytes(await getBytesFromAsset(
        'assets/icons/location.png', 70, 70));
  }

  Future<Uint8List> getBytesFromAsset(String path, int width,
      int height) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(), targetWidth: width, targetHeight: height);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer
        .asUint8List();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;

    Provider.of<LocationProvider>(context, listen: false)
        .fetchLocation((position) {
      setState(() {
        _markers.add(_getMarker(l.Location(
            name: null,
            active: false,
            lat: position.latitude,
            lng: position.latitude)));
      });

      _moveToNewLocation(
          l.Location(name: null,
              active: false,
              lat: position.latitude,
              lng: position.longitude)
      );
    });

    _location.onLocationChanged.listen((l) {
      Provider.of<LocationProvider>(context, listen: false)
          .updateCurrentLocation(LatLng(l.latitude!, l.longitude!));
    });

    Provider.of<LocationsProvider>(context, listen: false).getLocations();
  }

  Marker _getMarker(l.Location position) {
    return Marker(
        markerId: MarkerId(position.toString() + position.lat.toString()),
        position: LatLng(position.lat!, position.lng!),
        infoWindow: InfoWindow(
            title: position.name ?? position.name,
            snippet: "Lat ${position.lat} - Lng ${position.lng}"),
        icon:
        position.name == null ? currentLocationIcon! : otherLocationIcon!);
  }

  CameraPosition _getLocationTarget() {
    var initialCameraPosition;

    if (Provider
        .of<LocationProvider>(context, listen: false)
        .currentLatLng !=
        null) {
      initialCameraPosition = CameraPosition(
        target: LatLng(
            Provider
                .of<LocationProvider>(context, listen: false)
                .currentLatLng!
                .latitude,
            Provider
                .of<LocationProvider>(context, listen: false)
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
    return Scaffold(

      appBar: AppBar(
        title: const Text("Movam Test"),
      ),

      body: GoogleMap(
        onMapCreated: _onMapCreated,
        mapType: MapType.normal,
        initialCameraPosition: _getLocationTarget(),
        markers: _markers,
        myLocationEnabled: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLocations(),
        label: const Text('Locations'),
        icon: const Icon(Icons.arrow_forward_ios),
      ),

    );
  }

  void _moveToNewLocation(location) {
    setState(() {
      _markers.add(_getMarker(location));
    });

    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(location.lat!, location.lng!),
        zoom: 18)));
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
                      ...Provider
                          .of<LocationsProvider>(context, listen: true)
                          .locations
                          .map((location) =>
                          InkWell(
                              onTap: () => _moveToNewLocation(location),
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
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        elevation: 1,
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
            child: ListTile(
              leading: Image.asset(
                "assets/icons/location.png",
                height: 40,
                width: 40,
              ),
              title: Text(location.name!),
              subtitle: Text(location.active! ? "Active" : "InActive"),
            )),
      ),
    );
  }
}
