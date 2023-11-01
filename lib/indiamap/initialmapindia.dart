import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lets_charge/indiamap/mapforhome.dart';
import 'package:lets_charge/indiamapclass/currentlocation.dart';
import 'package:lets_charge/utils/routes.dart';
import 'package:uuid/data.dart';
import 'package:http/http.dart' as http;

class InitialMapIndia extends StatefulWidget {
  static String Address = "";

  // for marker
  static List<Marker> marker = [];
  static List<Circle> circle = [];

  const InitialMapIndia({super.key});

  @override
  State<InitialMapIndia> createState() => _InitialMapIndiaState();
}

class _InitialMapIndiaState extends State<InitialMapIndia> {
// Completer<GoogleMapController>
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  double lat = 0.0, lon = 0.0;
  bool isListVisible=false;
  LatLng? latLng;
  List<String> _suggestions = [];
  Completer<GoogleMapController> controllers = Completer();
  var getaccesstoken = '';
  TextEditingController textcontroller = TextEditingController();
  var userLatitude=MapForHome.lon;
  var userLongitude=MapForHome.lat;
  List<Marker> searchmarker = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    modifyuserlocation();
    getConnectivity();
    // Set up the subscription to listen for changes
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      handleConnectivityChange(result);
    });
    isListVisible = false;
  }

  //internet checker
  getConnectivity() async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    if (!isDeviceConnected && isAlertSet == false) {
      showDialogBox(context);
      setState(() => isAlertSet = true);
    }
  }

  void handleConnectivityChange(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      if (!isDeviceConnected && isAlertSet == false) {
        showDialogBox(context);
        setState(() => isAlertSet = true);
      }
    } else {
      // You can handle cases when the device is connected here
      // For example, you can dismiss the dialog if it's open
      if (isAlertSet) {
        Navigator.of(context).pop(); // Dismiss the dialog
        setState(() => isAlertSet = false);
      }
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 2,
              ),
              SizedBox(
                height: 50,
                child: Container(
                  color: Colors.grey.shade200,
                  padding: const EdgeInsets.only(left: 4, right: 4),
                  child: TextFormField(
                    controller: textcontroller,
                    onChanged: (query) {
                      // Call a function to fetch and update search suggestions based on the query
                      fetchSearchSuggestions(query);
                    },
                    onEditingComplete: () {
                      setState(() {
                        isListVisible = false;
                        FocusScope.of(context).unfocus();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "search with city & pincode",
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Colors.black, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    GoogleMap(
                      zoomControlsEnabled: false,
                      initialCameraPosition: kGooglePlex,
                      markers: Set<Marker>.of(InitialMapIndia.marker),
                      circles: Set<Circle>.of(InitialMapIndia.circle),
                      myLocationEnabled: true,
                      compassEnabled: true,
                      onMapCreated: (GoogleMapController controller) {
                        controllers.complete(controller);
                        controllers.complete(controller);
                      },
                    ),
                    Expanded(
                      child: isListVisible
                          ? SizedBox(
                              width: 350.w,
                              height: 350.h,
                              child: Container(
                                  color: Colors.grey.shade200,
                                  padding: EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  child: ListView.builder(
                                    itemCount:
                                        _suggestions.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        titleTextStyle: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                            fontFamily:
                                                GoogleFonts.lato().fontFamily),
                                        title: Text(
                                            _suggestions[index]),
                                        onTap: () {
                                          // Handle when a suggestion is tapped
                                          onSuggestionTapped(_suggestions[index]);
                                        },
                                      );
                                    },
                                  )),
                            )
                          : SizedBox.shrink(),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // initial camera position
  CameraPosition kGooglePlex =
      const CameraPosition(target: LatLng(12.8169693, 80.0399802), zoom: 13);

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

    CameraPosition cameraPosition = CameraPosition(
        zoom: 13, target: LatLng(MapForHome.lat, MapForHome.lon));
    final GoogleMapController controller =
        await controllers.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setState(() {
      fetchFuelPlaces();
      fetchEvPlaces();
    });
  }
//suggestion for user search
  Future<void> fetchSearchSuggestions(String query) async {
    const baseUrl = 'https://atlas.mapmyindia.com/api/places/search/json';
    print(query);
    var accesstoken = await getAccessToken(); // Replace with your access token
    final headers = {
      'Authorization': 'Bearer $accesstoken',
    };
    final response = await http.get(
      Uri.parse('$baseUrl?query=$query'),
      headers: headers,
    );
    print("fetchsearch");
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      final suggestions = List<dynamic>.from(json.decode(response.body)['suggestedLocations']);
      final List<String> modifiedSuggestions = [];
      for (var suggestion in suggestions) {
        final String name = suggestion['placeName'];
        final String address = suggestion['placeAddress'];
        final modifiedSuggestion = '$name, $address';
        modifiedSuggestions.add(modifiedSuggestion);
        print(modifiedSuggestions);
      }
      _suggestions = modifiedSuggestions;
      setState(() {
        isListVisible = true;
      });
    } else {
      print("Error");
    }
  }

  // get access token
  Future<String> getAccessToken() async {
    const clientId =
        '33OkryzDZsLOeDQTxe3oiJNjbJh-kTzigCKAAmyrekeaH9m502ciddUNvGyESt9qgLTspZLr0hQu1HFMTY-M1g==';
    const clientSecret =
        'lrFxI-iSEg9H9u-l6zqy5SRBytIhMMwmeltsNwp1lmfAptsupx3lxwr3N7cd5gryr0B8_Nw5U5zNRqGMhDyx5KnyYwaYEf6l';
    const tokenUrl = 'https://outpost.mapmyindia.com/api/security/oauth/token';

    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );
    print('getaccesstoken');

    print(response.statusCode);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String accessToken = data['access_token'];
      getaccesstoken = accessToken;
      return accessToken;
    } else {
      throw Exception('Failed to obtain access token');
    }
  }

  // on Suggestion tapped
  Future<void> onSuggestionTapped(String selectedPlace) async {
    // Perform a detailed search for the selected place using MapMyIndia
    FocusScope.of(context).unfocus();
    InitialMapIndia.Address = selectedPlace;
    const apiKey =
        '67cb6529c60e278225357773b10b64fc'; // Replace with your MapMyIndia API key
    const baseUrl = 'https://atlas.mapmyindia.com/api/places/geocode';
    final headers = {
      'Authorization': 'Bearer $getaccesstoken',
    };
    final response = await http.get(
      Uri.parse('$baseUrl?address=${Uri.encodeQueryComponent(selectedPlace)}'),
      headers: headers,
    );
    print("onsuggestiontaped");
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      // Parse the MapMyIndia response
      final mapmyindiaResponse = jsonDecode(response.body);
      // Check if the 'copResults' field exists
      if (mapmyindiaResponse.containsKey('copResults')) {
        final copResults = mapmyindiaResponse['copResults'];
        // Extract relevant address components
        var fullAddress;
        final suburb = copResults['district'] ?? '';
        final suburbdi = copResults['district'] ?? '';
        var town = copResults['locality'] ?? '';
        final postcode = copResults['pincode'] ?? '';
        final state = copResults['state'] ?? '';
        final country = 'india';
        final city = copResults['city'] ?? '';
        // if(town.isEmpty) town=copResults['city'];
        fullAddress = '$postcode $town, $country,';
        // formattedAddress to the geocodeAddress function
        print(fullAddress);
        geocodeAddress(fullAddress, apiKey);
      } else {
        print("Error: 'copResults' field not found in MapMyIndia response");
      }
    } else {
      print("Error: ${response.statusCode}");
    }
  }

  // getting address coordinates // drive into that location // circular radius
  Future<void> geocodeAddress(
      String selectedPlace, String apikey) async {
    final apiKey = '2f4e7fae95e545e681eef6f43ddb086d';
    BitmapDescriptor customMarkericon = await BitmapDescriptor.defaultMarker;
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        "assets/images/evlocationicon.png")
        .then((icon) {
      customMarkericon = icon;
    });
    try {
      latLng =
      await getAddressCoordinates(selectedPlace, apiKey);
      updatemap();
    } catch (e) {
      print('Error geocoding address: $e');
    }
  }
  // i want to put the nearby search function here
   updatemap() async {
    CameraPosition userpos = CameraPosition(
        target: LatLng(latLng!.latitude, latLng!.longitude), zoom: 13.5);
    GoogleMapController selectedlocation =
    await controllers.future;
    selectedlocation.animateCamera(CameraUpdate.newCameraPosition(userpos));
    InitialMapIndia.circle.add(Circle(
      circleId: CircleId('searchuserradius'),
      center: LatLng(latLng!.latitude, latLng!.longitude),
      radius: 3000,
      strokeWidth: 2,
      // Adjust the stroke width as needed
      strokeColor: Colors.green,
      // Adjust the stroke color as needed
      fillColor: Colors.green.withOpacity(0.2),
    ));
    setState(() {
      isListVisible=false;
      searchmarker.clear();
      SearchFuelPlaces();
      SearchEvPlaces();
    });
  }
  static Future<LatLng?> getAddressCoordinates(
      String selectedPlace, String apiKey) async {
    final encodedAddress = Uri.encodeQueryComponent(selectedPlace);
    final apiEndpoint =
        'https://api.opencagedata.com/geocode/v1/json?q=$encodedAddress&key=2f4e7fae95e545e681eef6f43ddb086d';
    print(selectedPlace);
    final response = await http.get(Uri.parse(apiEndpoint));
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry'];
        final latitude = location['lat'];
        final longitude = location['lng'];
        return LatLng(latitude, longitude);
      }
    }
    return null; // Return null if geocoding fails
  }

  //for back button
  Future<bool> _onWillPop() async {
    Navigator.pushReplacementNamed(context, MyRoutes.homeroute);
    return true;
  }

  showDialogBox(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("No Connection"),
      content: Text("Please check your internet connectivity"),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () async {
            Navigator.of(context).pop();
            setState(() => isAlertSet = false);
            isDeviceConnected = await InternetConnectionChecker().hasConnection;
            if (!isDeviceConnected && isAlertSet == false) {
              showDialogBox(context);
              setState(() => isAlertSet = true);
            }
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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
        "https://api.geoapify.com/v2/places?categories=catering.restaurant,accommodation.hotel&filter=circle:$userLatitude,$userLongitude,$radius&bias=proximity:$userLatitude,$userLongitude&limit=20&apiKey=3c61ea357ad340aeb5e2bea7fec13952");
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
    BitmapDescriptor customMarkericon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48,48)),
        "assets/images/fuelstationlogo.png");
    BitmapDescriptor ev = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48,48)),
        "assets/images/evcharginglogo.png");
    // sample ev marker
    InitialMapIndia.marker.add(Marker(
      markerId: MarkerId("ev1"),
      position: LatLng(12.802536, 80.025838),
      icon: ev,
      infoWindow: InfoWindow(title: "Kazam Charging Station"),
    ));
    InitialMapIndia.marker.add(Marker(
      markerId: MarkerId("ev2"),
      position: LatLng(12.806421, 80.028204),
      icon: ev,
      infoWindow: InfoWindow(title: "Electric Vehicle Charging Station"),
    ));
    InitialMapIndia.marker.add(Marker(
      markerId: MarkerId("ev3"),
      position: LatLng(12.788312, 80.026139),
      icon: ev,
      infoWindow: InfoWindow(title: "Power Active"),
    ));
    InitialMapIndia.marker.add(Marker(
      markerId: MarkerId("ev4"),
      position: LatLng(12.849476, 80.064167),
      icon: ev,
      infoWindow: InfoWindow(title: "Ather Grid Charging Station"),
    ));
    InitialMapIndia.marker.add(Marker(
      markerId: MarkerId("ev5"),
      position: LatLng(12.865895, 80.075239),
      icon: ev,
      infoWindow: InfoWindow(title: "SNAK4EV Charging Station"),
    ));
    for (var place in data['features']) {
      final name = place['properties']['name'];
      final latitude = place['geometry']['coordinates'][1];
      final longitude = place['geometry']['coordinates'][0];
      print(name);
      InitialMapIndia.marker.add(Marker(
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
        "https://api.geoapify.com/v2/places?categories=service.vehicle.charging_station&filter=circle:$userLatitude,$userLongitude,$radius&bias=proximity:$userLatitude,$userLongitude&limit=20&apiKey=3c61ea357ad340aeb5e2bea7fec13952");
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
    BitmapDescriptor customMarkericon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48,48)),
        "assets/images/evchargingstationlogo.png");
    for (var place in data['features']) {
      final name = place['properties']['name'];
      final latitude = place['geometry']['coordinates'][1];
      final longitude = place['geometry']['coordinates'][0];
      print(name);
      InitialMapIndia.marker.add(Marker(
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

  // when user search i will show all nearby ev and other service
  Future<void> SearchFuelPlaces() async {
    final radius = 3000; // 1000 meters (1 km) radius
    final latm=latLng!.longitude;
    final lonm=latLng!.latitude;
    final url = Uri.parse(
        "https://api.geoapify.com/v2/places?categories=catering.restaurant,accommodation.hotel&filter=circle:$latm,$lonm,$radius&bias=proximity:$latm,$lonm&limit=40&apiKey=9b5e55cd91d84c7ca8e1ed9b2e3fc045");
    final response = await http.get(url,headers: {
      "Accept": "application/json",
    });
    print(url);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      addMarkerssearchfuel(data);
      setState(() {
        // Update the state to trigger a rebuild with the markers or process the data further.
      });
    } else {
      throw Exception('Failed to load nearby fuel stations');
    }
  }
  Future<void> addMarkerssearchfuel(Map<String, dynamic> data) async {
    BitmapDescriptor customMarkericon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48,48)),
        "assets/images/fuelstationlogo.png");
    for (var place in data['features']) {
      final name = place['properties']['name'];
      final latitude = place['geometry']['coordinates'][1];
      final longitude = place['geometry']['coordinates'][0];
      searchmarker.add(Marker(
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
  Future<void> SearchEvPlaces() async {
    final radius = 3000; // 1000 meters (1 km) radius
    final latm=latLng!.longitude;
    final lonm=latLng!.latitude;
    final url = Uri.parse(
        "https://api.geoapify.com/v2/places?categories=service.vehicle.charging_station&filter=circle:$latm,$lonm,$radius&bias=proximity:$latm,$lonm&limit=40&apiKey=9b5e55cd91d84c7ca8e1ed9b2e3fc045");
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
        addMarkerssearchev(data); // Call your function when the "features" array is not empty
      }
      addMarkersfuel(data);
      setState(() {
        // Update the state to trigger a rebuild with the markers or process the data further.
      });
    } else {
      throw Exception('Failed to load nearby fuel stations');
    }
  }
  Future<void> addMarkerssearchev(Map<String, dynamic> data) async {
    BitmapDescriptor customMarkericon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48,48)),
        "assets/images/fuelstationlogo.png");
    for (var place in data['features']) {
      final name = place['properties']['name'];
      final latitude = place['geometry']['coordinates'][1];
      final longitude = place['geometry']['coordinates'][0];
      print(name);
      searchmarker.add(Marker(
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
  Permission(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Permission required"),
      content: Text("can't access the map features"),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () async {
            Navigator.of(context).pop();
            setState(() => isAlertSet = false);
            isDeviceConnected = await InternetConnectionChecker().hasConnection;
            if (!isDeviceConnected && isAlertSet == false) {
              showDialogBox(context);
              setState(() => isAlertSet = true);
            }
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
