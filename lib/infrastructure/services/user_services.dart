import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> addUser(UserModel model) async {
    final uid = model.userId.toString();

    if (uid.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(model.toJson());
    } else {
      throw Exception("Invalid uid");
    }
  }


  Stream<UserModel> fetchUserRecord(String userID) {
    return FirebaseFirestore.instance
        .collection("users")
        .where('uid', isEqualTo: userID)
        .snapshots()
        .map(
            (userData) => UserModel.fromJson(userData as Map<String, dynamic>));
  }


  Future<UserModel> getUserData(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        // Convert the Firestore data to a UserModel object ]
        UserModel user = UserModel.fromJson(userSnapshot.data() as Map<String, dynamic>);
        return user;
      } else {
        // Handle the case where the user document doesn't exist.
        throw Exception("User not found");
      }
    } catch (e) {
      // Handle any errors that occur during the process.
      print("Error getting user data: $e");
      throw e;
    }
  }
  //
  // Future<UserModel> getUserData(String userId) async {
  //   try {
  //     DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
  //
  //     if (userDoc.exists) {
  //       String userId = userDoc['userId'];
  //       String pin = userDoc['pin'];
  //
  //       return UserModel(userId: userId, pin: pin);
  //     } else {
  //       throw Exception("User not found");
  //     }
  //   } catch (e) {
  //     throw e;
  //   }
  // }

  Future updateUserBalance({required double balance}) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
      "balance": balance,
    });
  }

}
