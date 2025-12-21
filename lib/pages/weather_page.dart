import 'package:flutter/material.dart';
import 'package:smart_farming/services/bmkg_weather_service.dart';
import 'package:smart_farming/theme/app_colors.dart';

// 2. Weather Dashboard Screen Updated
class WeatherDashboardScreen extends StatefulWidget {
  const WeatherDashboardScreen({super.key});

  @override
  State<WeatherDashboardScreen> createState() => _WeatherDashboardScreenState();
}

class _WeatherDashboardScreenState extends State<WeatherDashboardScreen> {
  final _service = BmkgWeatherService();
  final String _adm4Code = '16.71.07.1005';

  late Future<BmkgForecast> _futureForecast;

  @override
  void initState() {
    super.initState();
    _futureForecast = _service.getForecast(_adm4Code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Menggunakan Cream
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.accent, // Menggunakan Deep Teal untuk kontras
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Smart Agriculture IoT',
              style: TextStyle(
                color: AppColors.accent, // Deep Teal agar tegas
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Sistem Monitoring & Kontrol Pertanian Cerdas',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary // Abu-abu gelap natural
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.notifications_none, size: 22, color: AppColors.textSecondary),
          SizedBox(width: 12),
          Icon(Icons.settings_outlined, size: 22, color: AppColors.textSecondary),
          SizedBox(width: 12),
          Icon(Icons.person_outline, size: 22, color: AppColors.textSecondary),
          SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<BmkgForecast>(
        future: _futureForecast,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          final data = snapshot.data!;
          final now = DateTime.now();

          // Cari titik prakiraan terdekat
          data.points.sort(
                (a, b) => (a.localDateTime.difference(now)).abs().compareTo(
              (b.localDateTime.difference(now)).abs(),
            ),
          );
          final current = data.points.first;

          // Logika probabilitas hujan sederhana
          final lowerDesc = current.weatherDesc.toLowerCase();
          final int rainProbability = lowerDesc.contains('hujan')
              ? 80
              : lowerDesc.contains('berawan')
              ? 60
              : 20;

          // Grouping harian
          final Map<DateTime, WeatherPoint> daily = {};
          for (final p in data.points) {
            final d = DateTime(p.localDateTime.year, p.localDateTime.month, p.localDateTime.day);
            if (!daily.containsKey(d)) {
              daily[d] = p;
            }
          }
          final List<DateTime> sortedDays = daily.keys.toList()
            ..sort((a, b) => a.compareTo(b));
          final today = DateTime(now.year, now.month, now.day);
          final dailyCards = sortedDays
              .where((d) => !d.isBefore(today))
              .take(4)
              .map((d) => MapEntry(d, daily[d]!))
              .toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              setState(() {
                _futureForecast = _service.getForecast(_adm4Code);
              });
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Cuaca Pintar',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent, // Deep Teal
                  ),
                ),
                const SizedBox(height: 16),

                // ======= Top small cards (2x2 grid) =======
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildStatCard(
                      title: 'Suhu Udara',
                      value: current.temperature.toStringAsFixed(0),
                      unit: '°C',
                      icon: Icons.thermostat,
                      // Background icon menggunakan primary dengan opacity
                      iconBg: AppColors.primary.withOpacity(0.15),
                      iconColor: AppColors.primary,
                    ),
                    _buildStatCard(
                      title: 'Kelembaban', // Dipersingkat agar muat
                      value: '${current.humidity}',
                      unit: '%',
                      icon: Icons.water_drop,
                      iconBg: AppColors.info.withOpacity(0.15),
                      iconColor: AppColors.info,
                    ),
                    _buildStatCard(
                      title: 'Kecepatan Angin',
                      value: current.windSpeed.toStringAsFixed(0),
                      unit: 'km/h',
                      icon: Icons.air,
                      iconBg: AppColors.secondary.withOpacity(0.3),
                      iconColor: AppColors.primaryDark,
                    ),
                    _buildStatCard(
                      title: 'Prediksi Hujan',
                      value: '$rainProbability',
                      unit: '%',
                      icon: Icons.bolt,
                      // Menggunakan warna Warning (Gold/Orange) untuk hujan
                      iconBg: AppColors.warning.withOpacity(0.2),
                      iconColor: AppColors.warning,
                      customBgColor: AppColors.surfaceVariant,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ======= Main current weather card =======
                _buildMainWeatherCard(data, current, dailyCards),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    Color? customBgColor,
  }) {
    // Default card background adalah Surface Variant (Putih)
    final cardColor = customBgColor ?? AppColors.surfaceVariant;

    return SizedBox(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: AppColors.textPrimary),
                      children: [
                        TextSpan(
                          text: value,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' $unit',
                          style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainWeatherCard(
      BmkgForecast data,
      WeatherPoint current,
      List<MapEntry<DateTime, WeatherPoint>> dailyCards,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant, // Putih agar kontras dengan Cream
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cuaca Saat Ini',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data.kota}, ${data.provinsi}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              // Icon Matahari diberi warna Warning (Gold)
              const Icon(Icons.wb_sunny, color: AppColors.warning, size: 30),
            ],
          ),

          const SizedBox(height: 24),

          Center(
            child: Column(
              children: [
                Text(
                  '${current.temperature.toStringAsFixed(0)}°C',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary, // Sage Green
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  current.weatherDesc,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: AppColors.divider),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomStat(
                icon: Icons.water_drop,
                label: 'Kelembaban',
                value: '${current.humidity}%',
              ),
              _buildBottomStat(
                icon: Icons.air,
                label: 'Angin',
                value: '${current.windSpeed.toStringAsFixed(1)} km/h',
              ),
              _buildBottomStat(
                icon: Icons.remove_red_eye_outlined,
                label: 'Visibilitas',
                value: current.visibility ?? '-',
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 10),

          const Text(
            'Prakiraan 4 Hari',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: dailyCards.map((entry) {
                final d = entry.key;
                final p = entry.value;
                final dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
                final dayLabel = dayNames[d.weekday % 7];

                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    // Menggunakan Light Mint (Surface) untuk kartu di dalam kartu
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Icon(Icons.wb_sunny, color: AppColors.warning, size: 20),
                      const SizedBox(height: 6),
                      Text(
                        '${p.temperature.toStringAsFixed(0)}°C',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}