import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        backgroundColor: const Color.fromARGB(255, 96, 4, 4),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              margin: const EdgeInsets.all(8),
             
              child: const Icon(Iconsax.menu_1, color: Color.fromARGB(255, 238, 118, 118), size: 28),
            ),
          ),
        ),
        elevation: 0,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Movies, Just for You",
                  style: TextStyle(
                    color: Colors.white,
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
                          color: const Color.fromARGB(255, 248, 179, 174),
                          fontFamily: secondaryFonts,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: Color.fromARGB(255, 252, 235, 235),
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
    final locations = ['Mumbai', 'Delhi', 'Chennai', 'Kolkata'];

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

// ------------------------
// Drawer with Firebase User Info
// ------------------------
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: lightColor,
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: kPrimary),
                accountName: Text(
                  user?.displayName ?? 'Your Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: primaryFont,
                    color: lightColor,
                  ),
                ),
                accountEmail: Text(
                  user?.email ?? 'your.email@example.com',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: subtitleFonts,
                    color: lightColor,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: lightColor,
                  child: Icon(
                    Iconsax.user,
                    color: kPrimary,
                    size: 40,
                  ),
                ),
              ),

              ListTile(
                leading: Icon(Iconsax.ticket, color: darkColor),
                title: Text(
                  'My Bookings',
                  style: TextStyle(fontFamily: primaryFont, color: darkColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShowTicket()),
                  );
                },
              ),
              const Divider(),

              ListTile(
                leading: Icon(Iconsax.logout, color: kPrimary),
                title: Text(
                  'Logout',
                  style: TextStyle(fontFamily: primaryFont, color: kPrimary),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SigninPage()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
