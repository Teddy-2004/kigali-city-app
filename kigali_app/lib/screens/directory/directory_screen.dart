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
            _buildCategoryChips(),
            _buildSearchBar(),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Near You',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildListingsList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddListingScreen()));
        },
        child: const Icon(Icons.add, color: AppColors.background),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kigali City',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Consumer<ap.AuthProvider>(
                builder: (_, auth, __) => Text(
                  'Welcome, ${auth.userProfile?.displayName ?? 'User'}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_city, color: AppColors.background, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Consumer<ListingProvider>(
      builder: (_, provider, __) {
        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('All'),
                  selected: provider.selectedCategory == null,
                  onSelected: (_) => provider.setCategory(null),
                ),
              ),
              ...kCategories.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: provider.selectedCategory == cat,
                      onSelected: (_) {
                        provider.setCategory(provider.selectedCategory == cat ? null : cat);
                      },
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: AppColors.textPrimary),
        onChanged: (v) => context.read<ListingProvider>().setSearchQuery(v),
        decoration: InputDecoration(
          hintText: 'Search for a service',
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textMuted),
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

  Widget _buildListingsList() {
    return Consumer<ListingProvider>(
      builder: (_, provider, __) {
        if (provider.status == ListingStatus.loading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (provider.status == ListingStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 12),
                Text(
                  provider.errorMessage ?? 'Failed to load listings',
                  style: const TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: provider.startListening,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final listings = provider.allListings;
        if (listings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, color: AppColors.textMuted, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'No listings found',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                if (provider.searchQuery.isNotEmpty || provider.selectedCategory != null)
                  TextButton(
                    onPressed: provider.clearFilters,
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: listings.length,
          itemBuilder: (_, i) => _ListingCard(listing: listings[i]),
        );
      },
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Listing listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(listing: listing)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_categoryIcon(listing.category), color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (listing.rating != null) ...[
                        const Icon(Icons.star, color: AppColors.starColor, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          listing.rating!.toStringAsFixed(1),
                          style: const TextStyle(color: AppColors.starColor, fontSize: 13),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        listing.category,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (listing.distanceKm != null)
                  Text(
                    '${listing.distanceKm!.toStringAsFixed(1)} km',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Hospital': return Icons.local_hospital;
      case 'Police Station': return Icons.local_police;
      case 'Library': return Icons.local_library;
      case 'Restaurant': return Icons.restaurant;
      case 'Café': return Icons.coffee;
      case 'Park': return Icons.park;
      case 'Tourist Attraction': return Icons.camera_alt;
      case 'Pharmacy': return Icons.medication;
      case 'School': return Icons.school;
      case 'Bank': return Icons.account_balance;
      default: return Icons.place;
    }
  }
}
