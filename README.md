# GESTION PERSO SDIS

Application mobile **Flutter** de gestion des disponibilités et du suivi des interventions pour sapeurs-pompiers et chefs de garde.

> **Contexte pédagogique et fictif** — Cette application n’est pas affiliée au SDIS 34 réel. Les données et comptes sont des données de démonstration.

---

## Présentation

L’application propose quatre espaces principaux :

| Écran | Description |
|-------|-------------|
| **Accueil** | Effectifs disponibles, indicateur d’armement, interventions en cours, historique sur 7 jours |
| **Interventions** | Liste filtrable et fiche détail (personnel et véhicules engagés) |
| **Planification** | Calendrier des disponibilités personnelles ; vue équipe pour les chefs de garde |
| **Paramètres** | Profil utilisateur, caserne, déconnexion |

Les données de démonstration (personnel, véhicules, interventions, créneaux) sont **incluses dans le dépôt** (`lib/data/mock_data.dart`). Aucune installation de base de données n’est requise pour utiliser l’application en configuration par défaut.

---

## Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.35** ou supérieur (Dart **3.9** ou supérieur)
- Un émulateur Android, un simulateur iOS, ou un appareil physique configuré pour le débogage USB
- Git

Vérifier l’environnement :

```bash
flutter doctor
```

---

## Installation

```bash
git clone <URL-du-depot>
cd gestion-perso-sdis
flutter pub get
flutter run
```

Le nom du dossier après clonage dépend du nom du dépôt GitHub ; se placer dans le répertoire qui contient le fichier `pubspec.yaml`.

Compilation des tests automatisés (optionnel) :

```bash
flutter test
```

---

## Connexion

Au premier lancement, l’application affiche un écran de connexion. Le comportement dépend du mode configuré dans `lib/config/app_config.dart` (par défaut : **mode démo**).

### Mode démo (configuration par défaut)

`useMockData = true` — aucun serveur requis.

| Champ | Valeur |
|-------|--------|
| Email | Tout email valide, ou laisser vide |
| Mot de passe | Tout mot de passe, ou laisser vide |

**Procédure :** appuyer sur **Se connecter**. L’identité affichée par défaut est celle du chef de garde de démonstration (**Pierre Durand**, caserne fictive).

Pour tester les autres profils sans se reconnecter :

1. Aller dans **Paramètres**
2. Section **Changer de rôle (Démo)**
3. Choisir **Pompier**, **Chef de garde** ou **Admin**

| Rôle | Accès spécifique |
|------|------------------|
| **Pompier** | Planification personnelle uniquement |
| **Chef de garde** | Planification personnelle + vue **Équipe** (validation des créneaux, filtres A / B / C) |
| **Admin** | Même accès que le chef de garde dans cette version de démonstration |

---

### Mode API (optionnel)

`useMockData = false` — nécessite une API REST (Express, port **4000**) et une base MySQL alimentée, généralement via le projet web associé. Ce mode n’est **pas requis** pour évaluer l’application depuis ce dépôt.

**Mot de passe commun à tous les comptes de démonstration :** `demo2026!`

| Profil | Email | Mot de passe |
|--------|-------|--------------|
| Personnel (pompier) | `personnel.limite@sdis34.demo` | `demo2026!` |
| Chef de garde (Pierre) | `pierre.durand@sdis34.demo` | `demo2026!` |
| Encadrement / officier (Sarah) | `sarah.lopez@sdis34.demo` | `demo2026!` |
| Encadrement (générique) | `encadrement@sdis34.demo` | `demo2026!` |
| Administrateur SI | `admin.si@sdis34.demo` | `demo2026!` |
| Opérateur poste | `operateur@sdis34.demo` | `demo2026!` |

Des raccourcis sur l’écran de connexion permettent de préremplir certains de ces comptes lorsque le mode API est actif.

**Activation du mode API :**

1. Démarrer l’API sur la machine hôte (port 4000) et vérifier `http://localhost:4000/api/health`
2. Dans `lib/config/app_config.dart`, définir `useMockData = false`
3. Relancer l’application avec `flutter run`

| Environnement d’exécution | Adresse de l’API |
|---------------------------|------------------|
| Émulateur Android | `http://10.0.2.2:4000` (automatique) |
| Simulateur iOS / application desktop | `http://127.0.0.1:4000` (automatique) |
| Appareil physique (même réseau Wi‑Fi) | `flutter run --dart-define=API_HOST=<IP-du-PC>` |

---

## Utilisation

1. **Connexion** selon le mode (voir section ci-dessus).
2. **Accueil** — consulter les indicateurs ; appuyer sur *Disponibles* ou *Armement* pour afficher le détail.
3. **Interventions** — filtrer la liste (*Toutes*, *En cours*, *Terminées*) ; ouvrir une fiche au toucher.
4. **Planification** — sélectionner une date sur le calendrier ; ajouter une disponibilité via le bouton **+** (type de créneau, horaires, notification au chef de garde).
5. **Paramètres** — consulter le profil ; **Déconnexion** pour quitter la session.

En mode démo, la session peut être mémorisée entre deux lancements de l’application.

---

## Architecture du projet

```
lib/
├── main.dart                 # Point d’entrée, injection Provider
├── config/app_config.dart    # Mode démo / API, URL du serveur
├── data/mock_data.dart       # Jeu de données de démonstration
├── models/                   # Modèles métier
├── providers/app_state.dart  # État global de l’application
├── repositories/           # Accès aux données (mock ou API)
├── api/                      # Client HTTP et conversion JSON
├── screens/                  # Écrans et navigation
└── auth/                     # Authentification et session
```

---

## Technologies

| Composant | Usage |
|-----------|--------|
| **Flutter / Dart** | Interface mobile |
| **Provider** | Gestion d’état |
| **Dio** | Appels REST vers l’API (mode API) |
| **table_calendar** | Calendrier de planification |
| **intl** | Formatage des dates (fr_FR) |
| **flutter_secure_storage** | Persistance sécurisée de la session |

Liste complète des dépendances : fichier `pubspec.yaml`.

---

## Licence et usage

Projet à vocation **pédagogique**. Données et identifiants **fictifs**. Toute utilisation en dehors d’un cadre de démonstration ou d’évaluation doit respecter la réglementation applicable et ne pas laisser supposer un lien avec un service de secours réel.
