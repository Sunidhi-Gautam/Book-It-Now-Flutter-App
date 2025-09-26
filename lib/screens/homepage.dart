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
import '../services/wallet_manager.dart';

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
      backgroundColor: const Color.fromARGB(255, 15, 14, 14),
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
            Icon(Iconsax.search_normal, color: kPrimaryColor),
            const SizedBox(width: 12),
            Icon(Iconsax.scan_barcode, color: kPrimaryColor),
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
      backgroundColor: const Color.fromARGB(255, 15, 14, 14),
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: kPrimaryColor),
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
                    color: kPrimaryColor,
                    size: 40,
                  ),
                ),
              ),

              StreamBuilder<double>(
                stream: WalletManager.getBalanceStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator while fetching the balance
                    return const ListTile(
                      leading: Icon(Iconsax.wallet_3, color: Colors.grey),
                      title: Text('My Credits'),
                      trailing: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  
                  // Format and display the balance once it's loaded
                  final balance = snapshot.data?.toStringAsFixed(2) ?? '0.00';
                  
                  return ListTile(
                    leading: const Icon(Iconsax.wallet_3, color: Colors.white),
                    title: Text(
                      'My Credits',
                      style: TextStyle(fontFamily: primaryFont, color: Colors.white),
                    ),
                    trailing: Text(
                      '₹$balance', // Displaying with a currency symbol
                      style: TextStyle(
                        fontFamily: primaryFont,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Iconsax.ticket, color: Color.fromARGB(255, 243, 172, 166)),
                title: Text(
                  'My Bookings',
                  style: TextStyle(fontFamily: primaryFont, color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShowTicket()),
                  );
                },
              ),
              const Divider(color: Colors.white,),

              ListTile(
                leading: const Icon(Iconsax.logout, color: Color.fromARGB(255, 243, 172, 166)),
                title: Text(
                  'Logout',
                  style: TextStyle(fontFamily: primaryFont, color: Colors.white),
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
