import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/login_page.dart';
import 'screens/user/user_home_page.dart';
import 'providers/commandes_provider.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialiser LocalStorage pour le cache
  await LocalStorageService.init();
  
  runApp(const VetementsApp());
}

class VetementsApp extends StatelessWidget {
  const VetementsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrappez MaterialApp avec MultiProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CommandesProvider()),
        // Ajoutez d'autres providers ici si nécessaire
        // ChangeNotifierProvider(create: (_) => ProduitsProvider()),
        // ChangeNotifierProvider(create: (_) => PanierProvider()),
      ],
      child: MaterialApp(
        title: 'Vêtements Store',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Afficher un loader pendant la vérification
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Si l'utilisateur est connecté
        if (snapshot.hasData) {
          return const UserHomePage();
        }
        
        // Sinon, afficher la page de connexion
        return const LoginPage();
      },
    );
  }
}