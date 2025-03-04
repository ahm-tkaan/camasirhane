import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../utils/constants.dart';
import 'status_badge.dart';

/// Makine kartı widget'ı - listelerde kullanılır
class MachineCard extends StatelessWidget {
  final Machine machine;
  final Function(Machine) onUse;
  final Function(Machine)? onViewUser; // Yeni: Kullanıcı bilgisini görüntülemek için callback

  const MachineCard({
    Key? key,
    required this.machine,
    required this.onUse,
    this.onViewUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: machine.status == MachineStatus.inUse ? () => _handleTap(context) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Row(
          children: [
            // Makine tipi ve durum indikatörü
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

            // Sağ taraf: Durum rozetleri veya butonlar
            _buildRightContent(context),
          ],
        ),
      ),
    );
  }

  // Kart'a tıklama işleme
  void _handleTap(BuildContext context) {
    // Eğer makine kullanımda ve onViewUser callback'i varsa, kullanıcı bilgisini göster
    if (machine.status == MachineStatus.inUse && onViewUser != null) {
      onViewUser!(machine);
    }
  }

  /// Durum gösterge noktası ve icon
  Widget _buildStatusIndicator() {
    IconData iconData;

    // Makine tipine göre icon seç
    if (machine.type == MachineType.washer) {
      iconData = Icons.local_laundry_service;
    } else {
      iconData = Icons.dry;
    }

    // Durum rengini belirle
    Color color;
    switch (machine.status) {
      case MachineStatus.available:
        color = AppColors.success;
        break;
      case MachineStatus.inUse:
        color = machine.isUsersMachine ? AppColors.primary : AppColors.warning;
        break;
      case MachineStatus.outOfOrder:
        color = AppColors.error;
        break;
    }

    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            iconData,
            color: color,
            size: 20,
          ),
        ),
        if (machine.isUsersMachine)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  /// Durum metni
  Widget _buildStatusText() {
    String statusText;
    Widget? additionalInfo;

    switch (machine.status) {
      case MachineStatus.available:
        statusText = AppTexts.available;
        break;
      case MachineStatus.inUse:
        statusText = machine.isUsersMachine
            ? 'Sizin makineniz (${machine.endTime} bitiş)'
            : '${AppTexts.inUse} (${machine.endTime} bitiş)';

        // Kalan süre göster
        if (machine.remainingMinutes != null) {
          additionalInfo = Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              'Kalan süre: ${machine.remainingMinutes} dakika',
              style: TextStyle(
                fontSize: 11.0,
                color: machine.isUsersMachine ? AppColors.primary : AppColors.textSecondary,
                fontWeight: machine.isUsersMachine ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }
        break;
      case MachineStatus.outOfOrder:
        statusText = 'Arızalı - Teknik destek bekliyor';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          statusText,
          style: TextStyle(
            color: machine.isUsersMachine ? AppColors.primary : AppColors.textSecondary,
            fontSize: 12.0,
            fontWeight: machine.isUsersMachine ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (additionalInfo != null) additionalInfo,
      ],
    );
  }

  /// Sağ taraftaki içerik (buton veya rozet)
  Widget _buildRightContent(BuildContext context) {
    switch (machine.status) {
      case MachineStatus.available:
        return _buildUseButton();
      case MachineStatus.inUse:
      // Kullanımdaki makine için durum rozeti ve info butonu
        return Row(
          children: [
            if (onViewUser != null)
              IconButton(
                icon: const Icon(Icons.info_outline, size: 18),
                color: AppColors.primary,
                onPressed: () => onViewUser!(machine),
                tooltip: 'Kullanıcı Bilgisi',
              ),
            const SizedBox(width: 4),
            StatusBadge.fromStatus(MachineStatus.inUse, compact: true),
          ],
        );
      case MachineStatus.outOfOrder:
        return StatusBadge.fromStatus(MachineStatus.outOfOrder, compact: true);
      default:
        return const SizedBox.shrink();
    }
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