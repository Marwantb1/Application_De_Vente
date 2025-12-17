import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/admins/admin_produits_page.dart';
import 'package:flutter_application_1/screens/livraisons/livraisons_page.dart';
import '../../services/auth_service.dart';
import '../../services/produits_service.dart';
import '../login_page.dart';
import '../produits/produits_page.dart';
import '../commandes/commandes_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key}) : super(key: key);

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initialiserProduits();
  }

  Future<void> _initialiserProduits() async {
    try {
      await ProduitsService.initialiserProduits();
    } catch (e) {
      print('Erreur initialisation produits: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  List<Widget> get _pages {
    if (AuthService.isAdmin) {
      return [
        const AdminProduitsPage(),
      ];
    } else {
      return [
        const ProduitsPage(),
        const CommandesPage(),
        const LivraisonsPage(),
      ];
    }
  }

  List<NavigationDestination> get _destinations {
    if (AuthService.isAdmin) {
      return const [
        NavigationDestination(
          icon: Icon(Icons.inventory),
          label: 'Gestion Stocks',
        ),
      ];
    } else {
      return const [
        NavigationDestination(
          icon: Icon(Icons.store),
          label: 'Produits',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_bag),
          label: 'Mes Commandes',
        ),
        NavigationDestination(
          icon: Icon(Icons.local_shipping),
          label: 'Livraisons',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vêtements Store'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement des produits...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AuthService.isAdmin ? 'Admin - Gestion' : 'Vêtements Store'),
        backgroundColor: AuthService.isAdmin ? Colors.deepPurple : null,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                AuthService.currentUserEmail ?? '',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      // ✅ N'afficher la NavigationBar QUE si l'utilisateur n'est PAS admin
      bottomNavigationBar: AuthService.isAdmin 
          ? null  // Pas de barre de navigation pour l'admin
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: _destinations,
            ),
    );
  }
}