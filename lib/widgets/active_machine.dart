import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../utils/constants.dart';
import 'status_badge.dart';

/// Aktif makine kartı widget'ı - ana sayfada kullanılır
class ActiveMachineCard extends StatelessWidget {
  final Machine machine;
  final VoidCallback? onPressed;

  const ActiveMachineCard({
    Key? key,
    required this.machine,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Makine programını belirle
    final programName = _getProgramName(machine.programType);

    // Tamamlanma yüzdesini hesapla
    final completionPercentage = machine.getCompletionPercentage();

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            _buildHeader(),

            // İçerik
            _buildContent(programName, completionPercentage),
          ],
        ),
      ),
    );
  }

  /// Kart başlığı
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wash,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          const Text(
            AppTexts.activeMachine,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              machine.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kart içeriği
  Widget _buildContent(String programName, double completionPercentage) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bilgi satırları
          Row(
            children: [
              // Sol taraf - İlerleme durumu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Program
                    _buildInfoRow(
                      Icons.settings,
                      'Program',
                      programName,
                    ),
                    const SizedBox(height: 8),

                    // Başlangıç ve bitiş zamanları
                    Row(
                      children: [
                        // Başlangıç
                        Expanded(
                          child: _buildInfoRow(
                            Icons.play_circle_outline,
                            'Başlangıç',
                            machine.startTime ?? '?',
                          ),
                        ),
                        // Bitiş
                        Expanded(
                          child: _buildInfoRow(
                            Icons.stop_circle_outlined,
                            'Bitiş',
                            machine.endTime ?? '?',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Sağ taraf - Kalan süre
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Kalan',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${machine.remainingMinutes ?? "?"}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'dakika',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // İlerleme çubuğu
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'İlerleme Durumu: %${completionPercentage.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const StatusBadge(
                    status: MachineStatus.inUse,
                    text: AppTexts.inProgress,
                    compact: true,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: completionPercentage / 100.0,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),

          // Detaylar için bilgi
          if (onPressed != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Detaylar için tıklayın',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Bilgi satırı widget'ı
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Program tipine göre isim döndür
  String _getProgramName(ProgramType? programType) {
    if (programType == null) return 'Bilinmiyor';

    switch (programType) {
      case ProgramType.quickWash:
        return 'Hızlı Yıkama';
      case ProgramType.normalWash:
        return 'Normal Yıkama';
      case ProgramType.heavyWash:
        return 'Yoğun Yıkama';
      case ProgramType.ecoWash:
        return 'Ekonomik Yıkama';
      case ProgramType.quickDry:
        return 'Hızlı Kurutma';
      case ProgramType.normalDry:
        return 'Normal Kurutma';
      case ProgramType.intenseDry:
        return 'Yoğun Kurutma';
      default:
        return 'Bilinmiyor';
    }
  }
}