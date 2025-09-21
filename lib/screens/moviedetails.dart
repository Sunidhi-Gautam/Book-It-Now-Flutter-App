import '../components/moviedetails/castDetails.dart';
import '../components/moviedetails/movieSummary.dart';
import '../components/moviedetails/ratingBar.dart';
import '../components/moviedetails/topBannerSection.dart';
import '../models/constants.dart';
import 'ticketBookingScreen.dart';
import 'package:flutter/material.dart';

class MovieDetails extends StatefulWidget {
  const MovieDetails({super.key, required this.movieIndex});
  final int movieIndex;
  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  @override
  Widget build(BuildContext context) {
    final movidetails= movieData[widget.movieIndex];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(movidetails['title'], style: TextStyle(color: darkColor, fontSize: textContent, fontFamily: primaryFont),),
            const Spacer(),
            const Icon(Icons.share)
          ],
        ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (builder)=>Ticketbookingscreen(movieIndex: widget.movieIndex,)));
          },
          child: Container(
            height: 48,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width-60,
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(10)
            ),
            child: Text('Book Tickets', style: TextStyle(color: Colors.white, fontSize: textContent, fontFamily: primaryFont),),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TopBannerSection(movieIndex1: widget.movieIndex,),
            const SizedBox(height: 15,),
            RatingBarDetails(ratingIndex: widget.movieIndex,),
            const SizedBox(height: 15,),
            MovieSummary(summaryIndex: widget.movieIndex,),
            CastDetails(peopleDetails: castDetails, title: 'Cast',),
            const Divider(),
            CastDetails(peopleDetails: crewDetails, title: 'Crew',),
          ],
        ),
      ),
    );
  }
}
