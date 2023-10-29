import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/controllers/masterpassword_controller.dart';
import 'package:guardian_key/src/features/authentication/models/note_model.dart';  
import 'package:guardian_key/src/repository/note_repository.dart';  

class NoteService {
  final _noteRepo = NoteRepository.instance;  // Use NoteRepository

    String get masterPassword {
    final masterPasswordController = Get.find<MasterPasswordController>();
    return masterPasswordController.masterPassword ?? '';  // if null, return an empty string
  }

  Future<List<NoteModel>> fetchNoteData() async {  // Updated to NoteModel
    return await _noteRepo.getAllNotes(masterPassword);  // Ensure _noteRepo returns NoteModel
  }
  
  Future<List<String>> fetchNoteTitles() async {
    try {
      // Fetch your note data from the data source
      final List<NoteModel> data = await fetchNoteData();  // Updated to NoteModel

      // Extract note titles from the note data
      final List<String> noteTitles = data.map((note) => note.noteTitle).toList();

      return noteTitles;
    } catch (e) {
      // Handle any errors here
      print('Error fetching note titles: $e');
      return []; // Return an empty list or handle the error as needed
    }
  }

  Future<NoteModel> getNoteByTitle(String title) async {  // Updated to NoteModel
    try {
      final List<NoteModel> data = await fetchNoteData();  // Updated to NoteModel
      
      // Find the note with the matching title
      final selectedNote = data.firstWhere(
        (note) => note.noteTitle == title,
        orElse: () => const NoteModel(  // Updated to NoteModel
          noteTitle: '',
          noteDetails: '',
        ), // Return an empty NoteModel object if no matching note is found
      );

      return selectedNote;
    } catch (e) {
      // Handle any errors here
      print('Error fetching note by title: $e');
      return const NoteModel(  // Updated to NoteModel
        noteTitle: '',
        noteDetails: '',
      ); // Return an empty NoteModel object in case of an error
    }
  }

  // Inside the NoteService class
  Stream<List<NoteModel>> listenToAllNotes() {
    return _noteRepo.listenToAllNotes(masterPassword);  // Use the NoteRepository's listenToAllNotes method
  }
}
