import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:lets_charge/utils/routes.dart';

class MapForHome extends StatefulWidget {
  const MapForHome({super.key});

  //for latitude and longitude of current location
  static double lat = 0.0, lon = 0.0;

  @override
  State<MapForHome> createState() => _MapForHomeState();
}

class _MapForHomeState extends State<MapForHome> {

  var userLongitude = 0.0;
  var userLatitude = 0.0;
  var apiKey = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    modifyuserlocation();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: GoogleMap(
            zoomControlsEnabled: false,
            initialCameraPosition: kGooglePlex,
            mapType: MapType.normal,
            markers: Set<Marker>.of(marker),
            myLocationEnabled: true,
            compassEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _controller.complete(controller);
            },
          ),
        ),
      ),
    );
  }

  // initial camera position
  CameraPosition kGooglePlex =
      CameraPosition(target: LatLng(12.8169693,80.0399802), zoom: 14);

  // Completer<GoogleMapController>
  final Completer<GoogleMapController> _controller = Completer();

  // for marker
  List<Marker> marker = [];

  //getting user current location permission
  Future<Position?> getUserCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission==LocationPermission.deniedForever){
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return await Geolocator.getCurrentPosition();
    }
    return null; // Handle other cases as needed
  }

  // current user location modify with marker
  modifyuserlocation() async {
    // custom marker
    BitmapDescriptor customMarkericon = await BitmapDescriptor.defaultMarker;
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)),
            "assets/images/evlocationicon.png")
        .then((icon) {
      setState(() {
        customMarkericon = icon;
      });
    });
    BitmapDescriptor ev = await BitmapDescriptor.defaultMarker;
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        "assets/images/evcharginglogo.png")
        .then((icon) {
      setState(() {
        ev = icon;
      });
    });
    getUserCurrentLocation().then((value) async {
      MapForHome.lat = value!.latitude;
      MapForHome.lon = value.longitude;
      marker.add(Marker(
        markerId: MarkerId("1"),
        position: LatLng(value.latitude, value.longitude),
        icon: customMarkericon,
        infoWindow: InfoWindow(title: "current location"),
      ));
      // sample ev marker
      marker.add(Marker(
        markerId: MarkerId("ev1"),
        position: LatLng(12.802536, 80.025838),
        icon: ev,
        infoWindow: InfoWindow(title: "Kazam Charging Station"),
      ));
      marker.add(Marker(
        markerId: MarkerId("ev2"),
        position: LatLng(12.806421, 80.028204),
        icon: ev,
        infoWindow: InfoWindow(title: "Electric Vehicle Charging Station"),
      ));
      marker.add(Marker(
        markerId: MarkerId("ev3"),
        position: LatLng(12.788312, 80.026139),
        icon: ev,
        infoWindow: InfoWindow(title: "Power Active"),
      ));
      marker.add(Marker(
        markerId: MarkerId("ev4"),
        position: LatLng(12.849476, 80.064167),
        icon: ev,
        infoWindow: InfoWindow(title: "Ather Grid Charging Station"),
      ));
      marker.add(Marker(
        markerId: MarkerId("ev5"),
        position: LatLng(12.865895, 80.075239),
        icon: ev,
        infoWindow: InfoWindow(title: "SNAK4EV Charging Station"),
      ));
     // print(value.latitude.toString() + " " + value.longitude.toString());
      CameraPosition cameraPosition = CameraPosition(
          zoom: 11.5, target: LatLng(value.latitude, value.longitude));
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      setState(() {
        userLongitude=value.latitude;
        userLatitude=value.longitude;
        fetchFuelPlaces();
        fetchEvPlaces();
        print("called");
      });
    });

  }

  noevcharge() {
    Fluttertoast.showToast(
      msg: "No EV station Nearby you",
      toastLength: Toast.LENGTH_SHORT, // or Toast.LENGTH_LONG
      gravity: ToastGravity.BOTTOM, // You can change the position
      timeInSecForIosWeb: 1, // Duration in seconds
      backgroundColor: Colors.green.withOpacity(0.7), // Background color
      textColor: Colors.white, // Text color
      fontSize: 16.0, // Text font size
    );
  }
  Future<void> fetchFuelPlaces() async {
    final radius = 3000; // 1000 meters (1 km) radius
    print(userLatitude);
    print(userLongitude);
    final url = Uri.parse(
        "https://api.geoapify.com/v2/places?categories=catering.restaurant,accommodation.hotel&filter=circle:$userLatitude,$userLongitude,$radius&bias=proximity:$userLatitude,$userLongitude&limit=20&apiKey=$apiKey");
    final response = await http.get(url,headers: {
      "Accept": "application/json",
    });
    print(url);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      addMarkersfuel(data);
      setState(() {
        // Update the state to trigger a rebuild with the markers or process the data further.
      });
    } else {
      throw Exception('Failed to load nearby fuel stations');
    }
  }
  Future<void> addMarkersfuel(Map<String, dynamic> data) async {
    print("fuel called");
    print(data);
    BitmapDescriptor customMarkericon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48,48)),
        "assets/images/fuelstationlogo.png");
    for (var place in data['features']) {
      final name = place['properties']['name'];
      final latitude = place['geometry']['coordinates'][1];
      final longitude = place['geometry']['coordinates'][0];
      print(name);
      marker.add(Marker(
        markerId: MarkerId('$latitude'),
        icon: customMarkericon,
        infoWindow: InfoWindow(title:name),
        position: LatLng(latitude, longitude),
      ));
    }
    setState(() {
      // Update the state to trigger a rebuild with the markers
    });
  }
  Future<void> fetchEvPlaces() async {
    final radius = 3000; // 1000 meters (1 km) radius
    print(userLatitude);
    print(userLongitude);
    final url = Uri.parse(
        "https://api.geoapify.com/v2/places?categories=service.vehicle.charging_station&filter=circle:$userLatitude,$userLongitude,$radius&bias=proximity:$userLatitude,$userLongitude&limit=20&apiKey=$apiKey");
    final response = await http.get(url,headers: {
      "Accept": "application/json",
    });
    print(url);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      if (data["features"].isEmpty) {
        noevcharge(); // Call your function when the "features" array is empty
      } else {
        addMarkersev(data); // Call your function when the "features" array is not empty
      }
      addMarkersfuel(data);
      setState(() {
        // Update the state to trigger a rebuild with the markers or process the data further.
      });
    } else {
      throw Exception('Failed to load nearby fuel stations');
    }
  }
  Future<void> addMarkersev(Map<String, dynamic> data) async {
    print("ev called");
    print(data);
    BitmapDescriptor customMarkericon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48,48)),
        "assets/images/evchargingstationlogo.png");
    for (var place in data['features']) {
      final name = place['properties']['name'];
      final latitude = place['geometry']['coordinates'][1];
      final longitude = place['geometry']['coordinates'][0];
      print(name);
      marker.add(Marker(
        markerId: MarkerId('$latitude'),
        icon: customMarkericon,
        infoWindow: InfoWindow(title:name),
        position: LatLng(latitude, longitude),
      ));
    }
    setState(() {
      // Update the state to trigger a rebuild with the markers
    });
  }
  //for back button
  Future<bool> _onWillPop() async {
    Navigator.pushReplacementNamed(context, MyRoutes.homeroute);
    return true;
  }

}
