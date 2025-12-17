import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/produit.dart';
import '../models/commande.dart';

/// Service de cache local pour améliorer les performances et permettre le mode hors ligne
class LocalStorageService {
  static SharedPreferences? _prefs;

  // Initialiser SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    print(' LocalStorage initialisé');
  }


  
  /// Sauvegarder les produits en cache local
  static Future<void> cacheProduits(List<Produit> produits) async {
    try {
      final produitsJson = produits.map((p) => {
        'id': p.id,
        'nom': p.nom,
        'description': p.description,
        'prix': p.prix,
        'categorie': p.categorie,
        'taille': p.taille,
        'couleur': p.couleur,
        'stock': p.stock,
        'imageUrl': p.imageUrl,
      }).toList();
      
      await _prefs?.setString('cached_produits', jsonEncode(produitsJson));
      await _prefs?.setString('cached_produits_date', DateTime.now().toIso8601String());
      
      print(' ${produits.length} produits mis en cache');
    } catch (e) {
      print(' Erreur cache produits: $e');
    }
  }

  /// Récupérer les produits du cache
  static List<Produit>? getCachedProduits() {
    try {
      final produitsJson = _prefs?.getString('cached_produits');
      if (produitsJson == null) return null;

      final List<dynamic> decoded = jsonDecode(produitsJson);
      return decoded.map((p) => Produit(
        id: p['id'],
        nom: p['nom'],
        description: p['description'],
        prix: p['prix'],
        categorie: p['categorie'],
        taille: p['taille'],
        couleur: p['couleur'],
        stock: p['stock'],
        imageUrl: p['imageUrl'],
      )).toList();
    } catch (e) {
      print(' Erreur lecture cache produits: $e');
      return null;
    }
  }

  /// Vérifier si le cache des produits est récent (moins de 1 heure)
  static bool isProduitsCacheValid() {
    try {
      final dateStr = _prefs?.getString('cached_produits_date');
      if (dateStr == null) return false;

      final cacheDate = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(cacheDate);
      
      return diff.inHours < 1; // Cache valide pendant 1 heure
    } catch (e) {
      return false;
    }
  }



  /// Sauvegarder les commandes en cache local
  static Future<void> cacheCommandes(List<Commande> commandes) async {
    try {
      final commandesJson = commandes.map((c) => {
        'id': c.id,
        'userId': c.userId,
        'clientNom': c.clientNom,
        'date': c.date.toIso8601String(),
        'produits': c.produits.map((p) => p.toMap()).toList(),
        'total': c.total,
        'statut': c.statut,
        'livraisonId': c.livraisonId,
      }).toList();
      
      await _prefs?.setString('cached_commandes', jsonEncode(commandesJson));
      print(' ${commandes.length} commandes mises en cache');
    } catch (e) {
      print(' Erreur cache commandes: $e');
    }
  }


  static List<Commande>? getCachedCommandes() {
    try {
      final commandesJson = _prefs?.getString('cached_commandes');
      if (commandesJson == null) return null;

      final List<dynamic> decoded = jsonDecode(commandesJson);
      return decoded.map((c) => Commande.fromMap(c['id'], c)).toList();
    } catch (e) {
      print(' Erreur lecture cache commandes: $e');
      return null;
    }
  }


  /// Sauvegarder le panier localement
  static Future<void> savePanier(Map<String, int> panier) async {
    try {
      await _prefs?.setString('panier', jsonEncode(panier));
      print(' Panier sauvegardé: ${panier.length} articles');
    } catch (e) {
      print(' Erreur sauvegarde panier: $e');
    }
  }

  /// Récupérer le panier local
  static Map<String, int> getPanier() {
    try {
      final panierJson = _prefs?.getString('panier');
      if (panierJson == null) return {};

      final Map<String, dynamic> decoded = jsonDecode(panierJson);
      return decoded.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      print(' Erreur lecture panier: $e');
      return {};
    }
  }

  /// Vider le panier
  static Future<void> clearPanier() async {
    await _prefs?.remove('panier');
    print('🗑️ Panier vidé');
  }


  /// Sauvegarder le thème
  static Future<void> saveThemeMode(bool isDark) async {
    await _prefs?.setBool('theme_dark', isDark);
  }

  /// Récupérer le thème
  static bool getThemeMode() {
    return _prefs?.getBool('theme_dark') ?? false;
  }

  /// Sauvegarder la dernière adresse de livraison
  static Future<void> saveLastAddress(String address) async {
    await _prefs?.setString('last_address', address);
  }

  /// Récupérer la dernière adresse
  static String? getLastAddress() {
    return _prefs?.getString('last_address');
  }

  /// Incrémenter le nombre de commandes passées
  static Future<void> incrementOrderCount() async {
    final count = _prefs?.getInt('order_count') ?? 0;
    await _prefs?.setInt('order_count', count + 1);
  }

  /// Récupérer le nombre de commandes
  static int getOrderCount() {
    return _prefs?.getInt('order_count') ?? 0;
  }

  /// Sauvegarder le montant total dépensé
  static Future<void> addToTotalSpent(double amount) async {
    final total = _prefs?.getDouble('total_spent') ?? 0.0;
    await _prefs?.setDouble('total_spent', total + amount);
  }

  /// Récupérer le montant total dépensé
  static double getTotalSpent() {
    return _prefs?.getDouble('total_spent') ?? 0.0;
  }

  // ========== NETTOYAGE ==========

  /// Effacer tous les caches (déconnexion)
  static Future<void> clearAllCache() async {
    await _prefs?.clear();
    print(' Tous les caches effacés');
  }
}