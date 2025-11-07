import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/shared/theme/app_theme.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;
  bool _loginNotifications = true;
  bool _deviceManagement = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres de sécurité'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 20),
          _buildPasswordSection(),
          const SizedBox(height: 20),
          _buildAuthenticationSection(),
          const SizedBox(height: 20),
          _buildNotificationSection(),
          const SizedBox(height: 20),
          _buildDeviceSection(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: AppTheme.primaryGreen,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sécurité de votre compte'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Protégez votre compte avec des mesures de sécurité avancées.'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Mot de passe'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSecurityOption(
            icon: Icons.lock,
            title: 'Changer le mot de passe'.tr(),
            subtitle: 'Modifiez votre mot de passe actuel'.tr(),
            onTap: () => _showChangePasswordDialog(),
            showArrow: true,
          ),
          _buildSecurityOption(
            icon: Icons.history,
            title: 'Dernière modification'.tr(),
            subtitle: 'Il y a 30 jours',
            onTap: null,
            showArrow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticationSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Authentification'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint, color: AppTheme.primaryGreen),
            title: Text('Authentification biométrique'.tr()),
            subtitle: Text('Utilisez votre empreinte ou Face ID'.tr()),
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() {
                _biometricEnabled = value;
              });
              _showBiometricSetup();
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.security, color: AppTheme.primaryGreen),
            title: Text('Authentification à deux facteurs'.tr()),
            subtitle: Text('Protection supplémentaire par SMS'.tr()),
            value: _twoFactorEnabled,
            onChanged: (value) {
              setState(() {
                _twoFactorEnabled = value;
              });
              _showTwoFactorSetup();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Notifications de sécurité'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: AppTheme.primaryGreen),
            title: Text('Notifications de connexion'.tr()),
            subtitle: Text('Alertes lors de nouvelles connexions'.tr()),
            value: _loginNotifications,
            onChanged: (value) {
              setState(() {
                _loginNotifications = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.devices, color: AppTheme.primaryGreen),
            title: Text('Gestion des appareils'.tr()),
            subtitle: Text('Surveiller les appareils connectés'.tr()),
            value: _deviceManagement,
            onChanged: (value) {
              setState(() {
                _deviceManagement = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Appareils et sessions'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSecurityOption(
            icon: Icons.devices,
            title: 'Appareils connectés'.tr(),
            subtitle: 'Gérer les appareils autorisés'.tr(),
            onTap: () => _showConnectedDevices(),
            showArrow: true,
          ),
          _buildSecurityOption(
            icon: Icons.logout,
            title: 'Déconnecter tous les appareils'.tr(),
            subtitle: 'Fermer toutes les sessions actives'.tr(),
            onTap: () => _showLogoutAllDialog(),
            showArrow: true,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required bool showArrow,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.errorRed : AppTheme.primaryGreen,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.errorRed : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: showArrow ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Changer le mot de passe'.tr()),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe actuel'.tr(),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe actuel'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe'.tr(),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmer le nouveau mot de passe'.tr(),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'Les mots de passe ne correspondent pas'.tr();
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Mot de passe modifié avec succès'.tr()),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: Text('Changer'.tr()),
          ),
        ],
      ),
    );
  }

  void _showBiometricSetup() {
    if (_biometricEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentification biométrique activée'.tr()),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentification biométrique désactivée'.tr()),
          backgroundColor: AppTheme.neutralGrey,
        ),
      );
    }
  }

  void _showTwoFactorSetup() {
    if (_twoFactorEnabled) {
      _showTwoFactorEnableDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentification à deux facteurs désactivée'.tr()),
          backgroundColor: AppTheme.neutralGrey,
        ),
      );
    }
  }

  void _showTwoFactorEnableDialog() {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Activer l\'authentification à deux facteurs'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Entrez votre numéro de téléphone pour recevoir les codes de vérification.'.tr()),
            const SizedBox(height: 16),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone'.tr(),
                hintText: '+225 XX XX XX XX XX',
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _twoFactorEnabled = false;
              });
              Navigator.pop(context);
            },
            child: Text('Annuler'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Authentification à deux facteurs activée'.tr()),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: Text('Activer'.tr()),
          ),
        ],
      ),
    );
  }

  void _showConnectedDevices() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Appareils connectés'.tr(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDeviceCard(
                      'Navigateur Chrome',
                      'Windows • Dernière activité: maintenant',
                      Icons.computer,
                      true,
                    ),
                    _buildDeviceCard(
                      'Application mobile',
                      'Android • Dernière activité: il y a 2 heures',
                      Icons.phone_android,
                      false,
                    ),
                    _buildDeviceCard(
                      'Navigateur Safari',
                      'macOS • Dernière activité: il y a 1 jour',
                      Icons.laptop_mac,
                      false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(String name, String details, IconData icon, bool isCurrent) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(name),
        subtitle: Text(details),
        trailing: isCurrent
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Actuel'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : TextButton(
                onPressed: () => _revokeDevice(name),
                child: Text('Révoquer'.tr()),
              ),
      ),
    );
  }

  void _revokeDevice(String deviceName) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accès révoqué pour $deviceName'.tr()),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _showLogoutAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnecter tous les appareils'.tr()),
        content: Text('Cette action fermera toutes les sessions actives sur tous vos appareils. Vous devrez vous reconnecter partout.'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Toutes les sessions ont été fermées'.tr()),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text('Déconnecter tout'.tr()),
          ),
        ],
      ),
    );
  }
}