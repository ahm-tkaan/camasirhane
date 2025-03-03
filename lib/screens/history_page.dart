import 'package:flutter/material.dart';
import '../utils/constants.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Mock geçmiş veri listesi
  final List<HistoryItem> _historyItems = [
    HistoryItem(
      id: '1',
      machineName: 'Çamaşır Makinesi 3',
      date: DateTime.now().subtract(const Duration(days: 1)),
      startTime: '14:30',
      endTime: '15:10',
      isWasher: true,
    ),
    HistoryItem(
      id: '2',
      machineName: 'Kurutma Makinesi 1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      startTime: '15:15',
      endTime: '15:45',
      isWasher: false,
    ),
    HistoryItem(
      id: '3',
      machineName: 'Çamaşır Makinesi 1',
      date: DateTime.now().subtract(const Duration(days: 5)),
      startTime: '10:30',
      endTime: '11:10',
      isWasher: true,
    ),
    HistoryItem(
      id: '4',
      machineName: 'Çamaşır Makinesi 2',
      date: DateTime.now().subtract(const Duration(days: 7)),
      startTime: '16:45',
      endTime: '17:25',
      isWasher: true,
    ),
    HistoryItem(
      id: '5',
      machineName: 'Çamaşır Makinesi 3',
      date: DateTime.now().subtract(const Duration(days: 12)),
      startTime: '20:15',
      endTime: '20:55',
      isWasher: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Geçmiş verilerini tarihe göre gruplandır
    final groupedHistory = _groupHistoryByDate();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          const Text(
            'Çamaşır Geçmişim',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8.0),

          // Toplam kullanım sayısı
          Text(
            'Toplam ${_historyItems.length} kullanım',
            style: const TextStyle(
              fontSize: 14.0,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24.0),

          // Geçmiş listesi
          if (groupedHistory.isEmpty)
            _buildEmptyState()
          else
            _buildHistoryList(groupedHistory),
        ],
      ),
    );
  }

  // Geçmiş verilerini tarihe göre gruplandırma
  Map<String, List<HistoryItem>> _groupHistoryByDate() {
    final Map<String, List<HistoryItem>> grouped = {};

    for (var item in _historyItems) {
      final dateKey = _formatDateKey(item.date);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }

      grouped[dateKey]!.add(item);
    }

    return grouped;
  }

  // Tarih anahtarını formatla
  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Bugün';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Dün';
    } else if (date.isAfter(now.subtract(const Duration(days: 7)))) {
      // Son 7 gün içindeyse haftanın gününü göster
      return _getWeekday(date);
    } else {
      // Daha önceyse tam tarihi göster
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    }
  }

  // Haftanın gününü döndür
  String _getWeekday(DateTime date) {
    const weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    // DateTime'in weekday'i 1-7 arası, Pazartesi=1, Pazar=7
    return weekdays[date.weekday - 1];
  }

  // Geçmiş listesi widget'ı
  Widget _buildHistoryList(Map<String, List<HistoryItem>> groupedHistory) {
    // Tarihleri sırala - Bugün ve Dün'ü en başa getir
    final sortedDates = groupedHistory.keys.toList()..sort((a, b) {
      if (a == 'Bugün') return -1;
      if (b == 'Bugün') return 1;
      if (a == 'Dün') return -1;
      if (b == 'Dün') return 1;
      return 0;
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final items = groupedHistory[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarih başlığı
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Bu tarihe ait geçmiş öğeleri
            ...items.map((item) => _buildHistoryItem(item)),

            // Ayırıcı (son öğeden sonra hariç)
            if (index < sortedDates.length - 1)
              const Divider(height: 32.0),
          ],
        );
      },
    );
  }

  // Geçmiş öğesi widget'ı
  Widget _buildHistoryItem(HistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.isWasher ? AppColors.primaryLight : AppColors.warningLight,
          child: Icon(
            item.isWasher ? Icons.local_laundry_service : Icons.dry,
            color: item.isWasher ? AppColors.primary : AppColors.warning,
          ),
        ),
        title: Text(
          item.machineName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${item.startTime} - ${item.endTime}',
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16.0,
          color: AppColors.textSecondary,
        ),
        onTap: () => _showHistoryDetails(item),
      ),
    );
  }

  // Boş durum widget'ı
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 80.0,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Henüz çamaşır geçmişiniz bulunmuyor',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Çamaşır makinesi kullandığınızda geçmişiniz burada görünecek',
            style: TextStyle(
              fontSize: 14.0,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Geçmiş öğesi detay dialogu
  void _showHistoryDetails(HistoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.machineName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Tarih', _formatDetailDate(item.date)),
            const SizedBox(height: 8.0),
            _buildDetailRow('Başlangıç', item.startTime),
            const SizedBox(height: 8.0),
            _buildDetailRow('Bitiş', item.endTime),
            const SizedBox(height: 8.0),
            _buildDetailRow('Süre', '40 dakika'),
            const SizedBox(height: 8.0),
            _buildDetailRow('Program', item.isWasher ? 'Normal Yıkama' : 'Normal Kurutma'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Detay satırı widget'ı
  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // Detay tarihini formatla
  String _formatDetailDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${_getWeekday(date)}';
  }
}

// Geçmiş öğesi sınıfı
class HistoryItem {
  final String id;
  final String machineName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool isWasher;

  HistoryItem({
    required this.id,
    required this.machineName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isWasher,
  });
}