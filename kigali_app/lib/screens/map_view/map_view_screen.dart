import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../models/listing.dart';
import '../../theme.dart';
import '../detail/detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  Listing? _selectedListing;

  // Kigali center
  static const LatLng _kigaliCenter = LatLng(-1.9441, 30.0619);

  Set<Marker> _buildMarkers(List<Listing> listings) {
    return listings.map((l) {
      return Marker(
        markerId: MarkerId(l.id),
        position: LatLng(l.latitude, l.longitude),
        infoWindow: InfoWindow(title: l.name, snippet: l.category),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _selected(l) ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueAzure,
        ),
        onTap: () => setState(() => _selectedListing = l),
      );
    }).toSet();
  }

  bool _selected(Listing l) => _selectedListing?.id == l.id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: Consumer<ListingProvider>(
        builder: (_, provider, __) {
          final listings = provider.rawListings;

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(target: _kigaliCenter, zoom: 13),
                markers: _buildMarkers(listings),
                onMapCreated: (ctrl) => _mapController = ctrl,
                onTap: (_) => setState(() => _selectedListing = null),
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapType: MapType.normal,
              ),

              // Selected listing card
              if (_selectedListing != null)
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(listing: _selectedListing!),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.place, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedListing!.name,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  '${_selectedListing!.category} • ${_selectedListing!.address}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                ),

              // Listing count badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${listings.length} places',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
