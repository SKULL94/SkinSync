import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skin_sync/core/constants/color_const.dart';
import 'package:skin_sync/core/services/news_service.dart';
import 'package:skin_sync/core/theme/theme_extension.dart';
import 'package:skin_sync/features/layout/presentation/bloc/layout_bloc.dart';

class SkinNewsPage extends StatefulWidget {
  const SkinNewsPage({super.key});

  @override
  State<SkinNewsPage> createState() => _SkinNewsPageState();
}

class _SkinNewsPageState extends State<SkinNewsPage> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  List<NewsArticle> _articles = [];
  final ScrollController _scrollController = ScrollController();

  static const int _pageSize = 15;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadNews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreNews();
    }
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    try {
      final articles = await NewsService.getSkinNews(pageSize: _pageSize);
      setState(() {
        _articles = articles;
        _isLoading = false;
        _hasMoreData = articles.length >= _pageSize;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isLoadingMore || !_hasMoreData || _isLoading) return;

    setState(() => _isLoadingMore = true);

    try {
      final newArticles = await NewsService.getSkinNews(
        pageSize: _pageSize * (_currentPage + 1),
      );

      setState(() {
        // Get only new articles (beyond current count)
        if (newArticles.length > _articles.length) {
          _articles = newArticles;
          _currentPage++;
        }
        _hasMoreData = newArticles.length > _articles.length;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _openArticle(NewsArticle article) async {
    final url = Uri.tryParse(article.url);
    if (url != null) {
      try {
        final canLaunch = await canLaunchUrl(url);
        if (canLaunch) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        } else {
          // Try with in-app browser as fallback
          await launchUrl(
            url,
            mode: LaunchMode.inAppBrowserView,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open article: ${article.title}'),
              action: SnackBarAction(
                label: 'Copy URL',
                onPressed: () {
                  // Copy URL to clipboard would go here
                },
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colors),
            Expanded(
              child: _isLoading ? _buildLoading(colors) : _buildNewsList(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColorsTheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<LayoutBloc>().add(const LayoutTabChanged(0)),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DISCOVER',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Skin News',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _isLoading ? null : _loadNews,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                      ),
                    )
                  : Icon(
                      Icons.refresh,
                      size: 18,
                      color: colors.primary,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(AppColorsTheme colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Fetching latest skin news...',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(AppColorsTheme colors) {
    if (_articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article_outlined,
              size: 48,
              color: colors.cardBorder,
            ),
            const SizedBox(height: 16),
            Text(
              'No news found',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different category or refresh',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: colors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadNews,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNews,
      color: colors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        itemCount: _articles.length + (_isLoadingMore || _hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading indicator at the bottom
          if (index >= _articles.length) {
            return _buildLoadingMore(colors);
          }

          final article = _articles[index];

          // First article is featured (larger)
          if (index == 0) {
            return _buildFeaturedCard(article, colors);
          }

          return _buildNewsCard(article, colors);
        },
      ),
    );
  }

  Widget _buildLoadingMore(AppColorsTheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: _isLoadingMore
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Loading more...',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildFeaturedCard(NewsArticle article, AppColorsTheme colors) {
    return GestureDetector(
      onTap: () => _openArticle(article),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with caching
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: _buildCachedImage(
                article.imageUrl,
                height: 180,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildCategoryBadge(article.category, colors),
                      const Spacer(),
                      Text(
                        article.timeAgo,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (article.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      article.description!,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.public,
                        size: 14,
                        color: colors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          article.source,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: colors.textTertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Read',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: colors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle article, AppColorsTheme colors) {
    return GestureDetector(
      onTap: () => _openArticle(article),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with caching
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildCachedImage(
                article.imageUrl,
                width: 85,
                height: 85,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildCategoryBadge(article.category, colors, small: true),
                      const SizedBox(width: 8),
                      Text(
                        article.timeAgo,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.source,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: colors.textTertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Read',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right,
                              size: 14,
                              color: colors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCachedImage(String? imageUrl, {double? width, double? height}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildImagePlaceholder(width: width, height: height);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      memCacheWidth: width != null && width.isFinite ? (width * 2).toInt() : null,
      memCacheHeight: height != null && height.isFinite ? (height * 2).toInt() : null,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.rose.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildImagePlaceholder(
        width: width,
        height: height,
      ),
    );
  }

  Widget _buildCategoryBadge(String category, AppColorsTheme colors, {bool small = false}) {
    Color bgColor;
    Color textColor;

    switch (category) {
      case 'Health':
        bgColor = AppColors.rose.withValues(alpha: 0.12);
        textColor = AppColors.rose;
        break;
      case 'Products':
        bgColor = AppColors.primary.withValues(alpha: 0.12);
        textColor = AppColors.primary;
        break;
      case 'Research':
        bgColor = AppColors.sage.withValues(alpha: 0.12);
        textColor = AppColors.sage;
        break;
      case 'Tips':
        bgColor = AppColors.amber.withValues(alpha: 0.12);
        textColor = AppColors.amber;
        break;
      case 'Trends':
        bgColor = const Color(0xFF9B59B6).withValues(alpha: 0.12);
        textColor = const Color(0xFF9B59B6);
        break;
      default:
        bgColor = AppColors.textTertiary.withValues(alpha: 0.12);
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: GoogleFonts.dmSans(
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder({double? width, double? height}) {
    final isSmall = (width ?? 200) < 100;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.rose.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: isSmall ? 24 : 40,
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
          if (!isSmall) ...[
            const SizedBox(height: 8),
            Text(
              'Skin News',
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
