// lib/screens/credits_page.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/credits_manager.dart';
import '../services/wallet_manager.dart';
import '../models/constants.dart'; // For kPrimaryColor

class CreditsPage extends StatefulWidget {
  const CreditsPage({super.key});

  @override
  State<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  // Conversion rates (500 = 100)
  final int creditsToConvert = 500;
  final double moneyToReceive = 100.0;

  bool _isConverting = false;

  void _convertCredits() async {
    setState(() {
      _isConverting = true;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showError('You are not logged in.');
      setState(() => _isConverting = false);
      return;
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists || snapshot.data() == null) {
          throw Exception("User document does not exist!");
        }

        final currentCredits =
            (snapshot.data()!['credits'] as num?)?.toInt() ?? 0;
        final currentWallet =
            (snapshot.data()!['walletBalance'] as num?)?.toDouble() ?? 0.0;

        if (currentCredits < creditsToConvert) {
          throw Exception("Not enough credits to convert.");
        }

        final newCredits = currentCredits - creditsToConvert;
        final newWallet = currentWallet + moneyToReceive;

        transaction.update(docRef, {
          'credits': newCredits,
          'walletBalance': newWallet,
        });
      });

      _showSuccess(
          'Success! $creditsToConvert credits converted to ₹$moneyToReceive.');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isConverting = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 14, 14),
      appBar: AppBar(
        title: const Text('My Credits'),
        backgroundColor: const Color.fromARGB(255, 96, 4, 4),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Credit Balance Card ---
              _buildCreditBalanceCard(CreditsManager.getCreditsStream()),
              
              const SizedBox(height: 16),

              // --- 2. Wallet Balance Row ---
              _buildWalletBalanceRow(WalletManager.getBalanceStream()),
              
              const SizedBox(height: 32),

              // --- 3. Instructions ---
              Text(
                "How to Earn Credits",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: primaryFont,
                ),
              ),
              const SizedBox(height: 16),
              _buildRuleCard(
                icon: Iconsax.edit,
                text: "Earn 100 credits per review",
              ),
              const SizedBox(height: 12),
              _buildRuleCard(
                icon: Iconsax.ticket_star,
                text: "Earn 10 credits per ticket",
              ),
              
              const SizedBox(height: 32),

              // --- 4. Conversion Button ---
              Text(
                "Redeem Your Credits",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: primaryFont,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$creditsToConvert Credits = ₹${moneyToReceive.toStringAsFixed(0)}",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontFamily: secondaryFonts,
                ),
              ),
              const SizedBox(height: 20),
              
              StreamBuilder<int>(
                stream: CreditsManager.getCreditsStream(),
                builder: (context, snapshot) {
                  final currentCredits = snapshot.data ?? 0;
                  final bool canConvert = currentCredits >= creditsToConvert;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canConvert ? kPrimaryColor : Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: (canConvert && !_isConverting)
                          ? _convertCredits
                          : null,
                      child: _isConverting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(color: Colors.white))
                          : Text(
                              'Redeem $creditsToConvert Credits',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: canConvert ? Colors.white : Colors.white54,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Credit Balance Card Widget ---
  Widget _buildCreditBalanceCard(Stream<int> stream) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 139, 0, 0), // Darker Red
            kPrimaryColor, // Your main app red
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Credits",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<int>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(color: Colors.white);
              }
              final credits = snapshot.data ?? 0;
              return Row(
                children: [
                  
                  const Icon(Icons.monetization_on, color: Colors.white, size: 40),
                 
                  const SizedBox(width: 10),
                  Text(
                    credits.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Simple Wallet Balance Row Widget ---
  Widget _buildWalletBalanceRow(Stream<double> stream) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Iconsax.wallet_3, color: Colors.green[400], size: 28),
        title: const Text(
          "Wallet Balance",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        trailing: StreamBuilder<double>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(strokeWidth: 2);
            }
            final balance = snapshot.data?.toStringAsFixed(2) ?? '0.00';
            return Text(
              '₹ $balance',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Styled Rule Card Widget ---
  Widget _buildRuleCard({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}