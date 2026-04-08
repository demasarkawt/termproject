import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:termproject/config/api_config.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  static const _primaryGreen = Color(0xFF1F5E37);

  List<dynamic> _events = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('$kBaseUrl/api/events/'));
      if (response.statusCode == 200) {
        setState(() {
          _events = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        setState(() { _loading = false; _error = 'Failed to load events.'; });
      }
    } catch (_) {
      setState(() { _loading = false; _error = 'Connection error.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: _primaryGreen),
                      SizedBox(width: 4),
                      Text('Kurdistan Go', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryGreen)),
                    ],
                  ),
                  Icon(Icons.wb_sunny_outlined, color: Colors.green),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('IMMERSIVE TRADITIONS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _primaryGreen, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  const Text('Upcoming\nEvents &\nFestivals', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'serif', height: 1.1)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: _primaryGreen))
                  : _error != null
                      ? Center(child: Text(_error!, style: const TextStyle(color: Colors.grey)))
                      : _events.isEmpty
                          ? const Center(child: Text('No events found.', style: TextStyle(color: Colors.grey)))
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                              itemCount: _events.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (_, i) => _buildEventCard(_events[i]),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final typeColors = {
      'FOOD': Colors.orange,
      'MUSIC': Colors.blue,
      'CULTURE': _primaryGreen,
    };
    final type = event['event_type'] ?? 'EVENT';
    final color = typeColors[type] ?? Colors.grey;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                ),
                if (event['location'] != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text(event['location'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(event['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'serif')),
            if (event['description'] != null) ...[
              const SizedBox(height: 8),
              Text(event['description'], style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
            ],
            if (event['start_date'] != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    event['end_date'] != null
                        ? '${event['start_date']}  →  ${event['end_date']}'
                        : event['start_date'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
