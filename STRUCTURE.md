# Struktur Folder Flutter Project dengan BLoC, API Integration, dan SharedPreferences

## 📁 Struktur Folder

```
lib/
├── core/                          # Core functionality
│   ├── constants/                 # Constants (colors, strings, dll)
│   │   └── app_colors.dart
│   ├── di/                        # Dependency Injection
│   │   └── injection_container.dart
│   ├── network/                   # Network layer
│   │   ├── api_client.dart        # Dio client wrapper
│   │   ├── api_endpoints.dart     # API endpoints constants
│   │   ├── api_exception.dart     # Custom exception handling
│   │   └── interceptors/          # Dio interceptors
│   │       ├── auth_interceptor.dart    # Token interceptor
│   │       └── logging_interceptor.dart  # Request/response logging
│   ├── storage/                   # Local storage (SharedPreferences)
│   │   ├── storage_keys.dart      # Keys untuk SharedPreferences
│   │   └── storage_service.dart   # Service untuk manage SharedPreferences
│   └── utils/                     # Utility functions
│       └── result.dart            # Either result helper
│
├── data/                          # Data layer
│   ├── datasources/               # Data sources
│   │   ├── local/                 # Local data sources (SharedPreferences, SQLite, dll)
│   │   │   └── auth_local_datasource.dart
│   │   └── remote/                # Remote data sources (API)
│   │       └── auth_remote_datasource.dart
│   ├── models/                    # Data models (JSON serialization)
│   │   └── auth/
│   │       └── auth_response_model.dart
│   └── repositories/              # Repository implementations
│       └── auth_repository.dart
│
├── domain/                        # Domain layer (business logic)
│   ├── entities/                  # Domain entities
│   │   ├── user.dart
│   │   └── failure.dart           # Error handling
│   └── usecases/                  # Use cases (optional)
│
├── presentation/                  # Presentation layer (UI)
│   └── bloc/                      # BLoC state management
│       └── auth/
│           ├── auth_bloc.dart     # BLoC logic
│           ├── auth_event.dart    # Events
│           └── auth_state.dart    # States
│
└── main.dart                      # Entry point
```

## 🔧 Dependencies yang Digunakan

### State Management
- `flutter_bloc: ^8.1.6` - BLoC pattern untuk state management
- `equatable: ^2.0.5` - Value equality untuk states dan events

### Local Storage
- `shared_preferences: ^2.3.2` - Untuk menyimpan token dan data user

### HTTP Client
- `dio: ^5.7.0` - HTTP client dengan interceptors
- `pretty_dio_logger: ^1.4.0` - Logging untuk debugging (optional)

### Functional Programming
- `dartz: ^0.10.1` - Either type untuk error handling

### Dependency Injection
- `get_it: ^8.0.2` - Service locator untuk DI

## 🚀 Cara Menggunakan

### 1. Initialize Storage Service
Storage service sudah di-initialize di `main.dart` melalui dependency injection.

### 2. Menggunakan Auth BLoC

```dart
// Di widget Anda
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    }
    if (state is AuthAuthenticated) {
      return HomePage();
    }
    if (state is AuthUnauthenticated) {
      return LoginPage();
    }
    if (state is AuthError) {
      return Text('Error: ${state.message}');
    }
    return SizedBox();
  },
)

// Dispatch event
context.read<AuthBloc>().add(
  LoginEvent(email: 'user@example.com', password: 'password'),
);
```

### 3. Menggunakan Storage Service

```dart
final storageService = StorageService.instance;

// Simpan token
await storageService.saveAccessToken('your_token_here');

// Ambil token
final token = storageService.getAccessToken();

// Simpan semua data user
await storageService.saveUserData(
  accessToken: 'access_token',
  refreshToken: 'refresh_token',
  userId: 'user_id',
  email: 'user@example.com',
  name: 'User Name',
);

// Clear data (logout)
await storageService.clearUserData();
```

### 4. Menggunakan API Client

```dart
final apiClient = ApiClient();

// GET request
final response = await apiClient.get('/endpoint');

// POST request
final response = await apiClient.post(
  '/endpoint',
  data: {'key': 'value'},
);
```

## 📝 Catatan Penting

1. **Base URL**: Update `ApiEndpoints.baseUrl` di `lib/core/network/api_endpoints.dart` dengan URL API Anda.

2. **Token Management**: Token secara otomatis ditambahkan ke header request melalui `AuthInterceptor`.

3. **Error Handling**: Semua error dari API akan di-convert menjadi `ApiException` dan kemudian menjadi `Failure` di repository.

4. **Refresh Token**: Implementasi refresh token dapat ditambahkan di `AuthInterceptor.onError` untuk handle 401 errors.

5. **Dependency Injection**: Semua dependencies sudah di-setup di `injection_container.dart`. Tambahkan dependencies baru di sana.

## 🔐 Keamanan

- Token disimpan menggunakan SharedPreferences (secure storage dapat ditambahkan untuk production)
- Token otomatis ditambahkan ke setiap request melalui interceptor
- Token dihapus saat logout

## 📚 Pattern yang Digunakan

- **Clean Architecture**: Separation of concerns dengan layer domain, data, dan presentation
- **Repository Pattern**: Abstraction untuk data sources
- **BLoC Pattern**: State management yang reactive
- **Dependency Injection**: Loose coupling dengan GetIt

