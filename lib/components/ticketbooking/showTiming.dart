// ignore: duplicate_ignore
// ignore: file_names, duplicate_ignore
// ignore: file_names, duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

import '../../models/constants.dart';
import 'package:flutter/material.dart';

class Showtiming extends StatefulWidget {
  const Showtiming({super.key, required this.movieIndex});
  final int movieIndex;
  @override
  State<Showtiming> createState() => _ShowtimingState();
}

class _ShowtimingState extends State<Showtiming> {
  int selectedDate=0;
  @override
  Widget build(BuildContext context) {
    final movieIndex=movieData[widget.movieIndex];
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: 7,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index){
                      final dateList= dateDetails[index];

                      return GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedDate=index;
                          });
                        },
                        child: Container(
                          width: 65,
                          color: selectedDate==index?kPrimary:Colors.transparent,
                          child: Column(
                            children: [
                              Text(dateList['day'], style: TextStyle(color: selectedDate==index?Colors.white:Colors.grey),),
                              Text(dateList['date'], style: TextStyle(color: selectedDate==index?Colors.white:Colors.black, fontFamily: primaryFont, fontSize: 20),),
                              Text(dateList['month'], style: TextStyle(color: selectedDate==index?Colors.white:Colors.grey),),
                            ],
                          ),
                        ),
                      );
                    }),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(movieIndex['language'], style: TextStyle(color: Colors.black, fontSize: 12, fontFamily: primaryFont),),
              const SizedBox(width: 3,),
              // ignore: prefer_interpolation_to_compose_strings
              Text("."+movieIndex['screenType'], style: TextStyle(color: Colors.black, fontSize: 12, fontFamily: primaryFont),),
            ],
          ),
        ),
        const Divider(),
        SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  height: 26,
                  width: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: Colors.black
                      )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.sort, color: kPrimary, size: 15,),
                      const SizedBox(width: 3,),
                      Text(
                        'Sort by', style: TextStyle(
                          color: kPrimary,
                          fontFamily: subtitleFonts,
                          fontSize: 11
                      ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: priceRange.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, index){
                        final priceOptions=priceRange[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 26,
                            width: 70,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.black
                                )
                            ),
                            child: Text(priceOptions, style: TextStyle(color: kPrimary, fontSize: 12),),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
