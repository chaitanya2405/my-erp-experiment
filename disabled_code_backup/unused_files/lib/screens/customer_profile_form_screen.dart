import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_profile.dart';
import '../services/customer_profile_service.dart';

class CustomerProfileFormScreen extends StatefulWidget {
  final CustomerProfile? profile;
  const CustomerProfileFormScreen({Key? key, this.profile}) : super(key: key);

  @override
  State<CustomerProfileFormScreen> createState() => _CustomerProfileFormScreenState();
}

class _CustomerProfileFormScreenState extends State<CustomerProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController fullNameController;
  late TextEditingController mobileNumberController;
  late TextEditingController emailController;
  String gender = 'Male';
  DateTime? dob;
  late TextEditingController addressLine1Controller;
  late TextEditingController addressLine2Controller;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController postalCodeController;
  late TextEditingController preferredStoreIdController;
  late TextEditingController loyaltyPointsController;
  late TextEditingController totalOrdersController;
  Timestamp? lastOrderDate;
  late TextEditingController averageOrderValueController;
  String customerSegment = 'New';
  String preferredContactMode = 'SMS';
  late TextEditingController referralCodeController;
  late TextEditingController referredByController;
  late TextEditingController feedbackNotesController;
  bool marketingOptIn = false;
  late TextEditingController firstOrderDateController;
  late TextEditingController lastActivityDateController;
  late TextEditingController churnRiskScoreController;
  late TextEditingController campaignResponsesController;
  late TextEditingController feedbackSentimentController;
  String preferredChannel = 'App';

  final List<String> _allCampaigns = [
    'Diwali2024', 'SummerSale', 'ReferralBonus', 'FestivePush', 'LoyaltyUpgrade'
  ];
  List<String> _selectedCampaigns = [];

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    fullNameController = TextEditingController(text: p?.fullName ?? '');
    mobileNumberController = TextEditingController(text: p?.mobileNumber ?? '');
    emailController = TextEditingController(text: p?.email ?? '');
    gender = p?.gender ?? 'Male';
    dob = p?.dob;
    addressLine1Controller = TextEditingController(text: p?.addressLine1 ?? '');
    addressLine2Controller = TextEditingController(text: p?.addressLine2 ?? '');
    cityController = TextEditingController(text: p?.city ?? '');
    stateController = TextEditingController(text: p?.state ?? '');
    postalCodeController = TextEditingController(text: p?.postalCode ?? '');
    preferredStoreIdController = TextEditingController(text: p?.preferredStoreId ?? '');
    loyaltyPointsController = TextEditingController(text: p?.loyaltyPoints.toString() ?? '0');
    totalOrdersController = TextEditingController(text: p?.totalOrders.toString() ?? '0');
    lastOrderDate = p?.lastOrderDate;
    averageOrderValueController = TextEditingController(text: p?.averageOrderValue.toString() ?? '0.0');
    customerSegment = p?.customerSegment ?? 'New';
    preferredContactMode = p?.preferredContactMode ?? 'SMS';
    referralCodeController = TextEditingController(text: p?.referralCode ?? '');
    referredByController = TextEditingController(text: p?.referredBy ?? '');
    feedbackNotesController = TextEditingController(text: p?.feedbackNotes ?? '');
    marketingOptIn = p?.marketingOptIn ?? false;
    firstOrderDateController = TextEditingController(text: p?.firstOrderDate?.toIso8601String() ?? '');
    lastActivityDateController = TextEditingController(text: p?.lastActivityDate?.toIso8601String() ?? '');
    churnRiskScoreController = TextEditingController(text: p?.churnRiskScore?.toString() ?? '');
    campaignResponsesController = TextEditingController(text: p?.campaignResponses?.join(', ') ?? '');
    feedbackSentimentController = TextEditingController(text: p?.feedbackSentiment ?? '');
    preferredChannel = p?.preferredChannel ?? 'App';
    _selectedCampaigns = p?.campaignResponses ?? [];
  }

  @override
  void dispose() {
    fullNameController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    preferredStoreIdController.dispose();
    loyaltyPointsController.dispose();
    totalOrdersController.dispose();
    averageOrderValueController.dispose();
    referralCodeController.dispose();
    referredByController.dispose();
    feedbackNotesController.dispose();
    firstOrderDateController.dispose();
    lastActivityDateController.dispose();
    churnRiskScoreController.dispose();
    campaignResponsesController.dispose();
    feedbackSentimentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.profile == null ? 'Add Customer' : 'Edit Customer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: mobileNumberController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other', 'Prefer not to say']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => gender = v ?? 'Male'),
              ),
              ListTile(
                title: Text(dob == null ? 'Select DOB' : 'DOB: ${dob!.toLocal().toString().split(' ').first}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dob ?? DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => dob = picked);
                },
              ),
              TextFormField(controller: addressLine1Controller, decoration: const InputDecoration(labelText: 'Address Line 1')),
              TextFormField(controller: addressLine2Controller, decoration: const InputDecoration(labelText: 'Address Line 2')),
              TextFormField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
              TextFormField(controller: stateController, decoration: const InputDecoration(labelText: 'State')),
              TextFormField(controller: postalCodeController, decoration: const InputDecoration(labelText: 'Postal Code')),
              TextFormField(controller: preferredStoreIdController, decoration: const InputDecoration(labelText: 'Preferred Store ID')),
              TextFormField(controller: loyaltyPointsController, decoration: const InputDecoration(labelText: 'Loyalty Points'), keyboardType: TextInputType.number),
              TextFormField(controller: totalOrdersController, decoration: const InputDecoration(labelText: 'Total Orders'), keyboardType: TextInputType.number),
              TextFormField(controller: averageOrderValueController, decoration: const InputDecoration(labelText: 'Average Order Value'), keyboardType: TextInputType.number),
              DropdownButtonFormField<String>(
                value: customerSegment,
                decoration: const InputDecoration(labelText: 'Customer Segment'),
                items: ['Platinum', 'Gold', 'Silver', 'New', 'Inactive']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => customerSegment = v ?? 'New'),
              ),
              DropdownButtonFormField<String>(
                value: preferredContactMode,
                decoration: const InputDecoration(labelText: 'Preferred Contact Mode'),
                items: ['SMS', 'Email', 'WhatsApp', 'App Push']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => preferredContactMode = v ?? 'SMS'),
              ),
              TextFormField(controller: referralCodeController, decoration: const InputDecoration(labelText: 'Referral Code')),
              TextFormField(controller: referredByController, decoration: const InputDecoration(labelText: 'Referred By')),
              SwitchListTile(
                value: marketingOptIn,
                onChanged: (v) => setState(() => marketingOptIn = v),
                title: const Text('Marketing Opt-In'),
              ),
              TextFormField(controller: feedbackNotesController, decoration: const InputDecoration(labelText: 'Feedback Notes')),
              ListTile(
                title: Text(
                  firstOrderDateController.text.isEmpty
                    ? 'Select First Order Date'
                    : 'First Order: ${firstOrderDateController.text.split('T').first}'
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: firstOrderDateController.text.isNotEmpty
                      ? DateTime.parse(firstOrderDateController.text)
                      : DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => firstOrderDateController.text = picked.toIso8601String());
                  }
                },
              ),
              ListTile(
                title: Text(
                  lastActivityDateController.text.isEmpty
                    ? 'Select Last Activity Date'
                    : 'Last Activity: ${lastActivityDateController.text.split('T').first}'
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: lastActivityDateController.text.isNotEmpty
                      ? DateTime.parse(lastActivityDateController.text)
                      : DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => lastActivityDateController.text = picked.toIso8601String());
                  }
                },
              ),
              TextFormField(controller: churnRiskScoreController, decoration: const InputDecoration(labelText: 'Churn Risk Score')),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Campaign Responses', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: _selectedCampaigns.map((campaign) => Chip(
                      label: Text(campaign),
                      onDeleted: () {
                        setState(() => _selectedCampaigns.remove(campaign));
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    hint: const Text('Add Campaign'),
                    items: _allCampaigns
                        .where((c) => !_selectedCampaigns.contains(c))
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null && !_selectedCampaigns.contains(val)) {
                        setState(() => _selectedCampaigns.add(val));
                      }
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Add Custom Campaign (press enter)',
                    ),
                    onFieldSubmitted: (val) {
                      if (val.trim().isNotEmpty && !_selectedCampaigns.contains(val.trim())) {
                        setState(() => _selectedCampaigns.add(val.trim()));
                      }
                    },
                  ),
                ],
              ),
              TextFormField(controller: feedbackSentimentController, decoration: const InputDecoration(labelText: 'Feedback Sentiment')),
              DropdownButtonFormField<String>(
                value: preferredChannel,
                decoration: const InputDecoration(labelText: 'Preferred Channel'),
                items: ['App', 'Web', 'Offline'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => preferredChannel = v ?? 'App'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final profile = CustomerProfile(
                      customerId: widget.profile?.customerId ?? FirebaseFirestore.instance.collection('customers').doc().id,
                      fullName: fullNameController.text,
                      mobileNumber: mobileNumberController.text,
                      email: emailController.text,
                      gender: gender,
                      dob: dob,
                      addressLine1: addressLine1Controller.text,
                      addressLine2: addressLine2Controller.text,
                      city: cityController.text,
                      state: stateController.text,
                      postalCode: postalCodeController.text,
                      preferredStoreId: preferredStoreIdController.text,
                      loyaltyPoints: int.tryParse(loyaltyPointsController.text) ?? 0,
                      totalOrders: int.tryParse(totalOrdersController.text) ?? 0,
                      totalPurchases: (double.tryParse(averageOrderValueController.text) ?? 0.0) * (int.tryParse(totalOrdersController.text) ?? 0),
                      lastOrderDate: lastOrderDate,
                      averageOrderValue: double.tryParse(averageOrderValueController.text) ?? 0.0,
                      customerSegment: customerSegment,
                      preferredContactMode: preferredContactMode,
                      referralCode: referralCodeController.text,
                      referredBy: referredByController.text,
                      supportTickets: widget.profile?.supportTickets ?? [],
                      marketingOptIn: marketingOptIn,
                      feedbackNotes: feedbackNotesController.text,
                      createdAt: widget.profile?.createdAt ?? Timestamp.now(),
                      updatedAt: Timestamp.now(),
                      firstOrderDate: firstOrderDateController.text.isNotEmpty ? DateTime.parse(firstOrderDateController.text) : null,
                      lastActivityDate: lastActivityDateController.text.isNotEmpty ? DateTime.parse(lastActivityDateController.text) : null,
                      churnRiskScore: churnRiskScoreController.text.isNotEmpty ? double.tryParse(churnRiskScoreController.text) : null,
                      campaignResponses: _selectedCampaigns,
                      feedbackSentiment: feedbackSentimentController.text,
                      preferredChannel: preferredChannel,
                    );
                    await CustomerProfileService().addOrUpdateCustomer(profile);
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.profile == null ? 'Create Customer' : 'Update Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}