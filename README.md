Ecom App 🛍️
Ecom App est une application mobile et web complète d'e-commerce développée avec Flutter. Elle offre une expérience utilisateur fluide pour les clients (navigation, panier, commandes) ainsi qu'une interface d'administration pour la gestion des produits et le suivi des ventes.

L'architecture est conçue pour être modulaire, évolutive et facile à maintenir.

✨ Fonctionnalités Principales
Pour les Clients
Authentification & Profil : Connexion, inscription, gestion du profil utilisateur et adresses de livraison.

Navigation Produits : Recherche avancée, filtrage par catégories, et affichage en grille ou liste.

Détails Produit : Descriptions, images, avis clients et produits similaires.

Panier & Wishlist : Gestion dynamique du panier et liste de souhaits (favoris).

Commandes : Passage de commande sécurisé et historique des achats.

Pour les Administrateurs
Tableau de bord : Vue d'ensemble des ventes et statistiques.

Gestion Produits : Ajouter, modifier ou supprimer des articles (CRUD).

Gestion Commandes : Suivi de l'état des commandes (En cours, Livré, Annulé).

📂 Structure du Projet
Le code source est organisé pour séparer la logique métier de l'interface utilisateur :

Plaintext

lib/
├── models/         # Modèles de données (ex: Product, CartItem, Order)
├── providers/      # Gestion d'état (ex: AuthProvider, CartProvider via Provider/Riverpod)
├── screens/        # Écrans de l'application (UI)
│   ├── admin/      # Écrans spécifiques à l'administration
│   ├── auth/       # Écrans de connexion/inscription
│   ├── cart/       # Écrans du panier et checkout
│   └── product/    # Liste et détails des produits
├── services/       # Appels API et services externes (ex: HttpService)
├── widgets/        # Composants UI réutilisables (boutons, cartes produits)
└── main.dart       # Point d'entrée de l'application
assets/
├── images/         # Images statiques (logos, bannières)
└── fonts/          # Polices personnalisées
🛠️ Prérequis
Avant de commencer, assurez-vous d'avoir installé les outils suivants :

Flutter SDK : Version 3.0.0 ou supérieure (Guide d'installation).

Dart SDK : Inclus avec Flutter.

IDE : VS Code (recommandé) ou Android Studio.

Plateformes : Émulateur Android/iOS ou navigateur (Chrome/Edge) pour le web.

🚀 Installation et Configuration
Cloner le dépôt :

Bash

git clone https://github.com/votre-username/ecom-app.git
cd ecom-app
Installer les dépendances :

Bash

flutter pub get
Configuration de l'environnement :

Renommez le fichier .env.example en .env (si vous utilisez flutter_dotenv).

Ou configurez l'URL de votre backend dans lib/services/api_constants.dart :

Dart

const String BASE_URL = "https://api.votre-boutique.com";
▶️ Lancer l'Application
Mobile (Android / iOS)
Assurez-vous qu'un émulateur est lancé ou qu'un appareil physique est connecté.

Bash

flutter run
Web
Pour lancer l'application dans votre navigateur par défaut :

Bash

flutter run -d chrome
Exécuter les tests
Pour vérifier que tout fonctionne correctement (tests unitaires et widgets) :

Bash

flutter test
🎨 Personnalisation
Changer l'API Backend : Modifiez l'URL de base dans lib/services/. Assurez-vous que les modèles JSON correspondent à votre API.

Thème et Couleurs : Modifiez le fichier lib/utils/theme.dart ou la configuration ThemeData dans main.dart pour ajuster la palette de couleurs (primaryColor, accentColor) et les polices.

Assets : Remplacez les images dans le dossier assets/images/ et mettez à jour le fichier pubspec.yaml si vous ajoutez de nouveaux fichiers.

❓ Dépannage
Si vous rencontrez des problèmes lors de la compilation ou de l'exécution :

Nettoyer le projet : C'est souvent la solution magique pour les problèmes de build.

Bash

flutter clean
flutter pub get
Vérifier l'installation : Assurez-vous qu'il n'y a pas d'erreurs dans votre configuration Flutter.

Bash

flutter doctor
Problèmes de cache (iOS/Android) : Parfois, il est nécessaire de désinstaller l'application de l'émulateur avant de relancer flutter run.

📄 Licence
Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

Développé avec ❤️ et Flutter.
