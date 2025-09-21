// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../../models/constants.dart';

class BestEvents extends StatefulWidget {
  const BestEvents({super.key});

  @override
  State<BestEvents> createState() => _BestEventsState();
}

class _BestEventsState extends State<BestEvents> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Best events for the month', style: TextStyle(color: darkColor, fontSize: textContent, fontFamily: primaryFont),),
            const SizedBox(height: 10,),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 9/9
                  ),
                  itemCount: eventImages.length,
                  itemBuilder: (_,index){
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                        child: Image.asset(eventImages[index], height: 120, width: 120, fit: BoxFit.cover,
                        ));
                  }
              ),
            ),
          ],
        ),
      )
    );
  }
}
