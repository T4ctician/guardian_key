import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/controllers/masterpassword_controller.dart';
import 'package:guardian_key/src/features/authentication/models/note_model.dart'; // Note: Adjust the import path
import 'package:guardian_key/src/repository/note_repository.dart'; // Note: Adjust the import path

class AddNoteController extends GetxController {
  static AddNoteController get instance => Get.find();

  /// Repositories
  final _noteRepo = NoteRepository.instance;

  String get masterPassword {
    final masterPasswordController = Get.find<MasterPasswordController>();
    return masterPasswordController.masterPassword ?? '';  // if null, return an empty string
  }

  /// Add a new note
  Future<void> addNote(NoteModel note) async {
    try {
      await _noteRepo.createNote(note, masterPassword);
      Get.snackbar("Success", "Note added successfully!",
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    }
  }

  /// Update a note
  Future<void> updateNote(NoteModel note) async {
    try {
      await _noteRepo.updateNoteRecord(note, masterPassword);
      Get.snackbar("Success", "Note updated successfully!",
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    }
  }

  /// Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      await _noteRepo.deleteNote(noteId);
      Get.snackbar("Success", "Note deleted successfully!",
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    }
  }

  // Fetch a note by its title
  Future<NoteModel?> getNoteByTitle(String noteTitle) async {
    return await _noteRepo.getNoteByTitle(noteTitle, masterPassword);
  }
}
