import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/movie_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  void _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _dialog(BuildContext ctx, String title, String body) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(title, style: const TextStyle(color: AppColors.white)),
      content: Text(body, style: const TextStyle(color: AppColors.grey, height: 1.6)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx),
        child: const Text('حسناً', style: TextStyle(color: AppColors.red)))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: ResAppBar(title: 'ℹ️ حول التطبيق', showBack: false),
      body: ListView(children: [
        // Hero
        Container(
          width: double.infinity, height: 200,
          color: const Color(0xFF0F0F1A),
          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('🎬', style: TextStyle(fontSize: 64)),
            SizedBox(height: 10),
            Text('Res سينما', style: TextStyle(color: AppColors.red, fontSize: 30, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('الإصدار 1.0.0', style: TextStyle(color: AppColors.grey, fontSize: 13)),
            SizedBox(height: 6),
            Text('⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 16)),
          ]),
        ),

        _section('عن التطبيق', [
          _textTile('Res سينما هو تطبيقك الذكي لاكتشاف الأفلام والمسلسلات. بدلاً من التمرير في قوائم لا نهاية لها، يساعدك على اتخاذ قرار سريع بناءً على مزاجك وتفضيلاتك.'),
        ]),

        _section('مميزات التطبيق', [
          _featureTile('⚡', 'اختيار ذكي فوري بناءً على مزاجك'),
          _featureTile('📦', 'حفظ البوسترات للمشاهدة بدون إنترنت'),
          _featureTile('🌐', 'ترجمة تلقائية لقصص الأعمال'),
          _featureTile('❤️', 'قائمة مفضلة متطورة مع ترتيب وبحث'),
          _featureTile('🌙', 'تصميم داكن احترافي'),
          _featureTile('📤', 'مشاركة الأفلام وقوائم المفضلة'),
        ]),

        _section('Res للبرمجيات', [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Row(children: [
                Text('💻', style: TextStyle(fontSize: 28)),
                SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Res للبرمجيات', style: TextStyle(color: AppColors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  Text('Res Software', style: TextStyle(color: AppColors.red, fontSize: 13)),
                ]),
              ]),
              const SizedBox(height: 12),
              const Text(
                'شركة مبتكرة متخصصة في تطوير التطبيقات والحلول الرقمية الذكية، تجمع بين البساطة والفعالية لتقديم تجربة مستخدم سلسة وحلول عملية تلبي احتياجات الأفراد والشركات.',
                style: TextStyle(color: AppColors.grey, fontSize: 14, height: 1.6),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),
              _linkRow('✈️', 'قناة Res على تيليجرام', '@res_For_software', () => _open('https://t.me/res_For_software')),
              const SizedBox(height: 10),
              _linkRow('🛠', 'الدعم وحل المشاكل', '@res_soft', () => _open('https://t.me/res_soft')),
            ]),
          ),
        ]),

        _section('الإعدادات', [
          _actionTile(Icons.privacy_tip_outlined, 'سياسة الخصوصية', () => _dialog(context,
            'سياسة الخصوصية',
            '• لا نجمع أي بيانات شخصية\n• لا نشارك بياناتك مع أطراف ثالثة\n• البيانات المحفوظة تبقى على جهازك فقط\n• الصور المحفوظة تُخزَّن محلياً\n\n© 2024 Res للبرمجيات')),
          _actionTile(Icons.description_outlined, 'شروط الاستخدام', () => _dialog(context,
            'شروط الاستخدام',
            '• الاستخدام للأغراض الشخصية فقط\n• بيانات الأفلام مقدمة من OMDb API\n• الترجمة عبر MyMemory API\n• الشركة غير مسؤولة عن دقة بيانات API\n\n© 2024 Res للبرمجيات')),
        ]),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: Text('© 2024 Res للبرمجيات - جميع الحقوق محفوظة',
            style: TextStyle(color: Color(0xFF444444), fontSize: 12))),
        ),
      ]),
    );
  }

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Text(title, style: const TextStyle(color: AppColors.red, fontSize: 15, fontWeight: FontWeight.bold))),
      Container(color: AppColors.card, child: Column(children: children)),
    ],
  );

  Widget _textTile(String text) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(text, style: const TextStyle(color: AppColors.grey, fontSize: 14, height: 1.6), textAlign: TextAlign.right),
  );

  Widget _featureTile(String emoji, String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 12),
      Text(text, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 14)),
    ]),
  );

  Widget _actionTile(IconData icon, String label, VoidCallback onTap) => ListTile(
    leading: Icon(icon, color: AppColors.grey),
    title: Text(label, style: const TextStyle(color: AppColors.white)),
    trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 14),
    onTap: onTap,
  );

  static Widget _linkRow(String emoji, String title, String sub, VoidCallback onTap) =>
    GestureDetector(onTap: onTap,
      child: Container(
        color: const Color(0xFF1A1A30), padding: const EdgeInsets.all(12),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            Text(sub, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          ])),
          const Icon(Icons.arrow_forward_ios, color: Color(0xFF4A90D9), size: 14),
        ]),
      ),
    );
}
