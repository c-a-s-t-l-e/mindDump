import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journal App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const EntryScreen(), // Start with the Entry Screen
    );
  }
}

// First Screen: Entry
class EntryScreen extends StatefulWidget {
  final File? entryFile; // Optional entryFile for editing

  const EntryScreen({super.key, this.entryFile});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final TextEditingController _entryController = TextEditingController();
  Directory? selectedDirectory;
  bool isEditing = false; // Track if we're editing

  @override
  void initState() {
    super.initState();
    _initializeStoragePermission();
    _loadEntryForEdit(); // Load entry content if editing
  }

  Future<void> _initializeStoragePermission() async {
    PermissionStatus status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      // Permission granted
    }
  }

  // Load the content of the entry if it's being edited
  Future<void> _loadEntryForEdit() async {
    if (widget.entryFile != null) {
      isEditing = true;
      _entryController.text = await widget.entryFile!.readAsString();
      selectedDirectory = widget.entryFile!.parent;

      setState(() {});
    }
  }

  Future<void> _saveEntry() async {
    if (_entryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first!')),
      );
      return;
    }

    if (selectedDirectory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a directory first!')),
      );
      return;
    }

    final now = DateTime.now();
    String fileName;
    File file;

    if (isEditing && widget.entryFile != null) {
      // If editing, use the existing filename
      fileName = widget.entryFile!.path.split('/').last;
      file = widget.entryFile!;
    } else {
      // If creating, generate a new filename
      fileName =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}-${now.millisecond.toString().padLeft(3, '0')}.txt';
      file = File('${selectedDirectory!.path}/$fileName');
    }

    await file.writeAsString(_entryController.text);
    _entryController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry saved successfully!')),
    );

    // If editing, pop the screen to return to the previous one
    if (isEditing) {
      Navigator.pop(context); // Return to the previous screen
    }
  }

  Future<void> _selectDirectory() async {
    String? pickedDirectory = await FilePicker.platform.getDirectoryPath();

    if (pickedDirectory != null) {
      setState(() {
        selectedDirectory = Directory(pickedDirectory);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Entry' : 'New Entry'), // Dynamic title
        actions: [
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: _selectDirectory,
          ),
          if (!isEditing) // Don't show the list icon if we are editing
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                if (selectedDirectory == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please select a directory first!')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviousEntriesScreen(
                        selectedDirectory: selectedDirectory!),
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (selectedDirectory != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Saving to: ${selectedDirectory!.path}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            Expanded(
              child: TextField(
                controller: _entryController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Write your journal entry here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveEntry,
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }
}

// Second Screen: Previous Entries (with Search)
class PreviousEntriesScreen extends StatefulWidget {
  final Directory selectedDirectory;

  const PreviousEntriesScreen({super.key, required this.selectedDirectory});

  @override
  State<PreviousEntriesScreen> createState() => _PreviousEntriesScreenState();
}

class _PreviousEntriesScreenState extends State<PreviousEntriesScreen> {
  List<FileSystemEntity> entries = [];
  List<FileSystemEntity> filteredEntries = [];
  bool loading = true;
  TextEditingController searchController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      loading = true;
    });

    entries = widget.selectedDirectory
        .listSync()
        .where((file) => file.path.endsWith('.txt'))
        .toList();
    entries.sort((a, b) =>
        File(b.path).lastModifiedSync().compareTo(File(a.path).lastModifiedSync()));
    filteredEntries = List.from(entries); // Initialize filtered list with all entries.

    setState(() {
      loading = false;
    });
  }

  Future<void> _viewEntry(File file) async {
    String content = await file.readAsString();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(file.path.split('/').last),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _filterEntries({String? searchText, DateTime? date}) {
    setState(() {
      filteredEntries = entries.where((entry) {
        if (searchText != null && searchText.isNotEmpty) {
          final file = File(entry.path);
          final content = file.readAsStringSync().toLowerCase();
          if (!content.contains(searchText.toLowerCase())) {
            return false;
          }
        }

        if (date != null) {
          final file = File(entry.path);
          final lastModified = file.lastModifiedSync();
          if (lastModified.year != date.year ||
              lastModified.month != date.month ||
              lastModified.day != date.day) {
            return false;
          }
        }
        return true;
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _filterEntries(date: selectedDate, searchText: searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Entries'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search entries...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _filterEntries(searchText: value, date: selectedDate);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
                if (selectedDate != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      DateFormat('MMM d, yyyy').format(selectedDate!),
                    ),
                  ),
                if (selectedDate != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedDate = null;
                      });
                      _filterEntries(
                        searchText: searchController.text,
                        date: selectedDate,
                      );
                    },
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEntries.isEmpty
                      ? const Center(child: Text('No entries match your criteria'))
                      : ListView.builder(
                          itemCount: filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = filteredEntries[index];
                            return ListTile(
                              title: Text(entry.path.split('/').last),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EntryScreen(
                                      entryFile: entry as File,
                                    ),
                                  ),
                                ).then((_) => _loadEntries()); // Reload entries when returning
                              },
                              leading: const Icon(Icons.book),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await entry.delete();
                                  _loadEntries();
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
