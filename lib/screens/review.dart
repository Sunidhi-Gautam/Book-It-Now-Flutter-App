// lib/screens/review_page.dart
// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
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

  final int _earnedCredits = 100;
  bool _showPopup = false;
  bool _isLoading = false;
  bool _isEditEnabled = false;
  bool _isReviewed = false; // track whether review exists
  bool _isEditing = false; // user clicked edit icon

  String? reviewDocId;
  int? movieId;
  String? movieTitle;
  String? posterUrl;
  List<String> castList = [];

  // dropdown options
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
    'Can do better',
    'My 8 year old sibling does better.',
  ];
  final List<String> _visualoptions = [
    'Select',
    'Blessed my eyes.',
    'Pretty good',
    'Okayishhh',
    'How can I unsee it?',
  ];
  final List<String> _musicoptions = [
    'Select',
    'I already changed my ringtone.',
    'Bro, I was grooving.',
    'Not my typa music.',
    'I am deaf now.',
  ];
  final List<String> _recommendOptions = [
    'Select',
    'Friends',
    'Family',
    'Kids',
    'Couple Date',
    'Everyone',
    'No one',
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

      if (!doc.exists) return;
      final data = doc.data()!;
      setState(() {
        movieId = data['movieId'];
        movieTitle = data['movieTitle'];
        posterUrl = data['posterUrl'];
        castList = List<String>.from(data['castList'] ?? []);
      });

      // Now check if review already exists
      final reviewQuery = await FirebaseFirestore.instance
          .collection('reviews')
          .where('bookingId', isEqualTo: widget.bookingId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (reviewQuery.docs.isNotEmpty) {
        final review = reviewQuery.docs.first;
        final reviewData = review.data();
        setState(() {
          reviewDocId = review.id;
          _rating = reviewData['rating'] ?? 0;
          _story = reviewData['story'] ?? "Select";
          _acting = reviewData['acting'] ?? "Select";
          _visuals = reviewData['visuals'] ?? "Select";
          _music = reviewData['music'] ?? "Select";
          _recommendTo = reviewData['recommendTo'] ?? "Select";
          _favoriteEmoji = reviewData['emoji'] ?? "Select";
          _favoriteCharacter = reviewData['favoriteCharacter'];
          _expectation = reviewData['expectation'] ?? "Select";
          _commentsController.text = reviewData['comments'] ?? "";
          _isReviewed = true;
          _isEditEnabled = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _submitReview() async {
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

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final reviewData = {
        'bookingId': widget.bookingId,
        'movieId': movieId,
        'movieTitle': movieTitle,
        'userId': user.uid,
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
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_isReviewed && reviewDocId != null) {
        // Update existing review (no credits)
        await FirebaseFirestore.instance
            .collection('reviews')
            .doc(reviewDocId)
            .update(reviewData);
      } else {
        // First submission → add new review + credits
        reviewData['createdAt'] = FieldValue.serverTimestamp();
        final newReview = await FirebaseFirestore.instance
            .collection('reviews')
            .add(reviewData);
        reviewDocId = newReview.id;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('bookings')
            .doc(widget.bookingId)
            .update({'reviewed': true});

        await CreditsManager.addCredits(_earnedCredits);

        setState(() => _showPopup = true);
      }

      setState(() {
        _isReviewed = true;
        _isEditEnabled = true;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isReviewed
              ? "Review updated successfully!"
              : "Review submitted successfully!"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error submitting: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool get _fieldsDisabled => _isReviewed && !_isEditing;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(movieTitle ?? '',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                      color: Colors.black54,
                      blurRadius: 6,
                      offset: Offset(1, 1))
                ])),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              onPressed: _isEditEnabled
                  ? () => setState(() => _isEditing = !_isEditing)
                  : null,
              icon: Icon(
                Iconsax.edit,
                color: _isEditEnabled ? Colors.white : Colors.white30,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (posterUrl != null)
            Positioned.fill(
              child: Image.network(posterUrl!, fit: BoxFit.cover),
            ),
          Positioned.fill(
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(color: Colors.black.withOpacity(0.6)))),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (posterUrl != null)
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
                _buildGlassCard(child: _buildStarRating()),
                _buildGlassCard(
                    child: _buildDropdown(
                        "Did the story keep you hooked or snoozing?",
                        _story,
                        _storyoptions,
                        (v) => _story = v)),
                _buildGlassCard(
                    child: _buildDropdown("How was the acting performance?",
                        _acting, _actingoptions, (v) => _acting = v)),
                _buildGlassCard(
                    child: _buildDropdown("Did the visuals blow your mind?",
                        _visuals, _visualoptions, (v) => _visuals = v)),
                _buildGlassCard(
                    child: _buildDropdown(
                        "Did the music hit the right corner of your heart?",
                        _music,
                        _musicoptions,
                        (v) => _music = v)),
                _buildGlassCard(
                    child: _buildDropdown(
                        "Did this movie met your expectations?",
                        _expectation,
                        _expectationOptions,
                        (v) => _expectation = v)),
                _buildGlassCard(
                    child: _buildDropdown(
                        "Who should you drag (or convince) to watch this?",
                        _recommendTo,
                        _recommendOptions,
                        (v) => _recommendTo = v)),
                _buildGlassCard(
                    child: _buildDropdown(
                        "Describe your mood after watching the show using emoji.",
                        _favoriteEmoji,
                        _emojiOptions,
                        (v) => _favoriteEmoji = v)),
                _buildGlassCard(child: _buildCharacterSelector()),
                _buildGlassCard(
                    child: _buildTextField(
                        "Spill the beans! How was your overall experience?",
                        _commentsController)),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed:
                        _isLoading || _fieldsDisabled ? null : _submitReview,
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            horizontal: 150, vertical: 18),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors
                                .grey[700]!; // visibly gray when disabled
                          }
                          return const Color.fromARGB(255, 139, 0, 0)
                              .withOpacity(0.8); // normal color
                        },
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isReviewed ? "Update" : "Submit",
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          if (_showPopup) _buildPopup(size),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String current, List<String> options,
      ValueChanged<String> onChanged) {
    return Opacity(
      opacity: _fieldsDisabled ? 0.45 : 1.0,
      child: IgnorePointer(
        ignoring: _fieldsDisabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                if (_fieldsDisabled) return;
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.grey[900],
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  builder: (_) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options
                        .map((opt) => ListTile(
                              title: Text(opt,
                                  style: TextStyle(
                                      color: current == opt
                                          ? Colors.amber
                                          : Colors.white)),
                              onTap: () {
                                onChanged(opt);
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ))
                        .toList(),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(current,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterSelector() => Opacity(
        opacity: _fieldsDisabled ? 0.45 : 1.0,
        child: IgnorePointer(
          ignoring: _fieldsDisabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Who won your heart?",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: castList.length,
                  itemBuilder: (context, i) {
                    final c = castList[i];
                    final selected = _favoriteCharacter == c;
                    return ChoiceChip(
                      label: Text(c,
                          style: TextStyle(
                              color: selected ? Colors.white : Colors.white70)),
                      selected: selected,
                      onSelected: (_) => setState(() => _favoriteCharacter = c),
                      selectedColor: Colors.grey[800],
                      backgroundColor: Colors.grey[700],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildTextField(String label, TextEditingController controller) =>
      Opacity(
        opacity: _fieldsDisabled ? 0.45 : 1.0,
        child: IgnorePointer(
          ignoring: _fieldsDisabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _commentsController,
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
          ),
        ),
      );

  Widget _buildStarRating() => Opacity(
        opacity: _fieldsDisabled ? 0.45 : 1.0,
        child: IgnorePointer(
          ignoring: _fieldsDisabled,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Icon(
                  i < _rating ? Icons.star : Icons.star_border,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildGlassCard({required Widget child}) => Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20)),
        child: Padding(padding: const EdgeInsets.all(18), child: child),
      );

  Widget _buildPopup(Size size) => Center(
        child: Container(
          width: size.width * 0.8,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.black87, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
              const SizedBox(height: 10),
              const Text("Yay! Review Submitted!",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 10),
              Text("You earned $_earnedCredits credits.",
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() => _showPopup = false);
                  Navigator.pop(context, true);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        ),
      );
}
