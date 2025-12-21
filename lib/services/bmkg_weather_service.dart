import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherPoint {
  final DateTime localDateTime;
  final String weatherDesc;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String windDirection;
  final String? visibility;

  WeatherPoint({
    required this.localDateTime,
    required this.weatherDesc,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    this.visibility,
  });

  factory WeatherPoint.fromJson(Map<String, dynamic> json) {
    return WeatherPoint(
      localDateTime: DateTime.parse(json['local_datetime'] as String),
      weatherDesc: json['weather_desc'] as String? ?? '-',
      temperature: double.tryParse(json['t'].toString()) ?? 0,
      humidity: int.tryParse(json['hu'].toString()) ?? 0,
      windSpeed: double.tryParse(json['ws'].toString()) ?? 0,
      windDirection: json['wd'] as String? ?? '-',
      visibility: json['vs_text'] as String?,
    );
  }
}

class BmkgForecast {
  final String desa;
  final String kecamatan;
  final String kota;
  final String provinsi;
  final List<WeatherPoint> points;

  BmkgForecast({
    required this.desa,
    required this.kecamatan,
    required this.kota,
    required this.provinsi,
    required this.points,
  });

  factory BmkgForecast.fromJson(Map<String, dynamic> json) {
    final lokasi = json['lokasi'] as Map<String, dynamic>;
    final List<dynamic> cuacaHari = json['data'][0]['cuaca'] as List<dynamic>;

    final List<WeatherPoint> allPoints = [];

    for (final hari in cuacaHari) {
      if (hari is List) {
        for (final item in hari) {
          if (item is Map<String, dynamic>) {
            allPoints.add(WeatherPoint.fromJson(item));
          }
        }
      }
    }

    return BmkgForecast(
      desa: (lokasi['desa'] ?? '') as String,
      kecamatan: (lokasi['kecamatan'] ?? '') as String,
      kota: (lokasi['kotkab'] ?? '') as String,
      provinsi: (lokasi['provinsi'] ?? '') as String,
      points: allPoints,
    );
  }
}

class BmkgWeatherService {
  static const _baseUrl = 'https://api.bmkg.go.id/publik/prakiraan-cuaca';

  Future<BmkgForecast> getForecast(String adm4Code) async {
    final uri = Uri.parse('$_baseUrl?adm4=$adm4Code');

    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('Gagal mengambil data BMKG: ${resp.statusCode}');
    }

    final jsonMap = json.decode(resp.body) as Map<String, dynamic>;
    return BmkgForecast.fromJson(jsonMap);
  }
}
