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
    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          _buildHeader(),

          // İçerik
          _buildContent(),
        ],
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
      child: const Text(
        AppTexts.activeMachine,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
    );
  }

  /// Kart içeriği
  Widget _buildContent() {
    return InkWell(
      onTap: onPressed,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(12.0),
        bottomRight: Radius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machine.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${AppTexts.estimatedEnd}: ${machine.endTime}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.0,
                    ),
                  ),

                  if (machine.remainingMinutes != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _buildProgressIndicator(),
                    ),
                ],
              ),
            ),
            const StatusBadge(
              status: MachineStatus.inUse,
              text: AppTexts.inProgress,
            ),
          ],
        ),
      ),
    );
  }

  /// İlerleme çubuğu - kalan süreyi gösterir
  Widget _buildProgressIndicator() {
    // Toplam süreyi 40 dakika olarak varsayalım
    const totalMinutes = 40.0;
    final remainingMinutes = machine.remainingMinutes ?? 0;
    final progress = 1.0 - (remainingMinutes / totalMinutes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: AppColors.border,
          color: AppColors.primary,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4.0),
        Text(
          '$remainingMinutes dakika kaldı',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}