// Polished cinematic Profile screen.
// Drop into: lib/screens/profile/profile_screen.dart
 
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
 
import '../../config/api_config.dart';
import '../../services/user_session.dart';
import '../../services/theme_service.dart';
import '../../widgets/cinematic.dart';
 
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
        http.get(Uri.parse('$kBaseUrl/api/users/$id'), headers: UserSession.authHeaders),
      ]);
      if (mounted) {
        if (results[2].statusCode == 200) {
          final u = jsonDecode(results[2].body) as Map<String, dynamic>;
          await UserSession.updateLocalProfile(
            name: u['name'] as String?,
            email: u['email'] as String?,
          );
        }
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
    final email = UserSession.userEmail;
    final avatarPath = UserSession.avatarLocalPath;
    final hasAvatar = avatarPath != null && File(avatarPath).existsSync();
 
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final isDark = themeService.isDark;
        final ink = isDark ? Colors.white : KurdishHeritageColors.res;
 
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              _buildGlowBlob(KurdishHeritageColors.sor.withOpacity(0.08), -100, 100, 400),
              _buildGlowBlob(KurdishHeritageColors.kesk.withOpacity(0.08), 300, 400, 300),
 
              SafeArea(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: KurdishHeritageColors.zer))
                    : CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // ── Header & Identity ──
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                              child: Column(
                                children: [
                                  Row(
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
                                      const Spacer(),
                                      PressScale(
                                        onTap: () => themeService.toggleTheme(),
                                        child: Glass(
                                          radius: 999,
                                          padding: const EdgeInsets.all(8),
                                          child: Icon(
                                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                            size: 20,
                                            color: ink,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40),
 
                                  // Avatar with Sweep Ring
                                  GoldRingSweep(
                                    size: 130,
                                    thickness: 2,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: ink.withOpacity(0.05),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: KurdishHeritageColors.zer.withOpacity(0.3), width: 1.5),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(999),
                                        child: hasAvatar
                                            ? Image.file(File(avatarPath), fit: BoxFit.cover)
                                            : Icon(Icons.person_rounded, size: 50, color: ink.withOpacity(0.2)),
                                      ),
                                    ),
                                  ),
 
                                  const SizedBox(height: 28),
                                  RevealText(
                                    name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      color: ink,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: KurdishHeritageColors.sor,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'LEVEL $level TRAVELER',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
                                    ),
                                  ),
                                  if (email != null) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      email,
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ink.withOpacity(0.5)),
                                    ),
                                  ],
 
                                  const SizedBox(height: 40),
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
 
                          // ── My Trips ──
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader('MY JOURNEYS', isDark),
                                  const SizedBox(height: 16),
                                  if (_trips.isEmpty)
                                    _buildEmptyCard('No trips planned yet.', isDark)
                                  else
                                    ...List.generate(_trips.length, (i) => ScrollReveal(
                                      duration: Duration(milliseconds: Motion.md.inMilliseconds + (i * 40)),
                                      child: _TripCard(trip: _trips[i], isDark: isDark),
                                    )),
                                ],
                              ),
                            ),
                          ),
 
                          // ── Menu Options ──
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(24, 40, 24, 150),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader('SETTINGS', isDark),
                                  const SizedBox(height: 16),
                                  _MenuItem(Icons.person_outline_rounded, 'Personal information', isDark, () => context.push('/personal-info')),
                                  _MenuItem(Icons.privacy_tip_outlined, 'Privacy policy', isDark, () => context.push('/privacy-policy')),
                                  _MenuItem(Icons.lock_outline_rounded, 'Security center', isDark, () => context.push('/security-center')),
                                  _MenuItem(Icons.support_agent_rounded, 'Help & Support', isDark, () => context.push('/support-center')),
                                  const SizedBox(height: 32),
                                  PressScale(
                                    onTap: _logout,
                                    child: Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: KurdishHeritageColors.sor.withOpacity(0.4)),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text('LOGOUT', style: TextStyle(color: KurdishHeritageColors.sor, fontWeight: FontWeight.w900, letterSpacing: 3)),
                                    ),
                                  ),
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
      },
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
 
  Widget _buildStatItem(String val, String label, bool isDark) {
    final ink = isDark ? Colors.white : KurdishHeritageColors.res;
    return Column(
      children: [
        CountUp(int.tryParse(val) ?? 0, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ink)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: KurdishHeritageColors.zer)),
      ],
    );
  }
 
  Widget _buildDivider(bool isDark) {
    return Container(width: 1, height: 36, color: isDark ? Colors.white12 : Colors.black12, margin: const EdgeInsets.symmetric(horizontal: 40));
  }
 
  Widget _buildSectionHeader(String title, bool isDark) {
    final ink = isDark ? Colors.white : KurdishHeritageColors.res;
    return Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 3, color: ink.withOpacity(0.3)));
  }
 
  Widget _buildEmptyCard(String msg, bool isDark) {
    final ink = isDark ? Colors.white : KurdishHeritageColors.res;
    return Glass(
      radius: 24,
      padding: const EdgeInsets.all(40),
      opacity: 0.03,
      child: Center(child: Text(msg, style: TextStyle(color: ink.withOpacity(0.3), fontWeight: FontWeight.bold))),
    );
  }
}
 
class _TripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  final bool isDark;
  const _TripCard({required this.trip, required this.isDark});
 
  @override
  Widget build(BuildContext context) {
    final ink = isDark ? Colors.white : KurdishHeritageColors.res;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PressScale(
        child: Glass(
          radius: 24,
          padding: const EdgeInsets.all(18),
          opacity: isDark ? 0.05 : 0.03,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: KurdishHeritageColors.kesk.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.luggage_rounded, color: KurdishHeritageColors.kesk, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip['title'] ?? '', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: ink)),
                    const SizedBox(height: 2),
                    Text('${trip['start_date']} — ${trip['end_date'] ?? ''}', style: TextStyle(fontSize: 12, color: ink.withOpacity(0.4))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: KurdishHeritageColors.sor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Text(trip['status']?.toUpperCase() ?? 'UPCOMING', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: KurdishHeritageColors.sor, letterSpacing: 0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.title, this.isDark, this.onTap);
 
  @override
  Widget build(BuildContext context) {
    final ink = isDark ? Colors.white : KurdishHeritageColors.res;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PressScale(
        onTap: onTap,
        child: Glass(
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          opacity: isDark ? 0.04 : 0.02,
          child: ListTile(
            leading: Icon(icon, color: ink.withOpacity(0.6), size: 22),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: ink)),
            trailing: Icon(Icons.chevron_right_rounded, color: ink.withOpacity(0.2)),
          ),
        ),
      ),
    );
  }
}
