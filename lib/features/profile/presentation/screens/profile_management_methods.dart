// Profile Management Methods Extension
// This file contains the implementation methods for profile management

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_livreur_pro/core/models/user.dart';
import 'package:le_livreur_pro/core/models/address.dart';
import 'package:le_livreur_pro/core/services/auth_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

// This will be used as a mixin or reference for profile management methods
class ProfileManagementMethods {
  
  static Widget buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () => _logout(context, ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.errorRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout),
            const SizedBox(width: 8),
            Text('Se déconnecter'.tr()),
          ],
        ),
      ),
    );
  }

  static Future<void> _logout(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Se déconnecter'.tr()),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await AuthService.signOut();
                
                if (context.mounted) {
                  // Navigate to login screen
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la déconnexion'.tr()),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text('Se déconnecter'.tr()),
          ),
        ],
      ),
    );
  }

  static void showLanguageSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choisir la langue'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Français'),
              value: 'fr',
              groupValue: context.locale.languageCode,
              onChanged: (value) {
                context.setLocale(const Locale('fr'));
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: context.locale.languageCode,
              onChanged: (value) {
                context.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'.tr()),
          ),
        ],
      ),
    );
  }

  static void showNotificationSettings(BuildContext context) {
    bool notificationsEnabled = true;
    bool locationSharingEnabled = true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Préférences de notification'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Notifications push'.tr()),
                subtitle: Text('Recevoir des notifications sur votre appareil'.tr()),
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Partage de localisation'.tr()),
                subtitle: Text('Permettre le suivi de livraison en temps réel'.tr()),
                value: locationSharingEnabled,
                onChanged: (value) {
                  setState(() {
                    locationSharingEnabled = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  static void showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('À propos de Le Livreur Pro'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Version: 1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Plateforme de livraison innovante en Côte d\'Ivoire'.tr()),
            const SizedBox(height: 16),
            const Text(
              'Développé avec ❤️ par l\'équipe Le Livreur Pro',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Text(
              'Contact: info@lelivreurpro.ci',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'.tr()),
          ),
        ],
      ),
    );
  }

  static void showHelpAndSupport(BuildContext context) {
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
                'Aide et support'.tr(),
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
                    ListTile(
                      leading: const Icon(Icons.help_outline, color: AppTheme.primaryGreen),
                      title: Text('FAQ'.tr()),
                      subtitle: Text('Questions fréquemment posées'.tr()),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showComingSoon(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.chat, color: AppTheme.primaryGreen),
                      title: Text('Chat en direct'.tr()),
                      subtitle: Text('Discuter avec notre équipe support'.tr()),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showComingSoon(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email, color: AppTheme.primaryGreen),
                      title: Text('Envoyer un email'.tr()),
                      subtitle: const Text('support@lelivreurpro.ci'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showComingSoon(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: AppTheme.primaryGreen),
                      title: Text('Appeler le support'.tr()),
                      subtitle: const Text('+225 XX XX XX XX XX'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showComingSoon(context),
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

  static void _showComingSoon(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fonctionnalité bientôt disponible'.tr()),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }
}