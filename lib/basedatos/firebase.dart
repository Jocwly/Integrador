import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // Credenciales fijas del veterinario
  static const String _vetEmail = 'vet@petcare.com';
  static const String _vetPass  = 'Vet12345!';

  Future<Map<String, dynamic>> login(String email, String password) async {
    if (email.trim().toLowerCase() == _vetEmail && password == _vetPass) {
      return {'ok': true, 'role': 'veterinario', 'uid': 'vet-fixed'};
    }

    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final uid = cred.user!.uid;

    final doc = await _db.collection('usuarios').doc(uid).get();
    final data = doc.data() ?? {};
    final role = (data['role'] ?? 'cliente') as String;

    return {'ok': true, 'role': role, 'uid': uid};
  }

  Future<Map<String, dynamic>> registerCliente({
    required String nombre,
    required String telefono,
    required String email,
    required String direccion,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = cred.user!.uid;

    await _db.collection('usuarios').doc(uid).set({
      'nombre': nombre.trim(),
      'telefono': telefono.trim(),
      'email': email.trim().toLowerCase(),
      'direccion': direccion.trim(),
      'role': 'cliente',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return {'ok': true, 'role': 'cliente', 'uid': uid};
  }

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
