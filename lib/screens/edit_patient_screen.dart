import 'package:flutter/material.dart';
import '../models/patient.dart';

class EditPatientScreen extends StatefulWidget {
  final Patient patient;

  const EditPatientScreen({
    super.key,
    required this.patient,
  });

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _medicalHistoryController;
  late String? _selectedGender;
  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.patient.fullName);
    _dateOfBirthController = TextEditingController(
        text:
            "${widget.patient.dateOfBirth.day}/${widget.patient.dateOfBirth.month}/${widget.patient.dateOfBirth.year}");
    _phoneNumberController =
        TextEditingController(text: widget.patient.phoneNumber);
    _addressController = TextEditingController(text: widget.patient.address);
    _medicalHistoryController =
        TextEditingController(text: widget.patient.medicalHistory ?? '');
    _selectedGender = widget.patient.gender;
    _selectedDate = widget.patient.dateOfBirth;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _updatePatient() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedGender != null) {
      final updatedPatient = widget.patient.copyWith(
        fullName: _fullNameController.text,
        dateOfBirth: _selectedDate!,
        gender: _selectedGender!,
        phoneNumber: _phoneNumberController.text,
        address: _addressController.text,
        medicalHistory: _medicalHistoryController.text.isEmpty
            ? null
            : _medicalHistoryController.text,
      );

      Navigator.pop(context, updatedPatient);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Patient',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateOfBirthController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select date of birth';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                items: ['Male', 'Female']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicalHistoryController,
                decoration: const InputDecoration(
                  labelText: 'Medical History (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updatePatient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BA07E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
