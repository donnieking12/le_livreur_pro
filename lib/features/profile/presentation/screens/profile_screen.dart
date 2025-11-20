import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:le_livreur_pro/core/models/user.dart';
import 'package:le_livreur_pro/core/models/address.dart';
import 'package:le_livreur_pro/core/services/auth_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';
import 'package:le_livreur_pro/shared/widgets/address_picker_widget.dart';
import 'package:le_livreur_pro/features/profile/presentation/screens/address_management_screen.dart';
import 'package:le_livreur_pro/features/profile/presentation/screens/payment_methods_screen.dart';
import 'package:le_livreur_pro/features/profile/presentation/screens/security_settings_screen.dart';
import 'profile_management_methods.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  File? _profileImage;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  bool _locationSharingEnabled = true;
  String _preferredLanguage = 'fr';

  final List<Address> _savedAddresses = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final userAsync = ref.read(currentUserProfileProvider);
    final user = userAsync.value;

    if (user != null) {
      _fullNameController.text = user.fullName ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phone ?? '';

      // Load demo addresses
      _savedAddresses.addAll([
        Address(
          id: '1',
          label: 'Domicile',
          fullAddress: 'Cocody, Riviera 2, Villa 123, Abidjan',
          latitude: 5.3800,
          longitude: -3.9700,
          type: AddressType.home,
          isDefault: true,
          userId: user.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Address(
          id: '2',
          label: 'Bureau',
          fullAddress: 'Plateau, Tour BCEAO, 15ème étage, Abidjan',
          latitude: 5.3200,
          longitude: -4.0100,
          type: AddressType.work,
          isDefault: false,
          userId: user.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildProfileOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final userAsync = ref.watch(currentUserProfileProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: userAsync.when(
          data: (user) => Column(
            children: [
              GestureDetector(
                onTap: () => _pickProfileImage(),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryGreen,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!) as ImageProvider
                          : (user?.profileImageUrl != null
                              ? NetworkImage(user!.profileImageUrl!)
                                  as ImageProvider
                              : null),
                      child:
                          _profileImage == null && user?.profileImageUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.fullName ?? 'Utilisateur',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getUserTypeLabel(user?.userType),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.neutralGrey,
                ),
              ),
              if (user?.email != null) ...[
                const SizedBox(height: 4),
                Text(
                  user!.email!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.neutralGrey,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProfileStat('Commandes'.tr(), '12'),
                  _buildProfileStat('Livraisons'.tr(), '8'),
                  _buildProfileStat('Évaluation'.tr(), '4.8'),
                ],
              ),
            ],
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text('Erreur: $error'),
          ),
        ),
      ),
    );
  }

  String _getUserTypeLabel(UserType? userType) {
    switch (userType) {
      case UserType.customer:
        return 'Client'.tr();
      case UserType.courier:
        return 'Coursier'.tr();
      case UserType.partner:
        return 'Partenaire'.tr();
      case UserType.admin:
        return 'Administrateur'.tr();
      default:
        return 'Utilisateur'.tr();
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (!mounted) return;

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });

        // TODO: Upload image to Supabase storage
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo de profil mise à jour'.tr()),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection de l\'image'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.neutralGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      children: [
        _buildProfileOption(
          icon: Icons.edit,
          title: 'Modifier le profil'.tr(),
          subtitle: 'Mettre à jour vos informations'.tr(),
          onTap: () => _showEditProfileDialog(),
        ),
        _buildProfileOption(
          icon: Icons.location_on,
          title: 'Adresses'.tr(),
          subtitle: 'Gérer vos adresses de livraison'.tr(),
          onTap: () => _showAddressManagement(),
        ),
        _buildProfileOption(
          icon: Icons.payment,
          title: 'Méthodes de paiement'.tr(),
          subtitle: 'Cartes et comptes bancaires'.tr(),
          onTap: () => _showPaymentMethods(),
        ),
        _buildProfileOption(
          icon: Icons.notifications,
          title: 'Notifications'.tr(),
          subtitle: 'Préférences de notification'.tr(),
          onTap: () =>
              ProfileManagementMethods.showNotificationSettings(context),
        ),
        _buildProfileOption(
          icon: Icons.security,
          title: 'Sécurité'.tr(),
          subtitle: 'Mot de passe et authentification'.tr(),
          onTap: () => _showSecuritySettings(),
        ),
        _buildProfileOption(
          icon: Icons.language,
          title: 'Langue'.tr(),
          subtitle: 'Changer la langue de l\'application'.tr(),
          onTap: () => ProfileManagementMethods.showLanguageSettings(context),
        ),
        _buildProfileOption(
          icon: Icons.help,
          title: 'Aide et support'.tr(),
          subtitle: 'FAQ et contact'.tr(),
          onTap: () => ProfileManagementMethods.showHelpAndSupport(context),
        ),
        _buildProfileOption(
          icon: Icons.info,
          title: 'À propos'.tr(),
          subtitle: 'Version et informations'.tr(),
          onTap: () => ProfileManagementMethods.showAboutDialog(context),
        ),
        const SizedBox(height: 16),
        ProfileManagementMethods.buildLogoutButton(context, ref),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.primaryGreen,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // Profile Management Methods
  void _showEditProfileDialog() {
    final userAsync = ref.read(currentUserProfileProvider);
    final user = userAsync.value;

    if (user != null) {
      _fullNameController.text = user.fullName ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phone ?? '';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier le profil'.tr()),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Nom complet'.tr(),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom complet'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email'.tr(),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email'.tr();
                    }
                    if (!value.contains('@')) {
                      return 'Veuillez entrer un email valide'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Téléphone'.tr(),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre numéro de téléphone'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emergencyContactController,
                  decoration: InputDecoration(
                    labelText: 'Contact d\'urgence'.tr(),
                    prefixIcon: const Icon(Icons.emergency),
                    hintText: 'Optionnel'.tr(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'.tr()),
          ),
          ElevatedButton(
            onPressed: () => _updateProfile(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('Sauvegarder'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement profile update in backend
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil mis à jour avec succès'.tr()),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour du profil'.tr()),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddressManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddressManagementScreen(),
      ),
    );
  }

  void _showPaymentMethods() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentMethodsScreen(),
      ),
    );
  }

  void _showSecuritySettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SecuritySettingsScreen(),
      ),
    );
  }
}
