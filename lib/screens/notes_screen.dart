import 'package:flutter/material.dart';
import 'package:smarttoolkit/core/services/storage_service.dart';
import 'package:smarttoolkit/core/constants/app_constants.dart';
import 'dart:convert';

class Note {
  String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

class TodoItem {
  String id;
  String title;
  bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
  };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
    id: json['id'],
    title: json['title'],
    isCompleted: json['isCompleted'] ?? false,
  );
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SingleTickerProviderStateMixin {
  List<Note> _notes = [];
  final List<TodoItem> _todos = [];
  StorageService? _storageService;
  String _searchQuery = '';
  final TextEditingController _todoController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initStorage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _todoController.dispose();
    super.dispose();
  }

  void _initStorage() async {
    _storageService = await StorageService.getInstance();
    _loadNotes();
  }

  void _loadNotes() {
    if (_storageService == null) return;
    
    final notesData = _storageService!.getStringList(AppConstants.notesKey) ?? [];
    setState(() {
      _notes = notesData.map((noteJson) {
        final json = jsonDecode(noteJson);
        return Note.fromJson(json);
      }).toList();
      
      // Sort notes by updated date (most recent first)
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
  }

  void _saveNotes() {
    if (_storageService == null) return;
    
    final notesData = _notes.map((note) => jsonEncode(note.toJson())).toList();
    _storageService!.saveStringList(AppConstants.notesKey, notesData);
  }

  void _addNote() {
    _navigateToEditor();
  }

  void _editNote(Note note) {
    _navigateToEditor(note: note);
  }

  void _navigateToEditor({Note? note}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          note: note,
          onSave: (Note savedNote) {
            setState(() {
              if (note == null) {
                _notes.add(savedNote);
              } else {
                final index = _notes.indexWhere((n) => n.id == savedNote.id);
                if (index != -1) {
                  _notes[index] = savedNote;
                }
              }
              _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            });
            _saveNotes();
          },
        ),
      ),
    );
  }

  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notes.removeWhere((n) => n.id == note.id);
              });
              _saveNotes();
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addTodo() {
    if (_todoController.text.isEmpty) return;
    
    setState(() {
      _todos.add(TodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _todoController.text,
        isCompleted: false,
      ));
      _todoController.clear();
    });
  }

  void _toggleTodo(String id) {
    setState(() {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index].isCompleted = !_todos[index].isCompleted;
      }
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });
  }

  List<Note> get _filteredNotes {
    if (_searchQuery.isEmpty) return _notes;
    return _notes.where((note) =>
        note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        note.content.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes & Todos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.note), text: 'Notes'),
            Tab(icon: Icon(Icons.checklist), text: 'Todos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotesTab(),
          _buildTodosTab(),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search notes...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: _filteredNotes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_add,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty 
                            ? 'No notes yet.'
                            : 'No notes found matching "$_searchQuery"',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_searchQuery.isEmpty)
                        ElevatedButton.icon(
                          onPressed: _addNote,
                          icon: const Icon(Icons.add),
                          label: const Text('Create Note'),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  itemCount: _filteredNotes.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _filteredNotes.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ElevatedButton.icon(
                          onPressed: _addNote,
                          icon: const Icon(Icons.add),
                          label: const Text('Create New Note'),
                        ),
                      );
                    }
                    final note = _filteredNotes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                      child: ListTile(
                        title: Text(
                          note.title.isEmpty ? 'Untitled' : note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Updated ${_formatDate(note.updatedAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _editNote(note),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              onTap: () {
                                Future.delayed(Duration.zero, () => _editNote(note));
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                Future.delayed(Duration.zero, () => _deleteNote(note));
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.delete),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTodosTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _todoController,
                  decoration: const InputDecoration(
                    hintText: 'Add a new todo...',
                  ),
                  onSubmitted: (_) => _addTodo(),
                ),
              ),
              IconButton(
                onPressed: _addTodo,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: _todos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.checklist,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No todos yet!',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _todos.length,
                  itemBuilder: (context, index) {
                    final todo = _todos[index];
                    return ListTile(
                      leading: Checkbox(
                        value: todo.isCompleted,
                        onChanged: (_) => _toggleTodo(todo.id),
                      ),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () => _deleteTodo(todo.id),
                        icon: const Icon(Icons.delete),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final Function(Note) onSave;

  const NoteEditorScreen({
    super.key,
    this.note,
    required this.onSave,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final now = DateTime.now();
    final note = Note(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
    );

    widget.onSave(note);
    setState(() {
      _hasUnsavedChanges = false;
    });
    Navigator.of(context).pop();
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Do you want to save before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              _saveNote();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onWillPop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
          actions: [
            TextButton(
              onPressed: _saveNote,
              child: const Text('Save'),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Note title...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Start writing...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}