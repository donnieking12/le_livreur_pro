# Le Livreur Pro 🚚

## Plateforme de Livraison Complète pour la Côte d'Ivoire

Le Livreur Pro est une plateforme de livraison moderne et complète, spécialement conçue pour le marché ivoirien. Elle connecte les clients, les livreurs, les commerçants et les administrateurs dans un écosystème unifié de livraison en temps réel.

### 🌟 Fonctionnalités Principales

#### Pour les Clients

- **Commande Facile**: Interface intuitive pour commander des livraisons
- **Suivi en Temps Réel**: Localisation GPS en direct du livreur
- **Paiements Multiples**: Orange Money, MTN Money, Moov Money, Wave, Cartes bancaires, Espèces
- **Support Multilingue**: Français et Anglais
- **Chat en Direct**: Communication avec le livreur
- **Historique Complet**: Suivi de toutes les commandes

#### Pour les Livreurs

- **Tableau de Bord Intelligent**: Gestion des commandes disponibles et actives
- **Navigation GPS**: Itinéraires optimisés vers les destinations
- **Gestion des Revenus**: Suivi des gains avec système de commission (90% livreur, 10% plateforme)
- **Statuts en Temps Réel**: Mise à jour instantanée des statuts de livraison
- **Système de Notation**: Évaluations clients pour améliorer la qualité

#### Pour les Commerçants

- **Gestion du Menu**: Interface complète pour gérer les produits
- **Analytiques Avancées**: Métriques de performance et revenus
- **Gestion des Commandes**: Suivi et traitement des commandes
- **Configuration Restaurant**: Paramètres personnalisables

#### Pour les Administrateurs

- **Tableau de Bord Complet**: Vue d'ensemble de toute la plateforme
- **Gestion des Utilisateurs**: Administration des clients, livreurs et partenaires
- **Suivi des Commandes**: Monitoring en temps réel de toutes les livraisons
- **Analytiques Détaillées**: Métriques de performance de la plateforme
- **Configuration Système**: Paramètres globaux et tarification

### 🛠️ Architecture Technique

#### Technologies Utilisées

- **Frontend**: Flutter Web (Support multi-plateforme)
- **Backend**: Supabase (PostgreSQL + Temps Réel)
- **Authentification**: OTP par SMS pour le marché ivoirien
- **Paiements**: Intégration complète avec les opérateurs ivoiriens
- **Cartes**: Google Maps Platform avec Directions API
- **Notifications**: Firebase Cloud Messaging
- **État Global**: Riverpod pour la gestion d'état
- **Localisation**: Easy Localization (FR/EN)

#### Fonctionnalités Avancées

- **Calcul de Prix Intelligent**: Système de zones avec tarification dynamique
- **Temps Réel**: WebSockets pour les mises à jour instantanées
- **Chat Intégré**: Communication client-livreur en temps réel
- **Géolocalisation**: Suivi précis avec optimisation des trajets
- **Système de Commission**: 10% plateforme, 90% livreur
- **Gestion des Priorités**: Livraison normale, urgente, express

### 📱 Captures d'Écran

_(Screenshots will be added here showing different interfaces)_

### 🚀 Installation et Configuration

#### Prérequis

- Flutter SDK 3.19.0+
- Dart 3.0+
- Compte Supabase
- Clés API Google Maps
- Configuration Firebase

#### Installation Rapide

```bash
# Cloner le repository
git clone https://github.com/your-org/le-livreur-pro.git
cd le-livreur-pro

# Installer les dépendances
flutter pub get

# Configurer les variables d'environnement
cp .env.template .env
# Éditer le fichier .env avec vos clés API réelles

# Lancer en mode développement
flutter run -d web-server --web-port 8080
```

#### Configuration des Identifiants Supabase

Pour configurer votre projet avec les identifiants Supabase fournis :

1. Copiez le fichier `.env.template` en `.env`
2. Remplacez les valeurs suivantes dans le fichier `.env` :
   ```
   SUPABASE_URL=https://fnygxppfogfpwycbbhsv.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZueWd4cHBmb2dmcHd5Y2JiaHN2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0OTkxNDIsImV4cCI6MjA3MDA3NTE0Mn0.MMu4mvYF7lR7ST6uHwf8A_EeujhwXUQ3-SxLNnFTV9o
   ```
3. Configurez les autres clés API selon vos besoins (Google Maps, paiements, etc.)

#### Configuration Complète

Pour une configuration complète pas à pas, voir [COMPLETE_SETUP_GUIDE.md](COMPLETE_SETUP_GUIDE.md) pour les instructions détaillées.

Voir [DEPLOYMENT.md](DEPLOYMENT.md) pour les instructions de déploiement avancées.

### 🏗️ Structure du Projet

```
lib/
├── core/                     # Logique métier centrale
│   ├── models/              # Modèles de données
│   ├── services/            # Services externes
│   ├── providers/           # Providers Riverpod
│   └── utils/               # Utilitaires
├── features/                # Fonctionnalités par domaine
│   ├── auth/               # Authentification
│   ├── orders/             # Gestion des commandes
│   ├── user/               # Interface client
│   ├── courier/            # Interface livreur
│   ├── partner/            # Interface commerçant
│   └── admin/              # Interface administrateur
├── shared/                  # Composants partagés
│   ├── widgets/            # Widgets réutilisables
│   ├── theme/              # Thème et styles
│   └── utils/              # Utilitaires partagés
└── main.dart               # Point d'entrée
```

### 💳 Intégration Paiements

#### Méthodes Supportées

- **Orange Money** - Opérateur principal en Côte d'Ivoire
- **MTN Money** - Deuxième opérateur majeur
- **Moov Money** - Service de paiement mobile Moov
- **Wave** - Portefeuille mobile populaire
- **Cartes Bancaires** - Visa/Mastercard via Stripe
- **Espèces** - Paiement à la livraison

#### Fonctionnalités Paiement

- Calcul automatique des frais
- Traitement en temps réel
- Système de remboursement
- Historique des transactions
- Notifications de paiement

### 🗺️ Système de Tarification

#### Zones de Livraison

- **Abidjan**: Zone de base 5km - Prix de base 500 XOF
- **Bouaké**: Zone de base 3km - Prix de base 500 XOF
- **Yamoussoukro**: Zone de base 4km - Prix de base 500 XOF
- **San-Pédro**: Zone de base 4.5km - Prix de base 500 XOF
- **Korhogo**: Zone de base 2.5km - Prix de base 500 XOF

#### Calcul des Prix

- **Prix de base**: 500 XOF (couvre la zone de base)
- **Distance supplémentaire**: 100 XOF/km au-delà de la zone
- **Livraison urgente**: +200 XOF
- **Livraison express**: +400 XOF
- **Colis fragile**: +200 XOF
- **Commission plateforme**: 10% du prix total

### 🔄 Fonctionnalités Temps Réel

#### Suivi des Commandes

- Localisation en direct du livreur
- Mises à jour automatiques du statut
- Notifications push instantanées
- Estimation du temps d'arrivée

#### Communication

- Chat client-livreur intégré
- Notifications de messages
- Historique des conversations
- Support multimédia

#### Gestion des Statuts

```
Statuts de Commande:
├── pending (En attente)
├── assigned (Attribuée)
├── courierEnRoute (Livreur en route)
├── pickedUp (Récupérée)
├── inTransit (En transit)
├── delivered (Livrée)
├── cancelled (Annulée)
└── refunded (Remboursée)
```

### 📊 Analytiques et Métriques

#### Métriques Clients

- Nombre de commandes
- Satisfaction client
- Fréquence d'utilisation
- Montant moyen des commandes

#### Métriques Livreurs

- Nombre de livraisons
- Temps de livraison moyen
- Évaluations clients
- Revenus générés

#### Métriques Plateforme

- Volume de commandes
- Croissance utilisateurs
- Performance des paiements
- Efficacité des livraisons

### 🧪 Tests et Qualité

#### Couverture de Tests

- **Tests Unitaires**: 90%+ des services principaux
- **Tests de Widgets**: Composants critiques
- **Tests d'Intégration**: Workflows utilisateur complets
- **Tests de Performance**: Charge et stress

#### Commandes de Test

```bash
# Tests unitaires
flutter test test/unit/

# Tests de widgets
flutter test test/widget/

# Tests d'intégration
flutter test test/integration/

# Couverture de code
flutter test --coverage
```

### 🔒 Sécurité

#### Authentification

- OTP par SMS sécurisé
- Gestion des sessions JWT
- Authentification multi-facteurs pour admin
- Chiffrement des données sensibles

#### Protection des Données

- Chiffrement HTTPS obligatoire
- Validation des entrées utilisateur
- Protection contre XSS et CSRF
- Audit trails des actions sensibles

#### Conformité

- Politique de confidentialité
- Conditions d'utilisation
- Conformité RGPD
- Standards de sécurité des paiements

### 📈 Roadmap

#### Version 1.1 (Q3 2024)

- [ ] Livraisons programmées
- [ ] Système de fidélité
- [ ] Intégration avec plus de restaurants
- [ ] Optimisation des trajets par IA

#### Version 1.2 (Q4 2024)

- [ ] Application mobile native
- [ ] Livraisons de groupe
- [ ] Programme de parrainage
- [ ] Support client 24/7

#### Version 2.0 (Q1 2025)

- [ ] Livraisons inter-villes
- [ ] Marketplace élargi
- [ ] Système de notation avancé
- [ ] Intelligence artificielle prédictive

### 🤝 Contribution

#### Comment Contribuer

1. Fork le repository
2. Créer une branche pour votre fonctionnalité
3. Commiter vos changements
4. Pousser vers la branche
5. Créer une Pull Request

#### Standards de Code

- Suivre les conventions Dart/Flutter
- Documenter les fonctions publiques
- Ajouter des tests pour les nouvelles fonctionnalités
- Respecter l'architecture existante

### 📞 Support

#### Contact

- **Email**: support@lelivreurpro.ci
- **Téléphone**: +225 XX XX XX XX
- **Site Web**: https://lelivreurpro.ci
- **Documentation**: https://docs.lelivreurpro.ci

#### Support Technique

- GitHub Issues pour les bugs
- Discord pour les discussions
- Email pour le support urgent
- Documentation complète disponible

### 📄 Licence

Ce projet est sous licence MIT. Voir [LICENSE](LICENSE) pour plus de détails.

### 🙏 Remerciements

Merci à tous les contributeurs qui ont rendu ce projet possible :

- Équipe de développement
- Testeurs et utilisateurs bêta
- Partenaires locaux en Côte d'Ivoire
- Communauté Flutter et open source

---

**Le Livreur Pro** - Révolutionner la livraison en Côte d'Ivoire 🇨🇮

_Développé avec ❤️ pour le marché ivoirien_
