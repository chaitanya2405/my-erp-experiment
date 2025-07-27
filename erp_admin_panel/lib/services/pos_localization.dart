import 'package:flutter/material.dart';

class PosLocalization {
  final Locale locale;

  PosLocalization(this.locale);

  static PosLocalization? of(BuildContext context) {
    return Localizations.of(context, PosLocalization);
  }

  static const LocalizationsDelegate<PosLocalization> delegate = _PosLocalizationDelegate();

  // Common UI text
  String get appTitle => _localize('app_title', {
    'en': 'POS System',
    'hi': 'पीओएस सिस्टम',
    'ta': 'POS அமைப்பு',
    'te': 'POS సిస్టమ్',
    'kn': 'POS ವ್ಯವಸ್ಥೆ',
    'mr': 'पीओएस सिस्टीम',
  });

  String get transactions => _localize('transactions', {
    'en': 'Transactions',
    'hi': 'लेन-देन',
    'ta': 'பரிவர்த்தனைகள்',
    'te': 'లావాదేవీలు',
    'kn': 'ವಹಿವಾಟುಗಳು',
    'mr': 'व्यवहार',
  });

  String get analytics => _localize('analytics', {
    'en': 'Analytics',
    'hi': 'विश्लेषण',
    'ta': 'பகுப்பாய்வு',
    'te': 'విశ్లేషణలు',
    'kn': 'ವಿಶ್ಲೇಷಣೆ',
    'mr': 'विश्लेषण',
  });

  String get newSale => _localize('new_sale', {
    'en': 'New Sale',
    'hi': 'नई बिक्री',
    'ta': 'புதிய விற்பனை',
    'te': 'కొత్త అమ్మకం',
    'kn': 'ಹೊಸ ಮಾರಾಟ',
    'mr': 'नवीन विक्री',
  });

  String get customer => _localize('customer', {
    'en': 'Customer',
    'hi': 'ग्राहक',
    'ta': 'வாடிக்கையாளர்',
    'te': 'కస్టమర్',
    'kn': 'ಗ್ರಾಹಕ',
    'mr': 'ग्राहक',
  });

  String get customerName => _localize('customer_name', {
    'en': 'Customer Name',
    'hi': 'ग्राहक का नाम',
    'ta': 'வாடிக்கையாளர் பெயர்',
    'te': 'కస్టమర్ పేరు',
    'kn': 'ಗ್ರಾಹಕರ ಹೆಸರು',
    'mr': 'ग्राहकाचे नाव',
  });

  String get phoneNumber => _localize('phone_number', {
    'en': 'Phone Number',
    'hi': 'फोन नंबर',
    'ta': 'தொலைபேசி எண்',
    'te': 'ఫోన్ నంబర్',
    'kn': 'ಫೋನ್ ಸಂಖ್ಯೆ',
    'mr': 'फोन नंबर',
  });

  String get emailAddress => _localize('email_address', {
    'en': 'Email Address',
    'hi': 'ईमेल पता',
    'ta': 'மின்னஞ்சல் முகவரி',
    'te': 'ఇమెయిల్ చిరునామా',
    'kn': 'ಇಮೇಲ್ ವಿಳಾಸ',
    'mr': 'ईमेल पत्ता',
  });

  // Product related
  String get productName => _localize('product_name', {
    'en': 'Product Name',
    'hi': 'उत्पाद का नाम',
    'ta': 'தயாரிப்பு பெயர்',
    'te': 'ఉత్పత్తి పేరు',
    'kn': 'ಉತ್ಪನ್ನದ ಹೆಸರು',
    'mr': 'उत्पादनाचे नाव',
  });

  String get quantity => _localize('quantity', {
    'en': 'Quantity',
    'hi': 'मात्रा',
    'ta': 'அளவு',
    'te': 'పరిమాణం',
    'kn': 'ಪ್ರಮಾಣ',
    'mr': 'प्रमाण',
  });

  String get unitPrice => _localize('unit_price', {
    'en': 'Unit Price',
    'hi': 'इकाई मूल्य',
    'ta': 'அலகு விலை',
    'te': 'యూనిట్ ధర',
    'kn': 'ಯೂನಿಟ್ ಬೆಲೆ',
    'mr': 'एकक किंमत',
  });

  String get totalPrice => _localize('total_price', {
    'en': 'Total Price',
    'hi': 'कुल मूल्य',
    'ta': 'மொத்த விலை',
    'te': 'మొత్తం ధర',
    'kn': 'ಒಟ್ಟು ಬೆಲೆ',
    'mr': 'एकूण किंमत',
  });

  // Payment related
  String get paymentMode => _localize('payment_mode', {
    'en': 'Payment Mode',
    'hi': 'भुगतान का तरीका',
    'ta': 'கட்டண முறை',
    'te': 'చెల్లింపు విధానం',
    'kn': 'ಪಾವತಿ ವಿಧಾನ',
    'mr': 'पेमेंट मोड',
  });

  String get cash => _localize('cash', {
    'en': 'Cash',
    'hi': 'नकद',
    'ta': 'பணம்',
    'te': 'నగదు',
    'kn': 'ನಗದು',
    'mr': 'रोख',
  });

  String get card => _localize('card', {
    'en': 'Card',
    'hi': 'कार्ड',
    'ta': 'அட்டை',
    'te': 'కార్డ్',
    'kn': 'ಕಾರ್ಡ್',
    'mr': 'कार्ड',
  });

  String get upi => _localize('upi', {
    'en': 'UPI',
    'hi': 'यूपीआई',
    'ta': 'UPI',
    'te': 'UPI',
    'kn': 'UPI',
    'mr': 'UPI',
  });

  // Amount related
  String get subtotal => _localize('subtotal', {
    'en': 'Subtotal',
    'hi': 'उप-योग',
    'ta': 'துணை மொத்தம்',
    'te': 'ఉప మొత్తం',
    'kn': 'ಉಪ ಒಟ್ಟು',
    'mr': 'उपबेरीज',
  });

  String get discount => _localize('discount', {
    'en': 'Discount',
    'hi': 'छूट',
    'ta': 'தள்ளுபடி',
    'te': 'తగ్గింపు',
    'kn': 'ರಿಯಾಯಿತಿ',
    'mr': 'सवलत',
  });

  String get tax => _localize('tax', {
    'en': 'Tax',
    'hi': 'कर',
    'ta': 'வரி',
    'te': 'పన్ను',
    'kn': 'ತೆರಿಗೆ',
    'mr': 'कर',
  });

  String get gst => _localize('gst', {
    'en': 'GST',
    'hi': 'जीएसटी',
    'ta': 'GST',
    'te': 'GST',
    'kn': 'GST',
    'mr': 'GST',
  });

  String get totalAmount => _localize('total_amount', {
    'en': 'Total Amount',
    'hi': 'कुल राशि',
    'ta': 'மொத்த தொகை',
    'te': 'మొత్తం మొత్తం',
    'kn': 'ಒಟ್ಟು ಮೊತ್ತ',
    'mr': 'एकूण रक्कम',
  });

  // Actions
  String get save => _localize('save', {
    'en': 'Save',
    'hi': 'सेव करें',
    'ta': 'சேமி',
    'te': 'సేవ్ చేయండి',
    'kn': 'ಉಳಿಸಿ',
    'mr': 'सेव्ह करा',
  });

  String get cancel => _localize('cancel', {
    'en': 'Cancel',
    'hi': 'रद्द करें',
    'ta': 'ரத்துசெய்',
    'te': 'రద్దుచేయండి',
    'kn': 'ರದ್ದುಮಾಡಿ',
    'mr': 'रद्द करा',
  });

  String get print => _localize('print', {
    'en': 'Print',
    'hi': 'प्रिंट करें',
    'ta': 'அச்சிடு',
    'te': 'ప్రింట్ చేయండి',
    'kn': 'ಮುದ್ರಿಸಿ',
    'mr': 'प्रिंट करा',
  });

  String get share => _localize('share', {
    'en': 'Share',
    'hi': 'साझा करें',
    'ta': 'பகிர்',
    'te': 'షేర్ చేయండి',
    'kn': 'ಹಂಚಿಕೊಳ್ಳಿ',
    'mr': 'शेअर करा',
  });

  // Status
  String get completed => _localize('completed', {
    'en': 'Completed',
    'hi': 'पूर्ण',
    'ta': 'முடிந்தது',
    'te': 'పూర్తయింది',
    'kn': 'ಪೂರ್ಣಗೊಂಡಿದೆ',
    'mr': 'पूर्ण',
  });

  String get pending => _localize('pending', {
    'en': 'Pending',
    'hi': 'लंबित',
    'ta': 'நிலுவையில்',
    'te': 'పెండింగ్',
    'kn': 'ಬಾಕಿ',
    'mr': 'प्रलंबित',
  });

  String get cancelled => _localize('cancelled', {
    'en': 'Cancelled',
    'hi': 'रद्द',
    'ta': 'ரத்துசெய்யப்பட்டது',
    'te': 'రద్దుచేయబడింది',
    'kn': 'ರದ್ದುಮಾಡಲಾಗಿದೆ',
    'mr': 'रद्द केले',
  });

  // Messages
  String get transactionCreatedSuccessfully => _localize('transaction_created_successfully', {
    'en': 'Transaction created successfully',
    'hi': 'लेन-देन सफलतापूर्वक बनाया गया',
    'ta': 'பரிவர्त्தனை வெற்றிகரமாக உருவாக்கப்பட்டது',
    'te': 'లావాదేవీ విజయవంతంగా సృష్టించబడింది',
    'kn': 'ವಹಿವಾಟು ಯಶಸ್ವಿಯಾಗಿ ರಚಿಸಲಾಗಿದೆ',
    'mr': 'व्यवहार यशस्वीरित्या तयार केला',
  });

  String get errorCreatingTransaction => _localize('error_creating_transaction', {
    'en': 'Error creating transaction',
    'hi': 'लेन-देन बनाने में त्रुटि',
    'ta': 'பரிவர्त्தனை உருவാக்குவதில் பிழை',
    'te': 'లావాదేవీ సృష్టించడంలో లోపం',
    'kn': 'ವಹಿವಾಟನ್ನು ರಚಿಸುವಲ್ಲಿ ದೋಷ',
    'mr': 'व्यवहार तयार करण्यात त्रुटी',
  });

  String get offlineMode => _localize('offline_mode', {
    'en': 'Offline Mode',
    'hi': 'ऑफलाइन मोड',
    'ta': 'ஆஃப்லைன் பயன்முறை',
    'te': 'ఆఫ్‌లైన్ మోడ్',
    'kn': 'ಆಫ್‌ಲೈನ್ ಮೋಡ್',
    'mr': 'ऑफलाइन मोड',
  });

  // Invoice specific
  String get invoice => _localize('invoice', {
    'en': 'Invoice',
    'hi': 'चालान',
    'ta': 'இன்வாய்ஸ்',
    'te': 'ఇన్‌వాయిస్',
    'kn': 'ಇನ್‌ವಾಯ್ಸ್',
    'mr': 'इन्व्हॉइस',
  });

  String get invoiceNumber => _localize('invoice_number', {
    'en': 'Invoice Number',
    'hi': 'चालान संख्या',
    'ta': 'இன்வாய்ஸ் எண்',
    'te': 'ఇన్‌వాయిస్ నంబర్',
    'kn': 'ಇನ್‌ವಾಯ್ಸ್ ಸಂಖ್ಯೆ',
    'mr': 'इन्व्हॉइस नंबर',
  });

  String get invoiceDate => _localize('invoice_date', {
    'en': 'Invoice Date',
    'hi': 'चालान दिनांक',
    'ta': 'இன்வாய்ஸ் தேதி',
    'te': 'ఇన్‌వాయిస్ తేదీ',
    'kn': 'ಇನ್‌ವಾಯ್ಸ್ ದಿನಾಂಕ',
    'mr': 'इन्व्हॉइस दिनांक',
  });

  // Currency formatting
  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Date formatting based on locale
  String formatDate(DateTime date) {
    switch (locale.languageCode) {
      case 'hi':
        return '${date.day}/${date.month}/${date.year}';
      case 'ta':
      case 'te':
      case 'kn':
      case 'mr':
        return '${date.day}-${date.month}-${date.year}';
      default:
        return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Number formatting
  String formatNumber(int number) {
    // Indian number formatting
    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(1)} Cr';
    } else if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(1)} L';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)} K';
    }
    return number.toString();
  }

  // Helper method to get localized text
  String _localize(String key, Map<String, String> translations) {
    return translations[locale.languageCode] ?? translations['en'] ?? key;
  }

  // Getters for customer tiers
  String get customerTierVip => _localize('customer_tier_vip', {
    'en': 'VIP',
    'hi': 'वीआईपी',
    'ta': 'VIP',
    'te': 'VIP',
    'kn': 'VIP',
    'mr': 'VIP',
  });

  String get customerTierPremium => _localize('customer_tier_premium', {
    'en': 'Premium',
    'hi': 'प्रीमियम',
    'ta': 'பிரீமியம்',
    'te': 'ప్రీమియం',
    'kn': 'ಪ್ರೀಮಿಯಂ',
    'mr': 'प्रीमियम',
  });

  String get customerTierGold => _localize('customer_tier_gold', {
    'en': 'Gold',
    'hi': 'गोल्ड',
    'ta': 'தங்கம்',
    'te': 'గోల్డ్',
    'kn': 'ಚಿನ್ನ',
    'mr': 'गोल्ड',
  });

  String get customerTierSilver => _localize('customer_tier_silver', {
    'en': 'Silver',
    'hi': 'सिल्वर',
    'ta': 'வெள்ளி',
    'te': 'సిల్వర్',
    'kn': 'ಬೆಳ್ಳಿ',
    'mr': 'सिल्व्हर',
  });

  String get customerTierRegular => _localize('customer_tier_regular', {
    'en': 'Regular',
    'hi': 'नियमित',
    'ta': 'வழக்கமான',
    'te': 'సాధారణ',
    'kn': 'ನಿಯಮಿತ',
    'mr': 'नियमित',
  });
}

class _PosLocalizationDelegate extends LocalizationsDelegate<PosLocalization> {
  const _PosLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'ta', 'te', 'kn', 'mr'].contains(locale.languageCode);
  }

  @override
  Future<PosLocalization> load(Locale locale) async {
    return PosLocalization(locale);
  }

  @override
  bool shouldReload(_PosLocalizationDelegate old) => false;
}

// Supported locales
const List<Locale> supportedLocales = [
  Locale('en', 'US'), // English
  Locale('hi', 'IN'), // Hindi
  Locale('ta', 'IN'), // Tamil
  Locale('te', 'IN'), // Telugu
  Locale('kn', 'IN'), // Kannada
  Locale('mr', 'IN'), // Marathi
];

// Language names for UI
const Map<String, String> languageNames = {
  'en': 'English',
  'hi': 'हिन्दी',
  'ta': 'தமிழ்',
  'te': 'తెలుగు',
  'kn': 'ಕನ್ನಡ',
  'mr': 'मराठी',
};
