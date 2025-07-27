import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/mobile_user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Example: Fetch permitted user profile and allowed modules for mobile app
Future<MobileUserProfile?> fetchMobileUserProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (!doc.exists) return null;
  return MobileUserProfile.fromMap(doc.data()!, doc.id);
}

/// Example: Query only permitted data (e.g., customer orders)
Stream<QuerySnapshot> customerOrdersStream(String customerId) {
  return FirebaseFirestore.instance
      .collection('orders')
      .where('customerId', isEqualTo: customerId)
      .snapshots();
}

/// Example: Use modulesAccess to show/hide features in the app
bool canAccessModule(MobileUserProfile profile, String module) {
  return profile.modulesAccess.contains(module);
}
