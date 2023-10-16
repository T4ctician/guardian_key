import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/models/note_model.dart';  // Note: Adjust the import path
import 'package:guardian_key/src/repository/exceptions/t_exceptions.dart';

class NoteRepository extends GetxController {
  static NoteRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  // Get the user's UID dynamically
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // Check if the user is logged in
  String get checkUserId {
    final uid = userId;
    if (uid == null) throw Exception('No user logged in.');
    return uid;
  }

  /// Store note data
  Future<void> createNote(NoteModel note) async {
    try {
      await _db.collection("Users").doc(checkUserId).collection("Notes").add(note.toJson());
    } catch (e) {
      throw handleFirebaseErrors(e);
    }
  }

  /// Fetch specific note details by title
  Future<NoteModel> getNoteDetails(String noteTitle) async {
    try {
      final snapshot = await _db.collection("Users").doc(checkUserId).collection("Notes").where("NoteTitle", isEqualTo: noteTitle).get();
      if (snapshot.docs.isEmpty) throw 'No such note found';
      return NoteModel.fromSnapshot(snapshot.docs.first);
    } catch (e) {
      throw handleFirebaseErrors(e);
    }
  }

  /// Update Note
  Future<void> updateNoteRecord(NoteModel note) async {
    try {
      await _db.collection("Users").doc(checkUserId).collection("Notes").doc(note.id).update(note.toJson());
    } catch (e) {
      throw handleFirebaseErrors(e);
    }
  }

  /// Handle Firebase Errors
  Exception handleFirebaseErrors(dynamic e) {
    if (e is FirebaseAuthException) {
      final result = TExceptions.fromCode(e.code);
      return Exception(result.message);
    } else if (e is FirebaseException) {
      return Exception(e.message.toString());
    } else {
      return Exception(e.toString().isEmpty ? 'Something went wrong. Please Try Again' : e.toString());
    }
  }

  /// Delete Note
  Future<void> deleteNote(String id) async {
    try {
      await _db.collection("Users").doc(checkUserId).collection("Notes").doc(id).delete();
    } on FirebaseAuthException catch (e) {
      final result = TExceptions.fromCode(e.code);
      throw result.message;
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } catch (_) {
      throw 'Something went wrong. Please Try Again';
    }
  }

  // Fetch a note by title
  Future<NoteModel?> getNoteByTitle(String noteTitle) async {
    try {
      final snapshot = await _db.collection("Users").doc(checkUserId).collection("Notes").where("NoteTitle", isEqualTo: noteTitle).get();
      if (snapshot.docs.isEmpty) return null;
      return NoteModel.fromSnapshot(snapshot.docs.first);
    } catch (e) {
        throw e.toString();
    }
  }

  // Fetch all notes
  Future<List<NoteModel>> getAllNotes() async {
    try {
      final snapshot = await _db.collection("Users").doc(checkUserId).collection("Notes").get();
      return snapshot.docs.map((doc) => NoteModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw handleFirebaseErrors(e);
    }
  }

  // Stream to listen to all notes
  Stream<List<NoteModel>> listenToAllNotes() {
    return _db.collection("Users").doc(checkUserId).collection("Notes").snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) => NoteModel.fromSnapshot(doc)).toList();
    });
  }
}
