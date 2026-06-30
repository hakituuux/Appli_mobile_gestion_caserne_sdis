# GESTION PERSO SDIS

Appli mobile **Flutter** (projet fictif SDIS 34) : disponibilités, interventions, armement du centre.

**Contexte fictif** — pas le vrai SDIS 34.

---

## Lancer l’appli (sans base de données)

Par défaut l’appli tourne en **mode démo** : toutes les données sont déjà dans le code (`lib/data/mock_data.dart`).  
**Pas besoin de MySQL, Docker ni serveur** pour tester.

### Prérequis

- [Flutter](https://docs.flutter.dev/get-started/install) 3.35+ (Dart 3.9+)
- Android Studio / VS Code + un émulateur **ou** un téléphone en USB

Vérifier :

```bash
flutter doctor
```

### Installation

```bash
git clone https://github.com/TON-USERNAME/TON-REPO.git
cd TON-REPO
flutter pub get
flutter run
```

*(Remplace l’URL par la tienne après publication.)*

### Utilisation (mode démo)

1. Au lancement → écran **Connexion**
2. Appuie sur **Se connecter** (email / mot de passe ignorés)
3. Navigue avec les **4 onglets** : Accueil, Interventions, Planification, Paramètres
4. Pour changer de rôle (pompier / chef / admin) : **Paramètres** → « Changer de rôle (Démo) »

Les données (personnel, véhicules, interventions, créneaux) viennent de `lib/data/mock_data.dart`.

---

## Où sont les « données » ?

| Mode | Où ça vit | Pour qui |
|------|-----------|----------|
| **Démo (défaut)** | `lib/data/mock_data.dart` dans le repo | Clone GitHub, prof, évaluateur |
| **API + MySQL (optionnel)** | Projet web séparé (Node + Docker) | Si tu as aussi l’appli web BTS |

Le dépôt GitHub **ne contient pas MySQL** : une appli Flutter ne embarque pas une base SQL.  
Pour un correcteur qui clone le repo, le mode démo suffit et **tout fonctionne tout de suite**.

Config : `lib/config/app_config.dart` → `useMockData = true` (valeur par défaut).

---

## Mode API (optionnel)

Uniquement si tu as le **projet web** (API Express port **4000** + MySQL via Docker) sur ta machine.

1. Démarrer l’API (dans le dossier du projet web) :

   ```bash
   npm run db:up
   npm run seed
   npm run dev
   ```

2. Vérifier : [http://localhost:4000/api/health](http://localhost:4000/api/health)

3. Dans `lib/config/app_config.dart` :

   ```dart
   static const bool useMockData = false;
   ```

4. Relancer : `flutter run`

| Appareil | Adresse API (automatique sauf téléphone) |
|----------|------------------------------------------|
| Émulateur Android | `10.0.2.2:4000` |
| PC / simulateur iOS | `127.0.0.1:4000` |
| Téléphone (même Wi‑Fi) | `flutter run --dart-define=API_HOST=192.168.x.x` |

Comptes de test (mot de passe `demo2026!`) :

- `personnel.limite@sdis34.demo`
- `encadrement@sdis34.demo`
- `admin.si@sdis34.demo`

---

## Structure utile

```
lib/
├── main.dart              # Entrée + Provider
├── config/app_config.dart # mock ou API
├── data/mock_data.dart    # Données démo (GitHub)
├── models/                # Modèles
├── providers/             # État global
├── repositories/          # Mock / API
├── screens/               # Écrans
└── auth/                  # Connexion
```

---

## Tests

```bash
flutter test
```

---

## Publier / mettre à jour avec GitHub Desktop

À faire **une seule fois** :

1. Sur [github.com](https://github.com) → **New repository** → nom ex. `gestion-perso-sdis` → **sans** README (tu en as déjà un)
2. Ouvre **GitHub Desktop** → **File** → **Add local repository**
3. Choisis le dossier **`GESTION PERSO SDIS`** (celui qui contient `pubspec.yaml` et ce README)
4. Si GitHub Desktop propose **Initialize repository** → accepte
5. Tous les fichiers cochés → message de commit ex. `Initial commit — appli Flutter mode démo`
6. **Commit to main** puis **Publish repository**

Ensuite, à chaque modif :

1. GitHub Desktop affiche les fichiers changés
2. Résumé du commit → **Commit to main** → **Push origin**

**Important :**

- Publie **uniquement** le dossier `GESTION PERSO SDIS`, pas tout `SITUATION 1` (sinon tu envoies les PDF de TP, Word, etc.)
- Le dossier `docs/` (rapport BTS, textes Word) est **ignoré** par Git → il reste sur ton PC, pas sur GitHub
- Ne commite pas `.env`, mots de passe, ni le dossier `build/`

---

## Dépendances principales

`provider`, `dio`, `table_calendar`, `intl`, `flutter_secure_storage` — voir `pubspec.yaml`.
