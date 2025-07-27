import 'package:firebase_core/firebase_core.dart';
import 'mock_data_service.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyB9g3Ku_faWmuXKYVjI2S0qieXHf5OM2hQ',
      appId: '1:526643219487:web:6e3205e5f2102e6740192a',
      messagingSenderId: '526643219487',
      projectId: 'ravali-software',
      authDomain: 'ravali-software.firebaseapp.com',
      storageBucket: 'ravali-software.appspot.com',
      measurementId: 'G-76L52S3HV0',
    ),
  );
  await MockDataService.regenerateMockData();
  print('Mock data regenerated!');
}
