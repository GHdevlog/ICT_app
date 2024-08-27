import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WalkPage extends StatefulWidget {
  const WalkPage({super.key});

  @override
  _WalkPageState createState() => _WalkPageState();
}

class _WalkPageState extends State<WalkPage> {
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지도 화면'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(35.190212, 128.127326), // San Francisco 좌표
          zoom: 12,
        ),
        markers: {
          const Marker(
            markerId: MarkerId('marker_1'),
            position: LatLng(35.190212, 128.127326), // San Francisco 좌표
            infoWindow: InfoWindow(
              title: 'San Francisco',
              snippet: 'Example marker',
            ),
          ),
        },
      ),
    );
  }
}