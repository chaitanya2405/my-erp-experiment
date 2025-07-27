import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Add Developer Tools module to Firebase modules collection
Future<void> addDeveloperToolsModule() async {
  try {
    // Initialize Firebase if not already done
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final firestore = FirebaseFirestore.instance;
    
    // Check if module already exists
    final existingModule = await firestore
        .collection('modules')
        .where('title', isEqualTo: 'Developer Tools')
        .get();
    
    if (existingModule.docs.isEmpty) {
      // Add the Developer Tools module
      await firestore.collection('modules').add({
        'title': 'Developer Tools',
        'icon': '🛠️',
        'description': 'Code activity tracking and development tools',
        'category': 'development',
        'priority': 100,
        'isActive': true,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'features': [
          'Code Activity Tracking',
          'File Change Monitoring',
          'Development Statistics',
          'Project Analytics',
          'Daily Reports'
        ],
        'version': '1.0.0'
      });
      
      print('✅ Developer Tools module added to Firebase');
    } else {
      print('ℹ️ Developer Tools module already exists');
    }
  } catch (e) {
    print('❌ Error adding Developer Tools module: $e');
  }
}

void main() async {
  await addDeveloperToolsModule();
}
