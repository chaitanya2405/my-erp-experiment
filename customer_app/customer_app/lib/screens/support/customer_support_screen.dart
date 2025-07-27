// 🎧 CUSTOMER SUPPORT SCREEN
// Complete support center with FAQ, chat, tickets, and contact options
// Includes search functionality and category-based help

import 'package:flutter/material.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  String _selectedCategory = 'All';
  bool _isSubmittingTicket = false;

  // Mock FAQ data
  final List<Map<String, dynamic>> _faqData = [
    {
      'category': 'Orders',
      'question': 'How do I track my order?',
      'answer': 'You can track your order by going to the Order History section in your account. Each order will show its current status and tracking information if available.',
    },
    {
      'category': 'Orders',
      'question': 'Can I cancel my order?',
      'answer': 'Orders can be cancelled within 24 hours of placement, provided they haven\'t been shipped yet. Go to Order History and click "Cancel Order" if the option is available.',
    },
    {
      'category': 'Shipping',
      'question': 'How long does shipping take?',
      'answer': 'Standard shipping takes 3-7 business days. Express shipping takes 1-3 business days. You\'ll receive a tracking number once your order ships.',
    },
    {
      'category': 'Shipping',
      'question': 'Do you offer free shipping?',
      'answer': 'Yes! We offer free standard shipping on orders over \$50. For orders under \$50, shipping costs \$9.99.',
    },
    {
      'category': 'Account',
      'question': 'How do I update my profile information?',
      'answer': 'Go to your Profile section and click the Edit button. You can update your name, email, phone number, and shipping addresses.',
    },
    {
      'category': 'Account',
      'question': 'How do I change my password?',
      'answer': 'In your Profile section, go to Account Settings and select "Change Password". You\'ll need to enter your current password and your new password.',
    },
    {
      'category': 'Payment',
      'question': 'What payment methods do you accept?',
      'answer': 'We accept all major credit cards (Visa, MasterCard, American Express), PayPal, and Apple Pay for a secure checkout experience.',
    },
    {
      'category': 'Payment',
      'question': 'Is my payment information secure?',
      'answer': 'Yes, we use industry-standard encryption and secure payment processing. Your payment information is never stored on our servers.',
    },
    {
      'category': 'Returns',
      'question': 'What is your return policy?',
      'answer': 'We offer a 30-day return policy for most items. Items must be in original condition with tags attached. Some restrictions apply to certain product categories.',
    },
    {
      'category': 'Returns',
      'question': 'How do I return an item?',
      'answer': 'Contact our support team to initiate a return. We\'ll provide you with a return shipping label and instructions for sending the item back.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredFAQs() {
    var filtered = _faqData;
    
    if (_selectedCategory != 'All') {
      filtered = filtered.where((faq) => faq['category'] == _selectedCategory).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((faq) => 
        faq['question'].toLowerCase().contains(searchTerm) ||
        faq['answer'].toLowerCase().contains(searchTerm)
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Center'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.help_outline), text: 'FAQ'),
            Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Contact'),
            Tab(icon: Icon(Icons.phone), text: 'Call'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFAQTab(),
          _buildContactTab(),
          _buildCallTab(),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    return Column(
      children: [
        // Search and Filter
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search FAQ...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Orders', 'Shipping', 'Account', 'Payment', 'Returns']
                      .map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                      ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),

        // FAQ List
        Expanded(
          child: Builder(
            builder: (context) {
              final filteredFAQs = _getFilteredFAQs();
              
              if (filteredFAQs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No FAQs found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search or category filter',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredFAQs.length,
                itemBuilder: (context, index) {
                  return _buildFAQItem(filteredFAQs[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          faq['question'],
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              faq['category'],
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq['answer'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Options
          _buildContactOption(
            icon: Icons.email,
            title: 'Email Support',
            subtitle: 'Get help via email within 24 hours',
            action: 'Send Email',
            onTap: () => _showEmailDialog(),
          ),
          const SizedBox(height: 12),
          _buildContactOption(
            icon: Icons.chat_bubble,
            title: 'Live Chat',
            subtitle: 'Chat with our support team now',
            action: 'Start Chat',
            onTap: () => _startLiveChat(),
          ),
          const SizedBox(height: 12),
          _buildContactOption(
            icon: Icons.bug_report,
            title: 'Report a Bug',
            subtitle: 'Help us improve by reporting issues',
            action: 'Report',
            onTap: () => _showBugReportDialog(),
          ),
          
          const SizedBox(height: 32),
          
          // Quick Contact Form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Message',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Your message',
                      hintText: 'Describe your issue or question...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmittingTicket ? null : _submitQuickMessage,
                      child: _isSubmittingTicket
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Send Message'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Contact Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactInfo(Icons.email, 'Email', 'support@erp-system.com'),
                  _buildContactInfo(Icons.phone, 'Phone', '+1 (555) 123-4567'),
                  _buildContactInfo(Icons.schedule, 'Hours', 'Mon-Fri: 9AM-6PM EST'),
                  _buildContactInfo(Icons.location_on, 'Address', '123 Business St, Suite 100\nNew York, NY 10001'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String action,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          onPressed: onTap,
          child: Text(action),
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.phone,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Call Support',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Speak directly with our support team for immediate assistance',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+1 (555) 123-4567',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.green[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Available: Monday - Friday, 9AM - 6PM EST',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _makePhoneCall,
                      icon: const Icon(Icons.phone),
                      label: const Text('Call Now'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Additional Call Options
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Before You Call',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCallTip('Have your order number ready if calling about an order'),
                  _buildCallTip('Check our FAQ section for quick answers'),
                  _buildCallTip('Consider using live chat for faster response'),
                  _buildCallTip('Have your account email address available'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Support'),
        content: const Text(
          'Our support team typically responds to emails within 24 hours. '
          'For faster assistance, consider using live chat or calling us directly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Open email client or web form
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening email client...'),
                ),
              );
            },
            child: const Text('Open Email'),
          ),
        ],
      ),
    );
  }

  void _startLiveChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Live chat feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showBugReportDialog() {
    final bugController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Help us improve by describing the issue you encountered:'),
            const SizedBox(height: 16),
            TextField(
              controller: bugController,
              decoration: const InputDecoration(
                labelText: 'Bug description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (bugController.text.trim().isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bug report submitted. Thank you!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitQuickMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmittingTicket = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isSubmittingTicket = false);
      _messageController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent successfully! We\'ll get back to you soon.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _makePhoneCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening phone app...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
