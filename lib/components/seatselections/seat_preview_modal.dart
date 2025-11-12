// lib/components/seatselections/seat_preview_modal.dart
// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import '../../models/constants.dart';

class SeatPreviewModal extends StatelessWidget {
  final String seatLabel;
  final VoidCallback onSelectSeat;
  final VoidCallback onClose;
  final String seatComment;

  const SeatPreviewModal({
    super.key,
    required this.seatLabel,
    required this.onSelectSeat,
    required this.onClose,
    required this.seatComment,
  });

  String _getSeatViewPath(String seatLabel) {
    seatLabel = seatLabel.toUpperCase();
    if (RegExp(r'^[A-D]').hasMatch(seatLabel)) {
      return 'assets/images/front_middle.png';
    }
    if (RegExp(r'^[E-H]').hasMatch(seatLabel)) {
      if (RegExp(r'[1-2]$').hasMatch(seatLabel))
        return 'assets/images/centre_middle_left.png';
      if (RegExp(r'(9|10)$').hasMatch(seatLabel))
        return 'assets/images/centre_middle_right.png';
      return 'assets/images/centre_middle.png';
    }
    if (RegExp(r'^[I-J]').hasMatch(seatLabel)) {
      if (RegExp(r'[1-2]$').hasMatch(seatLabel))
        return 'assets/images/far_left.png';
      if (RegExp(r'(9|10)$').hasMatch(seatLabel))
        return 'assets/images/far_right.png';
      if (RegExp(r'[3-4]$').hasMatch(seatLabel))
        return 'assets/images/far_middle_left.png';
      if (RegExp(r'[7-8]$').hasMatch(seatLabel))
        return 'assets/images/far_middle_right.png';
      return 'assets/images/far_middle.png';
    }
    return 'assets/images/front_middle.png';
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _getSeatViewPath(seatLabel);

    return Dialog(
      backgroundColor: const Color.fromARGB(191, 0, 0, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 60),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("View from Seat $seatLabel",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                    color: Color.fromARGB(255, 67, 65, 65),
                    spreadRadius: 2,
                    blurRadius: 15,
                    offset: Offset(0, 6))
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(imagePath,
                  fit: BoxFit.cover, height: 200, width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                return Container(
                    height: 200,
                    color: Colors.grey.shade800,
                    child: const Center(
                        child: Text('Preview unavailable',
                            style: TextStyle(color: Colors.white70))));
              }),
            ),
          ),
          const SizedBox(height: 25),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.comment, color: Colors.amber, size: 20),
            const SizedBox(width: 10),
            Expanded(
                child: Text(seatComment,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 25),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ElevatedButton(
              onPressed: onSelectSeat,
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text("Select Seat",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            OutlinedButton(
              onPressed: onClose,
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text("Close View",
                  style: TextStyle(color: Colors.white70)),
            ),
          ]),
        ]),
      ),
    );
  }
}
