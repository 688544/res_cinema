import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/movie_card.dart';
import '../services/api_service.dart';
import '../models/movie.dart';

class DetailScreen extends StatefulWidget {
  final String imdbId;
  final Movie? movie;
  const DetailScreen({Key? key, required this.imdbId, this.movie}) : super(key: key);
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Movie? _movie;
  bool _loading = true;
  bool _translating = false;
  bool _translated = false;
  String _plotDisplay = '';

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) { _movie = widget.movie; _plotDisplay = widget.movie!.plot; }
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final m = await ApiService.detail(widget.imdbId);
    if (m != null && mounted) setState(() { _movie = m; _plotDisplay = m.plot; _loading = false; });
    else if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggleTranslation() async {
    if (_translated) {
      setState(() { _translated = false; _plotDisplay = _movie!.plot; });
      return;
    }
    setState(() => _translating = true);
    final t = await ApiService.translate(_movie!.plot);
    if (mounted) setState(() { _translating = false; _translated = true; _plotDisplay = t; });
  }

  void _share() {
    final m = _movie;
    if (m == null) return;
    Share.share('🎬 شاهد: ${m.title}\n📅 ${m.year}\n⭐ ${m.rating}\n🔗 https://www.imdb.com/title/${m.imdbId}\n\nمن تطبيق Res سينما 🎬');
  }

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesProvider>();
    final isFav = _movie != null && fav.isFav(_movie!.imdbId);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _loading && _movie == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.red))
          : _buildContent(isFav, fav),
    );
  }

  Widget _buildContent(bool isFav, FavoritesProvider fav) {
    final m = _movie!;
    return Stack(children: [
      CustomScrollView(slivers: [
        // Hero poster
        SliverAppBar(
          expandedHeight: 360,
          backgroundColor: AppColors.bg,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppColors.white), onPressed: () => Navigator.pop(context)),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              PosterImage(url: m.poster, width: double.infinity, height: 360),
              const DecoratedBox(decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87], stops: [0.5, 1.0]),
              )),
              Positioned(bottom: 16, left: 16, right: 16, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.title, style: const TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text('📅 ${m.year}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(width: 12),
                    Text('⭐ ${m.rating}', style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Text('⏱ ${m.runtime}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ]),
                ],
              )),
            ]),
          ),
        ),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Genre chips
            if (m.genre.isNotEmpty) Wrap(spacing: 8, runSpacing: 6,
              children: m.genre.split(',').map((g) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                color: AppColors.darkRed,
                child: Text(g.trim(), style: const TextStyle(color: AppColors.white, fontSize: 12)),
              )).toList(),
            ),
            const SizedBox(height: 16),

            // Info grid
            Row(children: [
              _infoBox('المخرج', m.director),
              const SizedBox(width: 8),
              _infoBox('اللغة', m.language),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _infoBox('الدولة', m.country),
              const SizedBox(width: 8),
              _infoBox('الأصوات', '🗳 ${m.votes}'),
            ]),
            const SizedBox(height: 16),

            // Actors
            const Text('طاقم التمثيل', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(width: double.infinity, color: AppColors.card, padding: const EdgeInsets.all(12),
              child: Text(m.actors, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13))),
            const SizedBox(height: 16),

            // Plot
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('القصة', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: _translating ? null : _toggleTranslation,
                child: _translating
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.red, strokeWidth: 2))
                    : Text(_translated ? '📝 الأصلي' : '🌐 ترجمة', style: const TextStyle(color: AppColors.red, fontSize: 13)),
              ),
            ]),
            Container(width: double.infinity, color: AppColors.card, padding: const EdgeInsets.all(14),
              child: Text(_plotDisplay, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 14, height: 1.7))),

            // Awards
            if (m.awards.isNotEmpty && m.awards != 'N/A') ...[
              const SizedBox(height: 12),
              Container(width: double.infinity, color: const Color(0xFF1A1500), padding: const EdgeInsets.all(12),
                child: Text('🏆 ${m.awards}', style: const TextStyle(color: AppColors.gold, fontSize: 13))),
            ],
            const SizedBox(height: 80),
          ]),
        )),
      ]),

      // Bottom bar
      Positioned(bottom: 0, left: 0, right: 0,
        child: Container(
          height: 64, color: AppColors.card, padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(child: GestureDetector(
              onTap: () {
                if (isFav) fav.remove(m.imdbId); else fav.add(m);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(isFav ? '🗑 تم الحذف من المفضلة' : '❤️ تمت الإضافة للمفضلة!'),
                  backgroundColor: AppColors.red));
              },
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                color: isFav ? const Color(0xFF1A3A1A) : AppColors.red,
                alignment: Alignment.center,
                child: Text(isFav ? '✅ في المفضلة' : '❤️ أضف للمفضلة',
                  style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            )),
            Expanded(child: GestureDetector(
              onTap: _share,
              child: Container(
                margin: const EdgeInsets.only(left: 6),
                color: AppColors.navy,
                alignment: Alignment.center,
                child: const Text('📤 مشاركة', style: TextStyle(color: AppColors.white, fontSize: 14)),
              ),
            )),
          ]),
        ),
      ),
    ]);
  }

  Widget _infoBox(String label, String value) => Expanded(
    child: Container(
      color: AppColors.card, padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: AppColors.white, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
      ]),
    ),
  );
}
