import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LiveLocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String estimatedArea;
  final String estimatedCity;
  final String postalCode;
  final bool isLiveGps;
  final String? error;

  const LiveLocationResult({
    required this.latitude,
    required this.longitude,
    this.accuracy = 10.0,
    required this.estimatedArea,
    required this.estimatedCity,
    required this.postalCode,
    required this.isLiveGps,
    this.error,
  });

  String get formattedCoordinates =>
      '${latitude.toStringAsFixed(5)}° N, ${longitude.toStringAsFixed(5)}° E';
}

class LocationService {
  /// Comprehensive Tenkasi, Tirunelveli & Tamil Nadu reference points for pin-point reverse matching
  static final List<Map<String, dynamic>> _tnKnownCenters = [
    {
      'city': 'Tenkasi',
      'area': 'தென்காசி (Tenkasi)',
      'shortName': 'Tenkasi',
      'lat': 8.9594,
      'lng': 77.3160,
      'pincode': '627811',
    },
    {
      'city': 'Tenkasi',
      'area': 'பாவூர்சத்திரம் (Pavoorchatram)',
      'shortName': 'Pavoorchatram',
      'lat': 8.9056,
      'lng': 77.3828,
      'pincode': '627808',
    },
    {
      'city': 'Tenkasi',
      'area': 'குற்றாலம் (Courtallam)',
      'shortName': 'Courtallam',
      'lat': 8.9324,
      'lng': 77.2690,
      'pincode': '627802',
    },
    {
      'city': 'Tenkasi',
      'area': 'சுரண்டை (Surandai)',
      'shortName': 'Surandai',
      'lat': 8.9772,
      'lng': 77.4244,
      'pincode': '627859',
    },
    {
      'city': 'Tenkasi',
      'area': 'செங்கோட்டை (Shenkottai)',
      'shortName': 'Shenkottai',
      'lat': 8.9857,
      'lng': 77.2472,
      'pincode': '627809',
    },
    {
      'city': 'Tenkasi',
      'area': 'கடையநல்லூர் (Kadayanallur)',
      'shortName': 'Kadayanallur',
      'lat': 9.0754,
      'lng': 77.3482,
      'pincode': '627751',
    },
    {
      'city': 'Tenkasi',
      'area': 'கரிசலூர் (Karisalur)',
      'shortName': 'Karisalur',
      'lat': 8.9892,
      'lng': 77.3450,
      'pincode': '627753',
    },
    {
      'city': 'Tenkasi',
      'area': 'கடையம் (Kadayam)',
      'shortName': 'Kadayam',
      'lat': 8.8166,
      'lng': 77.3833,
      'pincode': '627415',
    },
    {
      'city': 'Tenkasi',
      'area': 'கீழப்பாவூர் (Keelapavoor)',
      'shortName': 'Keelapavoor',
      'lat': 8.9100,
      'lng': 77.4100,
      'pincode': '627806',
    },
    {
      'city': 'Tenkasi',
      'area': 'ஆலங்குளம் (Alangulam)',
      'shortName': 'Alangulam',
      'lat': 8.8711,
      'lng': 77.4983,
      'pincode': '627851',
    },
    {
      'city': 'Tenkasi',
      'area': 'சங்கரன்கோவில் (Sankarankovil)',
      'shortName': 'Sankarankovil',
      'lat': 9.1722,
      'lng': 77.5325,
      'pincode': '627756',
    },
    {
      'city': 'Tenkasi',
      'area': 'புளியங்குடி (Puliyangudi)',
      'shortName': 'Puliyangudi',
      'lat': 9.1672,
      'lng': 77.3995,
      'pincode': '627855',
    },
    {
      'city': 'Tenkasi',
      'area': 'வாசுதேவநல்லூர் (Vasudevanallur)',
      'shortName': 'Vasudevanallur',
      'lat': 9.2392,
      'lng': 77.4184,
      'pincode': '627758',
    },
    {
      'city': 'Tenkasi',
      'area': 'சிவகிரி (Sivagiri)',
      'shortName': 'Sivagiri',
      'lat': 9.3364,
      'lng': 77.4303,
      'pincode': '627757',
    },
    {
      'city': 'Tenkasi',
      'area': 'சாம்பவர் வடகரை (Sambavar Vadagarai)',
      'shortName': 'Sambavar Vadagarai',
      'lat': 8.9700,
      'lng': 77.3300,
      'pincode': '627856',
    },
    {
      'city': 'Tenkasi',
      'area': 'ஆய்க்குடி (Aaikudi)',
      'shortName': 'Aaikudi',
      'lat': 8.9750,
      'lng': 77.3100,
      'pincode': '627852',
    },
    {
      'city': 'Tenkasi',
      'area': 'இலஞ்சி (Ilanji)',
      'shortName': 'Ilanji',
      'lat': 8.9550,
      'lng': 77.2900,
      'pincode': '627805',
    },
    {
      'city': 'Tenkasi',
      'area': 'அச்சன்புதூர் (Achampudur)',
      'shortName': 'Achampudur',
      'lat': 8.9950,
      'lng': 77.3000,
      'pincode': '627801',
    },
    {
      'city': 'Tenkasi',
      'area': 'வடகரை (Vadakarai)',
      'shortName': 'Vadakarai',
      'lat': 9.0100,
      'lng': 77.3100,
      'pincode': '627812',
    },
    {
      'city': 'Tenkasi',
      'area': 'பண்பொழி (Panpoli)',
      'shortName': 'Panpoli',
      'lat': 8.9800,
      'lng': 77.2700,
      'pincode': '627807',
    },
    {
      'city': 'Tenkasi',
      'area': 'மேலகரம் (Melagaram)',
      'shortName': 'Melagaram',
      'lat': 8.9400,
      'lng': 77.3000,
      'pincode': '627818',
    },
    {
      'city': 'Tenkasi',
      'area': 'வீரகேரளம்புதூர் (VK Pudur)',
      'shortName': 'VK Pudur',
      'lat': 8.9480,
      'lng': 77.4410,
      'pincode': '627861',
    },
    {
      'city': 'Tenkasi',
      'area': 'ஆழ்வார்குறிச்சி (Alwarkurichi)',
      'shortName': 'Alwarkurichi',
      'lat': 8.7833,
      'lng': 77.4000,
      'pincode': '627412',
    },
    {
      'city': 'Tenkasi',
      'area': 'முக்கூடல் (Mukkudal)',
      'shortName': 'Mukkudal',
      'lat': 8.7333,
      'lng': 77.5167,
      'pincode': '627601',
    },
    {
      'city': 'Tenkasi',
      'area': 'திருவேங்கடம் (Thiruvenkatam)',
      'shortName': 'Thiruvenkatam',
      'lat': 9.2800,
      'lng': 77.6500,
      'pincode': '627719',
    },
    {
      'city': 'Tirunelveli',
      'area': 'திருநெல்வேலி (Tirunelveli)',
      'shortName': 'Tirunelveli',
      'lat': 8.7139,
      'lng': 77.7567,
      'pincode': '627002',
    },
    {
      'city': 'Tirunelveli',
      'area': 'அம்பாசமுத்திரம் (Ambasamudram)',
      'shortName': 'Ambasamudram',
      'lat': 8.7058,
      'lng': 77.4526,
      'pincode': '627401',
    },
    {
      'city': 'Madurai',
      'area': 'மதுரை (Madurai)',
      'shortName': 'Madurai',
      'lat': 9.9252,
      'lng': 78.1198,
      'pincode': '625020',
    },
    {
      'city': 'Chennai',
      'area': 'சென்னை (Chennai)',
      'shortName': 'Chennai',
      'lat': 13.0827,
      'lng': 80.2707,
      'pincode': '600001',
    },
  ];

  /// Calculate distance between two coordinates in Kilometers
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    try {
      final meters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
      return meters / 1000.0;
    } catch (_) {
      return 0.0;
    }
  }

  /// Get coordinates for a town name (e.g. 'Pavoorchatram', 'Tenkasi')
  static Map<String, double>? getCoordinatesForTown(String townName) {
    final query = townName.toLowerCase();
    for (final center in _tnKnownCenters) {
      final shortName = (center['shortName'] as String).toLowerCase();
      final area = (center['area'] as String).toLowerCase();
      final city = (center['city'] as String).toLowerCase();
      if (query.contains(shortName) || query.contains(area) || query.contains(city)) {
        return {
          'lat': center['lat'] as double,
          'lng': center['lng'] as double,
        };
      }
    }
    // Default to Tenkasi Central
    return {'lat': 8.9594, 'lng': 77.3160};
  }

  /// Online reverse geocoding using OpenStreetMap Nominatim
  static Future<Map<String, String>?> _reverseGeocodeOnline(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'TenkasiDreamsLand/1.0 (contact@tenkasidreams.com)',
          'Accept-Language': 'ta,en',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final suburb = address['suburb'] ?? address['neighbourhood'] ?? address['hamlet'];
          final village = address['village'] ?? address['town'] ?? address['city_district'];
          final city = address['city'] ?? address['county'] ?? address['state_district'] ?? 'Tenkasi';
          final postcode = address['postcode'] ?? '';

          final areaName = village ?? suburb ?? address['road'] ?? '';
          if (areaName.toString().isNotEmpty) {
            return {
              'area': areaName.toString(),
              'city': city.toString().replaceAll('District', '').trim(),
              'pincode': postcode.toString(),
            };
          }
        }
      }
    } catch (e) {
      debugPrint('Online reverse geocoding note: $e');
    }
    return null;
  }

  /// Request live device location with full mobile permission handling & high accuracy GPS
  static Future<LiveLocationResult> getCurrentLiveLocation({BuildContext? context}) async {
    try {
      // 1. Check if GPS / Location services are enabled on the phone
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context != null && context.mounted) {
          final openSettings = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.location_off_rounded, color: Colors.orange, size: 24),
                  SizedBox(width: 8),
                  Text('GPS சேவை தேவை', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text(
                'உங்கள் நேரலை இருப்பிடத்தைக் கண்டறிய மொபைலில் GPS / Location சேவையை ஆன் செய்யவும்.\n\n(Please turn ON GPS / Location service in your phone)',
                style: TextStyle(fontSize: 13.5),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('ரத்து'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008069),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('GPS Settings ஆன் செய்க'),
                ),
              ],
            ),
          );
          if (openSettings == true) {
            await Geolocator.openLocationSettings();
            await Future.delayed(const Duration(seconds: 1));
            serviceEnabled = await Geolocator.isLocationServiceEnabled();
          }
        }

        if (!serviceEnabled) {
          return _fallbackLocation(
            error: 'மொபைலில் GPS சேவை முடக்கப்பட்டுள்ளது (Location services disabled)',
          );
        }
      }

      // 2. Check and request mobile location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (context != null && context.mounted) {
          final openApp = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.security_rounded, color: Colors.red, size: 24),
                  SizedBox(width: 8),
                  Text('இருப்பிட அனுமதி தேவை', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text(
                'நேரலை GPS இருப்பிடத்தைப் பெற App Settings-ல் Location அனுமதியை இயக்கவும்.\n\n(Location permission is permanently denied. Please enable in App Settings)',
                style: TextStyle(fontSize: 13.5),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('ரத்து'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008069),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Settings திறக்க'),
                ),
              ],
            ),
          );
          if (openApp == true) {
            await Geolocator.openAppSettings();
          }
        }
        return _fallbackLocation(
          error: 'இருப்பிட அனுமதி மறுக்கப்பட்டுள்ளது (Location permission denied forever)',
        );
      }

      if (permission == LocationPermission.denied) {
        return _fallbackLocation(
          error: 'இருப்பிட அனுமதி வழங்கப்படவில்லை (Location permission denied)',
        );
      }

      // 3. Acquire Live Position with high accuracy and fallback to last known
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (e) {
        debugPrint('Current position fetch timeout/error, trying last known position: $e');
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        return _fallbackLocation(
          error: 'நேரலை GPS பெற முடியவில்லை (Could not acquire GPS fix)',
        );
      }

      // 4. Reverse Geocode: Try online first, fallback to closest Tenkasi database match
      Map<String, String>? online = await _reverseGeocodeOnline(position.latitude, position.longitude);
      final local = _findClosestTNLocality(position.latitude, position.longitude);

      final area = (online?['area'] != null && online!['area']!.isNotEmpty)
          ? online['area']!
          : local['area']!;

      final city = (online?['city'] != null && online!['city']!.isNotEmpty)
          ? online['city']!
          : local['city']!;

      final pincode = (online?['pincode'] != null && online!['pincode']!.isNotEmpty)
          ? online['pincode']!
          : local['pincode']!;

      return LiveLocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        estimatedArea: area,
        estimatedCity: city,
        postalCode: pincode,
        isLiveGps: true,
      );
    } catch (e) {
      debugPrint('Live location error: $e');
      return _fallbackLocation(error: 'நேரலை GPS பிழை: $e');
    }
  }

  static Map<String, String> _findClosestTNLocality(double lat, double lng) {
    double minDistance = double.infinity;
    Map<String, dynamic> closest = _tnKnownCenters.first;

    for (final center in _tnKnownCenters) {
      final dLat = (center['lat'] as double) - lat;
      final dLng = (center['lng'] as double) - lng;
      final distSq = dLat * dLat + dLng * dLng;
      if (distSq < minDistance) {
        minDistance = distSq;
        closest = center;
      }
    }

    return {
      'area': closest['shortName'] as String,
      'fullName': closest['area'] as String,
      'city': closest['city'] as String,
      'pincode': closest['pincode'] as String,
    };
  }

  static LiveLocationResult _fallbackLocation({String? error}) {
    return LiveLocationResult(
      latitude: 8.9594,
      longitude: 77.3160,
      accuracy: 25.0,
      estimatedArea: 'Tenkasi',
      estimatedCity: 'Tenkasi',
      postalCode: '627811',
      isLiveGps: false,
      error: error,
    );
  }

  /// Generates a Google Maps URL for opening in browser / native Maps app
  static String getGoogleMapsUrl(double lat, double lng, {String? label}) {
    final query = label != null ? Uri.encodeComponent(label) : '$lat,$lng';
    return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$query';
  }
}

