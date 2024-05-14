import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   static Future<User?> signInAnonymously() async {
    try {
      UserCredential result = await FirebaseAuth.instance.signInAnonymously();
      User? user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Get the UID
      String uid = userCredential.user!.uid;

      // Get the ID token
      String? idToken = await userCredential.user!.getIdToken();

      // Print the token and UID
      print('Token: $idToken');
      print('UID: $uid');

      // Save user information to Firestore
      await _firestore.collection('Users').doc(uid).set({
        'uid': uid,
        'email': email,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }


  Future<UserCredential> signUpWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> logout() async {
    return await _auth.signOut();
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   User? getCurrentUser() {
//     return _auth.currentUser;
//   }
//
//   Future<UserCredential> signInWithEmailPassword(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       await _updateUserCollection(userCredential.user!.uid, email);
//       return userCredential;
//     } on FirebaseAuthException catch (e) {
//       throw Exception(e.code);
//     }
//   }
//
//   Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       await _updateUserCollection(userCredential.user!.uid, email);
//       return userCredential;
//     } on FirebaseAuthException catch (e) {
//       throw Exception(e.code);
//     }
//   }
//
//   Future<void> logout() async {
//     await _auth.signOut();
//   }
//
//   Future<void> _updateUserCollection(String uid, String email) async {
//     await _firestore.collection('Users').doc(uid).set({
//       'uid': uid,
//       'email': email,
//     });
//   }
// }
