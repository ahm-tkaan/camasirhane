import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../utils/constants.dart';
import 'status_badge.dart';

/// Makine kartı widget'ı - listelerde kullanılır
class MachineCard extends StatelessWidget {
  final Machine machine;
  final Function(Machine) onUse;

  const MachineCard({
    Key? key,
    required this.machine,
    required this.onUse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      child: Row(
        children: [
          // Durum indikatörü
          _buildStatusIndicator(),
          const SizedBox(width: 12.0),

          // Makine bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  machine.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                _buildStatusText(),
              ],
            ),
          ),

          // Kullan butonu (sadece kullanılabilir makineler için)
          if (machine.status == MachineStatus.available)
            _buildUseButton(),
        ],
      ),
    );
  }

  /// Durum gösterge noktası
  Widget _buildStatusIndicator() {
    Color color;

    switch (machine.status) {
      case MachineStatus.available:
        color = AppColors.success;
        break;
      case MachineStatus.inUse:
        color = AppColors.warning;
        break;
      case MachineStatus.outOfOrder:
        color = AppColors.error;
        break;
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  /// Durum metni
  Widget _buildStatusText() {
    String statusText;

    switch (machine.status) {
      case MachineStatus.available:
        statusText = AppTexts.available;
        break;
      case MachineStatus.inUse:
        statusText = '${AppTexts.inUse} (${machine.endTime} bitiş)';
        break;
      case MachineStatus.outOfOrder:
        statusText = 'Arızalı - Teknik destek bekliyor';
        break;
    }

    return Text(
      statusText,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12.0,
      ),
    );
  }

  /// Kullan butonu
  Widget _buildUseButton() {
    return ElevatedButton(
      onPressed: () => onUse(machine),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 10.0,
        ),
        minimumSize: const Size(0, 0),
        textStyle: const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: const Text(AppTexts.use),
    );
  }
}