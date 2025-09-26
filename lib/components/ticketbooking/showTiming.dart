// show_timing_selector.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add 'intl: ^0.18.1' to your pubspec.yaml if not already there
import '../../models/constants.dart';

// Define the signature for the callback function
typedef DateSelectionCallback = void Function(DateTime selectedDate);

class ShowTimingSelector extends StatefulWidget {
  const ShowTimingSelector({
    super.key,
    required this.movieIndex,
    required this.onDateSelected,
  });

  final int movieIndex;
  final DateSelectionCallback onDateSelected;

  @override
  State<ShowTimingSelector> createState() => _ShowTimingSelectorState();
}

class _ShowTimingSelectorState extends State<ShowTimingSelector> {
  int _selectedDateIndex = 0;
  List<DateTime> _nextSevenDays = [];

  @override
  void initState() {
    super.initState();
    _generateNextSevenDays();
    // Trigger the initial callback with today's date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_nextSevenDays.isNotEmpty) {
        widget.onDateSelected(_nextSevenDays[_selectedDateIndex]);
      }
    });
  }

  void _generateNextSevenDays() {
    final now = DateTime.now();
    _nextSevenDays = List.generate(7, (index) {
      return DateTime(now.year, now.month, now.day).add(Duration(days: index));
    });
  }

  String _formatDay(DateTime date) {
    if (date.day == DateTime.now().day) {
      return 'Today';
    } else if (date.day == DateTime.now().add(const Duration(days: 1)).day) {
      return 'Tomorrow';
    }
    return DateFormat('EEE').format(date); // e.g., 'Mon', 'Tue'
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd').format(date); // e.g., '25'
  }

  String _formatMonth(DateTime date) {
    return DateFormat('MMM').format(date); // e.g., 'Sep'
  }

  @override
  Widget build(BuildContext context) {
  // Note: movieData and priceRange must be defined in constants.dart

    final movieIndexData = movieData[widget.movieIndex % movieData.length];
    
    return Column(
      children: [
        const SizedBox(height: 10,),
        SizedBox(
          height: 80,
          child: ListView.builder(
            itemCount: _nextSevenDays.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) {
              final date = _nextSevenDays[index];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDateIndex = index;
                  });
                  widget.onDateSelected(date);
                },
                child: Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: _selectedDateIndex == index ? kPrimaryColor : const Color.fromARGB(93, 255, 255, 255),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 240, 234, 234).withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatDay(date),
                        style: TextStyle(
                            color: _selectedDateIndex == index ? Colors.white : const Color.fromARGB(255, 13, 12, 12),
                            fontSize: 14),
                      ),
                      Text(
                        _formatDate(date),
                        style: TextStyle(
                            color: _selectedDateIndex == index ? Colors.white : const Color.fromARGB(255, 19, 19, 19),
                            fontFamily: primaryFont, // Replace with primaryFont variable
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatMonth(date),
                        style: TextStyle(
                            color: _selectedDateIndex == index ? Colors.white : const Color.fromARGB(255, 22, 14, 14),
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(vertical : 15, horizontal: 8),
          child: Row(
            children: [
              const Text(
                "Languages: ",
                style: TextStyle(color: Color.fromARGB(255, 243, 239, 239), fontSize: 14), // Replace with primaryFont
              ),
              Text(
                movieIndexData['language']!,
                style: const TextStyle(color: Color.fromARGB(255, 253, 250, 250), fontSize: 14), // Replace with primaryFont
              ),
              
            ],
          ),
        ),
        const Divider(),
      
      ],
    );
  }
}