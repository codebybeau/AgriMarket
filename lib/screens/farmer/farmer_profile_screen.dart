import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../consumer/home_screen.dart';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _farmOriginController = TextEditingController();
  final _bioController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  String? _avatarUrl;
  String? _bannerUrl;

  File? _avatarFile;
  File? _bannerFile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _farmNameController.dispose();
    _farmOriginController.dispose();
    _bioController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  User? get _user => _supabase.auth.currentUser;

  Future<void> _loadProfile() async {
    final user = _user;

    if (user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final response = await _supabase
          .from('farmer_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      final metadata = user.userMetadata ?? {};

      if (!mounted) return;

      setState(() {
        _fullNameController.text =
            response?['full_name'] ??
            metadata['full_name'] ??
            metadata['name'] ??
            '';

        _farmNameController.text =
            response?['farm_name'] ?? metadata['farm_name'] ?? '';

        _farmOriginController.text = response?['farm_origin'] ?? '';

        _bioController.text = response?['bio'] ?? '';

        _contactController.text =
            response?['contact_number'] ??
            metadata['mobile'] ??
            metadata['phone'] ??
            '';

        _emailController.text = user.email ?? '';

        _avatarUrl = response?['avatar_url'];
        _bannerUrl = response?['banner_url'];

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showMessage('Unable to load profile: $e', isError: true);
    }
  }

  Future<void> _pickImage({required bool isBanner}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (pickedFile == null || !mounted) return;

      setState(() {
        if (isBanner) {
          _bannerFile = File(pickedFile.path);
        } else {
          _avatarFile = File(pickedFile.path);
        }
      });
    } catch (e) {
      _showMessage('Unable to select image: $e', isError: true);
    }
  }

  Future<String?> _uploadImage(File? file, String folder) async {
    if (file == null) {
      return folder == 'avatar' ? _avatarUrl : _bannerUrl;
    }

    final user = _user;
    if (user == null) return null;

    final extension = file.path.split('.').last.toLowerCase();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';

    final path = '${user.id}/$folder/$fileName';

    await _supabase.storage.from('farmer-images').upload(path, file);

    return _supabase.storage.from('farmer-images').getPublicUrl(path);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _user;

    if (user == null) {
      _showMessage('Please log in again.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final newAvatarUrl = await _uploadImage(_avatarFile, 'avatar');

      final newBannerUrl = await _uploadImage(_bannerFile, 'banner');

      await _supabase.from('farmer_profiles').upsert({
        'user_id': user.id,
        'full_name': _fullNameController.text.trim(),
        'farm_name': _farmNameController.text.trim(),
        'farm_origin': _farmOriginController.text.trim(),
        'bio': _bioController.text.trim(),
        'contact_number': _contactController.text.trim(),
        'avatar_url': newAvatarUrl,
        'banner_url': newBannerUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      if (!mounted) return;

      setState(() {
        _avatarUrl = newAvatarUrl;
        _bannerUrl = newBannerUrl;
        _avatarFile = null;
        _bannerFile = null;
        _isEditing = false;
        _isSaving = false;
      });

      _showMessage('Farmer profile updated successfully!');
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);
      _showMessage('Failed to save profile: $e', isError: true);
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _avatarFile = null;
      _bannerFile = null;
      _isLoading = true;
    });

    _loadProfile();
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    try {
      await context.read<AuthProvider>().logout();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _showMessage('Logout failed: $e', isError: true);
    }
  }

  void _goToConsumerDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly || !_isEditing,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        validator: (value) {
          if (label == 'Full Name' || label == 'Farm Name') {
            if (value == null || value.trim().isEmpty) {
              return '$label is required';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildBanner() {
    ImageProvider? image;

    if (_bannerFile != null) {
      image = FileImage(_bannerFile!);
    } else if (_bannerUrl != null && _bannerUrl!.isNotEmpty) {
      image = NetworkImage(_bannerUrl!);
    }

    return Stack(
      children: [
        Container(
          height: 190,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            image: image != null
                ? DecorationImage(image: image, fit: BoxFit.cover)
                : null,
          ),
          child: image == null
              ? const Center(
                  child: Icon(Icons.landscape, size: 65, color: Colors.green),
                )
              : null,
        ),
        if (_isEditing)
          Positioned(
            right: 14,
            bottom: 14,
            child: ElevatedButton.icon(
              onPressed: () => _pickImage(isBanner: true),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Change Banner'),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar() {
    ImageProvider? image;

    if (_avatarFile != null) {
      image = FileImage(_avatarFile!);
    } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      image = NetworkImage(_avatarUrl!);
    }

    return Stack(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: Colors.green.shade100,
          backgroundImage: image,
          child: image == null
              ? const Icon(Icons.person, size: 60, color: Colors.green)
              : null,
        ),
        if (_isEditing)
          Positioned(
            right: 0,
            bottom: 0,
            child: InkWell(
              onTap: () => _pickImage(isBanner: false),
              child: const CircleAvatar(
                radius: 19,
                backgroundColor: Colors.green,
                child: Icon(Icons.camera_alt, size: 19, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Farmer Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: _isEditing
                  ? _cancelEditing
                  : () => setState(() => _isEditing = true),
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildBanner(),

                  Transform.translate(
                    offset: const Offset(0, -45),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildAvatar(),

                          const SizedBox(height: 12),

                          Text(
                            _farmNameController.text.isEmpty
                                ? 'Your Farm'
                                : _farmNameController.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Farmer Account',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 25),

                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 15),

                                _buildTextField(
                                  label: 'Full Name',
                                  controller: _fullNameController,
                                ),

                                _buildTextField(
                                  label: 'Email Address',
                                  controller: _emailController,
                                  readOnly: true,
                                  keyboardType: TextInputType.emailAddress,
                                ),

                                _buildTextField(
                                  label: 'Contact Number',
                                  controller: _contactController,
                                  keyboardType: TextInputType.phone,
                                ),

                                const SizedBox(height: 12),

                                const Text(
                                  'Farm Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 15),

                                _buildTextField(
                                  label: 'Farm Name',
                                  controller: _farmNameController,
                                ),

                                _buildTextField(
                                  label: 'Farm Location',
                                  controller: _farmOriginController,
                                  hint: 'Enter your farm location',
                                ),

                                _buildTextField(
                                  label: 'Farm Description',
                                  controller: _bioController,
                                  maxLines: 4,
                                  hint: 'Tell customers about your farm...',
                                ),

                                const SizedBox(height: 10),

                                if (_isEditing)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton.icon(
                                      onPressed: _isSaving
                                          ? null
                                          : _saveProfile,
                                      icon: _isSaving
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.save),
                                      label: Text(
                                        _isSaving
                                            ? 'Saving...'
                                            : 'Save Changes',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 12),

                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: OutlinedButton.icon(
                                    onPressed: _goToConsumerDashboard,
                                    icon: const Icon(Icons.storefront),
                                    label: const Text('Back to Consumer Home'),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: OutlinedButton.icon(
                                    onPressed: _confirmLogout,
                                    icon: const Icon(
                                      Icons.logout,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      'Logout',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
