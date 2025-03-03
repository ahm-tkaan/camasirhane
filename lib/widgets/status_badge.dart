import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../utils/constants.dart';

/// Durumu görsel olarak gösteren rozet widget'ı
class StatusBadge extends StatelessWidget {
  final MachineStatus status;
  final String text;
  final bool compact;

  const StatusBadge({
    Key? key,
    required this.status,
    required this.text,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8.0 : 12.0,
        vertical: compact ? 4.0 : 6.0,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(compact ? 4.0 : 12.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _getTextColor(),
          fontSize: compact ? 10.0 : 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Durum tipine göre arka plan rengi
  Color _getBackgroundColor() {
    switch (status) {
      case MachineStatus.available:
        return AppColors.successLight;
      case MachineStatus.inUse:
        return AppColors.primaryLight;
      case MachineStatus.outOfOrder:
        return AppColors.warningLight;
    }
  }

  /// Durum tipine göre yazı rengi
  Color _getTextColor() {
    switch (status) {
      case MachineStatus.available:
        return AppColors.success;
      case MachineStatus.inUse:
        return AppColors.primaryDark;
      case MachineStatus.outOfOrder:
        return AppColors.warning;
    }
  }

  /// Durum için önceden tanımlanmış rozet oluşturma
  factory StatusBadge.fromStatus(MachineStatus status, {bool compact = false}) {
    String text;

    switch (status) {
      case MachineStatus.available:
        text = AppTexts.available;
        break;
      case MachineStatus.inUse:
        text = AppTexts.inProgress;
        break;
      case MachineStatus.outOfOrder:
        text = 'Arızalı';
        break;
    }

    return StatusBadge(
      status: status,
      text: text,
      compact: compact,
    );
  }
}