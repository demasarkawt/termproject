import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:termproject/config/api_config.dart';
import 'package:termproject/services/user_session.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _primaryGreen = Color(0xFF1F5E37);
  static const _textDark = Color(0xFF1E1E1E);

  List<dynamic> _trips = [];
  List<dynamic> _savedPlaces = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final id = UserSession.userId;
    if (id == null) return;
    try {
      final results = await Future.wait([
        http.get(Uri.parse('$kBaseUrl/api/users/$id/trips'), headers: UserSession.authHeaders),
        http.get(Uri.parse('$kBaseUrl/api/users/$id/saved'), headers: UserSession.authHeaders),
      ]);
      if (mounted) {
        setState(() {
          _trips = results[0].statusCode == 200 ? jsonDecode(results[0].body) : [];
          _savedPlaces = results[1].statusCode == 200 ? jsonDecode(results[1].body) : [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await UserSession.clear();
    if (mounted) context.go('/signin');
  }

  @override
  Widget build(BuildContext context) {
    final name = UserSession.userName ?? 'Explorer';
    final level = UserSession.userLevel ?? 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _primaryGreen))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      // Top Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.location_on_outlined, color: _primaryGreen),
                              SizedBox(width: 4),
                              Text('Kurdistan Go', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryGreen)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Settings'),
                                content: const Text('App settings coming soon.'),
                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                              ),
                            ),
                            child: const Icon(Icons.settings_outlined, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Avatar
                      Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _primaryGreen.withOpacity(0.15),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                            ),
                            child: const Icon(Icons.person, size: 52, color: _primaryGreen),
                          ),
                          Positioned(
                            bottom: -10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFFFA726), borderRadius: BorderRadius.circular(12)),
                              child: Text('Level $level', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'serif', color: _textDark)),
                      const SizedBox(height: 4),
                      const Text('KURDISTAN EXPLORER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: _primaryGreen)),
                      const SizedBox(height: 20),

                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatCol('${_savedPlaces.length}', 'SAVED PLACES'),
                          Container(width: 1, height: 30, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 20)),
                          _buildStatCol('${_trips.length}', 'MY TRIPS'),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // My Trips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('My Trips', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'serif', color: _textDark)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_trips.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: const Center(child: Text('No trips yet. Start planning!', style: TextStyle(color: Colors.grey))),
                        )
                      else
                        ..._trips.map((trip) => _buildTripCard(trip)).toList(),

                      const SizedBox(height: 30),

                      // Saved Places
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Saved Places', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'serif', color: _textDark)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_savedPlaces.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: const Center(child: Text('No saved places yet.', style: TextStyle(color: Colors.grey))),
                        )
                      else
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _savedPlaces.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (_, i) => _buildSavedPlaceChip(_savedPlaces[i]),
                          ),
                        ),

                      const SizedBox(height: 30),

                      // Menu items
                      _buildMenuItem(Icons.person_outline, 'Personal Information', onTap: () => _showInfoDialog(context, 'Personal Information', 'Update your name, email and profile photo in the next release.')),
                      const SizedBox(height: 12),
                      _buildMenuItem(Icons.payment_outlined, 'Payment Methods', onTap: () => _showInfoDialog(context, 'Payment Methods', 'Add or manage your payment methods here.')),
                      const SizedBox(height: 12),
                      _buildMenuItem(Icons.security_outlined, 'Privacy & Security', onTap: () => _showInfoDialog(context, 'Privacy & Security', 'Manage your password, 2FA, and privacy settings.')),
                      const SizedBox(height: 12),

                      // Logout
                      Container(
                        decoration: BoxDecoration(color: const Color(0xFFFBE9E7), borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.logout_outlined, color: Color(0xFFD84315)),
                          title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFD84315))),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFD84315)),
                          onTap: _logout,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.luggage_outlined, color: _primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textDark)),
                if (trip['start_date'] != null)
                  Text('${trip['start_date']} — ${trip['end_date'] ?? ''}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFFFA726).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(trip['status'] ?? 'upcoming', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD47A00))),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPlaceChip(Map<String, dynamic> place) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.place_outlined, color: _primaryGreen, size: 20),
          const SizedBox(height: 8),
          Text(place['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(place['category'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatCol(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap ?? () {},
      ),
    );
  }
}
