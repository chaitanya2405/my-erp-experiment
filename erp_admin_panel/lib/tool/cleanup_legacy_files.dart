// Script to organize legacy files by moving them to unused_files folder
// This preserves the code for future reference instead of deleting

import 'dart:io';

Future<void> main() async {
  print('📁 Starting Legacy File Organization...');
  
  final projectRoot = Directory.current;
  int filesMoved = 0;
  int totalBytes = 0;
  
  // Create unused_files directory
  final unusedDir = Directory('${projectRoot.path}/unused_files');
  if (!await unusedDir.exists()) {
    await unusedDir.create(recursive: true);
    print('📂 Created unused_files directory');
  }
  
  // List of files to move to unused_files
  final filesToMove = [
    // Broken app_services files
    'lib/app_services.broken',
    'lib/app_services.broken2',
    'lib/app_services.broken3',
    'lib/app_services.broken4',
    'lib/app_services.broken5',
    'lib/app_services.broken6',
    'lib/app_services.broken7',
    'lib/app_services.broken8',
    'lib/app_services.broken9',
    'lib/app_services.broken10',
    'lib/app_services.broken11',
    'lib/app_services.broken12',
    'lib/app_services.broken13',
    'lib/app_services.broken14',
    'lib/app_services.broken15',
    'lib/app_services.broken16',
    'lib/app_services.broken17',
    'lib/app_services.old',
    
    // Broken module files
    'lib/add_modules.dart.broken',
    
    // Multiple main files (keep only main.dart)
    'lib/main_complete.dart',
    'lib/main_enhanced.dart',
    'lib/main_simple.dart',
    
    // Debug and test files
    'lib/debug_customer_test.dart',
    'lib/test_firestore_mac.dart',
    'lib/enhanced_erp_demo.dart',
    'lib/fix_demo_customer.dart',
    'lib/mobile_customer_sync_example.dart',
    
    // Service backup files
    'lib/services/core_services.backup',
    'lib/services/core_services.broken',
    'lib/services/core_services.old',
    'lib/services/test_imports.dart',
    
    // System files
    'lib/.DS_Store',
    '.DS_Store',
  ];
  
  print('📋 Files to be moved to unused_files/:');
  for (final filePath in filesToMove) {
    final file = File('${projectRoot.path}/$filePath');
    if (await file.exists()) {
      final stat = await file.stat();
      totalBytes += stat.size;
      print('  📦 $filePath (${_formatBytes(stat.size)})');
    }
  }
  
  print('\n� Total files to move: ${filesToMove.where((f) => File('${projectRoot.path}/$f').existsSync()).length}');
  print('💾 Total size: ${_formatBytes(totalBytes)}');
  
  print('\n💡 These files will be preserved in unused_files/ for future reference');
  
  stdout.write('\n❓ Do you want to proceed with organizing files? (y/N): ');
  final input = stdin.readLineSync()?.toLowerCase();
  
  if (input == 'y' || input == 'yes') {
    print('\n📁 Starting file organization...');
    
    for (final filePath in filesToMove) {
      final sourceFile = File('${projectRoot.path}/$filePath');
      if (await sourceFile.exists()) {
        try {
          // Create subdirectories in unused_files if needed
          final relativePath = filePath;
          final targetPath = '${unusedDir.path}/$relativePath';
          final targetFile = File(targetPath);
          
          // Create parent directories if they don't exist
          await targetFile.parent.create(recursive: true);
          
          // Move the file
          await sourceFile.copy(targetPath);
          await sourceFile.delete();
          
          filesMoved++;
          print('  ✅ Moved: $filePath → unused_files/$filePath');
        } catch (e) {
          print('  ❌ Failed to move $filePath: $e');
        }
      }
    }
    
    print('\n🎉 File organization completed!');
    print('📊 Summary:');
    print('  - Files moved: $filesMoved');
    print('  - Total size organized: ${_formatBytes(totalBytes)}');
    print('  - Files preserved in: unused_files/');
    
    print('\n✅ Benefits:');
    print('  - Cleaner project structure');
    print('  - Code preserved for future reference');
    print('  - Reduced confusion from duplicate files');
    print('  - Better IDE performance');
    print('  - Easy to restore files if needed');
    
    print('\n📝 Note: You can find all moved files in the unused_files/ directory');
    
  } else {
    print('\n🚫 Organization cancelled. No files were moved.');
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
