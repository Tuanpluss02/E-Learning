import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_bloc/repositories/user_repository/user_base.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../configs/api_path.dart';
import '../../models/models.dart';

class UserRepository implements UserBase {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  UserRepository({
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  @override
  Future<User> getProfile({required String uid}) async {
    try {
      final DocumentSnapshot userDoc =
          await firebaseFirestore.collection(ApiPath.user()).doc(uid).get();

      if (userDoc.exists) {
        final currentUser = User.fromDoc(userDoc);
        return currentUser;
      }

      throw 'User not found';
    } on FirebaseException catch (e) {
      throw CustomError(
        code: e.code,
        message: e.message!,
        plugin: e.plugin,
      );
    } catch (e) {
      throw CustomError(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }

  @override
  Future<List<MyLearning>> getListMyLearning({required String uid}) async {
    try {
      List<MyLearning> list = [];

      await firebaseFirestore
          .collection(ApiPath.user())
          .doc(uid)
          .collection(ApiPath.myLearning())
          .get()
          .then((value) {
        for (var element in value.docs) {
          list.add(MyLearning.fromDoc(element));
        }
      });

      return list;
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }

  @override
  Future<void> updateProfile({required User user}) async {
    try {
      await firebaseFirestore.collection(ApiPath.user()).doc(user.id).update({
        'name': user.name,
        'profileImage': user.profileImage,
      });
    } catch (e) {
      throw CustomError(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }

  @override
  Future<String> uploadImageToStorage({required File file}) async {
    Reference ref = firebaseStorage
        .ref()
        .child(ApiPath.userImages())
        .child(DateTime.now().toString());
    final uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();

    return imageUrl;
  }

  @override
  Future<void> updateFavoriteTeacherByUser({
    required String userID,
    required String teacherID,
  }) async {
    try {
      await firebaseFirestore.collection(ApiPath.user()).doc(userID).update({
        'favorites_teacher': FieldValue.arrayUnion([teacherID]),
      });
    } catch (e) {
      throw CustomError(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }

  @override
  Future<void> deleteFavoriteTeacherByUser({
    required String userID,
    required String teacherID,
  }) async {
    try {
      await firebaseFirestore.collection(ApiPath.user()).doc(userID).update({
        'favorites_teacher': FieldValue.arrayRemove([teacherID]),
      });
    } catch (e) {
      throw CustomError(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }

  @override
  Future<void> updateFavoriteCourseByUser({
    required String userID,
    required String productID,
  }) async {
    try {
      await firebaseFirestore.collection(ApiPath.user()).doc(userID).update({
        'favorites_course': FieldValue.arrayUnion([productID]),
      });
    } catch (e) {
      throw CustomError(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }

  @override
  Future<void> deleteFavoriteCourseByUser({
    required String userID,
    required String productID,
  }) async {
    try {
      await firebaseFirestore.collection(ApiPath.user()).doc(userID).update({
        'favorites_course': FieldValue.arrayRemove([productID]),
      });
    } catch (e) {
      throw CustomError(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }

  @override
  Future<Product> getProductByID({required String id}) async {
    try {
      final productDoc =
          await firebaseFirestore.collection(ApiPath.product()).doc(id).get();

      final currentProduct = Product.fromDoc(productDoc);
      return currentProduct;
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }

  @override
  Future<void> updateMyLearningByUser({
    required String userID,
    required List<String> listVideo,
    required String productID,
    required int progress,
  }) async {
    try {
      await firebaseFirestore
          .collection(ApiPath.user())
          .doc(userID)
          .collection(ApiPath.myLearning())
          .doc(productID)
          .set({'progress': progress});

      for (var i = 0; i < listVideo.length; i++) {
        await firebaseFirestore
            .collection(ApiPath.user())
            .doc(userID)
            .collection(ApiPath.myLearning())
            .doc(productID)
            .collection(ApiPath.listVideoProgress())
            .doc(listVideo[i])
            .set({'progress': progress});
      }
    } catch (e) {
      throw CustomError(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }

  @override
  Future<List<VideoProgress>> getListVideoProgressFromUser({
    required String userID,
    required String productID,
  }) async {
    try {
      List<VideoProgress> list = [];

      await firebaseFirestore
          .collection(ApiPath.user())
          .doc(userID)
          .collection(ApiPath.myLearning())
          .doc(productID)
          .collection(ApiPath.listVideoProgress())
          .get()
          .then((value) {
        for (var element in value.docs) {
          list.add(VideoProgress.fromDoc(element));
        }
      });

      return list;
    } on FirebaseException catch (e) {
      throw CustomError(code: e.code, message: e.message!, plugin: e.plugin);
    } catch (e) {
      throw CustomError(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }

  @override
  Future<void> updateVideoProgress({
    required String userID,
    required String productID,
    required String videoID,
    required int progress,
  }) async {
    try {
      await firebaseFirestore
          .collection(ApiPath.user())
          .doc(userID)
          .collection(ApiPath.myLearning())
          .doc(productID)
          .collection(ApiPath.listVideoProgress())
          .doc(videoID)
          .set({'progress': progress});
    } catch (e) {
      throw CustomError(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }

  @override
  Future<void> updateTotalProgress({
    required String userID,
    required String productID,
    required int progress,
  }) async {
    try {
      await firebaseFirestore
          .collection(ApiPath.user())
          .doc(userID)
          .collection(ApiPath.myLearning())
          .doc(productID)
          .set({'progress': progress});
    } catch (e) {
      throw CustomError(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }
}
