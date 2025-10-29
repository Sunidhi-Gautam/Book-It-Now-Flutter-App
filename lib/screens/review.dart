// // lib/screens/review_page.dart

// // ignore_for_file: deprecated_member_use

// import 'dart:ui';
// import 'package:flutter/material.dart';
// // Firebase imports
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../services/credits_manager.dart';
// import 'booking_store.dart';

// class ReviewPage extends StatefulWidget {
//   final int movieId;
//   final String movieTitle;
//   final String posterUrl;
//   final List<String> castList;
//   final int initialCredits;
//   final int bookingIndex;

//   const ReviewPage({
//     super.key,
//     required this.movieId,
//     required this.movieTitle,
//     required this.posterUrl,
//     required this.castList,
//     this.initialCredits = 0,
//     required this.bookingIndex,
//   });

//   @override
//   State<ReviewPage> createState() => _ReviewPageState();
// }

// class _ReviewPageState extends State<ReviewPage> {
//   int _rating = 0;
//   String _story = "Select";
//   String _acting = "Select";
//   String _visuals = "Select";
//   String _music = "Select";
//   String _recommendTo = "Select";
//   String _favoriteEmoji = "Select";
//   String? _favoriteCharacter;
//   String _expectation = "Select";
//   final TextEditingController _commentsController = TextEditingController();
//   int _credits = 0;
//   final int _earnedCredits = 100; // Each review gives 100 credits
//   bool _showPopup = false;
//   bool _isLoading = false; // To manage loading state

//   final List<String> _storyoptions = [
//     'Select',
//     'Did not blink even once.',
//     'It was quite good.',
//     'I dozed off few times.',
//     'Please, process my refund.',
//   ];
//   final List<String> _actingoptions = [
//     'Select',
//     'They were fantastic.',
//     '8 outta 10',
//     'My 8 year old sibling does better.',
//     'Ewwww'
//   ];
//   final List<String> _visualoptions = [
//     'Select',
//     'Crazyyyy good',
//     'Okayishhh',
//     'Production company ate all the money.',
//     'How can I unsee it?',
//   ];
//   final List<String> _musicoptions = [
//     'Select',
//     'I already changed my ringtone.',
//     'Bro, I was grooving.',
//     'Not my typa music.',
//     'They should keep their hidden talents...hidden.',
//   ];
//   final List<String> _recommendOptions = [
//     'Select',
//     'Friends',
//     'Family',
//     'Kids',
//     'Couple Date',
//     'Everyone',
//   ];
//   final List<String> _emojiOptions = [
//     'Select',
//     '😀',
//     '😢',
//     '😱',
//     '😍',
//     '🤣',
//     '😡'
//   ];
//   final List<String> _expectationOptions = [
//     'Select',
//     'Above my expectations',
//     'Totally',
//     'Kinda',
//     'Not at all',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _credits = widget.initialCredits;
//   }

//   // --- NEW: UPDATED SUBMIT FUNCTION ---
//   Future<void> _submitReview() async {
//     // 1. Validation
//     if (_rating == 0 ||
//         _story == "Select" ||
//         _acting == "Select" ||
//         _visuals == "Select" ||
//         _music == "Select" ||
//         _recommendTo == "Select" ||
//         _expectation == "Select" ||
//         _favoriteEmoji == "Select" ||
//         _favoriteCharacter == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please complete all required fields")),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true; // Show loading
//     });

//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("You are not logged in.")),
//         );
//         setState(() => _isLoading = false);
//         return;
//       }

//       // 2. Create a Review object
//       final reviewData = {
//         'movieId': widget.movieId,
//         'movieTitle': widget.movieTitle,
//         'userId': user.uid,
//         'createdAt': FieldValue.serverTimestamp(),
//         'rating': _rating,
//         'story': _story,
//         'acting': _acting,
//         'visuals': _visuals,
//         'music': _music,
//         'recommendTo': _recommendTo,
//         'emoji': _favoriteEmoji,
//         'favoriteCharacter': _favoriteCharacter,
//         'expectation': _expectation,
//         'comments': _commentsController.text,
//       };

//       // 3. Save the review to Firebase
//       await FirebaseFirestore.instance.collection('reviews').add(reviewData);

//       // 4. Award credits using your manager
//       await CreditsManager.addCredits(_earnedCredits);

//       // 5. Update local BookingStore (as before)
//       BookingStore.bookings[widget.bookingIndex]['reviewed'] = true;

//       // 6. Show the success popup
//       setState(() {
//         _showPopup = true;
//         _credits += _earnedCredits; // Update local display
//       });
//     } catch (e) {
//       // Show error if Firebase fails
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to submit review: $e")),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false; // Hide loading
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: Text(
//           widget.movieTitle,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             shadows: [
//               Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(1, 1))
//             ],
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 20.0),
//             child: Row(
//               children: [
//                 const Icon(Icons.monetization_on,
//                     color: Color.fromARGB(255, 239, 191, 0), size: 28),
//                 const SizedBox(width: 5),
//                 Text(
//                   '$_credits',
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.network(widget.posterUrl, fit: BoxFit.cover),
//           ),
//           Positioned.fill(
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
//               child: Container(color: Colors.black.withOpacity(0.6)),
//             ),
//           ),
//           SafeArea(
//             child: ListView(
//               padding: const EdgeInsets.all(20),
//               children: [
//                 Center(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(16),
//                     child: Image.network(
//                       widget.posterUrl,
//                       height: 220,
//                       width: 150,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 _buildGlassCard(
//                   child: Column(
//                     children: [
//                       const Text("Give meee starssss !!!",
//                           style: TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white)),
//                       const SizedBox(height: 10),
//                       _buildStarRating(),
//                     ],
//                   ),
//                 ),
//                 _buildGlassCard(
//                     child: _buildQuestionWithDrawer(
//                         "Did the story keep you hooked or snoozing?",
//                         _story,
//                         _storyoptions,
//                         (val) => setState(() => _story = val))),
//                 _buildGlassCard(
//                     child: _buildQuestionWithDrawer(
//                         "How was the acting performance?",
//                         _acting,
//                         _actingoptions,
//                         (val) => setState(() => _acting = val))),
//                 _buildGlassCard(
//                     child: _buildQuestionWithDrawer(
//                         "Did the visuals blow your mind?",
//                         _visuals,
//                         _visualoptions,
//                         (val) => setState(() => _visuals = val))),
//                 _buildGlassCard(
//                     child: _buildQuestionWithDrawer(
//                         "Did the music hit the right corner of your heart?",
//                         _music,
//                         _musicoptions,
//                         (val) => setState(() => _music = val))),
//                 _buildGlassCard(
//                     child: _buildQuestionWithDrawer(
//                         "Did this movie met your expectations?",
//                         _expectation,
//                         _expectationOptions,
//                         (val) => setState(() => _expectation = val))),
//                 _buildGlassCard(
//                     child: _buildQuestionWithDrawer(
//                         "Who should you drag (or convince) to watch this?",
//                         _recommendTo,
//                         _recommendOptions,
//                         (val) => setState(() => _recommendTo = val))),
//                 _buildGlassCard(
//                     child: _buildQuestionWithDrawer(
//                         "Your mood after the show?",
//                         _favoriteEmoji,
//                         _emojiOptions,
//                         (val) => setState(() => _favoriteEmoji = val))),
//                 _buildGlassCard(child: _buildCharacterSelector()),
//                 _buildGlassCard(
//                     child: _buildTextField(
//                         "Spill the beans! How was your overall experience?",
//                         _commentsController)),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed:
//                         _isLoading ? null : _submitReview, // Disable on load
//                     style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 150, vertical: 18),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30)),
//                         backgroundColor: const Color.fromARGB(255, 139, 0, 0)
//                             .withOpacity(0.8),
//                         shadowColor: Colors.black,
//                         elevation: 10),
//                     child: _isLoading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text("Submit",
//                             style: TextStyle(
//                                 fontSize: 20,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//                 const SizedBox(height: 50),
//               ],
//             ),
//           ),
//           if (_showPopup) _buildPopup(size),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuestionWithDrawer(String question, String currentValue,
//       List<String> options, ValueChanged<String> onSelected) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(question,
//             style: const TextStyle(
//                 fontSize: 18,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500)),
//         const SizedBox(height: 10),
//         GestureDetector(
//           onTap: () {
//             showModalBottomSheet(
//               context: context,
//               backgroundColor: Colors.grey[900],
//               shape: const RoundedRectangleBorder(
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//               ),
//               builder: (_) {
//                 return Container(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: options.map((opt) {
//                       final selected = currentValue == opt;
//                       return ListTile(
//                         title: Text(opt,
//                             style: TextStyle(
//                                 color: selected ? Colors.amber : Colors.white,
//                                 fontWeight: selected
//                                     ? FontWeight.bold
//                                     : FontWeight.normal)),
//                         onTap: () {
//                           onSelected(opt);
//                           Navigator.pop(context);
//                         },
//                       );
//                     }).toList(),
//                   ),
//                 );
//               },
//             );
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
//             decoration: BoxDecoration(
//               color: Colors.grey[850],
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(currentValue,
//                     style: const TextStyle(color: Colors.white, fontSize: 16)),
//                 const Icon(Icons.arrow_drop_down, color: Colors.white),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildGlassCard({required Widget child}) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.15)),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 10,
//               offset: const Offset(0, 5))
//         ],
//       ),
//       child: Padding(padding: const EdgeInsets.all(18), child: child),
//     );
//   }

//   Widget _buildStarRating() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(5, (index) {
//         return GestureDetector(
//           onTap: () => setState(() => _rating = index + 1),
//           child: Icon(
//             index < _rating ? Icons.star : Icons.star_border,
//             color: index < _rating
//                 ? const Color.fromARGB(255, 255, 255, 255)
//                 : Colors.white30,
//             size: 40,
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildCharacterSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Who won your heart?",
//             style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500)),
//         const SizedBox(height: 10),
//         SizedBox(
//           height: 40,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             separatorBuilder: (_, __) => const SizedBox(width: 8),
//             itemCount: widget.castList.length,
//             itemBuilder: (context, index) {
//               final character = widget.castList[index];
//               final selected = _favoriteCharacter == character;
//               return ChoiceChip(
//                 label: Text(character,
//                     style: TextStyle(
//                         color: selected ? Colors.white : Colors.white70)),
//                 selected: selected,
//                 onSelected: (_) =>
//                     setState(() => _favoriteCharacter = character),
//                 selectedColor: Colors.grey[800],
//                 backgroundColor: Colors.grey[700],
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: const TextStyle(
//                 fontSize: 18,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500)),
//         const SizedBox(height: 10),
//         TextField(
//           controller: controller,
//           maxLines: 3,
//           style: const TextStyle(color: Colors.white),
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Colors.white.withOpacity(0.1),
//             hintText: "Type your thoughts...",
//             hintStyle: const TextStyle(color: Colors.white60),
//             border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide.none),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPopup(Size size) {
//     return Stack(
//       children: [
//         GestureDetector(
//           onTap: () {},
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//             child: Container(
//               color: Colors.black.withOpacity(0.5),
//               width: size.width,
//               height: size.height,
//             ),
//           ),
//         ),
//         Center(
//           child: Container(
//             width: size.width * 0.8,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [
//                   Color.fromARGB(255, 73, 70, 70),
//                   Color.fromARGB(255, 3, 3, 3)
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(25),
//               boxShadow: [
//                 BoxShadow(
//                     color: Colors.black.withOpacity(0.6),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10))
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(mainAxisAlignment: MainAxisAlignment.end, children: [
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _showPopup = false;
//                       });
//                       Navigator.pop(context, true); // Pop back after success
//                     },
//                     child:
//                         const Icon(Icons.close, color: Colors.white, size: 28),
//                   )
//                 ]),
//                 const SizedBox(height: 5),
//                 const Icon(Icons.emoji_events, color: Colors.amber, size: 50),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "Yayyyy!! Successfully submitted the review!",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "You earned $_earnedCredits credit points.",
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.white70, fontSize: 18),
//                 ),
//                 const SizedBox(height: 50),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// lib/screens/review_page.dart

// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
// Firebase imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/credits_manager.dart';

class ReviewPage extends StatefulWidget {
  final String bookingId;
  final int initialCredits;

  const ReviewPage({
    super.key,
    this.initialCredits = 0,
    required this.bookingId,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _rating = 0;
  String _story = "Select";
  String _acting = "Select";
  String _visuals = "Select";
  String _music = "Select";
  String _recommendTo = "Select";
  String _favoriteEmoji = "Select";
  String? _favoriteCharacter;
  String _expectation = "Select";
  final TextEditingController _commentsController = TextEditingController();
  int _credits = 0;
  final int _earnedCredits = 100; // Each review gives 100 credits
  bool _showPopup = false;
  bool _isLoading = false; // To manage loading state

  // Movie details fetched from Firestore
  int? movieId;
  String? movieTitle;
  String? posterUrl;
  List<String> castList = [];

  final List<String> _storyoptions = [
    'Select',
    'Did not blink even once.',
    'It was quite good.',
    'I dozed off few times.',
    'Please, process my refund.',
  ];
  final List<String> _actingoptions = [
    'Select',
    'They were fantastic.',
    '8 outta 10',
    'My 8 year old sibling does better.',
    'Ewwww'
  ];
  final List<String> _visualoptions = [
    'Select',
    'Crazyyyy good',
    'Okayishhh',
    'Production company ate all the money.',
    'How can I unsee it?',
  ];
  final List<String> _musicoptions = [
    'Select',
    'I already changed my ringtone.',
    'Bro, I was grooving.',
    'Not my typa music.',
    'They should keep their hidden talents...hidden.',
  ];
  final List<String> _recommendOptions = [
    'Select',
    'Friends',
    'Family',
    'Kids',
    'Couple Date',
    'Everyone',
  ];
  final List<String> _emojiOptions = [
    'Select',
    '😀',
    '😢',
    '😱',
    '😍',
    '🤣',
    '😡'
  ];
  final List<String> _expectationOptions = [
    'Select',
    'Above my expectations',
    'Totally',
    'Kinda',
    'Not at all',
  ];

  @override
  void initState() {
    super.initState();
    _credits = widget.initialCredits;
    fetchBookingDetails();
  }

  Future<void> fetchBookingDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          movieId = data['movieId'];
          movieTitle = data['movieTitle'];
          posterUrl = data['posterUrl'];
          castList = List<String>.from(data['castList'] ?? []);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch booking details: $e')),
      );
    }
  }

  // --- NEW: UPDATED SUBMIT FUNCTION ---
  Future<void> _submitReview() async {
    // 1. Validation
    if (_rating == 0 ||
        _story == "Select" ||
        _acting == "Select" ||
        _visuals == "Select" ||
        _music == "Select" ||
        _recommendTo == "Select" ||
        _expectation == "Select" ||
        _favoriteEmoji == "Select" ||
        _favoriteCharacter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all required fields")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You are not logged in.")),
        );
        setState(() => _isLoading = false);
        return;
      }

      // 2. Create a Review object
      final reviewData = {
        'bookingId': widget.bookingId,
        'movieId': movieId,
        'movieTitle': movieTitle,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'rating': _rating,
        'story': _story,
        'acting': _acting,
        'visuals': _visuals,
        'music': _music,
        'recommendTo': _recommendTo,
        'emoji': _favoriteEmoji,
        'favoriteCharacter': _favoriteCharacter,
        'expectation': _expectation,
        'comments': _commentsController.text,
      };

      // 3. Save the review to Firebase
      await FirebaseFirestore.instance.collection('reviews').add(reviewData);

      // 4. Award credits using your manager
      await CreditsManager.addCredits(_earnedCredits);

      // 5. Update local BookingStore (as before)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('bookings')
          .doc(widget.bookingId)
          .update({'reviewed': true});

      // 6. Show the success popup
      setState(() {
        _showPopup = true;
        _credits += _earnedCredits; // Update local display
      });
    } catch (e) {
      // Show error if Firebase fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit review: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          movieTitle ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(1, 1))
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(
              children: [
                const Icon(Icons.monetization_on,
                    color: Color.fromARGB(255, 239, 191, 0), size: 28),
                const SizedBox(width: 5),
                Text(
                  '$_credits',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(posterUrl!, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      posterUrl!,
                      height: 220,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildGlassCard(
                  child: Column(
                    children: [
                      const Text("Give meee starssss !!!",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 10),
                      _buildStarRating(),
                    ],
                  ),
                ),
                _buildGlassCard(
                    child: _buildQuestionWithDrawer(
                        "Did the story keep you hooked or snoozing?",
                        _story,
                        _storyoptions,
                        (val) => setState(() => _story = val))),
                _buildGlassCard(
                    child: _buildQuestionWithDrawer(
                        "How was the acting performance?",
                        _acting,
                        _actingoptions,
                        (val) => setState(() => _acting = val))),
                _buildGlassCard(
                    child: _buildQuestionWithDrawer(
                        "Did the visuals blow your mind?",
                        _visuals,
                        _visualoptions,
                        (val) => setState(() => _visuals = val))),
                _buildGlassCard(
                    child: _buildQuestionWithDrawer(
                        "Did the music hit the right corner of your heart?",
                        _music,
                        _musicoptions,
                        (val) => setState(() => _music = val))),
                _buildGlassCard(
                    child: _buildQuestionWithDrawer(
                        "Did this movie met your expectations?",
                        _expectation,
                        _expectationOptions,
                        (val) => setState(() => _expectation = val))),
                _buildGlassCard(
                    child: _buildQuestionWithDrawer(
                        "Who should you drag (or convince) to watch this?",
                        _recommendTo,
                        _recommendOptions,
                        (val) => setState(() => _recommendTo = val))),
                _buildGlassCard(
                    child: _buildQuestionWithDrawer(
                        "Your mood after the show?",
                        _favoriteEmoji,
                        _emojiOptions,
                        (val) => setState(() => _favoriteEmoji = val))),
                _buildGlassCard(child: _buildCharacterSelector()),
                _buildGlassCard(
                    child: _buildTextField(
                        "Spill the beans! How was your overall experience?",
                        _commentsController)),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : _submitReview, // Disable on load
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 150, vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        backgroundColor: const Color.fromARGB(255, 139, 0, 0)
                            .withOpacity(0.8),
                        shadowColor: Colors.black,
                        elevation: 10),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
          if (_showPopup) _buildPopup(size),
        ],
      ),
    );
  }

  Widget _buildQuestionWithDrawer(String question, String currentValue,
      List<String> options, ValueChanged<String> onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question,
            style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.grey[900],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              builder: (_) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((opt) {
                      final selected = currentValue == opt;
                      return ListTile(
                        title: Text(opt,
                            style: TextStyle(
                                color: selected ? Colors.amber : Colors.white,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                        onTap: () {
                          onSelected(opt);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(currentValue,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                const Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => setState(() => _rating = index + 1),
          child: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: index < _rating
                ? const Color.fromARGB(255, 255, 255, 255)
                : Colors.white30,
            size: 40,
          ),
        );
      }),
    );
  }

  Widget _buildCharacterSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Who won your heart?",
            style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: castList.length,
            itemBuilder: (context, index) {
              final character = castList[index];
              final selected = _favoriteCharacter == character;
              return ChoiceChip(
                label: Text(character,
                    style: TextStyle(
                        color: selected ? Colors.white : Colors.white70)),
                selected: selected,
                onSelected: (_) =>
                    setState(() => _favoriteCharacter = character),
                selectedColor: Colors.grey[800],
                backgroundColor: Colors.grey[700],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            hintText: "Type your thoughts...",
            hintStyle: const TextStyle(color: Colors.white60),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildPopup(Size size) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {},
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              width: size.width,
              height: size.height,
            ),
          ),
        ),
        Center(
          child: Container(
            width: size.width * 0.8,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 73, 70, 70),
                  Color.fromARGB(255, 3, 3, 3)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 20,
                    offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPopup = false;
                      });
                      Navigator.pop(context);
                      Navigator.pop(context, true); // Pop back after success
                    },
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 28),
                  )
                ]),
                const SizedBox(height: 5),
                const Icon(Icons.emoji_events, color: Colors.amber, size: 50),
                const SizedBox(height: 10),
                const Text(
                  "Yayyyy!! Successfully submitted the review!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "You earned $_earnedCredits credit points.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
