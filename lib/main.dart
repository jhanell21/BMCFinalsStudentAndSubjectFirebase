
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FirstPage(),
  ));
}

class FirstPage extends StatelessWidget {
  FirstPage({super.key});

  final name = TextEditingController();
  final section = TextEditingController();
  final course = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Registration')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: name,decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: section,decoration: InputDecoration(labelText: 'Section')),
            TextField(controller: course,decoration: InputDecoration(labelText: 'Course')),
            ElevatedButton(
              onPressed: () {
                if (name.text.isEmpty ||
                    section.text.isEmpty ||
                    course.text.isEmpty) return;

                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SecondPage(name: name.text,section: section.text,course: course.text,
                  ),
                ));
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  final String name, section, course;

  SecondPage({
    super.key,
    required this.name,
    required this.section,
    required this.course,
  });

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final subject = TextEditingController();
  final time = TextEditingController();
  final subjects = <Map<String, String>>[];

  void addSubject() {
    if (subject.text.trim().isEmpty ||
        time.text.trim().isEmpty) return;

    setState(() {
      subjects.add({
        'subject': subject.text.trim(),
        'time': time.text.trim(),
      });
      subject.clear();
      time.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subject Enrollment')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: subject,decoration: InputDecoration(labelText: 'Subject')),
            TextField(controller: time,decoration: InputDecoration(labelText: 'Time')),
            ElevatedButton(
              onPressed: addSubject,
              child: Text('Add Subject'),
            ),
            ...subjects.asMap().entries.map((e) => ListTile(title: Text(e.value['subject']!),subtitle: Text(e.value['time']!),trailing: IconButton(icon: Icon(Icons.delete),onPressed: () => setState(() => subjects.removeAt(e.key)),
              ),
            )),
            ElevatedButton(
              onPressed: subjects.isEmpty ? null : () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ThirdPage(name: widget.name,section: widget.section,course: widget.course,subjects: List.from(subjects),
                  ),
                ));
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class ThirdPage extends StatefulWidget {
  final String name, section, course;
  final List<Map<String, String>> subjects;

  ThirdPage({
    super.key,required this.name,required this.section,required this.course,required this.subjects,
  });

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  bool saving = false;

  Future<void> saveData() async {
    setState(() => saving = true);

    try {
      await FirebaseFirestore.instance.collection('students').add({'name': widget.name,'section': widget.section,'course': widget.course,'subjects': widget.subjects,'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved successfully')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subject Verification')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [Text('Name: ${widget.name}'),Text('Section: ${widget.section}'),Text('Course: ${widget.course}'),
            SizedBox(height: 16),
            Text('Enrolled Subjects'),
            ...widget.subjects.map((s) => ListTile(title: Text(s['subject']!),subtitle: Text(s['time']!),
            )),
            ElevatedButton(onPressed: saving ? null : saveData,child: Text(saving ? 'Saving...' : 'Save'),
            ),
            TextButton(onPressed: saving ? null : () => Navigator.pop(context),child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
