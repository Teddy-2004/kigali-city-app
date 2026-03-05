import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final bool notificationsEnabled;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.notificationsEnabled = true,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notificationsEnabled: data['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'notificationsEnabled': notificationsEnabled,
    };
  }

  UserProfile copyWith({bool? notificationsEnabled, String? displayName}) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
