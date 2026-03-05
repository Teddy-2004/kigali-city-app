import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'listings';

  // Real-time stream of all listings
  Stream<List<Listing>> getAllListings() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Listing.fromFirestore).toList());
  }

  // Real-time stream of user's listings
  Stream<List<Listing>> getUserListings(String uid) {
    return _firestore
        .collection(_collection)
        .where('createdBy', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Listing.fromFirestore).toList());
  }

  Future<String> createListing(Listing listing) async {
    final doc = await _firestore
        .collection(_collection)
        .add(listing.toFirestore());
    return doc.id;
  }

  Future<void> updateListing(Listing listing) async {
    await _firestore
        .collection(_collection)
        .doc(listing.id)
        .update(listing.toFirestore());
  }

  Future<void> deleteListing(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<Listing?> getListingById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) return Listing.fromFirestore(doc);
    return null;
  }
}
