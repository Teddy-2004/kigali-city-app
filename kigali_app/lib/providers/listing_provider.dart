import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/listing.dart';
import '../services/listing_service.dart';

enum ListingStatus { initial, loading, loaded, error }

class ListingProvider extends ChangeNotifier {
  final ListingService _service = ListingService();

  List<Listing> _allListings = [];
  List<Listing> _userListings = [];
  ListingStatus _status = ListingStatus.initial;
  ListingStatus _userListingStatus = ListingStatus.initial;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCategory;

  StreamSubscription<List<Listing>>? _allListingsSubscription;
  StreamSubscription<List<Listing>>? _userListingsSubscription;

  List<Listing> get allListings => _filteredListings;
  List<Listing> get userListings => _userListings;
  List<Listing> get rawListings => _allListings;
  ListingStatus get status => _status;
  ListingStatus get userListingStatus => _userListingStatus;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  List<Listing> get _filteredListings {
    var result = _allListings;
    if (_selectedCategory != null) {
      result = result.where((l) => l.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((l) => l.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return result;
  }

  void startListening() {
    _status = ListingStatus.loading;
    notifyListeners();

    _allListingsSubscription?.cancel();
    _allListingsSubscription = _service.getAllListings().listen(
      (listings) {
        _allListings = listings;
        _status = ListingStatus.loaded;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Failed to load listings: $e';
        _status = ListingStatus.error;
        notifyListeners();
      },
    );
  }

  void startListeningUserListings(String uid) {
    _userListingStatus = ListingStatus.loading;
    notifyListeners();

    _userListingsSubscription?.cancel();
    _userListingsSubscription = _service.getUserListings(uid).listen(
      (listings) {
        _userListings = listings;
        _userListingStatus = ListingStatus.loaded;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Failed to load your listings: $e';
        _userListingStatus = ListingStatus.error;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _allListingsSubscription?.cancel();
    _userListingsSubscription?.cancel();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  Future<bool> createListing(Listing listing) async {
    try {
      await _service.createListing(listing);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create listing: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateListing(Listing listing) async {
    try {
      await _service.updateListing(listing);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update listing: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteListing(String id) async {
    try {
      await _service.deleteListing(id);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete listing: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
