import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Yoğunluk grafiği widget'ı - çamaşırhanenin saatlik doluluk oranını gösterir
class OccupancyChart extends StatelessWidget {
  final Map<int, double> occupancyData;

  const OccupancyChart({
    Key? key,
    required this.occupancyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Verileri sırala
    final sortedHours = occupancyData.keys.toList()..sort();

    // Maksimum ve minimum değerleri bul
    final double maxOccupancy = occupancyData.values.reduce((a, b) => a > b ? a : b);
    final double minOccupancy = occupancyData.values.reduce((a, b) => a < b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Y ekseni etiketleri
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Dolu',
                    style: TextStyle(
                      fontSize: 10.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 45),
                  const Text('Müsait',
                    style: TextStyle(
                      fontSize: 10.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Ana grafik
              Expanded(
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                    border: Border.all(
                      color: AppColors.border,
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: sortedHours.map((hour) {
                        // Doluluk oranına göre yükseklik ayarla
                        final value = occupancyData[hour] ?? 0.0;
                        final normalizedHeight = ((value - minOccupancy) / (maxOccupancy - minOccupancy)) * 100.0;

                        // Renk hesapla (yeşilden kırmızıya doğru)
                        final Color barColor = _getBarColor(value);

                        return _buildBar(hour, normalizedHeight, barColor);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // X ekseni etiketleri
          Padding(
            padding: const EdgeInsets.only(left: 28.0, top: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: sortedHours.map((hour) => Text(
                '$hour:00',
                style: const TextStyle(
                  fontSize: 10.0,
                  color: AppColors.textSecondary,
                ),
              )).toList(),
            ),
          ),

          // Lejant
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 8.0),
            child: Row(
              children: [
                _buildLegendItem(AppColors.success, 'Az Yoğun'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.orange, 'Orta Yoğun'),
                const SizedBox(width: 16),
                _buildLegendItem(AppColors.error, 'Çok Yoğun'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Lejant öğesi
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.0),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.0,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // Yoğunluk çubuğu
  Widget _buildBar(int hour, double heightPercentage, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: heightPercentage,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.0),
          ),
        ),
      ],
    );
  }

  // Yoğunluğa göre çubuk rengi hesapla
  Color _getBarColor(double value) {
    // 0-10 skalasında renk değişimi
    if (value <= 3.0) {
      return AppColors.success; // Az yoğun - yeşil
    } else if (value <= 6.0) {
      return Colors.orange; // Orta yoğun - turuncu
    } else {
      return AppColors.error; // Çok yoğun - kırmızı
    }
  }
}