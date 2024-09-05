import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// WalkPage 위젯 클래스. StatefulWidget을 사용하여 지도 상태를 관리
class WalkPage extends StatefulWidget {
  const WalkPage({super.key});

  @override
  _WalkPageState createState() => _WalkPageState();
}

// WalkPage 상태 클래스
class _WalkPageState extends State<WalkPage> {
  // GoogleMapController는 지도를 제어하는 데 사용됨
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    // 여기서 초기화가 필요할 경우 추가적으로 작성 가능
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 상단 앱바에 '지도 화면'이라는 제목 표시
        title: const Text('지도 화면'),
      ),
      // 본문에 GoogleMap 위젯을 표시
      body: GoogleMap(
        // 지도가 생성되었을 때 호출되는 콜백 메소드
        onMapCreated: (GoogleMapController controller) {
          // mapController를 초기화하여 지도 제어 가능
          mapController = controller;
        },
        // 초기 카메라 위치를 설정 (LatLng에 지정한 좌표로 카메라가 이동함)
        initialCameraPosition: const CameraPosition(
          target: LatLng(35.190212, 128.127326), // 예시 좌표 (San Francisco 좌표)
          zoom: 12, // 줌 레벨
        ),
        // 마커 설정. 지도에 마커가 표시됨
        markers: {
          const Marker(
            // 마커 ID는 고유해야 함
            markerId: MarkerId('marker_1'),
            // 마커의 위치를 지정
            position: LatLng(35.190212, 128.127326), // San Francisco 좌표
            // 마커 클릭 시 나타날 정보창
            infoWindow: InfoWindow(
              title: 'San Francisco', // 마커 제목
              snippet: 'Example marker', // 부가 설명
            ),
          ),
        },
      ),
    );
  }
}
