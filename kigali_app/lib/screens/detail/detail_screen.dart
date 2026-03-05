import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/listing.dart';
import '../../theme.dart';

class DetailScreen extends StatefulWidget {
  final Listing listing;
  const DetailScreen({super.key, required this.listing});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  GoogleMapController? _mapController;

  Future<void> _launchNavigation() async {
    final l = widget.listing;
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${l.latitude},${l.longitude}&travelmode=driving',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  Future<void> _callPhone() async {
    final phone = widget.listing.contactNumber;
    if (phone.isEmpty) return;
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.listing;
    final latLng = LatLng(l.latitude, l.longitude);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: GoogleMap(
                initialCameraPosition: CameraPosition(target: latLng, zoom: 15),
                markers: {
                  Marker(
                    markerId: const MarkerId('listing'),
                    position: latLng,
                    infoWindow: InfoWindow(title: l.name, snippet: l.address),
                  ),
                },
                onMapCreated: (ctrl) => _mapController = ctrl,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Category
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    l.category,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (l.distanceKm != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '${l.distanceKm!.toStringAsFixed(1)} km',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (l.rating != null)
                        Column(
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < l.rating!.floor() ? Icons.star : Icons.star_border,
                                  color: AppColors.starColor,
                                  size: 18,
                                ),
                              ),
                            ),
                            if (l.reviewCount != null)
                              Text(
                                '${l.reviewCount} reviews',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info Cards
                  _InfoRow(icon: Icons.location_on_outlined, label: 'Address', value: l.address),
                  if (l.contactNumber.isNotEmpty)
                    GestureDetector(
                      onTap: _callPhone,
                      child: _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Contact',
                        value: l.contactNumber,
                        valueColor: AppColors.accent,
                      ),
                    ),
                  _InfoRow(
                    icon: Icons.my_location_outlined,
                    label: 'Coordinates',
                    value: '${l.latitude.toStringAsFixed(4)}, ${l.longitude.toStringAsFixed(4)}',
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.description,
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
                  ),

                  const SizedBox(height: 32),

                  // Navigation Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _launchNavigation,
                      icon: const Icon(Icons.navigation_outlined),
                      label: const Text('Get Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (l.contactNumber.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _callPhone,
                        icon: const Icon(Icons.phone, color: AppColors.accent),
                        label: const Text('Call', style: TextStyle(color: AppColors.accent)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.accent),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
