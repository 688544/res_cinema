import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/movie_card.dart';
import '../services/api_service.dart';
import '../models/movie.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<Movie> _results = [];
  bool _loading = false;
  bool _searched = false;
  String _filter = '';

  final _filters = [
    ['', 'الكل'], ['movie', '🎬 أفلام'], ['series', '📺 مسلسلات'],
    ['anime', '🇯🇵 أنمي'], ['2024', '🆕 2024+'],
  ];

  Future<void> _search() async {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() { _loading = true; _results = []; _searched = true; });
    String query = _filter == 'anime' ? 'anime $q' : q;
    String type  = (_filter == 'movie' || _filter == 'series') ? _filter : '';
    String year  = _filter == '2024' ? '2024' : '';
    final r = await ApiService.search(query, type: type, year: year);
    setState(() { _results = r; _loading = false; });
  }

  void _paste() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _ctrl.text = data!.text!;
      _search();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: ResAppBar(title: '🔍 البحث', showBack: false),
      body: Column(children: [
        // Search bar
        Container(
          color: AppColors.card, padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(color: AppColors.white),
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: 'ابحث عن فيلم أو مسلسل...',
                  hintStyle: TextStyle(color: AppColors.grey),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _search(),
              ),
            ),
            IconButton(icon: const Icon(Icons.content_paste, color: AppColors.grey, size: 20), onPressed: _paste),
            IconButton(icon: const Icon(Icons.search, color: AppColors.red), onPressed: _search),
          ]),
        ),

        // Filters
        SizedBox(
          height: 44,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: _filters.map((f) {
              final active = _filter == f[0];
              return GestureDetector(
                onTap: () { setState(() => _filter = f[0]); if (_searched) _search(); },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  color: active ? AppColors.red : AppColors.navy,
                  child: Text(f[1], style: const TextStyle(color: AppColors.white, fontSize: 12)),
                ),
              );
            }).toList(),
          ),
        ),

        // Results
        Expanded(child: _buildBody()),
      ]),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.red));
    if (!_searched) return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('🔍', style: TextStyle(fontSize: 64)),
      SizedBox(height: 16),
      Text('ابحث عن فيلم أو مسلسل', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      Text('اكتب الاسم في الخانة أعلاه', style: TextStyle(color: AppColors.grey)),
    ]));
    if (_results.isEmpty) return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('😕', style: TextStyle(fontSize: 64)),
      SizedBox(height: 16),
      Text('لا توجد نتائج', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      Text('جرب كلمات أخرى أو بالإنجليزية', style: TextStyle(color: AppColors.grey)),
    ]));

    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Align(alignment: Alignment.centerRight,
          child: Text('وجدنا ${_results.length} نتيجة', style: const TextStyle(color: AppColors.grey, fontSize: 13))),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: _results.length,
          itemBuilder: (_, i) => MovieCard(
            movie: _results[i],
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => DetailScreen(imdbId: _results[i].imdbId, movie: _results[i]))),
            onFav: () {
              context.read<FavoritesProvider>().add(_results[i]);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('❤️ تم حفظ ${_results[i].title}'), backgroundColor: AppColors.red));
            },
          ),
        ),
      ),
    ]);
  }
}
