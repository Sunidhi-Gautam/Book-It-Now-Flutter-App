// ignore_for_file: file_names

import 'package:bookmyshowclone/screens/homepage.dart';

import '../components/ticketbooking/showTiming.dart';
import '../models/constants.dart';
import 'package:flutter/material.dart';

class Ticketbookingscreen extends StatefulWidget {
  const Ticketbookingscreen({super.key, required this.movieIndex});
  final int movieIndex;
  @override
  State<Ticketbookingscreen> createState() => _TicketbookingscreenState();
}

class _TicketbookingscreenState extends State<Ticketbookingscreen> {
  @override
  Widget build(BuildContext context) {
    final movieName=movieData[widget.movieIndex];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(movieName['title'], style: TextStyle(color: darkColor, fontSize: textContent, fontFamily: primaryFont),),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ShowTimingSelector(movieIndex: widget.movieIndex, onDateSelected: (DateTime selectedDate) {  },),
            const HomePageScreen()
          ],
        ),
      )
    );
  }
}
