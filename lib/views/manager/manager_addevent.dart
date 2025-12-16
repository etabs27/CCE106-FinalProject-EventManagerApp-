import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_manager_application_finalproject/theme.dart';
import 'package:event_manager_application_finalproject/views/manager/manager_homepage.dart';
import 'package:event_manager_application_finalproject/models/event.dart';
import 'package:event_manager_application_finalproject/event_service.dart';

class ManagerAddEventPage extends StatefulWidget {
  const ManagerAddEventPage({super.key});

  @override
  State<ManagerAddEventPage> createState() => _ManagerAddEventPageState();
}

class _ManagerAddEventPageState extends State<ManagerAddEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _fullAddressController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _selectedCategory;
  
  // For mobile platforms
  File? _bannerImage;
  
  // For web platforms and Cloudinary
  String? _imageUrl; // For Cloudinary URL after upload
  Uint8List? _webImageBytes; // For web platform image bytes

  final List<String> _categories = [
    'Music',
    'Comedy',
    'Sports',
    'Art',
    'Theater',
    'Food & Drink',
    'Technology',
    'Business',
    'Education',
    'Health & Wellness'
  ];

  int _currentStep = 0;
  final List<GlobalKey<FormState>> _stepFormKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _fullAddressController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onBackground,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? TimeOfDay.now() : const TimeOfDay(hour: 19, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _pickBannerImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (image != null) {
      if (kIsWeb) {
        // For web platform
        final bytes = await image.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _bannerImage = null;
        });
      } else {
        // For mobile platforms
        setState(() {
          _bannerImage = File(image.path);
          _webImageBytes = null;
        });
      }
      // Here you would upload to Cloudinary and get the URL
      // For now, we'll store the file locally
      // _uploadToCloudinary(_bannerImage!);
    }
  }

  // Check if we have an image (platform-agnostic)
  bool get _hasImage {
    if (kIsWeb) {
      return _webImageBytes != null;
    } else {
      return _bannerImage != null;
    }
  }

  // Get image widget (platform-agnostic)
  Widget get _imageWidget {
    if (kIsWeb) {
      if (_webImageBytes != null) {
        return Image.memory(
          _webImageBytes!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.broken_image,
                size: 48,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
              ),
            );
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      if (_bannerImage != null) {
        return Image.file(
          _bannerImage!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.broken_image,
                size: 48,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
              ),
            );
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      return _eventNameController.text.isNotEmpty && 
             _selectedCategory != null && 
             _descriptionController.text.length >= 20 &&
             _hasImage;
    } else if (_currentStep == 1) {
      return _selectedDate != null && 
             _startTime != null && 
             _endTime != null &&
             _venueController.text.isNotEmpty &&
             _fullAddressController.text.isNotEmpty &&
             _capacityController.text.isNotEmpty &&
             int.tryParse(_capacityController.text) != null;
    }
    return true;
  }

  void _goToNextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        if (_currentStep < 2) {
          _currentStep++;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _goToPreviousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  void _submitEvent() async {
    if (_validateCurrentStep()) {
      try {
        // Get current user
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('User not authenticated'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }

        // TODO: Upload image to Cloudinary and get URL
        String? imageUrl;
        if (_hasImage) {
          // For now, we'll skip image upload and set imageUrl to null
          // imageUrl = await _uploadToCloudinary();
        }

        // Create Event object
        final event = Event(
          id: '', // Will be set by Firestore
          title: _eventNameController.text,
          description: _descriptionController.text,
          category: _selectedCategory!,
          date: _selectedDate!,
          startTime: _startTime!,
          endTime: _endTime!,
          venue: _venueController.text,
          fullAddress: _fullAddressController.text,
          capacity: int.parse(_capacityController.text),
          price: _priceController.text.isNotEmpty ? double.parse(_priceController.text) : null,
          managerEmail: user.email!,
          imageUrl: imageUrl,
          submittedAt: DateTime.now(),
        );

        // Save to Firestore
        await EventService.submitEvent(event);

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => _buildReviewDialog(),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit event: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildStepIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepCircle(0, 'Basic Info'),
          _buildStepConnector(),
          _buildStepCircle(1, 'Details'),
          _buildStepConnector(),
          _buildStepCircle(2, 'Review'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int stepIndex, String label) {
    final bool isActive = stepIndex == _currentStep;
    final bool isCompleted = stepIndex < _currentStep;
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive || isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check,
                    size: 18,
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      color: isActive
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector() {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildDetailsStep();
      case 2:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicInfoStep() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Form(
      key: _stepFormKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Banner
          GestureDetector(
            onTap: _pickBannerImage,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: _hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _imageWidget,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Upload event banner',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onBackground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'JPG, PNG up to 5MB',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Event Title
          Text(
            'Event Title *',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _eventNameController,
            decoration: InputDecoration(
              hintText: 'Enter event title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surface,
            ),
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),

          // Category
          Text(
            'Category *',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surface,
            ),
            items: _categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
            hint: const Text('Select category'),
            icon: Icon(Icons.arrow_drop_down, color: colorScheme.onBackground.withOpacity(0.6)),
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            'Description *',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Describe your event...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surface,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Form(
      key: _stepFormKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Date
          Text(
            'Event Date *',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null
                          ? _formatDate(_selectedDate!)
                          : 'dd/mm/yyyy',
                      style: TextStyle(
                        color: _selectedDate != null
                            ? colorScheme.onBackground
                            : colorScheme.onBackground.withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Start and End Time
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Time *',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectTime(context, true),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _startTime != null
                                    ? _startTime!.format(context)
                                    : '--:--',
                                style: TextStyle(
                                  color: _startTime != null
                                      ? colorScheme.onBackground
                                      : colorScheme.onBackground.withOpacity(0.5),
                                  fontSize: 16,
                                ),
                              ),
                              Icon(
                                Icons.access_time,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Time *',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectTime(context, false),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _endTime != null
                                    ? _endTime!.format(context)
                                    : '--:--',
                                style: TextStyle(
                                  color: _endTime != null
                                      ? colorScheme.onBackground
                                      : colorScheme.onBackground.withOpacity(0.5),
                                  fontSize: 16,
                                ),
                              ),
                              Icon(
                                Icons.access_time,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Location
          Text(
            'Location *',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _venueController,
            decoration: InputDecoration(
              hintText: 'Event venue',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surface,
            ),
          ),
          const SizedBox(height: 12),

          // Full Address
          TextFormField(
            controller: _fullAddressController,
            decoration: InputDecoration(
              hintText: 'Street, City, Province',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surface,
            ),
          ),
          const SizedBox(height: 20),

          // Capacity and Price
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Capacity *',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Maximum attendees',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ticket Price (₱)',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: '0',
                        prefixText: '₱ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner Preview
        Text(
          'Event Banner Preview',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: _hasImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _imageWidget,
                )
              : Center(
                  child: Icon(
                    Icons.image,
                    size: 48,
                    color: colorScheme.onBackground.withOpacity(0.3),
                  ),
                ),
        ),
        const SizedBox(height: 24),

        // Event Information
        Text(
          'Event Information',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildReviewItem('Title', _eventNameController.text),
              _buildReviewItem('Category', _selectedCategory ?? 'Not selected'),
              _buildReviewItem('Date', _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'Not set'),
              _buildReviewItem('Time', _startTime != null && _endTime != null
                  ? '${_startTime!.format(context)} - ${_endTime!.format(context)}'
                  : 'Not set'),
              _buildReviewItem('Location', _venueController.text),
              _buildReviewItem('Capacity', _capacityController.text),
              _buildReviewItem('Price', _priceController.text.isNotEmpty
                  ? '₱${_priceController.text}'
                  : 'Free'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Your event will be submitted for admin approval. You'll be notified once it's approved.",
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Event Submitted!',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your event has been submitted for admin approval. You will be notified once it\'s approved.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ManagerDashboard()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Return to Dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onBackground,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Create Event',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepIndicator(),
            const SizedBox(height: 16),
            _buildStepContent(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.1))),
        ),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _goToPreviousStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.onBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_back, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _currentStep < 2 ? _goToNextStep : _submitEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentStep < 2 ? 'Continue' : 'Submit Event',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (_currentStep < 2) const SizedBox(width: 8),
                      if (_currentStep < 2)
                        const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}