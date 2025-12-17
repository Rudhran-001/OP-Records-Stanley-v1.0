import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request storage permission before initializing Hive
  await requestStoragePermission();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('patients'); // Ensure the correct box is used

  runApp(MyApp());
}

// Function to request storage permission
Future<void> requestStoragePermission() async {
  PermissionStatus status = await Permission.manageExternalStorage.request();
  if (status.isGranted) {
    print("Storage permission granted.");
  } else {
    print("Storage permission denied.");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // ✅ Added const

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartScreen(), // ✅ Set the correct home screen
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Patients Data Manager",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A), // ✅ Consider using Theme.of(context).primaryColor
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NameInputScreen()), // ✅ Ensure NameInputScreen exists
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A), // ✅ Consider using Theme.of(context).primaryColor
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                "Start Registration",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  _NameInputScreenState createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  // ✅ Declare Controllers
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _edNumberController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();


  // ✅ Declare Dropdown Selections
  String _selectedGender = 'Male';
  String _selectedDepartment = 'Medicine';
  String _selectedCaseType = 'MLC';
  String _selectedZone = 'Green';
  String _selectedEDOutcome = 'OP';

  late Box patientBox; // ✅ Hive Box for storing records
  List<Map<String, dynamic>> _patientRecords = [];

  @override
  void initState() {
    super.initState();
    _openHiveBox();
    
    _debugHiveData(); 
    Future.delayed(Duration(seconds: 1), () => _debugHiveData()); // Double-check
    _loadRecords(); // ✅ Load records when screen loads
  }

  Future<void> _openHiveBox() async {
    patientBox = await Hive.openBox('patients');
  }

  

  

  Future<void> _debugHiveData() async {
  final box = await Hive.openBox('patients');

  print("Hive Debug: Total records: ${box.length}");
  print("Hive Debug: All stored records: ${box.toMap()}");

  if (box.containsKey("test")) {
    print("Test record exists: ${box.get('test')}");
  } else {
    print("Test record not found! Did you call addTestData()?");
  }
}


  Future<void> _loadRecords() async {
    await Future.delayed(Duration(milliseconds: 100)); // Small delay to avoid UI freeze
    final box = await Hive.openBox('patients');

    setState(() {
      _patientRecords = box.values.map((record) => Map<String, dynamic>.from(record)).toList();
    });
    print("Loaded records: $_patientRecords"); // ✅ Debug print
  }

  Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(), // default date is today
    firstDate: DateTime(2000), // the earliest date the user can pick
    lastDate: DateTime(2101), // the latest date the user can pick
  );

  if (picked != null && picked != DateTime.now()) {
    setState(() {
      _dateController.text = "${picked.toLocal()}".split(' ')[0]; // Format as YYYY-MM-DD
    });
  }
}


  void _confirmSubmission() {
    if (_dateController.text.isNotEmpty &&
        _timeController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _edNumberController.text.isNotEmpty &&
        _ageController.text.isNotEmpty &&
        _diagnosisController.text.isNotEmpty &&
        _treatmentController.text.isNotEmpty ) {

      String enteredDate = _dateController.text.trim(); // Get the selected date
      String enteredTime = _timeController.text.trim(); // Get the selected time
      String enteredName = _nameController.text.trim();
      String enteredEDNumber = _edNumberController.text.trim();
      String enteredAge = _ageController.text.trim();
      String enteredDiagnosis = _diagnosisController.text.trim();
      String enteredTreatment = _treatmentController.text.trim();

      

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Submission"),
          content: Text(
            "Date: $enteredDate\nTime: $enteredTime\n"
            "Name: $enteredName\nED Number: $enteredEDNumber\nAge: $enteredAge\n"
            "Gender: $_selectedGender\nDepartment: $_selectedDepartment\n"
            "Type of Case: $_selectedCaseType\nDiagnosis: $enteredDiagnosis\n"
            "Zone: $_selectedZone\nED Outcome: $_selectedEDOutcome\n"
            "Treatment: $enteredTreatment",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (!patientBox.isOpen) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error: Database not initialized!")),
                  );
                  return;
                }

                await patientBox.put(enteredEDNumber, {  // ✅ Store with unique key (ED Number)
                  'date': enteredDate, // Save the date in the database 
                  'time': enteredTime, // Save the time in the database
                  'name': enteredName,
                  'edNumber': enteredEDNumber,
                  'age': enteredAge,
                  'gender': _selectedGender,
                  'department': _selectedDepartment,
                  'typeOfCase': _selectedCaseType,
                  'diagnosis': enteredDiagnosis,
                  'zone': _selectedZone,
                  'edOutcome': _selectedEDOutcome,
                  'treatment': enteredTreatment,

                });

                setState(() {
                  _dateController.clear(); // Clear the date field
                  _timeController.clear(); // Clear the time field
                  _nameController.clear();
                  _edNumberController.clear();
                  _ageController.clear();
                  _diagnosisController.clear();
                  _treatmentController.clear();

                  _selectedGender = 'Male';
                  _selectedDepartment = 'Medicine';
                  _selectedCaseType = 'MLC';
                  _selectedZone = 'Green';
                  _selectedEDOutcome = 'OP';
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Patient data has been submitted successfully!')),
                );
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all details before submitting.')),
      );
    }
  }

  void _viewRecords() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewRecordsScreen(patientRecords: _patientRecords),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Enter Patient Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _dateController,
                readOnly: true, // Make the TextField read-only to prevent manual input
                decoration: InputDecoration(
                  hintText: "Select date",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onTap: () => _selectDate(context), // Show the date picker when tapped
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  hintText: 'Select Time',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    final now = DateTime.now();
                    final formattedTime = DateFormat.jm().format(
                      DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute),
                    );
                    _timeController.text = formattedTime;
                  }
                },
              ),
              const SizedBox(height: 16),
              
              const Text("Full Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Enter full name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              const Text("ED Number", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _edNumberController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: "Enter ED Number",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Age", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter age",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Gender", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: ['Male', 'Female', 'Others']
                      .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                const Text("Department", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  items: ['Medicine', 'Surgery', 'Orthopedics', 'Others']
                      .map((dept) => DropdownMenuItem(value: dept, child: Text(dept)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartment = value!;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                const Text("Type of Case", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCaseType,
                  items: ['MLC', 'NMLC']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCaseType = value!;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

              const Text("Diagnosis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _diagnosisController,
                decoration: InputDecoration(
                  hintText: "Enter diagnosis",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

             const Text("Zone", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 10),
             DropdownButtonFormField<String>(
                value: _selectedZone,
                items: ['Green', 'Yellow', 'Red'].map((zone) {
                  return DropdownMenuItem(
                    value: zone,
                    child: Text(
                      zone,
                      style: TextStyle(
                        color: zone == 'Green' ? Colors.green :
                               zone == 'Yellow' ? Colors.yellow[800] :
                             Colors.red, // Assigning colors based on selection
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedZone = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),


              const Text("ED Outcome", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedEDOutcome,
                items: ['OP', 'NWA']
                    .map((outcome) => DropdownMenuItem(value: outcome, child: Text(outcome)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEDOutcome = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Treatment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField( 
                controller: _treatmentController,
                decoration: InputDecoration(
                  hintText: "Enter treatment",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _confirmSubmission,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("Submit"),
                  ),
                  ElevatedButton(
                    onPressed: _viewRecords,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF1E3A8A),
                    ),
                    child: const Text("View Records"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ViewRecordsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> patientRecords;

  const ViewRecordsScreen({super.key, required this.patientRecords});

  @override
  _ViewRecordsScreenState createState() => _ViewRecordsScreenState();
}

class _ViewRecordsScreenState extends State<ViewRecordsScreen> {
  List<Map<String, dynamic>> _patientRecords = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final box = await Hive.openBox('patients');
    setState(() {
      _patientRecords = box.values.map((record) => Map<String, dynamic>.from(record)).toList();
    });
  }

  void _editRecord(int index) {
  TextEditingController dateController = TextEditingController(
  text: _patientRecords[index]['date'] ?? '',
  );

  TextEditingController timeController = TextEditingController(
    text: _patientRecords[index]['time'] ?? '',
  );

  TextEditingController nameController = TextEditingController(
    text: _patientRecords[index]['name'] ?? '',
  );

  TextEditingController edNumberController = TextEditingController(
    text: _patientRecords[index]['edNumber'] ?? '',
  );

  TextEditingController ageController = TextEditingController(
    text: _patientRecords[index]['age'] ?? '',
  );

  TextEditingController diagnosisController = TextEditingController(
    text: _patientRecords[index]['diagnosis'] ?? '',
  );

  TextEditingController treatmentController = TextEditingController(
    text: _patientRecords[index]['treatment'] ?? '',
  );

  String selectedGender = _patientRecords[index]['gender'] ?? 'Male';
  String selectedDepartment = _patientRecords[index]['department'] ?? 'Medicine';
  String selectedCaseType = _patientRecords[index]['typeOfCase'] ?? 'MLC';
  String selectedZone = _patientRecords[index]['zone'] ?? 'Green';
  String selectedEdOutcome = _patientRecords[index]['edOutcome'] ?? 'OP';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Record"),
              content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: "Date"),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: "Time"),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: edNumberController,
                decoration: const InputDecoration(labelText: "ED Number"),
              ),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Age"),
              ),
              
              DropdownButtonFormField<String>(
                value: selectedGender,
                onChanged: (value) => selectedGender = value!,
                items: ['Male', 'Female', 'Others']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              DropdownButtonFormField<String>(
                value: selectedDepartment,
                onChanged: (value) => selectedDepartment = value!,
                items: ['Medicine', 'Surgery', 'Orthopedics', 'Others']
                    .map((dept) => DropdownMenuItem(
                          value: dept,
                          child: Text(dept),
                        ))
                    .toList(),
                decoration: const InputDecoration(labelText: "Department"),
              ),
              DropdownButtonFormField<String>(
                value: selectedCaseType,
                onChanged: (value) => selectedCaseType = value!,
                items: ['MLC', 'NMLC']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                decoration: const InputDecoration(labelText: "Type of Case"),
              ),
              TextField(
                controller: diagnosisController,
                decoration: const InputDecoration(labelText: "Diagnosis"),
              ),
              DropdownButtonFormField<String>(
                value: selectedZone,
                onChanged: (value) => selectedZone = value!,
                items: ['Green', 'Yellow', 'Red']
                    .map((zone) => DropdownMenuItem(
                          value: zone,
                          child: Text(zone),
                        ))
                    .toList(),
                decoration: const InputDecoration(labelText: "Zone"),
              ),
              DropdownButtonFormField<String>(
                value: selectedEdOutcome,
                onChanged: (value) => selectedEdOutcome = value!,
                items: ['OP', 'NWA']
                    .map((outcome) => DropdownMenuItem(
                          value: outcome,
                          child: Text(outcome),
                        ))
                    .toList(),
                decoration: const InputDecoration(labelText: "ED Outcome"),
              ),
              TextField(
                controller: treatmentController,
                decoration: const InputDecoration(labelText: "Treatment"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _patientRecords[index] = {
                  'date': dateController.text,
                  'time': timeController.text,
                  'name': nameController.text,
                  'edNumber': edNumberController.text,
                  'age': ageController.text,
                  'gender': selectedGender,
                  'department': selectedDepartment,
                  'typeOfCase': selectedCaseType,
                  'diagnosis': diagnosisController.text,
                  'zone': selectedZone,
                  'edOutcome': selectedEdOutcome,
                  'treatment': treatmentController.text,
                };
              });

              final box = await Hive.openBox('patients');
              box.put(_patientRecords[index]['edNumber'], _patientRecords[index]);

              Navigator.pop(context);
              _loadRecords(); // ✅ Refresh records after edit
            },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

   void _confirmDelete(int index) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRecord(index); // Proceed with Deletion
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

// Function to delete a record
void _deleteRecord(int index) async {
  final box = await Hive.openBox('patients'); // Open Hive box

  await box.deleteAt(index); // Delete the record at the given index

  setState(() {
    _patientRecords.removeAt(index); // Update UI
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Record deleted successfully!")),
  );
}

void _confirmDeleteAll() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Confirm Delete All"),
        content: const Text("Are you sure you want to delete all records? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllRecords(); // Proceed with deletion
            },
            child: const Text("Delete All", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

void _deleteAllRecords() async {
  final box = await Hive.openBox('patients'); // Open Hive box
  await box.clear(); // Delete all records

  setState(() {
    _patientRecords.clear(); // Update UI
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("All records deleted successfully!")),
  );
}


  Future<void> _exportToDevice(BuildContext context) async {
    if (_patientRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data to export!")),
      );
      return;
    }

    List<List<String>> csvData = [
      ["Date", "Time", "Name", "ED Number", "Age", "Gender", "Department", "Type of Case", "Diagnosis", "Zone", "ED Outcome", "Treatment"],
      ..._patientRecords.map((record) => [
        record['date'] ?? "",
        record['time']?.replaceAll(RegExp(r'[^\x00-\x7F]'), '') ?? "", // Clean weird chars
        record['name'] ?? "",
        record['edNumber'] ?? "",
        record['age'] ?? "",
        record['gender'] ?? "",
        record['department'] ?? "",
        record['typeOfCase'] ?? "MLC",
        record['diagnosis'] ?? "",
        record['zone'] ?? "Green",
        record['edOutcome'] ?? "OP",
        record['treatment'] ?? "",
      ]),
    ];

    String csvContent = csvData.map((row) => row.join(',')).join("\n");

    try {
      String? directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No directory selected!")),
        );
        return;
      }

      String filePath = '$directory/patient_records.csv';
      await File(filePath).writeAsString(csvContent, encoding: utf8);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File saved successfully at $filePath")),
      );

      OpenFilex.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save file: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "View Records",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _patientRecords.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> details = _patientRecords[index];

                 

                 return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(
                        "Name: ${details['name'] ?? ''}\nED Number: ${details['edNumber'] ?? ''}\nAge: ${details['age'] ?? ''}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editRecord(index), // ✅ Edit button
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(index), // ✅ Delete button added
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => _exportToDevice(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Export to Device Files", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10), // Space between buttons
            ElevatedButton(
              onPressed: () => _confirmDeleteAll(), // ✅ Delete All button added
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete All Records", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}