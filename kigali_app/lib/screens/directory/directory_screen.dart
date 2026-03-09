import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../models/listing.dart';
import '../../theme.dart';
import '../detail/detail_screen.dart';
import 'add_listing_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});
  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryChips(),
            _buildCountRow(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddListingScreen()),
        ),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Add Place'),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KIGALI CITY',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Directory',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
          ),
          Consumer<ap.AuthProvider>(
            builder: (_, auth, __) {
              final name = auth.userProfile?.displayName ?? 'User';
              final initials = name
                  .split(' ')
                  .take(2)
                  .map((s) => s.isNotEmpty ? s[0].toUpperCase() : '')
                  .join();
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.25)),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: TextField(
        controller: _searchCtrl,
        style:
            const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        onChanged: (v) =>
            context.read<ListingProvider>().setSearchQuery(v),
        decoration: InputDecoration(
          hintText: 'Search places, hospitals, parks…',
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textMuted, size: 20),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    context.read<ListingProvider>().setSearchQuery('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  // ── Category chips ─────────────────────────────────────────────────────────

  Widget _buildCategoryChips() {
    return Consumer<ListingProvider>(
      builder: (_, provider, __) => SizedBox(
        height: 38,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _chip('All', null, provider),
            ...kCategories.map((cat) => _chip(cat, cat, provider)),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String? value, ListingProvider provider) {
    final selected = provider.selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => provider.setCategory(
            selected && value != null ? null : value),
      ),
    );
  }

  // ── Count row ──────────────────────────────────────────────────────────────

  Widget _buildCountRow() {
    return Consumer<ListingProvider>(
      builder: (_, provider, __) {
        final count = provider.allListings.length;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Row(
            children: [
              const Text('Near you',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    '$count result${count != 1 ? 's' : ''}',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── List ───────────────────────────────────────────────────────────────────

  Widget _buildList() {
    return Consumer<ListingProvider>(
      builder: (_, provider, __) {
        if (provider.status == ListingStatus.loading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (provider.status == ListingStatus.error) {
          return _emptyState(
            icon: Icons.wifi_off_rounded,
            color: AppColors.error,
            title: 'Connection error',
            subtitle: provider.errorMessage ?? 'Failed to load listings',
            action: TextButton.icon(
              onPressed: provider.startListening,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          );
        }

        final listings = provider.allListings;
        if (listings.isEmpty) {
          return _emptyState(
            icon: Icons.search_off_rounded,
            color: AppColors.textMuted,
            title: 'No places found',
            subtitle: provider.searchQuery.isNotEmpty ||
                    provider.selectedCategory != null
                ? 'Try adjusting your search or filters'
                : 'Be the first to add a place in Kigali',
            action: provider.searchQuery.isNotEmpty ||
                    provider.selectedCategory != null
                ? TextButton.icon(
                    onPressed: provider.clearFilters,
                    icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                    label: const Text('Clear filters'),
                  )
                : null,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          itemCount: listings.length,
          itemBuilder: (_, i) => _ListingCard(listing: listings[i]),
        );
      },
    );
  }

  Widget _emptyState({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 16),
              action,
            ],
          ],
        ),
      ),
    );
  }
}

// ── Listing card ──────────────────────────────────────────────────────────────

class _ListingCard extends StatelessWidget {
  final Listing listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(listing.category);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(listing: listing)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(AppColors.categoryIcon(listing.category),
                  color: color, size: 24),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      // Category pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          listing.category,
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (listing.rating != null) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.star_rounded,
                            color: AppColors.starColor, size: 13),
                        const SizedBox(width: 2),
                        Text(
                          listing.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                              color: AppColors.starColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppColors.textMuted, size: 12),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          listing.address,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}
