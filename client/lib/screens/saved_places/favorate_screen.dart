import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/favorites_scope.dart';
import '../../data/place_repo.dart';
import '../../widgets/glass.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fav = FavoritesScope.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FFFB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedBuilder(
                      animation: fav,
                      builder: (context, _) {
                        return Text(
                          'Saved (${fav.ids.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Color(0xFF0B3D3B),
                          ),
                        );
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: fav.clear,
                    icon: const Icon(Icons.delete_sweep_rounded),
                  ),
                ],
              ),
            ),

            Expanded(
              child: AnimatedBuilder(
                animation: fav,
                builder: (context, _) {
                  final savedPlaces = fav.ids
                      .map((id) => PlaceRepo.get(id))
                      .toList(growable: false);

                  if (savedPlaces.isEmpty) {
                    return Center(
                      child: Glass(
                        radius: 22,
                        blur: 18,
                        opacity: 0.14,
                        padding: const EdgeInsets.all(16),
                        child: const Text(
                          'No saved places yet.\nOpen a place and tap ❤️',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: savedPlaces.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final p = savedPlaces[i];

                      return Glass(
                        radius: 22,
                        blur: 18,
                        opacity: 0.12,
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          onTap: () => context.push('/place/${p.id}'),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              p.coverImage,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 56,
                                height: 56,
                                color: const Color(0xFFEFFCF7),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.image_not_supported_rounded,
                                  color: Color(0xFF0F766E),
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            p.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0B3D3B),
                            ),
                          ),
                          subtitle: Text(
                            p.locationText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () => fav.toggle(p.id),
                            icon: const Icon(Icons.favorite_rounded, color: Colors.red),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
