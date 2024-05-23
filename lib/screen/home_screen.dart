import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatelessWidget {
  static const LatLng companyLatLng = LatLng(
    // 1)
    37.5233273, // 위도
    126.921252, // 경도
  );

  static const Marker marker = Marker(
    markerId: MarkerId('company'),
    position: companyLatLng,
  );

  static final Circle circle = Circle(
    circleId: const CircleId('choolCheckCircle'),
    center: companyLatLng,
    fillColor: Colors.blue.withOpacity(0.5),
    radius: 100,
    strokeColor: Colors.blue,
    strokeWidth: 1,
  );

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      // 2)
      appBar: renderAppBar(),
      body: FutureBuilder<String>(
          future: checkPermission(),
          builder: (context, snapshot) {
            if (!snapshot.hasData &&
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.data == '위치 권한이 허가 되었습니다.') {
              return Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: companyLatLng,
                        zoom: 16,
                      ),
                      myLocationEnabled: true,
                      markers: {marker},
                      circles: {circle},
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.timelapse_outlined,
                          color: Colors.blue,
                          size: 50.0,
                        ),
                        const SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: () async {
                            final curPosition =
                                await Geolocator.getCurrentPosition();
                            final distance = Geolocator.distanceBetween(
                              curPosition.latitude,
                              curPosition.longitude,
                              companyLatLng.latitude,
                              companyLatLng.longitude,
                            );

                            bool canCheck = distance < 100;

                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: Text('출근하기'),
                                  content: Text(
                                    canCheck ? '출근을 하시겠습니까?' : '출근할 수 없는 위치입닏다',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text('취소'),
                                    ),
                                    if (canCheck)
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text('출근하기'),
                                      ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('출근하기!'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Center(
              child: Text(
                snapshot.data.toString(),
              ),
            );
          }),
    );
  }

  AppBar renderAppBar() {
    //   AppBar 를 구현하는 함수
    return AppBar(
      centerTitle: true,
      title: const Text(
        '오늘도 출첵!!!!',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Future<String> checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationEnabled) {
      return '위치 서비스를 활성화해주세요';
    }

    LocationPermission checkPermission = await Geolocator.checkPermission();

    if (checkPermission == LocationPermission.denied) {
      checkPermission = await Geolocator.requestPermission();

      if (checkPermission == LocationPermission.denied) {
        return '위치 권한을 허가해주세요';
      }
    }

    if (checkPermission == LocationPermission.deniedForever) {
      return '앱의 위치 권한을 설정에서 허가해주세요';
    }

    return '위치 권한이 허가 되었습니다.';
  }
}
