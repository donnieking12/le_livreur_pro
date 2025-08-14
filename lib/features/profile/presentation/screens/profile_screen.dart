import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryGreen,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'John Doe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Client',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.neutralGrey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProfileStat('Commandes', '12'),
                _buildProfileStat('Livraisons', '8'),
                _buildProfileStat('Évaluation', '4.8'),
              ],
            ),
          ],
        ),
      ),
    );
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
          onTap: () {},
        ),
        _buildProfileOption(
          icon: Icons.location_on,
          title: 'Adresses'.tr(),
          subtitle: 'Gérer vos adresses de livraison'.tr(),
          onTap: () {},
        ),
        _buildProfileOption(
          icon: Icons.payment,
          title: 'Méthodes de paiement'.tr(),
          subtitle: 'Cartes et comptes bancaires'.tr(),
          onTap: () {},
        ),
        _buildProfileOption(
          icon: Icons.notifications,
          title: 'Notifications'.tr(),
          subtitle: 'Préférences de notification'.tr(),
          onTap: () {},
        ),
        _buildProfileOption(
          icon: Icons.security,
          title: 'Sécurité'.tr(),
          subtitle: 'Mot de passe et authentification'.tr(),
          onTap: () {},
        ),
        _buildProfileOption(
          icon: Icons.help,
          title: 'Aide et support'.tr(),
          subtitle: 'FAQ et contact'.tr(),
          onTap: () {},
        ),
        _buildProfileOption(
          icon: Icons.info,
          title: 'À propos'.tr(),
          subtitle: 'Version et informations'.tr(),
          onTap: () {},
        ),
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
}
