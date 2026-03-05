# Kigali City Services & Places Directory

A Flutter mobile application that helps Kigali residents locate and navigate to essential public services and leisure locations.

## Features

- **Firebase Authentication** – Email/password sign up, login, logout, with enforced email verification
- **Cloud Firestore CRUD** – Create, read, update, delete service/location listings in real time
- **Search & Filtering** – Search by name, filter by category (Hospital, Café, Park, etc.)
- **Google Maps Integration** – Embedded map with markers on the detail page; launch turn-by-turn navigation
- **Map View** – Browse all listings on a city-wide map with selectable markers
- **State Management (Provider)** – All Firestore operations go through a service layer and are exposed via `AuthProvider` and `ListingProvider`
- **Bottom Navigation** – Directory, My Listings, Map View, Settings
- **Settings** – User profile display + location notification toggle

## Firestore Database Structure

```
/users/{uid}
  - email: string
  - displayName: string
  - createdAt: timestamp
  - notificationsEnabled: boolean

/listings/{listingId}
  - name: string
  - category: string  (Hospital | Police Station | Library | Restaurant | Café | Park | Tourist Attraction | ...)
  - address: string
  - contactNumber: string
  - description: string
  - latitude: number
  - longitude: number
  - createdBy: string  (user UID)
  - timestamp: timestamp
  - rating: number?
  - reviewCount: number?
```

## State Management

**Provider** is used throughout:

- `AuthProvider` – wraps `AuthService`, listens to Firebase Auth state changes, exposes `AuthStatus`, handles sign up/in/out, email verification polling, and notification preference updates.
- `ListingProvider` – wraps `ListingService`, maintains real-time Firestore streams for all listings and user-specific listings, manages search/filter state, and performs CRUD operations. **No Firestore calls appear in UI widgets.**

### Data flow:
```
FirebaseFirestore → ListingService (stream) → ListingProvider (state) → UI widgets (Consumer)
```

## Project Structure

```
lib/
├── main.dart               # App entry, MultiProvider setup, AuthGate
├── home_screen.dart        # BottomNavigationBar wrapper
├── theme.dart              # AppColors, AppTheme
├── firebase_options.dart   # Firebase credentials (replace with yours)
├── models/
│   ├── listing.dart        # Listing model + fromFirestore/toFirestore
│   └── user_profile.dart   # UserProfile model
├── services/
│   ├── auth_service.dart   # Firebase Auth + Firestore user ops
│   └── listing_service.dart # Firestore CRUD + real-time streams
├── providers/
│   ├── auth_provider.dart  # Auth state management
│   └── listing_provider.dart # Listing state management
└── screens/
    ├── auth/
    │   ├── login_screen.dart
    │   ├── signup_screen.dart
    │   └── verify_email_screen.dart
    ├── directory/
    │   ├── directory_screen.dart   # Browse + search + filter
    │   └── add_listing_screen.dart # Create / edit listing
    ├── my_listings/
    │   └── my_listings_screen.dart
    ├── map_view/
    │   └── map_view_screen.dart
    ├── settings/
    │   └── settings_screen.dart
    └── detail/
        └── detail_screen.dart      # Full info + embedded map + navigate
```

## Setup

### Prerequisites
- Flutter SDK ≥ 3.0.0
- A Firebase project with Authentication and Firestore enabled
- Google Maps API key (Android & iOS)

### Steps

1. **Clone the repo**
   ```bash
   git clone https://github.com/YOUR_USERNAME/kigali-city-directory.git
   cd kigali-city-directory
   ```

2. **Install FlutterFire CLI and configure Firebase**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` with your credentials.

3. **Add Google Maps API key**

   *Android* – `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data android:name="com.google.android.geo.API_KEY"
              android:value="YOUR_MAPS_API_KEY"/>
   ```

   *iOS* – `ios/Runner/AppDelegate.swift`:
   ```swift
   GMSServices.provideAPIKey("YOUR_MAPS_API_KEY")
   ```

4. **Set Firestore Security Rules**
   Copy `firestore.rules` to your Firebase Console → Firestore → Rules.

5. **Install dependencies**
   ```bash
   flutter pub get
   ```

6. **Run on device/emulator**
   ```bash
   flutter run
   ```

## Important Notes

- The app **enforces email verification** – users cannot access the main directory until they verify their email.
- Only the listing **creator** can edit or delete their own listings (enforced both in UI and Firestore rules).
- Real-time Firestore listeners ensure the UI updates automatically without manual refresh.
