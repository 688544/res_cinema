import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/movie_card.dart';
import '../services/api_service.dart';
import 'smart_pick_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final _screens = const [_HomeTab(), SmartPickScreen(), SearchScreen(), FavoritesScreen(), AboutScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.red,
        unselectedItemColor: AppColors.grey,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Text('🏠', style: TextStyle(fontSize: 20)), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Text('⚡', style: TextStyle(fontSize: 20)), label: 'ذكي'),
          BottomNavigationBarItem(icon: Text('🔍', style: TextStyle(fontSize: 20)), label: 'بحث'),
          BottomNavigationBarItem(icon: Text('❤️', style: TextStyle(fontSize: 20)), label: 'مفضلة'),
          BottomNavigationBarItem(icon: Text('ℹ️', style: TextStyle(fontSize: 20)), label: 'حول'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({Key? key}) : super(key: key);

  String get _greeting {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'صباح الخير ☀️';
    if (h >= 12 && h < 17) return 'مساء النور 🌤';
    if (h >= 17 && h < 21) return 'مساء الخير 🌅';
    return 'مساء الخير 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final favCount = context.watch<FavoritesProvider>().favs.length;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('🎬 Res سينما', style: TextStyle(color: AppColors.red, fontSize: 22, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 20),

          // Greeting
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            color: AppColors.card,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_greeting, style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('ماذا تريد أن تشاهد الليلة؟', style: TextStyle(color: AppColors.grey, fontSize: 14)),
            ]),
          ),
          const SizedBox(height: 20),

          const Text('اختر طريقتك', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Smart Pick Card
          _buildCard(
            context,
            emoji: '⚡', title: 'الاختيار الذكي',
            sub: 'اختر مزاجك وسنختار لك فورًا',
            color: AppColors.darkRed, accent: AppColors.red,
            onTap: () => _go(context, 1),
          ),
          const SizedBox(height: 10),

          // Search Card
          _buildCard(
            context,
            emoji: '🔍', title: 'البحث التقليدي',
            sub: 'ابحث عن عمل معين',
            color: const Color(0xFF0A1A0A), accent: Colors.green,
            onTap: () => _go(context, 2),
          ),
          const SizedBox(height: 10),

          // Favorites Card
          GestureDetector(
            onTap: () => _go(context, 3),
            child: Container(
              color: const Color(0xFF0F0F1A), padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Text('❤️', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 16),
                const Expanded(child: Text('قائمة المفضلة', style: TextStyle(color: AppColors.white, fontSize: 16))),
                Container(
                  width: 28, height: 28,
                  color: AppColors.red,
                  alignment: Alignment.center,
                  child: Text('$favCount', style: const TextStyle(color: AppColors.white, fontSize: 12)),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          // Stats
          Row(children: [
            _stat('$favCount', 'محفوظ', AppColors.red),
            const SizedBox(width: 8),
            _stat('∞', 'أفلام', AppColors.gold),
            const SizedBox(width: 8),
            _stat('⚡', 'قرار فوري', AppColors.white),
          ]),
        ]),
      ),
    );
  }

  void _go(BuildContext context, int tab) {
    final state = context.findAncestorStateOfType<_HomeScreenState>();
    state?.setState(() => state._tab = tab);
  }

  Widget _buildCard(BuildContext context, {required String emoji, required String title, required String sub, required Color color, required Color accent, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: color, padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(sub, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
            ])),
            Icon(Icons.arrow_forward_ios, color: accent, size: 20),
          ]),
          const SizedBox(height: 12),
          Divider(color: accent, height: 1),
        ]),
      ),
    );
  }

  Widget _stat(String val, String label, Color color) {
    return Expanded(
      child: Container(
        height: 70, color: AppColors.card,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(val, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
        ]),
      ),
    );
  }
}
