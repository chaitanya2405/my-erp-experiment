import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audit_log.dart';
import '../services/pos_audit_service.dart';
import '../services/role_based_access_service.dart';
import '../widgets/export_widget.dart';

class PosAuditLogScreen extends StatefulWidget {
  const PosAuditLogScreen({Key? key}) : super(key: key);

  @override
  State<PosAuditLogScreen> createState() => _PosAuditLogScreenState();
}

class _PosAuditLogScreenState extends State<PosAuditLogScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  
  List<AuditLog> _auditLogs = [];
  List<AuditLog> _filteredLogs = [];
  bool _isLoading = true;
  String _selectedEventType = 'All';
  DateTimeRange? _selectedDateRange;
  String _selectedUserId = 'All';
  
  final List<String> _eventTypes = [
    'All',
    'TRANSACTION_CREATED',
    'TRANSACTION_UPDATED',
    'TRANSACTION_DELETED',
    'REFUND_PROCESSED',
    'DISCOUNT_APPLIED',
    'USER_LOGIN',
    'USER_LOGOUT',
    'PAYMENT_PROCESSED',
    'INVENTORY_UPDATED',
    'SETTINGS_CHANGED',
    'DATA_EXPORTED',
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadAuditLogs();
    _searchController.addListener(_filterLogs);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _checkPermissions() {
    final rbac = RoleBasedAccessService.instance;
    if (!rbac.hasPermission(PosPermission.viewAuditLogs)) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to view audit logs'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadAuditLogs() async {
    setState(() => _isLoading = true);
    
    try {
      final logs = await PosAuditService.getAllLogs();
      setState(() {
        _auditLogs = logs;
        _filteredLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading audit logs: $e')),
      );
    }
  }

  void _filterLogs() {
    setState(() {
      _filteredLogs = _auditLogs.where((log) {
        // Text search
        final searchText = _searchController.text.toLowerCase();
        final matchesSearch = searchText.isEmpty ||
            log.eventType.toLowerCase().contains(searchText) ||
            log.description.toLowerCase().contains(searchText) ||
            log.userId.toLowerCase().contains(searchText) ||
            log.entityId.toLowerCase().contains(searchText);

        // Event type filter
        final matchesEventType = _selectedEventType == 'All' ||
            log.eventType == _selectedEventType;

        // User filter
        final matchesUser = _selectedUserId == 'All' ||
            log.userId == _selectedUserId;

        // Date range filter
        final matchesDateRange = _selectedDateRange == null ||
            (log.timestamp.isAfter(_selectedDateRange!.start) &&
             log.timestamp.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))));

        return matchesSearch && matchesEventType && matchesUser && matchesDateRange;
      }).toList();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _filterLogs();
    }
  }

  Future<void> _exportLogs() async {
    try {
      final csvData = _generateCSVData();
      await ExportWidget.exportToCSV(
        context: context,
        data: csvData,
        filename: 'audit_logs_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  String _generateCSVData() {
    final buffer = StringBuffer();
    buffer.writeln('Timestamp,Event Type,User ID,Entity ID,Description,IP Address,Additional Data');
    
    for (final log in _filteredLogs) {
      buffer.writeln([
        log.timestamp.toIso8601String(),
        log.eventType,
        log.userId,
        log.entityId,
        '"${log.description.replaceAll('"', '""')}"',
        log.ipAddress ?? '',
        '"${log.additionalData.toString().replaceAll('"', '""')}"',
      ].join(','));
    }
    
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportLogs,
            tooltip: 'Export Logs',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAuditLogs,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildLogsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search logs',
                    hintText: 'Event type, user, description...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedEventType,
                  decoration: const InputDecoration(
                    labelText: 'Event Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _eventTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.replaceAll('_', ' ')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEventType = value!;
                    });
                    _filterLogs();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _selectedDateRange == null
                        ? 'Select Date Range'
                        : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (_selectedDateRange != null)
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedDateRange = null;
                    });
                    _filterLogs();
                  },
                  child: const Text('Clear Date'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    if (_filteredLogs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No audit logs found'),
            Text('Try adjusting your filters'),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _filteredLogs.length,
      itemBuilder: (context, index) {
        final log = _filteredLogs[index];
        return _buildLogTile(log);
      },
    );
  }

  Widget _buildLogTile(AuditLog log) {
    final eventIcon = _getEventIcon(log.eventType);
    final eventColor = _getEventColor(log.eventType);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: eventColor.withOpacity(0.2),
          child: Icon(eventIcon, color: eventColor),
        ),
        title: Text(
          log.eventType.replaceAll('_', ' '),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  log.userId,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(log.timestamp),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Event ID', log.id),
                _buildDetailRow('User ID', log.userId),
                _buildDetailRow('Entity ID', log.entityId),
                _buildDetailRow('IP Address', log.ipAddress ?? 'N/A'),
                _buildDetailRow('Timestamp', log.timestamp.toString()),
                if (log.additionalData.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Additional Data:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      log.additionalData.toString(),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType) {
      case 'TRANSACTION_CREATED':
      case 'TRANSACTION_UPDATED':
        return Icons.receipt;
      case 'TRANSACTION_DELETED':
        return Icons.delete;
      case 'REFUND_PROCESSED':
        return Icons.money_off;
      case 'DISCOUNT_APPLIED':
        return Icons.local_offer;
      case 'USER_LOGIN':
        return Icons.login;
      case 'USER_LOGOUT':
        return Icons.logout;
      case 'PAYMENT_PROCESSED':
        return Icons.payment;
      case 'INVENTORY_UPDATED':
        return Icons.inventory;
      case 'SETTINGS_CHANGED':
        return Icons.settings;
      case 'DATA_EXPORTED':
        return Icons.file_download;
      default:
        return Icons.info;
    }
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'TRANSACTION_CREATED':
        return Colors.green;
      case 'TRANSACTION_UPDATED':
        return Colors.blue;
      case 'TRANSACTION_DELETED':
        return Colors.red;
      case 'REFUND_PROCESSED':
        return Colors.orange;
      case 'DISCOUNT_APPLIED':
        return Colors.purple;
      case 'USER_LOGIN':
        return Colors.teal;
      case 'USER_LOGOUT':
        return Colors.grey;
      case 'PAYMENT_PROCESSED':
        return Colors.green;
      case 'INVENTORY_UPDATED':
        return Colors.brown;
      case 'SETTINGS_CHANGED':
        return Colors.indigo;
      case 'DATA_EXPORTED':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
