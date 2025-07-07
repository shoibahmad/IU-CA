# IU-CA

IU-CA is a Flutter-based student-centric application, integrated with Firebase, designed to provide university students with seamless access to their profile, educational resources, notifications, and administrative controls. The system features robust authentication, user management, and a notification system for both students and administrators.

---

---

## Features

- **User Authentication:** Secure registration, login, and password reset via Firebase Auth.
- **Profile Management:** Users can view their complete profile and verify their information.
- **URL Redirects:** Centralized links to educational content and important student resources.
- **Notifications:** Real-time notifications powered by Firebase Messaging with a bottom notification sheet for read/unread management.
- **Admin Panel:** Admins can view active/logged-in users, manage user lists, and send targeted notifications.
- **Logout Confirmation:** User-friendly logout alert dialog with identity verification.

---

## Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend & Auth:** Firebase (Firestore, Firebase Auth, Firebase Messaging)
- **Other Libraries:** 
  - `get` (state management)
  - `firebase_ui_auth`, `firebase_ui_oauth_google`
  - `url_launcher`, `flutter_local_notifications`
  - `shared_preferences`, `cached_network_image`, `image_picker`
  - Custom navigation bars and notification UI components

See [pubspec.yaml](https://github.com/shoibahmad/IU-CA/blob/main/pubspec.yaml) for a full dependency list.

---

## Screens & Core Functionality

### 1. Home
- **Central Hub:** Main landing/dashboard for users.
- **Content:** Displays user profile, quick-access links, and announcements.
- **URL Redirects:** Buttons for educational and student services.

### 2. Registration
- **Form:** New user onboarding, collecting name, email, password, etc.
- **Secure Storage:** Data saved securely in Firebase.

### 3. Password Reset
- **Recovery:** Users receive a reset link via registered email.

### 4. Logout Alert Dialogue
- **Confirmation:** Ensures intentional logout, optionally displays user info.

### 5. Profile Section
- **Display:** Shows complete user profile post-login.

### 6. URL Redirect Section
- **Organized:** Curated links to student-focused resources.

### 7. Bottom Notification Sheet
- **Notifications:** All received from admin, separated by read/unread.
- **Mark as Read:** Manage notification status efficiently.

---

## Admin Panel

- **Access:** Restricted to admin credentials.
- **Features:**
  - View real-time number of logged-in users (from Firebase).
  - View full user list with details (name, enrollment, etc.).
  - Send notifications to students (title + body).
  - Monitor all sent notifications in a dedicated bottom sheet.

---

## Setup & Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/shoibahmad/IU-CA.git
   cd IU-CA
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Firebase Configuration:**
   - Add your `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS) to the respective directories.
   - Review and configure `firebase.json` and Firestore rules as needed.

4. **Run the app:**
   ```sh
   flutter run
   ```

---

## Usage

- **User:** Register or log in, update/view profile, access student resources, and receive notifications.
- **Admin:** Log in via admin credentials, monitor user activity, and send/track notifications.

---

## Contributing

Contributions are welcome! Please open an issue or pull request for feature requests, bug fixes, or enhancements.

1. Fork the repository
2. Create a new branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Contact

For questions or support, please contact the repository owner via [GitHub](https://github.com/shoibahmad).

---

> _Note: This README is generated based on partial repository analysis and your feature outline. Please customize further if needed! For full code structure, visit the [project repository](https://github.com/shoibahmad/IU-CA)._ 
