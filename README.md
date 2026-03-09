# Kigali City Services & Places Directory

A Flutter mobile application that helps Kigali residents locate and navigate to essential public services and leisure locations.

## Features

- **Firebase Authentication** – Email/password sign up, login, logout, with enforced email verification before accessing the app
- **Cloud Firestore CRUD** – Create, read, update, and delete service/location listings in real time
- **Search & Filtering** – Search listings by name and filter by category with instant results
- **Google Maps Integration** – Embedded map with a marker on the detail page; launch turn-by-turn navigation via Google Maps
- **Map View** – City-wide map showing all listing markers
- **State Management (Provider)** – All Firestore operations go through a dedicated service layer exposed via ChangeNotifier providers. No direct Firebase calls in UI widgets.
- **Bottom Navigation** – Directory, My Listings, Map View, Settings
- **Settings** – Authenticated user profile display and notification preference toggle

---

## Firestore Database Structure

```
/users/{uid}
  - email: string
  - displayName: string
  - createdAt: timestamp
  - notificationsEnabled: boolean

/listings/{listingId}
  - name: string
  - category: string  (Hospital | Police Station | Library | Restaurant | Café | Park | Tourist Attraction | Pharmacy | School | Bank)
  - address: string
  - contactNumber: string
  - description: string
  - latitude: number
  - longitude: number
  - createdBy: string  (user UID)
  - timestamp: timestamp
```

Listings are stored as a flat top-level collection rather than subcollections under users. This allows a single Firestore stream to power the shared Directory screen, while user-specific listings are filtered with a `.where('createdBy', isEqualTo: uid)` query. A composite index on `createdBy (Ascending)` + `timestamp (Descending)` is required for this query.

---

## State Management

**Provider** with **ChangeNotifier** is used throughout the application.

### Data Flow
```
Firebase Auth / Firestore
        ↓
  Service Layer
  (auth_service.dart, listing_service.dart)
        ↓
  Provider Layer
  (auth_provider.dart, listing_provider.dart)
        ↓
  UI Widgets (Consumer / context.watch)
```

### AuthProvider
Listens to Firebase Auth state changes via a stream subscription. Exposes an `AuthStatus` enum (`initial`, `loading`, `authenticated`, `unauthenticated`, `emailNotVerified`, `error`). The `_AuthGate` widget in `main.dart` rebuilds automatically as auth status changes, routing the user to the correct screen. Email verification is enforced by polling `user.reload()` every 3 seconds from the `VerifyEmailScreen`.

### ListingProvider
Maintains two real-time Firestore streams: one for all listings (Directory screen) and one filtered by the current user's UID (My Listings screen). Both use Firestore's `snapshots()` API for automatic UI updates. A `reset()` method clears all state and cancels subscriptions on sign-out to prevent cross-account data leakage.

---

## Project Structure

```
lib/
├── main.dart               # App entry, MultiProvider setup, AuthGate
├── home_screen.dart        # BottomNavigationBar (IndexedStack)
├── theme.dart              # AppColors, AppTheme
├── firebase_options.dart   # Firebase credentials (not committed to repo)
├── models/
│   ├── listing.dart        # Listing model + fromFirestore/toFirestore
│   └── user_profile.dart   # UserProfile model
├── services/
│   ├── auth_service.dart   # Firebase Auth + Firestore user operations
│   └── listing_service.dart # Firestore CRUD + real-time streams
├── providers/
│   ├── auth_provider.dart  # Auth state (AuthStatus enum, sign in/out/up)
│   └── listing_provider.dart # Listing state (streams, CRUD, search/filter)
└── screens/
    ├── auth/
    │   ├── login_screen.dart
    │   ├── signup_screen.dart
    │   └── verify_email_screen.dart
    ├── directory/
    │   ├── directory_screen.dart    # Browse + search + filter
    │   └── add_listing_screen.dart  # Create / edit listing
    ├── my_listings/
    │   └── my_listings_screen.dart
    ├── map_view/
    │   └── map_view_screen.dart
    ├── settings/
    │   └── settings_screen.dart
    └── detail/
        └── detail_screen.dart       # Full info + map + directions
```

---

## Setup Instructions

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Android Studio with an Android emulator (API 21+)
- A Firebase project with Authentication and Firestore enabled
- Google Maps API key with Maps SDK for Android enabled

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/teddy-2004/kigali-city-app.git
   cd kigali-app
   ```

2. **Configure Firebase**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
   ```
   This generates `lib/firebase_options.dart` with your credentials.

3. **Add Google Maps API key**

   In `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_MAPS_API_KEY"/>
   ```

4. **Enable Firebase services**
   - Firebase Console → Authentication → Sign-in method → Enable Email/Password
   - Firebase Console → Firestore Database → Create database → Start in test mode

5. **Create Firestore composite index**
   - Firebase Console → Firestore → Indexes → Add composite index
   - Collection: `listings`, Fields: `createdBy` (Asc) + `timestamp` (Desc)

6. **Register SHA-1 fingerprint**
   ```bash
   cd android && ./gradlew signingReport
   ```
   Copy the SHA-1 value and add it in Firebase Console → Project Settings → Your Apps → Android App → Add Fingerprint.

7. **Install dependencies and run**
   ```bash
   flutter pub get
   flutter run
   ```

---

## Security Notes

- `google-services.json` and `lib/firebase_options.dart` are excluded from this repository via `.gitignore`
- Firestore security rules enforce that only authenticated users can create listings, and only the listing creator can update or delete their own listings
- Email verification is enforced before any authenticated access is granted

---

## Important Notes

- Run on an Android emulator or physical Android device. Browser execution is not supported.
- The app enforces email verification — users cannot access the directory until their email is verified.
- Only the listing creator can edit or delete their own listings (enforced in both UI and Firestore rules).