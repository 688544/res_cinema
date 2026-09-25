import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/movie_card.dart';
import '../services/api_service.dart';
import '../models/movie.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _search = '';
  int _sort = 0; // 0=default 1=A-Z 2=Z-A 3=newest

  List<Movie> _filtered(List<Movie> all) {
    var list = _search.isEmpty ? all : all.where((m) => m.title.toLowerCase().contains(_search.toLowerCase())).toList();
    if (_sort == 1) list.sort((a, b) => a.title.compareTo(b.title));
    else if (_sort == 2) list.sort((a, b) => b.title.compareTo(a.title));
    else if (_sort == 3) list.sort((a, b) => b.year.compareTo(a.year));
    return list;
  }

  void _shareAll(List<Movie> all) {
    if (all.isEmpty) return;
    final sb = StringBuffer('🎬 قائمة مفضلتي في Res سينما:\n\n');
    for (int i = 0; i < all.length; i++) sb.writeln('${i+1}. ${all[i].title} (${all[i].year})');
    sb.write('\nمن تطبيق Res سينما 🎬');
    Share.share(sb.toString());
  }

  void _confirmClear(FavoritesProvider fav) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('مسح المفضلة', style: TextStyle(color: AppColors.white)),
      content: const Text('هل تريد مسح كل المفضلة؟', style: TextStyle(color: AppColors.grey)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: AppColors.grey))),
        TextButton(onPressed: () {
          for (final m in fav.favs.toList()) fav.remove(m.imdbId);
          Navigator.pop(context);
        }, child: const Text('مسح الكل', style: TextStyle(color: AppColors.red))),
      ],
    ));
  }

  void _confirmRemove(FavoritesProvider fav, Movie m) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('حذف من المفضلة', style: TextStyle(color: AppColors.white)),
      content: Text('هل تريد حذف "${m.title}"؟', style: const TextStyle(color: AppColors.grey)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: AppColors.grey))),
        TextButton(onPressed: () { fav.remove(m.imdbId); Navigator.pop(context); },
          child: const Text('حذف', style: TextStyle(color: AppColors.red))),
      ],
    ));
  }

  void _showSort() {
    showModalBottomSheet(context: context, backgroundColor: AppColors.card, builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(padding: EdgeInsets.all(16),
          child: Text('ترتيب حسب', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold))),
        for (final opt in [['الافتراضي', 0], ['أ-ي تصاعدي', 1], ['ي-أ تنازلي', 2], ['الأحدث أولاً', 3]])
          ListTile(
            title: Text(opt[0] as String, style: TextStyle(color: _sort == opt[1] ? AppColors.red : AppColors.white)),
            leading: Icon(_sort == opt[1] ? Icons.check : Icons.sort, color: _sort == opt[1] ? AppColors.red : AppColors.grey),
            onTap: () { setState(() => _sort = opt[1] as int); Navigator.pop(context); },
          ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesProvider>();
    final all = fav.favs;
    final list = _filtered(all);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: ResAppBar(title: '❤️ المفضلة', showBack: false, actions: [
        IconButton(icon: const Icon(Icons.share, color: AppColors.grey), onPressed: () => _shareAll(all)),
        IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.grey), onPressed: () => _confirmClear(fav)),
      ]),
      body: Column(children: [
        // Stats
        Container(color: AppColors.card, height: 56,
          child: Row(children: [
            _stat('${all.length}', 'محفوظ', AppColors.red),
            _vDivider(),
            _stat('${all.length}', 'أفلام', AppColors.white),
            _vDivider(),
            _stat('0', 'مسلسلات', AppColors.white),
          ]),
        ),

        // Search + Sort
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(children: [
            Expanded(
              child: TextField(
                style: const TextStyle(color: AppColors.white, fontSize: 14),
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: '🔍 ابحث في المفضلة',
                  hintStyle: TextStyle(color: AppColors.grey, fontSize: 14),
                  filled: true, fillColor: AppColors.card,
                  border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(onTap: _showSort,
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: AppColors.navy,
                child: const Text('ترتيب ↕', style: TextStyle(color: AppColors.white, fontSize: 12)))),
          ]),
        ),

        // List
        Expanded(child: all.isEmpty
            ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('💔', style: TextStyle(fontSize: 72)),
                SizedBox(height: 16),
                Text('المفضلة فارغة', style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('أضف أفلامك ومسلسلاتك المفضلة', style: TextStyle(color: AppColors.grey)),
              ]))
            : list.isEmpty
                ? const Center(child: Text('لا توجد نتائج للبحث', style: TextStyle(color: AppColors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final m = list[i];
                      return Dismissible(
                        key: Key(m.imdbId),
                        direction: DismissDirection.endToStart,
                        background: Container(color: AppColors.red, alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white)),
                        confirmDismiss: (_) async {
                          _confirmRemove(fav, m);
                          return false;
                        },
                        child: MovieCard(
                          movie: m,
                          showFavBtn: false,
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => DetailScreen(imdbId: m.imdbId, movie: m))),
                          onFav: () => _confirmRemove(fav, m),
                        ),
                      );
                    },
                  ),
        ),
      ]),
    );
  }

  Widget _stat(String val, String label, Color color) => Expanded(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
    ]),
  );

  Widget _vDivider() => Container(width: 1, height: 30, color: const Color(0xFF333333));
}
