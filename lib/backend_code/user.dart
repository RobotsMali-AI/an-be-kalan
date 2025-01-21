// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../models/Users.dart';

// /// Function to save user data as a Firebase database collection
// Future<void> saveUserData(String uid, Users userData) async {
//   await FirebaseFirestore.instance
//       .collection('users')
//       .doc(uid)
//       .set(userData.toFirestore(), SetOptions(merge: true));
// }

// /// Function that retrieves a specific user data from
// Future<Users> getUserData(String uid) async {
//   DocumentSnapshot doc =
//       await FirebaseFirestore.instance.collection('users').doc(uid).get();
//   return doc.exists
//       ? Users.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)
//       : createUserData(uid);
// }

// /// Deleting a User data from the collection
// Future<void> deleteUserData(String uid) async {
//   await FirebaseFirestore.instance.collection('users').doc(uid).delete();
// }

// /// Function that creates and save empty user data dictionary for new user
// Users createUserData(String uid) {
//   Users userData = Users(completedBooks: [], inProgressBooks: [], xp: 0);

//   // Save user data to Firestore
//   saveUserData(uid, userData); // Ensure it's saved before returning
//   return userData;
// }
