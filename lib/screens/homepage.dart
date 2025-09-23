import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../components/homepage/browse_genre.dart';
import '../components/homepage/newRelases.dart';
import '../components/homepage/topCarousel.dart';
import '../components/homepage/upcomingMovies.dart';
import '../models/constants.dart';
import 'siginPage.dart';
import 'showTicket.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  String _selectedLocation = 'Delhi';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _selectLocation() async {
    final newLocation = await showDialog<String>(
      context: context,
      builder: (context) => LocationDialog(currentLocation: _selectedLocation),
    );

    if (newLocation != null && newLocation != _selectedLocation) {
      setState(() {
        _selectedLocation = newLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        // custom leading icon to open the drawer
        leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Iconsax.menu, color: kPrimary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
        elevation: 0,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "It's All Starts Here",
                  style: TextStyle(
                    color: darkColor,
                    fontFamily: primaryFont,
                    fontSize: textContent,
                  ),
                ),
                GestureDetector(
                  onTap: _selectLocation,
                  child: Row(
                    children: [
                      Text(
                        _selectedLocation,
                        style: TextStyle(
                          color: darkColor,
                          fontFamily: subtitleFonts,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Iconsax.search_normal, color: kPrimary),
            const SizedBox(width: 12),
            Icon(Iconsax.scan_barcode, color: kPrimary),
            const SizedBox(width: 15),
          ],
        ),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            TopCarouselSection(),
            SizedBox(height: 8),
            NewReleases(),
            SizedBox(height: 8),
            BrowseByGenre(),
            SizedBox(height: 8),
            UpcomingMovies(),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ------------------------
// Location Selection Dialog
// ------------------------
class LocationDialog extends StatelessWidget {
  final String currentLocation;
  const LocationDialog({super.key, required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    final locations = ['Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata'];

    return AlertDialog(
      title: const Text('Select Location'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final loc = locations[index];
            return ListTile(
              title: Text(loc),
              trailing: loc == currentLocation ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, loc),
            );
          },
        ),
      ),
    );
  }
}


// drawer feature 

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: lightColor, // <-- Using your lightColor
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: kPrimary, // <-- Using your kPrimary color
            ),
            accountName: Text(
              "Your Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: primaryFont,
                color: lightColor, // <-- Using your lightColor for text
              ),
            ),
            accountEmail: Text(
              "your.email@example.com",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: subtitleFonts,
                color: lightColor, // <-- Using your lightColor for text
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: lightColor, // <-- Using your lightColor for avatar background
              child: Icon(
                Iconsax.user,
                color: kPrimary, // <-- Using your kPrimary for the icon
                size: 40,
              ),
            ),
          ),
          
          // ListTile for Booked Tickets
          ListTile(
            leading: Icon(Iconsax.ticket, color: darkColor),
            title: Text('My Bookings',
            style: TextStyle(fontFamily: primaryFont, color: darkColor),
           ),
           onTap: () {
            // First, close the drawer
             Navigator.pop(context);
    // Then, navigate to the ShowTicket screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShowTicket()),
    );
  },
),
          const Divider(),
          
          // ListTile for Logout
           ListTile(
            leading: Icon(Iconsax.logout, color: kPrimary),
            title: Text(
              'Logout',
              style: TextStyle(fontFamily: primaryFont, color: kPrimary),
              ),
              onTap: () {
// Navigate to the SigninPage and remove all previous screens from history
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SigninPage()),
                (Route<dynamic> route) => false,
                 );
              },
          ),
        ],
      ),
    );
  }
}