import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/movie.dart';

class AppColors {
  static const bg      = Color(0xFF0A0A0F);
  static const card    = Color(0xFF111118);
  static const navy    = Color(0xFF1A1A2E);
  static const red     = Color(0xFFE50914);
  static const gold    = Color(0xFFFFD700);
  static const grey    = Color(0xFF888888);
  static const white   = Color(0xFFFFFFFF);
  static const darkRed = Color(0xFF1A0A0A);
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback? onFav;
  final bool showFavBtn;

  const MovieCard({Key? key, required this.movie, required this.onTap, this.onFav, this.showFavBtn = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        color: AppColors.card,
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          PosterImage(url: movie.poster, width: 75, height: 108),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(movie.title, style: const TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('📅 ${movie.year}', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              Text(movie.type == 'movie' ? '🎬 فيلم' : '📺 مسلسل', style: const TextStyle(color: AppColors.red, fontSize: 11)),
              if (movie.rating.isNotEmpty && movie.rating != 'N/A')
                Text('⭐ ${movie.rating}', style: const TextStyle(color: AppColors.gold, fontSize: 12)),
              if (showFavBtn && onFav != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onFav,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    color: AppColors.darkRed,
                    child: const Text('❤️ حفظ', style: TextStyle(color: AppColors.white, fontSize: 12)),
                  ),
                ),
              ]
            ],
          )),
        ]),
      ),
    );
  }
}

class PosterImage extends StatelessWidget {
  final String url;
  final double width, height;
  const PosterImage({Key? key, required this.url, required this.width, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty || url == 'N/A') {
      return Container(width: width, height: height, color: AppColors.navy,
        child: const Icon(Icons.movie, color: AppColors.grey));
    }
    return CachedNetworkImage(
      imageUrl: url, width: width, height: height, fit: BoxFit.cover,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.navy, highlightColor: AppColors.card,
        child: Container(width: width, height: height, color: AppColors.navy),
      ),
      errorWidget: (_, __, ___) => Container(width: width, height: height, color: AppColors.navy,
        child: const Icon(Icons.broken_image, color: AppColors.grey)),
    );
  }
}

class ResAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  const ResAppBar({Key? key, required this.title, this.actions, this.showBack = true}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bg,
      elevation: 0,
      leading: showBack ? IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ) : null,
      automaticallyImplyLeading: false,
      title: Text(title, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      centerTitle: true,
      actions: actions,
    );
  }
}
