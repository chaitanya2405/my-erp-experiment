import 'package:flutter/material.dart';
import 'advanced_search_filter_widget.dart';
import 'supplier_segmentation_widget.dart';
import 'compliance_tracking_widget.dart';
import 'supplier_scorecard_widget.dart';
import 'relationship_timeline_widget.dart';
import 'communication_log_widget.dart';

class SupplierAdvancedFeaturesScreen extends StatelessWidget {
  const SupplierAdvancedFeaturesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Advanced Supplier Features'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Search & Filter'),
              Tab(text: 'Segmentation'),
              Tab(text: 'Compliance'),
              Tab(text: 'Scorecard'),
              Tab(text: 'Timeline'),
              Tab(text: 'Comm Log'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            AdvancedSearchFilterWidget(),
            SupplierSegmentationWidget(),
            ComplianceTrackingWidget(),
            SupplierScorecardWidget(),
            RelationshipTimelineWidget(),
            CommunicationLogWidget(),
          ],
        ),
      ),
    );
  }
}