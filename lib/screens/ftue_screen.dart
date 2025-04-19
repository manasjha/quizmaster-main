import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class FTUEScreen extends StatefulWidget {
  const FTUEScreen({super.key});

  @override
  State<FTUEScreen> createState() => _FTUEScreenState();
}

class _FTUEScreenState extends State<FTUEScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final nameController = TextEditingController();
  XFile? newPhoto;

  String selectedClass = '6';
  String selectedSubject = 'Math';

  @override
  void initState() {
    super.initState();
    nameController.text = user.displayName ?? '';
  }

  Future<void> pickNewPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => newPhoto = picked);
    }
  }

  Widget buildClassDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedClass,
      decoration: const InputDecoration(
        labelText: 'Select Class',
        labelStyle: TextStyle(fontFamily: 'Poppins', color: Colors.white70),
        border: OutlineInputBorder(),
      ),
      dropdownColor: Colors.black,
      iconEnabledColor: Color(0xFFD4AF37),
      items: List.generate(5, (index) {
        final classNum = (index + 6).toString();
        final enabled = classNum == '6';
        return DropdownMenuItem(
          value: classNum,
          enabled: enabled,
          child: Text(
            'Class $classNum',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: enabled ? Colors.white : Colors.white24,
              decoration: enabled ? null : TextDecoration.lineThrough,
            ),
          ),
        );
      }),
      onChanged: (value) {
        if (value == '6') setState(() => selectedClass = value!);
      },
    );
  }

  Widget buildSubjectBoxes() {
    final subjects = ['Math', 'Science', 'Social Studies'];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: subjects.map((subject) {
        final enabled = subject == 'Math';
        final selected = subject == selectedSubject;

        return GestureDetector(
          onTap: enabled
              ? () => setState(() => selectedSubject = subject)
              : null,
          child: Container(
            width: 100,
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFD4AF37)
                  : Colors.transparent,
              border: Border.all(
                color: enabled ? const Color(0xFFD4AF37) : Colors.white24,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              subject,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: enabled
                    ? (selected ? Colors.black : const Color(0xFFD4AF37))
                    : Colors.white24,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = user.photoURL;
    final photoWidget = newPhoto != null
        ? Image.file(
            File(newPhoto!.path),
            fit: BoxFit.cover,
          )
        : (photoUrl != null
            ? Image.network(photoUrl, fit: BoxFit.cover)
            : const Icon(Icons.person, size: 60, color: Colors.white24));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 60),
            const Text(
              'Welcome to Isylsi!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete your profile to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white10,
                    child: ClipOval(
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: photoWidget,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFFD4AF37)),
                    onPressed: pickNewPhoto,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: nameController,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                labelText: 'Your Name',
                labelStyle: TextStyle(fontFamily: 'Poppins', color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD4AF37)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD4AF37)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            buildClassDropdown(),
            const SizedBox(height: 24),
            const Text(
              'Select Subject',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            buildSubjectBoxes(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final uid = user.uid;
                final name = nameController.text.trim();
                final selectedClassInt = int.parse(selectedClass);
                final selectedSubjectText = selectedSubject;

                final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

                String? uploadedPhotoUrl;
                if (newPhoto != null) {
                  final storageRef = FirebaseStorage.instance
                      .ref()
                      .child('users/$uid/profile.jpg');

                  final uploadTask = await storageRef.putFile(File(newPhoto!.path));
                  uploadedPhotoUrl = await uploadTask.ref.getDownloadURL();
                }

                await userRef.update({
                  'name': name,
                  'class': selectedClassInt,
                  'subject': selectedSubjectText,
                  'profileCompleted': true,
                  if (uploadedPhotoUrl != null) 'photoUrl': uploadedPhotoUrl,
                });

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Start Learning',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}