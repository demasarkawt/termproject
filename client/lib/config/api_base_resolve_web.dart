import 'dart:html' as html;

const String _railwayProd = 'https://termproject-production.up.railway.app';

/// Reads `<meta name="kurdistan-api-base" content="https://...">` from [web/index.html].
/// If absent, production web defaults to Railway (avoids debug web calling 127.0.0.1:8000).
String resolveApiBaseForWeb() {
  final meta = html.document.querySelector('meta[name="kurdistan-api-base"]');
  final fromMeta = meta?.getAttribute('content')?.trim();
  if (fromMeta != null && fromMeta.isNotEmpty) {
    return fromMeta.replaceAll(RegExp(r'/+$'), '');
  }
  return _railwayProd;
}
