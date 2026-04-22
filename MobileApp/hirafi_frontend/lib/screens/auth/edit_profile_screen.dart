import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/animated_scale_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _professionController;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _firstNameController = TextEditingController(text: user?.firstName);
    _lastNameController = TextEditingController(text: user?.lastName);
    _cityController = TextEditingController(text: user?.city);
    _countryController = TextEditingController(text: user?.country);
    _phoneController = TextEditingController(text: user?.phone);
    // Note: Bio and Profession might need separate fetching if not in basic user model
    // But for now we'll assume they might be passed or null
    _bioController = TextEditingController(); 
    _professionController = TextEditingController();

    if (user?.role == 'WORKER') {
      _loadWorkerData();
    }
  }

  Future<void> _loadWorkerData() async {
    // In a real scenario, we might want to fetch the worker profile specifically
    // to get the bio and profession if they aren't in the User object
    try {
      final auth = context.read<AuthProvider>();
      // The updateProfile endpoint in backend actually returns the full updated object
      // But for initial load, we might need a fetch. 
      // For now, let's assume we can at least initialize with current values if we had them.
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isWorker = auth.user?.role == 'WORKER';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Modifier le Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: auth.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                            backgroundImage: _imageFile != null 
                                ? FileImage(_imageFile!) as ImageProvider 
                                : (auth.user?.profileImageUrl != null ? NetworkImage(auth.user!.profileImageUrl!) : null),
                            child: _imageFile == null && auth.user?.profileImageUrl == null
                                ? const Icon(Icons.camera_alt_outlined, size: 32, color: AppTheme.accentColor)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: AppTheme.accentColor, shape: BoxShape.circle),
                              child: const Icon(Icons.edit, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Informations Personnelles'),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _firstNameController,
                      label: 'Prénom',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _lastNameController,
                      label: 'Nom',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _phoneController,
                      label: 'Téléphone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Localisation'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _cityController,
                            label: 'Ville',
                            icon: Icons.location_on_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            controller: _countryController,
                            label: 'Pays',
                            icon: Icons.flag_outlined,
                          ),
                        ),
                      ],
                    ),
                    if (isWorker) ...[
                      const SizedBox(height: 32),
                      _buildSectionTitle('Profil Professionnel'),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _professionController,
                        label: 'Profession',
                        icon: Icons.work_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _bioController,
                        label: 'Ma Bio',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                      ),
                    ],
                    const SizedBox(height: 48),
                    AnimatedScaleButton(
                      onTap: _saveProfile,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Enregistrer les modifications',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textHint),
          prefixIcon: Icon(icon, color: AppTheme.textHint, size: 22),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.accentColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthProvider>();
    final data = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'phone': _phoneController.text,
      'city': _cityController.text,
      'country': _countryController.text,
    };
    
    if (auth.user?.role == 'WORKER') {
      data['profession'] = _professionController.text;
      data['bio'] = _bioController.text;
    }

    final success = await auth.updateProfile(data);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil mis à jour avec succès !'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }
}
