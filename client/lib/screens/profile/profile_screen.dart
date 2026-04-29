import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:termproject/config/api_config.dart';
import 'package:termproject/services/user_session.dart';
import 'package:termproject/services/theme_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Background Glow Blobs ──────────────────────────────────────────
          _buildGlowBlob(KurdishHeritageColors.sor.withOpacity(0.1), -100, 100, 400),
          _buildGlowBlob(KurdishHeritageColors.kesk.withOpacity(0.1), 300, 400, 300),

          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: KurdishHeritageColors.zer))
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // ── Profile Header ───────────────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'PROFILE',
                                    style: TextStyle(
                                      color: KurdishHeritageColors.zer,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      letterSpacing: 4,
                                    ),
                                  ),
                                  _buildGlassCircleBtn(Icons.settings_rounded, () {}, isDark),
                                ],
                              ),
                              const SizedBox(height: 30),
                              
                              // Avatar with Diamond Frame
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.rotate(
                                    angle: 0.785,
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: KurdishHeritageColors.xweli.withOpacity(0.1),
                                        border: Border.all(color: KurdishHeritageColors.zer.withOpacity(0.5), width: 2),
                                      ),
                                    ),
                                  ),
                                  Transform.rotate(
                                    angle: 0.785,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: isDark ? KurdishHeritageColors.res : Colors.white,
                                        border: Border.all(color: KurdishHeritageColors.zer, width: 2),
                                      ),
                                      child: Transform.rotate(
                                        angle: -0.785,
                                        child: Icon(Icons.person_rounded, size: 50, color: isDark ? Colors.white70 : KurdishHeritageColors.res),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(color: KurdishHeritageColors.sor, borderRadius: BorderRadius.circular(12)),
                                      child: Text('LEVEL $level', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : KurdishHeritageColors.res,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'TRAVELO TRAVELER',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  color: KurdishHeritageColors.zer.withOpacity(0.8),
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              // Stats Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildStatItem('${_savedPlaces.length}', 'SAVED', isDark),
                                  _buildDivider(isDark),
                                  _buildStatItem('${_trips.length}', 'TRIPS', isDark),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Trips Section ─────────────────────────────────────────
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('MY TRIPS', isDark),
                              const SizedBox(height: 16),
                              if (_trips.isEmpty)
                                _buildGlassEmptyCard('No trips planned yet.', isDark)
                              else
                                ..._trips.map((trip) => _buildTripCard(trip, isDark)).toList(),
                            ],
                          ),
                        ),
                      ),

                      // ── Menu Section ──────────────────────────────────────────
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 150),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('ACCOUNT', isDark),
                              const SizedBox(height: 16),
                              _buildMenuItem(Icons.person_outline_rounded, 'Personal Information', isDark),
                              _buildMenuItem(Icons.security_rounded, 'Privacy & Security', isDark),
                              _buildMenuItem(Icons.help_outline_rounded, 'Support Center', isDark),
                              const SizedBox(height: 24),
                              _buildLogoutButton(),
                            ],
                          ),
                        ),
                      ),
                    ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowBlob(Color color, double left, double top, double size) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
        ),
      ),
    );
  }

  Widget _buildGlassCircleBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
        ),
        child: Icon(icon, color: isDark ? Colors.white : KurdishHeritageColors.res, size: 22),
      ),
    );
  }

  Widget _buildStatItem(String val, String label, bool isDark) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : KurdishHeritageColors.res)),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, color: KurdishHeritageColors.zer)),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(width: 1, height: 30, color: isDark ? Colors.white12 : Colors.black12, margin: const EdgeInsets.symmetric(horizontal: 32));
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3)));
  }

  Widget _buildTripCard(Map<String, dynamic> trip, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: KurdishHeritageColors.kesk.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.luggage_rounded, color: KurdishHeritageColors.kesk),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip['title'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : KurdishHeritageColors.res)),
                Text('${trip['start_date']} — ${trip['end_date'] ?? ''}', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: KurdishHeritageColors.sor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(trip['status']?.toUpperCase() ?? 'UPCOMING', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: KurdishHeritageColors.sor)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDark ? Colors.white70 : KurdishHeritageColors.res),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : KurdishHeritageColors.res)),
        trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white.withOpacity(0.24) : Colors.black.withOpacity(0.24)),
        onTap: () {},
      ),
    );
  }

  Widget _buildGlassEmptyCard(String msg, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03), style: BorderStyle.none),
      ),
      child: Center(child: Text(msg, style: TextStyle(color: isDark ? Colors.white.withOpacity(0.24) : Colors.black.withOpacity(0.24), fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _logout,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: KurdishHeritageColors.sor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: KurdishHeritageColors.sor.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: const Text('LOGOUT', style: TextStyle(color: KurdishHeritageColors.sor, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
    );
  }
}
