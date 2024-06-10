import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud1_firebase/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // firestore
  final FirestoreService _firestoreService = FirestoreService();
  // text controller
  final TextEditingController textController = TextEditingController();

  // open a dialog box to add a new note
  void openNoteBox({String? docId, String? noteText}) {
    if (docId != null) {
      textController.text = noteText!;
    } else {
      textController.clear();
    }
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SizedBox(
                height: 80,
                width: double.maxFinite,
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(hintText: 'Inserte Task'),
                ),
              ),
              actions: [
                //button to save
                Center(
                  child: ElevatedButton(
                      onPressed: () {
                        if (textController.text.isNotEmpty) {
                          if (docId == null) {
                            // create note
                            _firestoreService.addNote(textController.text);
                          } else {
                            // edite note
                            _firestoreService.updateNote(
                                docId, textController.text);
                          }
                        }

                        // clear controller
                        textController.clear();

                        // close the dialog
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.blue[600]),
                      ),
                      child: const Text(
                        'Guardar',
                        style: TextStyle(color: Colors.white),
                      )),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22),
        backgroundColor: Colors.blue[600],
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          // si tenemos data, obtenemos elementos
          if (snapshot.hasData) {
            List noteList = snapshot.data!.docs;

            // mostramos como una lista
            return ListView.builder(
                itemCount: noteList.length,
                itemBuilder: (context, index) {
                  // obtener cada documento indivudual
                  DocumentSnapshot document = noteList[index];
                  String docId = document.id;

                  // obtener nota de cada doc
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String noteText = data['note'];

                  // mostrarla como una list title
                  return Container(
                    margin: const EdgeInsets.only(left: 12, top: 15, right: 12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue[300]),
                    child: ListTile(
                      title: Text(noteText),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () =>
                                  openNoteBox(docId: docId, noteText: noteText),
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.amber,
                              )),
                          IconButton(
                              onPressed: () =>
                                  _firestoreService.deleteNote(docId),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ))
                        ],
                      ),
                    ),
                  );
                });
          } else {
            // si no hay data para mostrar
            return const Text("Sin data para mostrar...");
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        backgroundColor: Colors.blue[600],
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
