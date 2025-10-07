import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';
import 'package:le_livreur_pro/core/services/auth_service.dart';
import 'package:le_livreur_pro/core/services/demo_auth_service.dart';
import 'package:le_livreur_pro/core/models/user.dart';

class AuthHelpWidget extends ConsumerWidget {
  final bool isSignUp;
  
  const AuthHelpWidget({
    super.key,
    this.isSignUp = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isSignUp ? 'Guide d\'inscription'.tr() : 'Guide de connexion'.tr(),
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isSignUp) ...[
            _buildHelpItem(
              '1. Utilisez votre email personnel',
              Icons.email,
              context,
            ),
            _buildHelpItem(
              '2. Choisissez un mot de passe (min. 6 caractères)',
              Icons.lock,
              context,
            ),
            _buildHelpItem(
              '3. Vérifiez votre email après inscription',
              Icons.mark_email_read,
              context,
            ),
          ] else ...[
            _buildHelpItem(
              'Comptes de démo disponibles:',
              Icons.account_circle,
              context,
            ),
            const SizedBox(height: 8),
            _buildDemoAccount(
              'client@demo.com',
              'demo123',
              'Client',
              Colors.green,
              context,
              ref,
            ),
            _buildDemoAccount(
              'coursier@demo.com',
              'demo123', 
              'Coursier',
              Colors.orange,
              context,
              ref,
            ),
            _buildDemoAccount(
              'partenaire@demo.com',
              'demo123',
              'Partenaire',
              Colors.purple,
              context,
              ref,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildHelpItem(String text, IconData icon, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDemoAccount(
    String email,
    String password,
    String type,
    Color color,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$type: $email',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.8),
                  ),
                ),
                Text(
                  'Mot de passe: $password',
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.login,
              size: 18,
              color: color,
            ),
            onPressed: () async {
              try {
                print('🔴 Quick demo login: $email');
                await ref.read(authNotifierProvider.notifier).signInWithEmail(
                  email: email,
                  password: password,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur de connexion: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            tooltip: 'Connexion rapide',
          ),
        ],
      ),
    );
  }
}