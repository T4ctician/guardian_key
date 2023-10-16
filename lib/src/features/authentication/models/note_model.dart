import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String? id;
  final String noteTitle;    // Title of the note
  final String noteDetails;  // Details or content of the note

  /// Constructor
  const NoteModel({
    this.id,
    required this.noteTitle,
    required this.noteDetails,
  });

  /// Convert model to Json structure so that you can use it to store data in Firebase
  Map<String, dynamic> toJson() {
    return {
      "NoteTitle": noteTitle,
      "NoteDetails": noteDetails,
    };
  }

  /// Map Json oriented document snapshot from Firebase to NoteModel
  factory NoteModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document){
    final data = document.data()!;
    return NoteModel(
      id: document.id,
      noteTitle: data["NoteTitle"],
      noteDetails: data["NoteDetails"],
    );
  }
}
