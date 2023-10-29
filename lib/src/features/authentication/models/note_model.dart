import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardian_key/src/services/encryption_service.dart';

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
  Map<String, dynamic> toJson(String masterPassword) {
      final encryptionService = EncryptionService();
      
      final encryptedNoteTitle = encryptionService.encryptData(noteTitle, masterPassword);

      Map<String, dynamic> data = {
        "NoteTitle": encryptedNoteTitle['encryptedText'],
        "NoteTitleIV": encryptedNoteTitle['iv'],
      };

      if (noteDetails.isNotEmpty) {
        final encryptedNoteDetails = encryptionService.encryptData(noteDetails, masterPassword);
        data["NoteDetails"] = encryptedNoteDetails['encryptedText'];
        data["NoteDetailsIV"] = encryptedNoteDetails['iv'];
      }

      return data;
  }


  /// Map Json oriented document snapshot from Firebase to NoteModel
  factory NoteModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document, String masterPassword) {

    final data = document.data()!;
    final encryptionService = EncryptionService();
    
    print(data);
    String noteTitle, noteDetails;

    try {
      noteTitle = encryptionService.decryptData(data["NoteTitle"], masterPassword, data["NoteTitleIV"]);
      
      // Only attempt to decrypt the noteDetails if its IV is present
      if (data.containsKey("NoteDetailsIV") && (data["NoteDetailsIV"]?.isNotEmpty ?? false)) {
        noteDetails = encryptionService.decryptData(data["NoteDetails"], masterPassword, data["NoteDetailsIV"]);
      } else {
        noteDetails = "";
      }
    } catch (error) {
      print('Decryption error: $error');
      noteTitle = "";
      noteDetails = "";
    }

    return NoteModel(
      id: document.id,
      noteTitle: noteTitle,
      noteDetails: noteDetails,
    );
  }
}
