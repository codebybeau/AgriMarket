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
  static const Color primaryColor = Colors.green;
  static const Color backgroundColor = Color(0xFFF7F9F7);

  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = true;
  bool _isUploadingAvatar = false;
  bool _isUploadingBanner = false;

  String? _dbFullName;
  String? _dbContactNumber;
  String? _dbFarmName;
  String? _dbFarmOrigin;
  String? _dbBio;
  String? _avatarUrl;
  String? _bannerUrl;

  @override
  void initState() {
    super.initState();
    _loadFarmerProfile();
  }

  Future<void> _loadFarmerProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final data = await _supabase
          .from('farmer_profiles')
          .select(
            'full_name, farm_name, farm_origin, bio, contact_number, avatar_url, banner_url',
          )
          .eq('user_id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _dbFullName = data?['full_name']?.toString();
        _dbFarmName = data?['farm_name']?.toString();
        _dbFarmOrigin = data?['farm_origin']?.toString();
        _dbBio = data?['bio']?.toString();
        _dbContactNumber = data?['contact_number']?.toString();
        _avatarUrl = data?['avatar_url']?.toString();
        _bannerUrl = data?['banner_url']?.toString();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading farmer profile: $e');

      if (!mounted) return;

      setState(() => _isLoading = false);
      _showMessage('Unable to load farmer profile.', isError: true);
    }
  }

  String _metadataValue(
    Map<String, dynamic>? metadata,
    String firstKey, [
    String? secondKey,
  ]) {
    final first = metadata?[firstKey]?.toString();

    if (first != null && first.trim().isNotEmpty) {
      return first;
    }

    if (secondKey != null) {
      final second = metadata?[secondKey]?.toString();

      if (second != null && second.trim().isNotEmpty) {
        return second;
      }
    }

    return '';
  }

  Future<void> _pickAndUploadImage({required bool isBanner}) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      _showMessage('Please log in again.', isError: true);
      return;
    }

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: isBanner ? 1400 : 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null || !mounted) return;

      setState(() {
        if (isBanner) {
          _isUploadingBanner = true;
        } else {
          _isUploadingAvatar = true;
        }
      });

      final bytes = await pickedFile.readAsBytes();

      final extension = pickedFile.name.contains('.')
          ? pickedFile.name.split('.').last.toLowerCase()
          : 'jpg';

      final mimeType = (extension == 'jpg' || extension == 'jpeg')
          ? 'image/jpeg'
          : extension == 'webp'
          ? 'image/webp'
          : 'image/png';

      final imageType = isBanner ? 'banner' : 'avatar';
      final column = isBanner ? 'banner_url' : 'avatar_url';

      final filePath =
          '${user.id}/${imageType}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      await _supabase.storage
          .from('farmer-images')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: true),
          );

      final publicUrl = _supabase.storage
          .from('farmer-images')
          .getPublicUrl(filePath);

      await _supabase.from('farmer_profiles').upsert({
        'user_id': user.id,
        column: publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      if (!mounted) return;

      setState(() {
        if (isBanner) {
          _bannerUrl = publicUrl;
          _isUploadingBanner = false;
        } else {
          _avatarUrl = publicUrl;
          _isUploadingAvatar = false;
        }
      });

      _showMessage(
        isBanner ? 'Farm banner updated!' : 'Profile photo updated!',
      );
    } catch (e) {
      debugPrint('Image upload error: $e');

      if (!mounted) return;

      setState(() {
        _isUploadingBanner = false;
        _isUploadingAvatar = false;
      });

      _showMessage('Failed to upload image: $e', isError: true);
    }
  }

  Future<void> _showEditProfileSheet({
    required String currentName,
    required String currentMobile,
    required String currentFarmName,
    required String currentFarmOrigin,
    required String currentBio,
  }) async {
    final nameController = TextEditingController(text: currentName);
    final mobileController = TextEditingController(text: currentMobile);
    final farmController = TextEditingController(text: currentFarmName);
    final originController = TextEditingController(text: currentFarmOrigin);
    final bioController = TextEditingController(text: currentBio);

    bool isSaving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Farmer Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: farmController,
                      decoration: const InputDecoration(
                        labelText: 'Farm Name',
                        prefixIcon: Icon(Icons.store_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: originController,
                      decoration: const InputDecoration(
                        labelText: 'Farm Origin / Location',
                        hintText: 'e.g., Kabacan, North Cotabato',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Farm Bio / Description',
                        hintText: 'Tell buyers about your farm and produce...',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              final user = _supabase.auth.currentUser;

                              if (user == null) {
                                return;
                              }

                              setSheetState(() => isSaving = true);

                              try {
                                final newName = nameController.text.trim();
                                final newMobile = mobileController.text.trim();
                                final newFarm = farmController.text.trim();
                                final newOrigin = originController.text.trim();
                                final newBio = bioController.text.trim();

                                await _supabase.from('farmer_profiles').upsert({
                                  'user_id': user.id,
                                  'full_name': newName,
                                  'contact_number': newMobile,
                                  'farm_name': newFarm,
                                  'farm_origin': newOrigin,
                                  'bio': newBio,
                                  'updated_at': DateTime.now()
                                      .toIso8601String(),
                                }, onConflict: 'user_id');

                                if (!mounted) return;

                                setState(() {
                                  _dbFullName = newName;
                                  _dbContactNumber = newMobile;
                                  _dbFarmName = newFarm;
                                  _dbFarmOrigin = newOrigin;
                                  _dbBio = newBio;
                                });

                                if (sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                }

                                _showMessage('All profile changes saved!');
                              } catch (e) {
                                debugPrint('Profile save error: $e');

                                setSheetState(() => isSaving = false);

                                if (!mounted) return;

                                _showMessage(
                                  'Error saving profile: $e',
                                  isError: true,
                                );
                              }
                            },
                      child: Text(
                        isSaving ? 'Saving...' : 'Save Changes',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    mobileController.dispose();
    farmController.dispose();
    originController.dispose();
    bioController.dispose();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;

    try {
      final auth = context.read<AuthProvider>();

      await auth.logout();

      if (!context.mounted) return;

      if (auth.isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              auth.errorMessage ?? 'Logout failed. Please try again.',
            ),
          ),
        );
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  void _goToConsumerDashboard(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Widget _buildProfileInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          final currentUser = auth.currentUser;
          final metadata = currentUser?.userMetadata;

          final displayName = (_dbFullName?.isNotEmpty == true)
              ? _dbFullName!
              : (auth.fullName.isNotEmpty
                    ? auth.fullName
                    : _metadataValue(metadata, 'full_name', 'name'));

          final email = currentUser?.email ?? 'Not provided';

          final mobile = (_dbContactNumber?.isNotEmpty == true)
              ? _dbContactNumber!
              : _metadataValue(metadata, 'mobile', 'phone');

          final farmName = (_dbFarmName?.isNotEmpty == true)
              ? _dbFarmName!
              : _metadataValue(metadata, 'farm_name', 'farmName');

          final farmOrigin = _dbFarmOrigin ?? '';
          final bio = _dbBio ?? '';

          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  SizedBox(
                    height: 215,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        GestureDetector(
                          onTap: _isUploadingBanner
                              ? null
                              : () => _pickAndUploadImage(isBanner: true),
                          child: Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              image:
                                  (_bannerUrl != null && _bannerUrl!.isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(_bannerUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                if (_bannerUrl == null || _bannerUrl!.isEmpty)
                                  Center(
                                    child: Icon(
                                      Icons.landscape_outlined,
                                      size: 56,
                                      color: Colors.white.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.55,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (_isUploadingBanner)
                                          const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        else
                                          const Icon(
                                            Icons.photo_camera_outlined,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _isUploadingBanner
                                              ? 'Uploading...'
                                              : 'Edit Cover',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _isUploadingAvatar
                                      ? null
                                      : () => _pickAndUploadImage(
                                          isBanner: false,
                                        ),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.green.shade100,
                                      backgroundImage:
                                          (_avatarUrl != null &&
                                              _avatarUrl!.isNotEmpty)
                                          ? NetworkImage(_avatarUrl!)
                                          : null,
                                      child: _isUploadingAvatar
                                          ? const CircularProgressIndicator(
                                              color: primaryColor,
                                            )
                                          : (_avatarUrl == null ||
                                                _avatarUrl!.isEmpty)
                                          ? const Icon(
                                              Icons.person,
                                              size: 52,
                                              color: primaryColor,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          displayName.isEmpty ? 'Farmer' : displayName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Farmer Account',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Farm & Account Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showEditProfileSheet(
                                currentName: displayName,
                                currentMobile: mobile,
                                currentFarmName: farmName,
                                currentFarmOrigin: farmOrigin,
                                currentBio: bio,
                              ),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Edit Profile'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 44),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildProfileInfoTile(
                          icon: Icons.person_outline,
                          title: 'Full Name',
                          value: displayName,
                        ),
                        _buildProfileInfoTile(
                          icon: Icons.store_outlined,
                          title: 'Farm Name',
                          value: farmName,
                        ),
                        _buildProfileInfoTile(
                          icon: Icons.location_on_outlined,
                          title: 'Farm Origin / Location',
                          value: farmOrigin,
                        ),
                        _buildProfileInfoTile(
                          icon: Icons.phone_outlined,
                          title: 'Contact Number',
                          value: mobile,
                        ),
                        _buildProfileInfoTile(
                          icon: Icons.info_outline,
                          title: 'Farm Bio',
                          value: bio,
                        ),
                        _buildProfileInfoTile(
                          icon: Icons.email_outlined,
                          title: 'Email Address',
                          value: email,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _goToConsumerDashboard(context),
                            icon: const Icon(Icons.shopping_bag_outlined),
                            label: const Text('Back to Consumer Home'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 54),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: auth.isLoading
                              ? null
                              : () => _confirmLogout(context),
                          icon: const Icon(Icons.logout),
                          label: Text(
                            auth.isLoading ? 'Logging out...' : 'Log Out',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
