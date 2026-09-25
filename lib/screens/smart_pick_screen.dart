import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/movie_card.dart';
import '../services/api_service.dart';
import '../models/movie.dart';
import 'detail_screen.dart';

class SmartPickScreen extends StatefulWidget {
  const SmartPickScreen({Key? key}) : super(key: key);
  @override
  State<SmartPickScreen> createState() => _SmartPickScreenState();
}

class _SmartPickScreenState extends State<SmartPickScreen> {
  int _step = 1;
  String _mood = '', _genre = '', _duration = '', _workType = '', _origin = '';
  Movie? _result;
  bool _loading = false;
  List<Movie> _pool = [];
  int _poolIndex = 0;

  final _moods = [
    ['action','🔥 إثارة'], ['romance','💕 رومانسي'], ['comedy','😂 كوميدي'],
    ['horror','👻 رعب'], ['adventure','🌍 مغامرة'], ['mystery','🕵️ غموض'],
  ];
  final _genres = [
    ['science fiction','🚀 خيال علمي'], ['drama','🎭 دراما'], ['crime','🔫 جريمة'],
    ['fantasy','🧙 فانتازيا'], ['history','🏛️ تاريخي'], ['sport','⚽ رياضي'],
  ];
  final _durations = [['short','⏱ أقل من ساعة'], ['medium','🕑 1-2 ساعة'], ['long','🕰 أكثر من ساعتين']];
  final _types    = [['movie','🎬 فيلم'], ['series','📺 مسلسل']];
  final _origins  = [['anime','🇯🇵 أنمي'], ['foreign','🌍 أجنبي']];

  final _questions = ['', 'كيف مزاجك الآن؟', 'ما النوع المفضل؟', 'كم لديك من وقت؟', 'فيلم أم مسلسل؟', 'أنمي أم أجنبي؟'];

  void _pick(String val, int nextStep) {
    switch (_step) {
      case 1: _mood = val; break;
      case 2: _genre = val; break;
      case 3: _duration = val; break;
      case 4: _workType = val; break;
      case 5: _origin = val; break;
    }
    if (nextStep > 5) { _fetch(false); return; }
    setState(() => _step = nextStep);
  }

  Future<void> _fetch(bool next) async {
    if (next && _pool.isNotEmpty && _poolIndex < _pool.length - 1) {
      setState(() { _poolIndex++; _result = _pool[_poolIndex]; });
      return;
    }
    setState(() { _loading = true; _result = null; });
    String q = _mood;
    if (_origin == 'anime') q = 'anime $q';
    if (_genre.isNotEmpty) q += ' $_genre';
    final type = _workType == 'series' ? 'series' : 'movie';
    final results = await ApiService.search(q, type: type);
    if (results.isNotEmpty) {
      _pool = results; _poolIndex = 0;
      final detail = await ApiService.detail(results[0].imdbId);
      setState(() { _result = detail ?? results[0]; _loading = false; });
    } else {
      setState(() { _loading = false; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم نجد نتائج، جرب اختيارات أخرى'), backgroundColor: AppColors.red));
    }
  }

  void _reset() => setState(() {
    _step = 1; _mood = ''; _genre = ''; _duration = ''; _workType = ''; _origin = '';
    _result = null; _loading = false; _pool = []; _poolIndex = 0;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: ResAppBar(title: '⚡ الاختيار الذكي', showBack: false,
        actions: [IconButton(icon: const Icon(Icons.refresh, color: AppColors.grey), onPressed: _reset)]),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (_result == null && !_loading) ...[
              Text('الخطوة $_step من 5', style: const TextStyle(color: AppColors.red, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(_questions[_step], style: const TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildChoices(),
            ],
            if (_loading) _buildLoading(),
            if (_result != null) _buildResult(),
          ]),
        ),
      ),
    );
  }

  Widget _buildChoices() {
    List<List<String>> opts = [];
    if (_step == 1) opts = _moods;
    else if (_step == 2) opts = _genres;
    else if (_step == 3) opts = _durations;
    else if (_step == 4) opts = _types;
    else if (_step == 5) opts = _origins;

    return Wrap(spacing: 8, runSpacing: 8,
      children: opts.map((o) => _chip(o[1], () => _pick(o[0], _step + 1))).toList());
  }

  Widget _chip(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.navy,
      child: Text(label, style: const TextStyle(color: AppColors.white, fontSize: 14)),
    ),
  );

  Widget _buildLoading() => SizedBox(
    height: 300,
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const CircularProgressIndicator(color: AppColors.red),
      const SizedBox(height: 16),
      const Text('🎬 جاري الاختيار...', style: TextStyle(color: AppColors.grey, fontSize: 16)),
    ])),
  );

  Widget _buildResult() {
    final m = _result!;
    return Column(children: [
      PosterImage(url: m.poster, width: double.infinity, height: 300),
      const SizedBox(height: 12),
      Align(alignment: Alignment.centerRight,
        child: Text(m.title, style: const TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold))),
      const SizedBox(height: 4),
      Row(children: [
        Text('📅 ${m.year}', style: const TextStyle(color: AppColors.grey, fontSize: 13)),
        const SizedBox(width: 12),
        Text('⭐ ${m.rating}', style: const TextStyle(color: AppColors.gold, fontSize: 13)),
        const SizedBox(width: 12),
        Text('⏱ ${m.runtime}', style: const TextStyle(color: AppColors.grey, fontSize: 13)),
      ]),
      const SizedBox(height: 12),
      if (m.plot.isNotEmpty)
        Text(m.plot, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 14, height: 1.6)),
      const SizedBox(height: 20),
      // Action buttons
      Row(children: [
        Expanded(child: _btn('👍 أعجبني', AppColors.red, () {
          context.read<FavoritesProvider>().add(m);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ تمت الإضافة للمفضلة!'), backgroundColor: AppColors.red));
        })),
        const SizedBox(width: 10),
        Expanded(child: _btn('🔄 غيّره', AppColors.navy, () => _fetch(true))),
      ]),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity,
        child: TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(imdbId: m.imdbId, movie: m))),
          child: const Text('📋 عرض التفاصيل الكاملة', style: TextStyle(color: AppColors.grey)),
        ),
      ),
    ]);
  }

  Widget _btn(String label, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 52, alignment: Alignment.center, color: color,
      child: Text(label, style: const TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.bold)),
    ),
  );
}
