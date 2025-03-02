import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'theme.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Notes App',
      theme: appTheme, 
      home: NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() async {
    final data = await DatabaseHelper.instance.getAllNotes();
    setState(() {
      _notes = data;
    });
  }

  void _addOrUpdateNote({int? id}) async {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();
    
    if (title.isEmpty || content.isEmpty) return;

    if (id == null) {
      await DatabaseHelper.instance.insert({'title': title, 'content': content});
    } else {
      await DatabaseHelper.instance.update({'id': id, 'title': title, 'content': content});
    }

    _titleController.clear();
    _contentController.clear();
    _refreshNotes();
  }

  void _deleteNote(int id) async {
    await DatabaseHelper.instance.delete(id);
    _refreshNotes();
  }

  void _showForm({int? id}) {
    if (id != null) {
      final existingNote = _notes.firstWhere((note) => note['id'] == id);
      _titleController.text = existingNote['title'];
      _contentController.text = existingNote['content'];
    } else {
      _titleController.clear();
      _contentController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              id == null ? 'Nueva Nota' : 'Editar Nota',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Contenido',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addOrUpdateNote(id: id);
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Guardar' : 'Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notas')),
      body: _notes.isEmpty
          ? Center(child: Text("No hay notas aún", style: TextStyle(fontSize: 16, color: Colors.black54)))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      note['title'],
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(note['content'], maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.deepPurple),
                          onPressed: () => _showForm(id: note['id']),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteNote(note['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showForm(),
      ),
    );
  }
}
