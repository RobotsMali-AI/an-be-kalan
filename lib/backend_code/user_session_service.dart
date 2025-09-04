import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Users.dart';
import 'semb_database.dart';

class UserSessionService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _localDb = DatabaseHelper();

  Users? _currentUser;
  String? _currentUserId;
  bool _isAuthenticated = false;
  bool _disposed = false;

  Users? get currentUser => _currentUser;
  String? get currentUserId => _currentUserId;
  bool get isAuthenticated => _isAuthenticated;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      try {
        super.notifyListeners();
      } catch (e) {
        print('UserSessionService: notifyListeners failed: $e');
      }
    }
  }

  // Initialize user session (called on app start)
  Future<void> initializeSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('current_user_id');
    bool? isAuth = prefs.getBool('is_authenticated');

    if (userId != null) {
      _currentUserId = userId;
      _isAuthenticated = isAuth ?? false;

      if (_isAuthenticated) {
        // Try to load from Firebase
        await _loadAuthenticatedUser(userId);
      } else {
        // Load from local database
        await _loadAnonymousUser(userId);
      }
    } else {
      // Create new anonymous user
      await createAnonymousUser();
    }

    notifyListeners();
  }

  // Create a new anonymous user
  Future<void> createAnonymousUser() async {
    try {
      // Create a new document in Firebase users collection
      DocumentReference docRef = await _firestore.collection('users').add({
        'downloadBooks': [],
        'completedBooks': [],
        'inProgressBooks': [],
        'favoriteBooks': [],
        'xpLog': [],
        'xp': 0,
        'totalReadingTime': 0,
        'isAuthenticated': false,
        'createdAt': DateTime.now().toIso8601String(),
        'displayName': 'Kalan-folo', // Anonymous learner in Bambara
      });

      // Use the Firebase document ID as the user ID
      String firebaseDocId = docRef.id;

      Users newUser = Users(
        uid: firebaseDocId,
        downloadBooks: [],
        completedBooks: [],
        inProgressBooks: [],
        favoriteBooks: [],
        xpLog: [],
        xp: 0,
        totalReadingTime: 0,
        isAuthenticated: false,
        createdAt: DateTime.now(),
        displayName: 'Kalan-folo', // Anonymous learner in Bambara
      );

      // Save locally
      await _localDb.insertUser(newUser);

      // Save session with Firebase document ID
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', firebaseDocId);
      await prefs.setBool('is_authenticated', false);

      _currentUser = newUser;
      _currentUserId = firebaseDocId;
      _isAuthenticated = false;

      _safeNotifyListeners();
    } catch (e) {
      print('Error creating anonymous user: $e');
      // Fallback to local-only user
      await _createLocalAnonymousUser();
    }
  }

  // Fallback method for creating local anonymous user
  Future<void> _createLocalAnonymousUser() async {
    String anonymousId = _generateAnonymousId();

    Users newUser = Users(
      uid: anonymousId,
      downloadBooks: [],
      completedBooks: [],
      inProgressBooks: [],
      favoriteBooks: [],
      xpLog: [],
      xp: 0,
      totalReadingTime: 0,
      isAuthenticated: false,
      createdAt: DateTime.now(),
      displayName: 'Kalan-folo',
    );

    // Save locally
    await _localDb.insertUser(newUser);

    // Save session
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', anonymousId);
    await prefs.setBool('is_authenticated', false);

    _currentUser = newUser;
    _currentUserId = anonymousId;
    _isAuthenticated = false;

    _safeNotifyListeners();
  }

  // Create account for anonymous user
  Future<Map<String, dynamic>> createAccount({
    required String emailOrPhone,
    required String password,
    String? displayName,
  }) async {
    try {
      // Check if email/phone already exists in any document
      QuerySnapshot existingQuery = await _firestore
          .collection('users')
          .where('email',
              isEqualTo: _isEmail(emailOrPhone) ? emailOrPhone : null)
          .where('phone',
              isEqualTo: _isEmail(emailOrPhone) ? null : emailOrPhone)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'Ni imɛli walima telefɔni nin bɛ kɛ ka baara la kɔrɔ',
          'messageEn': 'This email or phone is already in use'
        };
      }

      // Hash password
      String hashedPassword = _hashPassword(password);

      // Update current user data
      if (_currentUser != null && _currentUserId != null) {
        _currentUser!.email = _isEmail(emailOrPhone) ? emailOrPhone : null;
        _currentUser!.phone = _isEmail(emailOrPhone) ? null : emailOrPhone;
        _currentUser!.password = hashedPassword;
        _currentUser!.isAuthenticated = true;
        _currentUser!.displayName = displayName ?? _currentUser!.displayName;

        // Update the existing Firebase document (keep the same document ID)
        await _firestore.collection('users').doc(_currentUserId!).update({
          'email': _currentUser!.email,
          'phone': _currentUser!.phone,
          'password': hashedPassword,
          'isAuthenticated': true,
          'displayName': _currentUser!.displayName,
        });

        // Update local session to authenticated
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_authenticated', true);

        _isAuthenticated = true;

        _safeNotifyListeners();

        return {
          'success': true,
          'message': 'Jatebɔsɛbɛn dabɔra ka ɲɛ!',
          'messageEn': 'Account created successfully!'
        };
      }

      return {
        'success': false,
        'message': 'Fɛn dɔ ma ɲɛ',
        'messageEn': 'Something went wrong'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Fɛn dɔ ma ɲɛ: $e',
        'messageEn': 'Error: $e'
      };
    }
  }

  // Sign in with existing account
  Future<Map<String, dynamic>> signIn({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      // Search for user by email or phone
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where(_isEmail(emailOrPhone) ? 'email' : 'phone',
              isEqualTo: emailOrPhone.toLowerCase().trim())
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Jatebɔsɛbɛn ma sɔrɔ',
          'messageEn': 'Account not found'
        };
      }

      DocumentSnapshot doc = querySnapshot.docs.first;
      Users userData =
          Users.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);

      // Verify password
      if (!_verifyPassword(password, userData.password ?? '')) {
        return {
          'success': false,
          'message': 'Kɔdi ma bɛn',
          'messageEn': 'Incorrect password'
        };
      }

      // Merge with current anonymous data if exists
      if (_currentUser != null && !_isAuthenticated) {
        userData = _mergeUserData(_currentUser!, userData);
        await _firestore
            .collection('users')
            .doc(doc.id)
            .set(userData.toFirestore());
      }

      // Update session
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', doc.id);
      await prefs.setBool('is_authenticated', true);

      _currentUser = userData;
      _currentUserId = doc.id;
      _isAuthenticated = true;

      _safeNotifyListeners();

      return {
        'success': true,
        'message': 'I sera la ka ɲɛ!',
        'messageEn': 'Signed in successfully!'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Fɛn dɔ ma ɲɛ: $e',
        'messageEn': 'Error: $e'
      };
    }
  }

  // Sign out
  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
    await prefs.remove('is_authenticated');

    // Create new anonymous user
    await createAnonymousUser();
  }

  // Delete account
  Future<Map<String, dynamic>> deleteAccount({required String password}) async {
    try {
      if (_currentUser == null || _currentUserId == null) {
        return {
          'success': false,
          'message': 'Jatebɔsɛbɛn ma sɔrɔ',
          'messageEn': 'Account not found'
        };
      }

      // Check if user is authenticated (has password)
      if (_currentUser!.password == null || _currentUser!.password!.isEmpty) {
        return {
          'success': false,
          'message': 'Jatebɔsɛbɛn nin tɛ kɔdi ye',
          'messageEn': 'This account has no password'
        };
      }

      // Verify password
      if (!_verifyPassword(password, _currentUser!.password!)) {
        return {
          'success': false,
          'message': 'Kɔdi ma bɛn',
          'messageEn': 'Incorrect password'
        };
      }

      // Delete from Firebase
      await _firestore.collection('users').doc(_currentUserId!).delete();

      // Clear local session
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_id');
      await prefs.remove('is_authenticated');

      // Reset current user
      _currentUser = null;
      _currentUserId = null;
      _isAuthenticated = false;

      _safeNotifyListeners();

      return {
        'success': true,
        'message': 'Jatebɔsɛbɛn bɔra ka ɲɛ!',
        'messageEn': 'Account deleted successfully!'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Fɛn dɔ ma ɲɛ: $e',
        'messageEn': 'Error: $e'
      };
    }
  }

  // Update user data
  Future<void> updateUserData(Users userData) async {
    if (_isAuthenticated && _currentUserId != null) {
      await _firestore
          .collection('users')
          .doc(_currentUserId!)
          .set(userData.toFirestore());
    }

    // Always update locally
    await _localDb.updateUser(userData.toSemb());
    _currentUser = userData;
    _safeNotifyListeners();
  }

  // Private helper methods
  Future<void> _loadAuthenticatedUser(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _currentUser =
            Users.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
      }
    } catch (e) {
      // If failed to load from Firebase, try local
      await _loadAnonymousUser(userId);
    }
  }

  Future<void> _loadAnonymousUser(String userId) async {
    bool found = await _localDb.getUser(userId);
    if (found && _localDb.userData != null) {
      _currentUser = _localDb.userData;
    }
  }

  String _generateAnonymousId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return 'anon_${String.fromCharCodes(Iterable.generate(12, (_) => chars.codeUnitAt(random.nextInt(chars.length))))}';
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password + 'an_be_kalan_salt'); // Salt for security
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool _verifyPassword(String password, String hashedPassword) {
    return _hashPassword(password) == hashedPassword;
  }

  bool _isEmail(String input) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(input);
  }

  Users _mergeUserData(Users anonymousData, Users authenticatedData) {
    // Merge anonymous user data with authenticated user data
    // Prioritize anonymous data for progress, authenticated data for profile
    return Users(
      uid: authenticatedData.uid,
      downloadBooks: [
        ...authenticatedData.downloadBooks,
        ...anonymousData.downloadBooks
      ],
      completedBooks: [
        ...authenticatedData.completedBooks,
        ...anonymousData.completedBooks
      ],
      inProgressBooks: [
        ...authenticatedData.inProgressBooks,
        ...anonymousData.inProgressBooks
      ],
      favoriteBooks: [
        ...authenticatedData.favoriteBooks,
        ...anonymousData.favoriteBooks
      ],
      xpLog: [...authenticatedData.xpLog, ...anonymousData.xpLog],
      xp: authenticatedData.xp + anonymousData.xp,
      totalReadingTime:
          authenticatedData.totalReadingTime + anonymousData.totalReadingTime,
      email: authenticatedData.email,
      phone: authenticatedData.phone,
      password: authenticatedData.password,
      isAuthenticated: true,
      createdAt: authenticatedData.createdAt,
      displayName: authenticatedData.displayName,
      birth_date: authenticatedData.birth_date,
    );
  }
}
