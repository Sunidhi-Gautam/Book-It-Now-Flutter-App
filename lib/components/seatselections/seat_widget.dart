import 'package:book_my_seat/book_my_seat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class SeatWidget extends StatefulWidget {
  final SeatModel model;
  final void Function(int rowI, int colI, SeatState currentState) onSeatStateChanged;

  const SeatWidget({
    super.key,
    required this.model,
    required this.onSeatStateChanged,
  });

  @override
  State<SeatWidget> createState() => _SeatWidgetState();
}

class _SeatWidgetState extends State<SeatWidget> {
  late SeatState seatState;

  @override
  void initState() {
    super.initState();
    seatState = widget.model.seatState;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (seatState == SeatState.unselected) {
          setState(() => seatState = SeatState.selected);
        } else if (seatState == SeatState.selected) {
          setState(() => seatState = SeatState.unselected);
        } else {
          return; // sold or disabled cannot be tapped
        }
        widget.onSeatStateChanged(widget.model.rowI, widget.model.colI, seatState);
      },
      child: seatState != SeatState.empty
          ? SvgPicture.asset(
              _getSvgForSeat(seatState),
              width: widget.model.seatSvgSize.toDouble(),
              height: widget.model.seatSvgSize.toDouble(),
            )
          : SizedBox(
              width: widget.model.seatSvgSize.toDouble(),
              height: widget.model.seatSvgSize.toDouble(),
            ),
    );
  }

  String _getSvgForSeat(SeatState state) {
    switch (state) {
      case SeatState.selected:
        return widget.model.pathSelectedSeat;
      case SeatState.unselected:
        return widget.model.pathUnSelectedSeat;
      case SeatState.sold:
        return widget.model.pathSoldSeat;
       case SeatState.disabled:
        return widget.model.pathDisabledSeat;
      case SeatState.empty:
      default:
        return '';
    }
  }
}
