# 🎬 MovieRec Express
**Mini Projet Flutter — Système de Recommandation de Films**

---

## 📋 Cahier des charges — Critères couverts

| Critère | Points | Ce qui est implémenté |
|---|---|---|
| **Architecture & Code** | /4 | Riverpod, Clean Architecture (features/data/domain/presentation), gestion erreurs API, responsive |
| **UI/UX** | /4 | Dark cinéma, Material 3, loading shimmer, snackbars, animations |
| **Data & API** | /6 | TMDB API (Dio), persistance Hive (offline), fl_chart visualisation, JWT auth local |
| **Démo & Maîtrise** | /6 | Code documenté, architecture claire, algorithme expliqué |

---

## 🚀 Installation rapide

### 1. Clé API TMDB (OBLIGATOIRE)
1. Va sur **https://www.themoviedb.org**
2. Crée un compte → **Settings → API → Create → Developer**
3. Copie ta clé **API Read Access Token** (ou API Key v3)

### 2. Configure la clé dans le projet
Ouvre `lib/core/constants/app_constants.dart` et remplace :
```dart
static const String tmdbApiKey = 'VOTRE_CLE_TMDB_ICI';
```

### 3. Installe les dépendances
```bash
flutter pub get
```

### 4. Lance l'app
```bash
flutter run
```

> ⚠️ Si tu as une erreur avec `uuid`, ajoute dans `pubspec.yaml` :
> ```yaml
> uuid: ^4.4.0
> ```

---

## 🏗️ Architecture du projet

```
lib/
├── core/
│   ├── constants/       # AppConstants (API keys, box names)
│   ├── theme/           # AppTheme (dark cinema)
│   └── router/          # GoRouter + MainScaffold
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/  # UserModel + Hive adapter
│   │   │   └── datasources/ # AuthService (JWT local + Hive)
│   │   └── presentation/
│   │       ├── providers/   # AuthNotifier (Riverpod)
│   │       └── screens/     # Login, Register, GenrePicker
│   ├── movies/
│   │   ├── data/
│   │   │   ├── models/      # Movie, Genre
│   │   │   ├── datasources/ # TmdbApiService (Dio)
│   │   │   └── repositories/ # RecommendationEngine (CBF)
│   │   └── presentation/
│   │       ├── providers/   # MoviesProviders (Riverpod)
│   │       ├── screens/     # Home, Search, Detail, Recommendations
│   │       └── widgets/     # MovieCard, MovieCardLarge
│   ├── profile/
│   │   └── presentation/
│   │       └── screens/     # ProfileScreen + fl_chart
│   └── splash/
│       └── presentation/
│           └── screens/     # SplashScreen
└── main.dart                # ProviderScope + Hive init
```

---

## 🤖 Algorithme de Recommandation — Content-Based Filtering

Le moteur (`RecommendationEngine`) calcule un **score de pertinence** pour chaque film :

```
Score final = Genre Score × 40% + Rating Score × 40% + Quality Score × 20%
```

### Genre Score — Similarité de Jaccard
```
Jaccard(A, B) = |A ∩ B| / |A ∪ B|
```
- A = genres du film
- B = genres préférés de l'utilisateur

### Quality Score — Wilson Score Bayésien
```
Score = (votes / (votes + minVotes)) × rating + (1 - weight) × 0.5
```
Évite qu'un film avec 1 vote parfait domine.

### Pénalité films déjà vus
```
score × 0.3  →  les films déjà sauvegardés descendent dans le classement
```

---

## 🛠️ Stack technique

| Tech | Usage |
|---|---|
| **Flutter 3.x** | Framework mobile |
| **Riverpod 2.x** | State management (cahier des charges) |
| **GoRouter** | Navigation déclarative |
| **Dio** | HTTP client → TMDB API |
| **Hive** | Persistance locale (offline) |
| **flutter_secure_storage** | Stockage sécurisé JWT |
| **fl_chart** | Visualisation (distribution des notes) |
| **cached_network_image** | Cache images affiches |
| **shimmer** | Loading skeleton |
| **flutter_rating_bar** | Notation films |
| **google_fonts** | Urbanist font |
| **crypto** | Hash SHA-256 mots de passe |

---

## 📱 Fonctionnalités

- ✅ **Inscription / Connexion** avec hash SHA-256 + JWT simulé
- ✅ **Onboarding genres** — sélection des préférences au premier lancement
- ✅ **Home** — Trending, En salle, Populaires (TMDB)
- ✅ **Recherche** — temps réel (≥2 caractères)
- ✅ **Recommandations IA** — Content-Based Filtering personnalisé
- ✅ **Détail film** — Synopsis, Cast, Note utilisateur, Films similaires
- ✅ **Profil** — Statistiques + graphique distribution des notes (fl_chart)
- ✅ **Notation** — 0.5 à 5 étoiles, influence l'algorithme
- ✅ **Sauvegarde** — Favoris persistés en Hive (offline)
- ✅ **Gestion erreurs** — Timeout API, offline, clé invalide

---

## 🎯 Pour la démo

1. **Montre l'inscription** → formulaire avec validation
2. **Sélectionne 3 genres** → onboarding
3. **Navigue sur Home** → données TMDB en temps réel
4. **Recherche un film** → résultats instantanés
5. **Entre dans un film** → note-le 5 étoiles
6. **Va sur "Pour vous"** → montre que l'algorithme a changé
7. **Profil** → montre le graphique fl_chart
8. **Explique l'algorithme** → Jaccard + Wilson Score

---

*Projet réalisé dans le cadre du module Développement Mobile Cross-Plateforme — 2026*
