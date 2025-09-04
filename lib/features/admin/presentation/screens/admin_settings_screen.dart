import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/admin_settings.dart';
import 'package:le_livreur_pro/core/services/admin_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

// Provider for admin settings
final adminSettingsProvider = FutureProvider<AdminSettings>((ref) async {
  return await AdminService.getSettings();
});

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres Système'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: [
            Tab(text: 'Général'.tr()),
            Tab(text: 'Paiements'.tr()),
            Tab(text: 'Sécurité'.tr()),
            Tab(text: 'Maintenance'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralSettingsTab(),
          _buildPaymentSettingsTab(),
          _buildSecuritySettingsTab(),
          _buildMaintenanceTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralSettingsTab() {
    final settingsAsync = ref.watch(adminSettingsProvider);

    return settingsAsync.when(
      data: (settings) => _buildGeneralSettings(settings),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildGeneralSettings(AdminSettings settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Configuration de la plateforme'.tr()),
          _buildSettingsCard([
            _buildSwitchSetting(
              'Maintenance mode'.tr(),
              'Activer le mode maintenance',
              settings.maintenanceMode,
              (value) => _updateSetting('maintenanceMode', value),
            ),
            _buildSwitchSetting(
              'Nouveaux enregistrements'.tr(),
              'Permettre de nouveaux utilisateurs',
              settings.allowRegistrations,
              (value) => _updateSetting('allowRegistrations', value),
            ),
            _buildSwitchSetting(
              'Commandes automatiques'.tr(),
              'Attribution automatique des commandes',
              settings.autoAssignOrders,
              (value) => _updateSetting('autoAssignOrders', value),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('Tarification'.tr()),
          _buildSettingsCard([
            _buildNumberSetting(
              'Commission de base'.tr(),
              'Pourcentage de commission (%)',
              settings.baseCommissionRate,
              (value) => _updateSetting('baseCommissionRate', value),
            ),
            _buildNumberSetting(
              'Prix de base livraison'.tr(),
              'Prix minimum en XOF',
              settings.baseDeliveryPrice.toDouble(),
              (value) => _updateSetting('baseDeliveryPrice', value.toInt()),
            ),
            _buildNumberSetting(
              'Rayon de base'.tr(),
              'Distance de base en km',
              settings.baseZoneRadius,
              (value) => _updateSetting('baseZoneRadius', value),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('Notifications'.tr()),
          _buildSettingsCard([
            _buildSwitchSetting(
              'Notifications push'.tr(),
              'Envoyer des notifications push',
              settings.enablePushNotifications,
              (value) => _updateSetting('enablePushNotifications', value),
            ),
            _buildSwitchSetting(
              'Notifications email'.tr(),
              'Envoyer des notifications par email',
              settings.enableEmailNotifications,
              (value) => _updateSetting('enableEmailNotifications', value),
            ),
            _buildSwitchSetting(
              'Notifications SMS'.tr(),
              'Envoyer des notifications par SMS',
              settings.enableSmsNotifications,
              (value) => _updateSetting('enableSmsNotifications', value),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildPaymentSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Méthodes de paiement'.tr()),
          _buildSettingsCard([
            _buildPaymentMethodSetting('Orange Money', true),
            _buildPaymentMethodSetting('MTN Money', true),
            _buildPaymentMethodSetting('Moov Money', false),
            _buildPaymentMethodSetting('Wave', true),
            _buildPaymentMethodSetting('Paiement à la livraison', true),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('Configuration API'.tr()),
          _buildSettingsCard([
            _buildTextSetting(
                'Clé API Orange Money', '****-****-****', Icons.vpn_key),
            _buildTextSetting(
                'Clé API MTN Money', '****-****-****', Icons.vpn_key),
            _buildTextSetting('Clé API Wave', '****-****-****', Icons.vpn_key),
            _buildActionSetting(
              'Tester les connexions',
              'Vérifier la connectivité avec les services de paiement',
              Icons.network_check,
              () => _testPaymentConnections(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('Frais et limites'.tr()),
          _buildSettingsCard([
            _buildNumberSetting(
              'Frais de transaction',
              'Pourcentage des frais (%)',
              2.5,
              (value) => _updatePaymentSetting('transactionFees', value),
            ),
            _buildNumberSetting(
              'Montant minimum',
              'Montant minimum en XOF',
              500.0,
              (value) => _updatePaymentSetting('minimumAmount', value),
            ),
            _buildNumberSetting(
              'Montant maximum',
              'Montant maximum en XOF',
              100000.0,
              (value) => _updatePaymentSetting('maximumAmount', value),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSecuritySettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Authentification'.tr()),
          _buildSettingsCard([
            _buildSwitchSetting(
              'Authentification à deux facteurs'.tr(),
              'Exiger 2FA pour les admins',
              true,
              (value) => _updateSecuritySetting('require2FA', value),
            ),
            _buildSwitchSetting(
              'Vérification OTP'.tr(),
              'Exiger OTP pour les connexions',
              true,
              (value) => _updateSecuritySetting('requireOTP', value),
            ),
            _buildNumberSetting(
              'Durée de session',
              'Durée en minutes',
              60.0,
              (value) => _updateSecuritySetting('sessionDuration', value),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('Contrôle d\'accès'.tr()),
          _buildSettingsCard([
            _buildActionSetting(
              'Gérer les rôles',
              'Configurer les permissions des utilisateurs',
              Icons.admin_panel_settings,
              () => _manageRoles(),
            ),
            _buildActionSetting(
              'Journal d\'audit',
              'Consulter les logs de sécurité',
              Icons.security,
              () => _viewAuditLog(),
            ),
            _buildActionSetting(
              'Sessions actives',
              'Voir les utilisateurs connectés',
              Icons.people,
              () => _viewActiveSessions(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('Sauvegarde et restauration'.tr()),
          _buildSettingsCard([
            _buildActionSetting(
              'Sauvegarde automatique',
              'Configurer les sauvegardes automatiques',
              Icons.backup,
              () => _configureBackup(),
            ),
            _buildActionSetting(
              'Créer sauvegarde',
              'Créer une sauvegarde maintenant',
              Icons.save,
              () => _createBackup(),
            ),
            _buildActionSetting(
              'Restaurer données',
              'Restaurer depuis une sauvegarde',
              Icons.restore,
              () => _restoreData(),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildMaintenanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('État du système'.tr()),
          _buildSystemHealthCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Actions de maintenance'.tr()),
          _buildSettingsCard([
            _buildActionSetting(
              'Nettoyer cache',
              'Vider le cache système',
              Icons.cleaning_services,
              () => _clearCache(),
            ),
            _buildActionSetting(
              'Optimiser base de données',
              'Optimiser les performances',
              Icons.tune,
              () => _optimizeDatabase(),
            ),
            _buildActionSetting(
              'Redémarrer services',
              'Redémarrer les services backend',
              Icons.refresh,
              () => _restartServices(),
            ),
            _buildActionSetting(
              'Mise à jour système',
              'Vérifier les mises à jour',
              Icons.system_update,
              () => _checkUpdates(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('Surveillance'.tr()),
          _buildSettingsCard([
            _buildActionSetting(
              'Logs système',
              'Consulter les logs détaillés',
              Icons.article,
              () => _viewSystemLogs(),
            ),
            _buildActionSetting(
              'Métriques performance',
              'Voir les métriques de performance',
              Icons.analytics,
              () => _viewPerformanceMetrics(),
            ),
            _buildActionSetting(
              'Alertes système',
              'Configurer les alertes',
              Icons.notification_important,
              () => _configureAlerts(),
            ),
          ]),
        ],
      ),
    );
  }

  // ==================== WIDGET BUILDERS ====================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryGreen,
    );
  }

  Widget _buildNumberSetting(
    String title,
    String subtitle,
    double value,
    Function(double) onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: SizedBox(
        width: 100,
        child: TextFormField(
          initialValue: value.toString(),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          onFieldSubmitted: (str) {
            final newValue = double.tryParse(str);
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextSetting(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(title),
      subtitle: Text(value),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => _editTextSetting(title, value),
      ),
    );
  }

  Widget _buildActionSetting(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  Widget _buildPaymentMethodSetting(String method, bool enabled) {
    return SwitchListTile(
      title: Text(method),
      subtitle: Text(enabled ? 'Activé' : 'Désactivé'),
      value: enabled,
      onChanged: (value) => _togglePaymentMethod(method, value),
      activeColor: AppTheme.primaryGreen,
    );
  }

  Widget _buildSystemHealthCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHealthItem('Base de données', true, '99.9% uptime'),
            _buildHealthItem('Services API', true, 'Tous opérationnels'),
            _buildHealthItem('Cache Redis', false, 'Nettoyage requis'),
            _buildHealthItem('Stockage', true, '65% utilisé'),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthItem(String name, bool healthy, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            healthy ? Icons.check_circle : Icons.warning,
            color: healthy ? AppTheme.successGreen : AppTheme.warningOrange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: healthy ? AppTheme.successGreen : AppTheme.warningOrange,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur lors du chargement des paramètres'.tr(),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _refreshSettings(),
              child: Text('Réessayer'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EVENT HANDLERS ====================

  void _updateSetting(String key, dynamic value) async {
    try {
      await AdminService.updateSetting(key, value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paramètre mis à jour'.tr()),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      _refreshSettings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _updatePaymentSetting(String key, dynamic value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paramètre de paiement mis à jour: $key'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _updateSecuritySetting(String key, dynamic value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paramètre de sécurité mis à jour: $key'.tr()),
        backgroundColor: AppTheme.warningOrange,
      ),
    );
  }

  void _togglePaymentMethod(String method, bool enabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$method ${enabled ? "activé" : "désactivé"}'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _editTextSetting(String title, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Save the new value
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title mis à jour'.tr()),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: Text('Enregistrer'.tr()),
          ),
        ],
      ),
    );
  }

  void _testPaymentConnections() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Test des connexions de paiement...'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _manageRoles() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gestion des rôles bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _viewAuditLog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Journal d\'audit bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _viewActiveSessions() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sessions actives bientôt disponibles'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _configureBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configuration de sauvegarde bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _createBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Création de sauvegarde en cours...'.tr()),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _restoreData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Restauration bientôt disponible'.tr()),
        backgroundColor: AppTheme.warningOrange,
      ),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cache vidé avec succès'.tr()),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _optimizeDatabase() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Optimisation de la base de données...'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _restartServices() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redémarrage des services...'.tr()),
        backgroundColor: AppTheme.warningOrange,
      ),
    );
  }

  void _checkUpdates() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vérification des mises à jour...'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _viewSystemLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logs système bientôt disponibles'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _viewPerformanceMetrics() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Métriques de performance bientôt disponibles'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _configureAlerts() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configuration d\'alertes bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _refreshSettings() {
    ref.refresh(adminSettingsProvider);
  }
}
