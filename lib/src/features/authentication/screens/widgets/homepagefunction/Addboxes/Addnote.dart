import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardian_key/src/constants/constants.dart';
import 'package:guardian_key/src/features/authentication/models/note_model.dart'; 
import 'package:guardian_key/src/features/authentication/controllers/addnote_controller.dart';
import 'package:guardian_key/src/services/note_service.dart';

  class AddNote extends StatefulWidget {
    final NoteModel? noteO;

    const AddNote({Key? key, this.noteO}) : super(key: key);

    @override
    AddNoteState createState() => AddNoteState();
  }

  class AddNoteState extends State<AddNote> {
    final TextEditingController noteTitleController = TextEditingController();
    final TextEditingController noteDetailController = TextEditingController();
    final NoteService noteService = NoteService(); // Added noteService
    String? selectedNoteTitle; 
    String? userId;
    String? selectedNoteId;


  @override
  void initState() {
      super.initState();
      print('AddNoteState initState called');
      
      // Check if the note is provided
      if (widget.noteO != null) {
          // Update the TextEditingController values
          noteTitleController.text = widget.noteO!.noteTitle ?? '';
          noteDetailController.text = widget.noteO!.noteDetails ?? '';
      }
  }
  
  @override
  void dispose() {
    noteTitleController.dispose();
    noteDetailController.dispose();
    super.dispose();
  }

  void updateSelectedNoteTitle(String? newTitle) {
      setState(() {
          selectedNoteTitle = newTitle;
      });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: screenWidth * 0.4,
                height: 5,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 156, 156, 156),
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            noteContainer(context, NoteService()),
            Column(
              children: [
                formHeading("Note Title"),
                formTextField("Enter Note Title", Icons.title, controller: noteTitleController),
                formHeading("Note Details"),
                formTextField("Enter Note Details", Icons.notes, controller: noteDetailController),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ok Done Button
                SizedBox(
                  height: screenHeight * 0.065,
                  width: screenWidth * 1.0 * 0.8,
                  child: 
                  ElevatedButton(
                    onPressed: () async {
                        String noteTitle = noteTitleController.text.trim();
                        String noteDetails = noteDetailController.text.trim();

                        if (noteTitle.isEmpty) {
                            Get.snackbar('Error', 'Note title cannot be empty.', backgroundColor: Colors.red, colorText: Colors.white);
                            return;
                        }

                        NoteModel note = NoteModel(
                            id: widget.noteO?.id,
                            noteTitle: noteTitle,
                            noteDetails: noteDetails,
                        );

                        if (widget.noteO != null) {
                            AddNoteController.instance.updateNote(note);
                        } else {
                            AddNoteController.instance.addNote(note);
                        }

                        Navigator.pop(context);
                    },
                    child: const Text(
                      "Ok Done",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                // Red Circle Delete Button
                SizedBox(
                  height: screenHeight * 0.065,
                  width: screenHeight * 0.065,
                  child: ElevatedButton(
                    onPressed: () async {
                      bool? shouldDelete = await showConfirmationDialog(context);
                      if (shouldDelete == true) {
                        // Delete the note based on the unique identifier
                        AddNoteController.instance.deleteNote(widget.noteO!.id ?? 'default_value');
                        // Close the modal
                        Navigator.of(context).pop();
                      }
                    },
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget formTextField(String hintText, IconData icon, {TextEditingController? controller}) {
      int maxLines = 1;
      Widget? prefixIcon;
      bool isScrollable = false;

      if (hintText == "Enter Note Details") {
        maxLines = 10;  // Setting maxLines to 7 for the "Enter Note Details" field
        isScrollable = true;  // Make the note details scrollable
      } else {
        prefixIcon = Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 5, 5),
          child: Icon(
            icon,
            color: Constants.searchGrey,
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: isScrollable 
                  ? SingleChildScrollView(  // Wrap TextFormField with SingleChildScrollView for note details
                      child: TextFormField(
                        controller: controller,
                        maxLines: maxLines,  // Use maxLines here
                        maxLength: hintText == "Enter Note Details" ? 3000 : null, // set maxLength for note details
                        buildCounter: hintText == "Enter Note Details"
                          ? (BuildContext context, { int? currentLength, int? maxLength, bool? isFocused }) => 
                              Text('$currentLength/$maxLength') 
                          : null, 
                        decoration: InputDecoration(
                          prefixIcon: prefixIcon,  // Use the prefixIcon variable here
                          filled: true,
                          contentPadding: const EdgeInsets.all(16),
                          hintText: hintText,
                          hintStyle: TextStyle(
                            color: Constants.searchGrey, fontWeight: FontWeight.w500
                          ),
                          fillColor: const Color.fromARGB(247, 232, 235, 237),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                            borderRadius: BorderRadius.circular(20)
                          ),
                        ),
                        style: const TextStyle(),
                      ),
                    )
                  : TextFormField(  // If not note details, then just the TextFormField
                      controller: controller,
                      maxLines: maxLines,
                      decoration: InputDecoration(
                        prefixIcon: prefixIcon,
                        filled: true,
                        contentPadding: const EdgeInsets.all(16),
                        hintText: hintText,
                        hintStyle: TextStyle(
                          color: Constants.searchGrey, fontWeight: FontWeight.w500
                        ),
                        fillColor: const Color.fromARGB(247, 232, 235, 237),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                          borderRadius: BorderRadius.circular(20)
                        ),
                      ),
                      style: const TextStyle(),
                    ),
                ),
              ),
            ],
          ),
        ],
      );
  }



    Widget formHeading(String text) {
      return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 10),
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
      );
    }

  Widget noteContainer(BuildContext context, NoteService noteService) {
      double screenHeight = MediaQuery.of(context).size.height;
      double screenWidth = MediaQuery.of(context).size.width;

      return Row(
        children: [
          GestureDetector(
            onTap: () {
              showAddModal(context);
            },
            child: Container(
              height: 55,
              width: 120,
              decoration: BoxDecoration(
                  color: Constants.logoBackground,
                  borderRadius: BorderRadius.circular(20)),
              child: FractionallySizedBox(
                heightFactor: 0.5,
                widthFactor: 0.5,
                child: Container(
                  child: const Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        "Add",
                        style: TextStyle(fontSize: 14),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    height: 60,
                    width: screenWidth * 0.6,
                    child: FutureBuilder<List<NoteModel>>(
                      future: noteService.fetchNoteData(),
                      builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                          } else {
                              List<NoteModel> notes = snapshot.data ?? [];
                              return ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: notes.length,
                                  itemBuilder: (context, index) => noteBlock(notes[index], context, updateSelectedNoteTitle),
                              );
                          }
                      },
                  ),
                  );
                },
              ),
            ),
          ),
        ],
      );
  }

  void showAddModal(BuildContext context, {NoteModel? noteO}) {
    Navigator.of(context).pop();
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext bc) {
        return Wrap(children: <Widget>[
          Container(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: AddNote(noteO: noteO),
            ),
          )
        ]);
      },
    );
  }


  Widget noteBlock(NoteModel note, BuildContext context, void Function(String?) updateSelectedTitle) {
    
    final isSelected = note.id == widget.noteO?.id;

    return GestureDetector(
        onTap: () {
            setState(() {
                selectedNoteId = note.id;
            });

            showAddModal(context, noteO: note);
        },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6.0, 3, 6, 3),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Constants.logoBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                        note.noteTitle ?? "",
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }


    Future<bool?> showConfirmationDialog(BuildContext context) {
      return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Confirmation'),
            content: const Text('Are you sure you want to delete the note?'),
            actions: <Widget>[
              TextButton(
                child: const Row(
                  children: [
                    Icon(Icons.check, color: Colors.green),
                    Text('Yes', style: TextStyle(color: Colors.green)),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true when user taps 'Yes'
                },
              ),
              TextButton(
                child: const Row(
                  children: [
                    Icon(Icons.close, color: Colors.red),
                    Text('No', style: TextStyle(color: Colors.red)),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false when user taps 'No'
                },
              ),
            ],
          );
        },
      );
    }
    
  }
