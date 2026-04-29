/// User-facing Travelo branding and travel-copy strings.
abstract final class AppBranding {
  static const String appName = 'Travelo';

  // Splash / Liquid Orb hero
  /// Used where a thin eyebrow fits; middots scan cleaner than slashes.
  static const String splashWordmarkCaps = 'TOURS  ·  ROUTES  ·  PLACES';
  static const String splashDescription =
      'Plan trips, save tours, visit places—and wander with guides you trust.';
  /// Sign-in/up hero band — one clear sentence (replaces cramped all-caps + chip row).
  static const String authHeroTagline =
      'Trip ideas, itineraries, and routes—picked for Kurdish cities and valleys.';

  // Auth eyebrows (Liquid Orb)
  static const String signInEyebrow = 'CONTINUE YOUR JOURNEY';
  static const String signUpEyebrow = 'START YOUR NEXT TRIP';

  /// Hero photo behind sign-in / sign-up (matches splash / home citadel).
  static const String authTravelHeroAsset = 'assets/images/place_citadel.png';

  // Main shell
  static const String drawerSubtitle = 'Travel & tours edition';
  static const String homeTileSubtitleRegions = 'Cities & scenic routes';

  /// Parallax hero (home hero image overlay).
  static const String homeHeroEyebrow = 'WANDER  ·  TOURS  ·  PLACES';

  /// Section under hero after scroll (“Discover”).
  static const String homeDiscoverTitle = 'Discover\nplaces';

  /// Explore tab — headline line 1 (large).
  static const String exploreHeroLine1 = 'Scenic routes';
  /// Explore tab — headline line 2 (completes thought; avoids “Explore routes”).
  static const String exploreHeroLine2 = '& places worth the drive';
  /// Short line under the big title on Explore.
  static const String exploreHeroSupporting =
      'Search heritage sites, viewpoints, eats—then open any spot on the map.';

  /// Secondary line under Discover (home).
  static const String homeDiscoverBody =
      'Pick a region—then map itineraries, sights, and day trips.';
}
