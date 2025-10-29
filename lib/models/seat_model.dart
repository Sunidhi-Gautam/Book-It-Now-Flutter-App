import 'package:book_my_seat/book_my_seat.dart';

class SeatModel {
  final int rowI;
  final int colI;
  final SeatState seatState;
  final int seatSvgSize;
  final String pathSelectedSeat;
  final String pathPreviewSeat;
  final String pathUnSelectedSeat;
  final String pathSoldSeat;
  final String pathDisabledSeat;

  const SeatModel({
    required this.rowI,
    required this.colI,
    required this.seatState,
    required this.pathSelectedSeat,
    required this.pathPreviewSeat,
    required this.pathUnSelectedSeat,
    required this.pathSoldSeat,
    required this.pathDisabledSeat,
    this.seatSvgSize = 20,
  });
}
