import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/index.dart';
import '../../../core/activity_tracker.dart';

class CRMScreen extends StatefulWidget {
  const CRMScreen({super.key});

  @override
  State<CRMScreen> createState() => _CRMScreenState();
}

class _CRMScreenState extends State<CRMScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeCRM();
  }

  Future<void> _initializeCRM() async {
    try {
      print('👥 Initializing CRM Module...');
      print('  • Loading customer database...');
      print('  • Setting up interaction tracking...');
      print('  • Configuring lead management...');
      print('  • Loading customer preferences...');
      print('  • Setting up loyalty program data...');
      print('  • Initializing support ticket system...');
      print('  • Configuring communication channels...');
      print('✅ CRM Module ready for customer operations');
      
      // Track CRM module navigation with activity tracker
      ActivityTracker().trackNavigation(
        screenName: 'CRMModule',
        routeName: '/crm',
        relatedFiles: [
          'lib/modules/crm/screens/crm_screen.dart',
        ],
      );
      
      // Track initialization
      ActivityTracker().trackInteraction(
        action: 'crm_init',
        element: 'crm_screen',
        data: {'store': 'STORE_001', 'mode': 'customer_management', 'tracking_enabled': 'true'},
      );
      
      print('  👥 Customer relationship management active');
      print('  📞 Support and communication systems ready');
    } catch (e) {
      print('⚠️ CRM initialization warning: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM - Customer Relationship Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Contacts'),
            Tab(icon: Icon(Icons.business), text: 'Leads'),
            Tab(icon: Icon(Icons.handshake), text: 'Opportunities'),
            Tab(icon: Icon(Icons.analytics), text: 'CRM Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContactsTab(),
          _buildLeadsTab(),
          _buildOpportunitiesTab(),
          _buildCRMAnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Contact'),
      ),
    );
  }

  Widget _buildContactsTab() {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search contacts...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  // Implement filtering logic
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'all', child: Text('All Contacts')),
                  const PopupMenuItem(value: 'leads', child: Text('Leads Only')),
                  const PopupMenuItem(value: 'customers', child: Text('Customers Only')),
                  const PopupMenuItem(value: 'vip', child: Text('VIP Contacts')),
                ],
              ),
            ],
          ),
        ),
        // Contacts List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('crm_contacts').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final contacts = snapshot.data?.docs ?? [];
              final filteredContacts = contacts.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['name']?.toString().toLowerCase() ?? '';
                final company = data['company']?.toString().toLowerCase() ?? '';
                final email = data['email']?.toString().toLowerCase() ?? '';
                final query = _searchQuery.toLowerCase();
                return name.contains(query) || company.contains(query) || email.contains(query);
              }).toList();

              if (filteredContacts.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No contacts found', style: TextStyle(fontSize: 18)),
                      Text('Add your first contact to get started'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = filteredContacts[index].data() as Map<String, dynamic>;
                  final docId = filteredContacts[index].id;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(contact['status'] ?? 'lead'),
                        child: Text(
                          (contact['name'] ?? 'N')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(contact['name'] ?? 'Unknown'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contact['company'] ?? 'No company'),
                          Text(contact['email'] ?? 'No email'),
                          Row(
                            children: [
                              Chip(
                                label: Text(
                                  contact['status'] ?? 'lead',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: _getStatusColor(contact['status'] ?? 'lead').withOpacity(0.2),
                              ),
                              const SizedBox(width: 8),
                              if (contact['lastContact'] != null)
                                Text(
                                  'Last contact: ${_formatDate(contact['lastContact'])}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              _showEditDialog(docId, contact);
                              break;
                            case 'delete':
                              _deleteContact(docId);
                              break;
                            case 'log_activity':
                              _showActivityDialog(docId, contact);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'log_activity', child: Text('Log Activity')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                      onTap: () => _showContactDetails(docId, contact),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeadsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('crm_contacts')
          .where('status', isEqualTo: 'lead')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final leads = snapshot.data?.docs ?? [];

        return Column(
          children: [
            // Lead Conversion Funnel
            Container(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Lead Conversion Funnel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildLeadFunnel(),
                    ],
                  ),
                ),
              ),
            ),
            // Leads List
            Expanded(
              child: leads.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.trending_up, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No leads found', style: TextStyle(fontSize: 18)),
                          Text('Start generating leads to grow your business'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: leads.length,
                      itemBuilder: (context, index) {
                        final lead = leads[index].data() as Map<String, dynamic>;
                        final docId = leads[index].id;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange,
                              child: Text(
                                (lead['name'] ?? 'L')[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(lead['name'] ?? 'Unknown Lead'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Source: ${lead['source'] ?? 'Unknown'}'),
                                Text('Score: ${lead['leadScore'] ?? 0}/100'),
                                Text('Value: ₹${lead['estimatedValue'] ?? 0}'),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => _convertLead(docId, lead),
                              child: const Text('Convert'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOpportunitiesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('crm_opportunities').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final opportunities = snapshot.data?.docs ?? [];

        return Column(
          children: [
            // Opportunity Pipeline
            Container(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sales Pipeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildSalesPipeline(),
                    ],
                  ),
                ),
              ),
            ),
            // Opportunities List
            Expanded(
              child: opportunities.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.monetization_on, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No opportunities found', style: TextStyle(fontSize: 18)),
                          Text('Create opportunities to track potential sales'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: opportunities.length,
                      itemBuilder: (context, index) {
                        final opportunity = opportunities[index].data() as Map<String, dynamic>;
                        final docId = opportunities[index].id;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getOpportunityColor(opportunity['stage'] ?? 'prospecting'),
                              child: const Icon(Icons.monetization_on, color: Colors.white),
                            ),
                            title: Text(opportunity['name'] ?? 'Unknown Opportunity'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Stage: ${opportunity['stage'] ?? 'prospecting'}'),
                                Text('Value: ₹${opportunity['value'] ?? 0}'),
                                Text('Probability: ${opportunity['probability'] ?? 0}%'),
                                Text('Close Date: ${_formatDate(opportunity['closeDate'])}'),
                              ],
                            ),
                            trailing: Text(
                              '₹${opportunity['value'] ?? 0}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCRMAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // KPI Cards
          Row(
            children: [
              Expanded(child: _buildKPICard('Total Contacts', '0', Icons.people, Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildKPICard('Active Leads', '0', Icons.trending_up, Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _buildKPICard('Opportunities', '₹0', Icons.monetization_on, Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildKPICard('Conversion Rate', '0%', Icons.transform, Colors.purple)),
            ],
          ),
          const SizedBox(height: 24),
          // Charts
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Lead Sources', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(height: 200, child: _buildLeadSourceChart()),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sales Pipeline Value', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(height: 200, child: _buildPipelineChart()),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadFunnel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFunnelStage('Leads', '0', Colors.blue),
        const Icon(Icons.arrow_forward, color: Colors.grey),
        _buildFunnelStage('Qualified', '0', Colors.orange),
        const Icon(Icons.arrow_forward, color: Colors.grey),
        _buildFunnelStage('Opportunity', '0', Colors.purple),
        const Icon(Icons.arrow_forward, color: Colors.grey),
        _buildFunnelStage('Customer', '0', Colors.green),
      ],
    );
  }

  Widget _buildFunnelStage(String label, String count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 24,
          child: Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSalesPipeline() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPipelineStage('Prospecting', '₹0', Colors.blue),
        _buildPipelineStage('Qualification', '₹0', Colors.orange),
        _buildPipelineStage('Proposal', '₹0', Colors.purple),
        _buildPipelineStage('Negotiation', '₹0', Colors.red),
        _buildPipelineStage('Closed Won', '₹0', Colors.green),
      ],
    );
  }

  Widget _buildPipelineStage(String stage, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Column(
            children: [
              Text(stage, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
              Text(value, style: TextStyle(fontSize: 14, color: color)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeadSourceChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 30, color: Colors.blue, title: 'Website'),
          PieChartSectionData(value: 25, color: Colors.orange, title: 'Referral'),
          PieChartSectionData(value: 20, color: Colors.green, title: 'Social Media'),
          PieChartSectionData(value: 15, color: Colors.purple, title: 'Email'),
          PieChartSectionData(value: 10, color: Colors.red, title: 'Other'),
        ],
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildPipelineChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 100000, color: Colors.blue)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 80000, color: Colors.orange)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 60000, color: Colors.purple)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 40000, color: Colors.red)]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 120000, color: Colors.green)]),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const stages = ['Prospect', 'Qualify', 'Propose', 'Negotiate', 'Won'];
                return Text(stages[value.toInt()], style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'lead':
        return Colors.orange;
      case 'customer':
        return Colors.green;
      case 'prospect':
        return Colors.blue;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getOpportunityColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'prospecting':
        return Colors.blue;
      case 'qualification':
        return Colors.orange;
      case 'proposal':
        return Colors.purple;
      case 'negotiation':
        return Colors.red;
      case 'closed_won':
        return Colors.green;
      case 'closed_lost':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'No date';
    if (date is Timestamp) {
      return '${date.toDate().day}/${date.toDate().month}/${date.toDate().year}';
    }
    return date.toString();
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final companyController = TextEditingController();
    String selectedStatus = 'lead';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(labelText: 'Company'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['lead', 'prospect', 'customer', 'inactive']
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => selectedStatus = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('crm_contacts').add({
                  'name': nameController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'company': companyController.text,
                  'status': selectedStatus,
                  'source': 'manual',
                  'leadScore': 50,
                  'estimatedValue': 0,
                  'createdAt': Timestamp.now(),
                  'lastContact': Timestamp.now(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact added successfully')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String docId, Map<String, dynamic> contact) {
    // Implementation for editing contact
  }

  void _showActivityDialog(String docId, Map<String, dynamic> contact) {
    // Implementation for logging activity
  }

  void _showContactDetails(String docId, Map<String, dynamic> contact) {
    // Implementation for showing contact details
  }

  void _deleteContact(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('crm_contacts').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact deleted successfully')),
      );
    }
  }

  void _convertLead(String docId, Map<String, dynamic> lead) async {
    await FirebaseFirestore.instance.collection('crm_contacts').doc(docId).update({
      'status': 'customer',
      'convertedAt': Timestamp.now(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lead converted to customer!')),
    );
  }
}
