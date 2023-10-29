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
  Future<void> createNote(NoteModel note, String masterPassword) async {
    try {
      await _db.collection("Users").doc(checkUserId).collection("Notes").add(note.toJson(masterPassword));
    } catch (e) {
      throw handleFirebaseErrors(e);
    }
  }

  /// Fetch specific note details by title
  Future<NoteModel> getNoteDetails(String noteTitle, String masterPassword) async {
    try {
      final snapshot = await _db.collection("Users").doc(checkUserId).collection("Notes").where("NoteTitle", isEqualTo: noteTitle).get();
      if (snapshot.docs.isEmpty) throw 'No such note found';
      return NoteModel.fromSnapshot(snapshot.docs.first, masterPassword);
    } catch (e) {
      throw handleFirebaseErrors(e);
    }
  }

  /// Update Note
  Future<void> updateNoteRecord(NoteModel note, String masterPassword) async {
    Map<String, dynamic> noteData = note.toJson(masterPassword);
    try {
      if (note.noteDetails.isEmpty) {
        // Explicitly delete the fields if noteDetails are empty
        await _db.collection("Users").doc(checkUserId).collection("Notes").doc(note.id).update({
          "NoteDetails": FieldValue.delete(),
          "NoteDetailsIV": FieldValue.delete()
        });
        await _db.collection("Users").doc(checkUserId).collection("Notes").doc(note.id).update(noteData);
      } else {
        await _db.collection("Users").doc(checkUserId).collection("Notes").doc(note.id).update(noteData);
      }
    } catch (e) {
      if (e is FirebaseException && e.code == "not-found") {
        // If the document doesn't exist, then create it.
        await _db.collection("Users").doc(checkUserId).collection("Notes").doc(note.id).set(noteData);
      } else {
        throw handleFirebaseErrors(e);
      }
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
  Future<NoteModel?> getNoteByTitle(String noteTitle, String masterPassword) async {
    try {
      final snapshot = await _db.collection("Users").doc(checkUserId).collection("Notes").where("NoteTitle", isEqualTo: noteTitle).get();
      if (snapshot.docs.isEmpty) return null;
      return NoteModel.fromSnapshot(snapshot.docs.first, masterPassword);
    } catch (e) {
        throw e.toString();
    }
  }

  // Fetch all notes
  Future<List<NoteModel>> getAllNotes(String masterPassword) async {
    try {
      final snapshot = await _db.collection("Users").doc(checkUserId).collection("Notes").get();
      return snapshot.docs.map((doc) => NoteModel.fromSnapshot(doc, masterPassword)).toList();
    } catch (e) {
      throw handleFirebaseErrors(e);
    }
  }

  // Stream to listen to all notes
  Stream<List<NoteModel>> listenToAllNotes(String masterPassword) {
    return _db.collection("Users").doc(checkUserId).collection("Notes").snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) => NoteModel.fromSnapshot(doc, masterPassword)).toList();
    });
  }
}
