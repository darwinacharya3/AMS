import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MembershipDetailsSection extends StatefulWidget {
  final Map<String, dynamic> formData;

  const MembershipDetailsSection({
    Key? key,
    required this.formData,
  }) : super(key: key);

  @override
  State<MembershipDetailsSection> createState() => _MembershipDetailsSectionState();
}

class _MembershipDetailsSectionState extends State<MembershipDetailsSection> {
  final List<Map<String, dynamic>> _membershipTypes = [
    {'id': 1, 'name': 'Regular Membership', 'amount': 100},
    {'id': 2, 'name': 'Premium Membership', 'amount': 200},
    {'id': 3, 'name': 'VIP Membership', 'amount': 500},
  ];

  Map<String, dynamic>? _selectedMembershipType;
  final TextEditingController _paidAmountController = TextEditingController();
  File? _paymentSlipFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.formData.containsKey('membershipTypeId')) {
      int? id = widget.formData['membershipTypeId'];
      if (id != null) {
        _selectedMembershipType = _membershipTypes.firstWhere(
          (type) => type['id'] == id,
          orElse: () => <String, dynamic>{},
        );
        if (_selectedMembershipType!.isNotEmpty) {
          _paidAmountController.text = _selectedMembershipType!['amount'].toString();
        }
      }
    }
  }

  @override
  void dispose() {
    _paidAmountController.dispose();
    super.dispose();
  }

  Future<void> _getPaymentSlip() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _paymentSlipFile = File(image.path);
        widget.formData['paymentSlipPath'] = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Membership Details',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF205EB5),
          ),
        ),
        const SizedBox(height: 12),

        // Membership Type Dropdown
        InputDecorator(
          decoration: InputDecoration(
            labelText: 'Membership Type',
            prefixIcon: const Icon(Icons.card_membership),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          isEmpty: _selectedMembershipType == null,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Map<String, dynamic>>(
              value: _selectedMembershipType,
              isDense: true,
              isExpanded: true,
              hint: const Text('Select Type'),
              items: _membershipTypes.map((Map<String, dynamic> type) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: type,
                  child: Text('${type['name']} - \$${type['amount']}'),
                );
              }).toList(),
              onChanged: (Map<String, dynamic>? newValue) {
                setState(() {
                  _selectedMembershipType = newValue;
                  if (newValue != null) {
                    _paidAmountController.text = newValue['amount'].toString();
                    widget.formData['membershipTypeId'] = newValue['id'];
                    widget.formData['membershipTypeName'] = newValue['name'];
                  }
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Paid Amount
        TextFormField(
          controller: _paidAmountController,
          decoration: InputDecoration(
            labelText: 'Paid Amount',
            prefixIcon: const Icon(Icons.attach_money),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          keyboardType: TextInputType.number,
          onSaved: (value) => widget.formData['paidAmount'] = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter paid amount';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Payment Slip Upload
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Slip',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF205EB5),
                )),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextButton(
                        onPressed: _getPaymentSlip,
                        child: const Text('Choose File'),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          _paymentSlipFile != null
                              ? _paymentSlipFile!.path.split('/').last
                              : 'No file chosen',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_paymentSlipFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'File selected successfully',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}