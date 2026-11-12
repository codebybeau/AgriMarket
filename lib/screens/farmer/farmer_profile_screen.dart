import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../consumer/home_screen.dart';

typedef JsonMap = Map<String, dynamic>;

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  static const Color primaryColor = Colors.green;
  static const Color backgroundColor = Color(0xFFF7F9F7);

  bool _isUploadingAvatar = false;
  bool _isUploadingBanner = false;

  String? _avatarUrl;
  String? _bannerUrl;
  String? _dbFullName;
  String? _dbContactNumber;
  String? _dbFarmName;
  String? _dbFarmOrigin;
  String? _dbBio;

  @override
  void initState() {
    super.initState();
    _loadFarmerProfile();
  }

  Future<void> _loadFarmerProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await Supabase.instance.client
          .from('farmer_profiles')
          .select(
            'full_name, farm_name, farm_origin, bio, contact_number, avatar_url, banner_url',
          )
          .eq('user_id', userId)
          .maybeSingle();

      if (!mounted) return;
      if (data != null) {
        setState(() {
          _dbFullName = data['full_name']?.toString();
          _dbFarmName = data['farm_name']?.toString();
          _dbFarmOrigin = data['farm_origin']?.toString();
          _dbBio = data['bio']?.toString();
          _dbContactNumber = data['contact_number']?.toString();
          _avatarUrl = data['avatar_url']?.toString();
          _bannerUrl = data['banner_url']?.toString();
        });
      }
    } catch (e) {
      debugPrint('Error loading farmer profile: $e');
    }
  }

  Future<void> _pickAndUploadImage({required bool isBanner}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: isBanner ? 1400 : 800,
      maxHeight: isBanner ? 800 : 800,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() {
      if (isBanner) {
        _isUploadingBanner = true;
      } else {
        _isUploadingAvatar = true;
      }
    });

    try {
      final bytes = await pickedFile.readAsBytes();
      final rawExt = pickedFile.name.split('.').last.toLowerCase();
      final mimeSubType = (rawExt == 'jpg' || rawExt == 'jpeg')
          ? 'jpeg'
          : (rawExt == 'webp' ? 'webp' : 'png');
      final prefix = isBanner ? 'banner' : 'avatar';
      final column = isBanner ? 'banner_url' : 'avatar_url';
      final filePath =
          '${user.id}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.$rawExt';

      await Supabase.instance.client.storage.from('farmer-images').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$mimeSubType',
              upsert: true,
            ),
          );

      final String publicUrl = Supabase.instance.client.storage
          .from('farmer-images')
          .getPublicUrl(filePath);

      final auth = context.read<AuthProvider>();
      final existing = await Supabase.instance.client
          .from('farmer_profiles')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (existing != null) {
        await Supabase.instance.client.from('farmer_profiles').update({
          column: publicUrl,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', user.id);
      } else {
        await Supabase.instance.client.from('farmer_profiles').insert({
          'user_id': user.id,
          'full_name': _dbFullName ?? auth.fullName,
          column: publicUrl,
        });
      }

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBanner ? 'Farm banner updated!' : 'Profile photo updated!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploadingBanner = false;
        _isUploadingAvatar = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Future<void> _showEditProfileSheet({
    required String currentName,
    required String currentMobile,
    required String currentFarmName,
    required String currentFarmOrigin,
    required String currentBio,
  }) async {
    final nameController = TextEditingController(
      text: currentName == 'Not provided' ? '' : currentName,
    );
    final mobileController = TextEditingController(
      text: currentMobile == 'Not provided' ? '' : currentMobile,
    );
    final farmController = TextEditingController(
      text: currentFarmName == 'Not provided' ? '' : currentFarmName,
    );
    final originController = TextEditingController(
      text: currentFarmOrigin == 'Not provided' ? '' : currentFarmOrigin,
    );
    final bioController = TextEditingController(
      text: currentBio == 'No bio added yet.' ? '' : currentBio,
    );

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
                              final userId = Supabase
                                  .instance.client.auth.currentUser?.id;
                              if (userId == null) return;

                              setSheetState(() => isSaving = true);

                              try {
                                final newName = nameController.text.trim();
                                final newMobile = mobileController.text.trim();
                                final newFarm = farmController.text.trim();
                                final newOrigin = originController.text.trim();
                                final newBio = bioController.text.trim();

                                final existing = await Supabase.instance.client
                                    .from('farmer_profiles')
                                    .select('id')
                                    .eq('user_id', userId)
                                    .maybeSingle();

                                final JsonMap payload = {
                                  'full_name': newName,
                                  'contact_number': newMobile,
                                  'farm_name': newFarm,
                                  'farm_origin': newOrigin,
                                  'bio': newBio,
                                  'updated_at':
                                      DateTime.now().toIso8601String(),
                                };

                                if (existing != null) {
                                  await Supabase.instance.client
                                      .from('farmer_profiles')
                                      .update(payload)
                                      .eq('user_id', userId);
                                } else {
                                  payload['user_id'] = userId;
                                  await Supabase.instance.client
                                      .from('farmer_profiles')
                                      .insert(payload);
                                }

                                if (newName.isNotEmpty) {
                                  await Supabase.instance.client
                                      .from('profiles')
                                      .update({'full_name': newName})
                                      .eq('id', userId);
                                }

                                if (!mounted) return;
                                setState(() {
                                  _dbFullName =
                                      newName.isNotEmpty ? newName : null;
                                  _dbContactNumber =
                                      newMobile.isNotEmpty ? newMobile : null;
                                  _dbFarmName =
                                      newFarm.isNotEmpty ? newFarm : null;
                                  _dbFarmOrigin =
                                      newOrigin.isNotEmpty ? newOrigin : null;
                                  _dbBio = newBio.isNotEmpty ? newBio : null;
                                });

                                if (sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('All profile changes saved!'),
                                  ),
                                );
                              } catch (e) {
                                setSheetState(() => isSaving = false);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error saving profile: $e'),
                                  ),
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
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;
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

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _goToConsumerDashboard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
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

          final displayName = (_dbFullName != null && _dbFullName!.isNotEmpty)
              ? _dbFullName!
              : auth.fullName;

          final email = currentUser?.email ?? 'Not provided';

          final mobile =
              (_dbContactNumber != null && _dbContactNumber!.isNotEmpty)
                  ? _dbContactNumber!
                  : (metadata?['mobile']?.toString() ??
                      metadata?['phone']?.toString() ??
                      'Not provided');

          final farmName = (_dbFarmName != null && _dbFarmName!.isNotEmpty)
              ? _dbFarmName!
              : (metadata?['farm_name']?.toString() ??
                  metadata?['farmName']?.toString() ??
                  'Not provided');

          final farmOrigin =
              (_dbFarmOrigin != null && _dbFarmOrigin!.isNotEmpty)
                  ? _dbFarmOrigin!
                  : 'Not provided';

          final bio = (_dbBio != null && _dbBio!.isNotEmpty)
              ? _dbBio!
              : 'No bio added yet.';

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              image: (_bannerUrl != null &&
                                      _bannerUrl!.isNotEmpty)
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
                                      color:
                                          Colors.white.withValues(alpha: 0.35),
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
                                      color:
                                          Colors.black.withValues(alpha: 0.55),
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
                                      : () =>
                                          _pickAndUploadImage(isBanner: false),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.green.shade100,
                                      backgroundImage: (_avatarUrl != null &&
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
                          displayName,
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
                            const Text(
                              'Farm & Account Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
                                tapTargetSize: MaterialTapTargetSize.padded,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
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
                        _ProfileInfoTile(
                          icon: Icons.person_outline,
                          title: 'Full Name',
                          value: displayName,
                        ),
                        _ProfileInfoTile(
                          icon: Icons.store_outlined,
                          title: 'Farm Name',
                          value: farmName,
                        ),
                        _ProfileInfoTile(
                          icon: Icons.location_on_outlined,
                          title: 'Farm Origin / Location',
                          value: farmOrigin,
                        ),
                        _ProfileInfoTile(
                          icon: Icons.phone_outlined,
                          title: 'Contact Number',
                          value: mobile,
                        ),
                        _ProfileInfoTile(
                          icon: Icons.info_outline,
                          title: 'Farm Bio',
                          value: bio,
                        ),
                        _ProfileInfoTile(
                          icon: Icons.email_outlined,
                          title: 'Email Address',
                          value: email,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _goToConsumerDashboard(context);
                            },
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

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.green.shade700),
        title: Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}