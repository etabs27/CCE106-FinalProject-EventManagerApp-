import 'package:flutter/material.dart';
import 'package:event_manager_application_finalproject/theme.dart';

class UserProfilePagePayment extends StatefulWidget {
  const UserProfilePagePayment({super.key});

  @override
  State<UserProfilePagePayment> createState() => _UserProfilePagePaymentState();
}

class _UserProfilePagePaymentState extends State<UserProfilePagePayment> {
  int _selectedCardIndex = 0;
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'type': 'Visa',
      'lastFour': '4242',
      'expiry': '12/25',
      'isDefault': true,
      'icon': Icons.credit_card_rounded,
    },
    {
      'type': 'Mastercard',
      'lastFour': '8888',
      'expiry': '08/24',
      'isDefault': false,
      'icon': Icons.credit_card_rounded,
    },
    {
      'type': 'PayPal',
      'lastFour': 'alex@example.com',
      'expiry': '',
      'isDefault': false,
      'icon': Icons.payment_rounded,
    },
    {
      'type': 'Apple Pay',
      'lastFour': '',
      'expiry': '',
      'isDefault': false,
      'icon': Icons.apple_rounded,
    },
  ];

  void _addNewPaymentMethod() {
    // Add new payment method logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add payment method feature coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setDefaultPayment(int index) {
    setState(() {
      for (var i = 0; i < _paymentMethods.length; i++) {
        _paymentMethods[i]['isDefault'] = i == index;
      }
      _selectedCardIndex = index;
    });
  }

  void _deletePaymentMethod(int index) {
    setState(() {
      _paymentMethods.removeAt(index);
      if (_selectedCardIndex >= _paymentMethods.length) {
        _selectedCardIndex = _paymentMethods.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Payment Methods',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Payment Methods List
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Payment Methods',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Manage your payment methods for faster checkout',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._paymentMethods.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> method = entry.value;
                    
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  method['icon'],
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              
                              // Card Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          method['type'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onBackground,
                                          ),
                                        ),
                                        if (method['isDefault']) ...[
                                          SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(
                                                color: colorScheme.primary.withOpacity(0.2),
                                              ),
                                            ),
                                            child: Text(
                                              'Default',
                                              style: TextStyle(
                                                color: colorScheme.primary,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    if (method['lastFour'].isNotEmpty)
                                      Text(
                                        method['type'] == 'PayPal' 
                                          ? method['lastFour']
                                          : '•••• ${method['lastFour']}',
                                        style: TextStyle(
                                          color: colorScheme.onBackground.withOpacity(0.65),
                                          fontSize: 14,
                                        ),
                                      ),
                                    if (method['expiry'].isNotEmpty)
                                      Text(
                                        'Expires ${method['expiry']}',
                                        style: TextStyle(
                                          color: colorScheme.onBackground.withOpacity(0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              
                              // Radio Button
                              Radio(
                                value: index,
                                groupValue: _selectedCardIndex,
                                onChanged: (value) => _setDefaultPayment(value as int),
                                activeColor: colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                        
                        // Divider (except for last item)
                        if (index < _paymentMethods.length - 1)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(
                              height: 24,
                              color: colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Add New Payment Method Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _addNewPaymentMethod,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.onBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Add New Payment Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Security Information
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your payment information is secured with 256-bit encryption',
                        style: TextStyle(
                          color: colorScheme.onBackground.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}