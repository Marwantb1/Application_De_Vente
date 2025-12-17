import 'package:flutter/foundation.dart';
import '../models/commande.dart';
import '../models/produit.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';

/// Provider pour gérer l'état des commandes (Pattern MVVM)
/// Sépare la logique métier de l'interface utilisateur
class CommandesProvider extends ChangeNotifier {
  // État
  List<Commande> _commandes = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Commande> get commandes => _commandes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCommandes => _commandes.isNotEmpty;

  // Statistiques
  double get totalGeneral => _commandes.fold(0, (sum, cmd) => sum + cmd.total);
  int get totalProduits => _commandes.fold(0, (sum, cmd) => sum + cmd.produits.length);
  int get nombreCommandes => _commandes.length;

  /// Charger les commandes (avec cache local en premier)
  Future<void> loadCommandes() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 1. Charger depuis le cache local en premier (affichage rapide)
      final cachedCommandes = LocalStorageService.getCachedCommandes();
      if (cachedCommandes != null && cachedCommandes.isNotEmpty) {
        _commandes = cachedCommandes;
        notifyListeners();
        print(' ${cachedCommandes.length} commandes chargées depuis le cache');
      }

      // 2. Écouter le stream Firebase pour les données en temps réel
      FirebaseService.getCommandesStream().listen(
        (commandesFirebase) {
          _commandes = commandesFirebase;
          _isLoading = false;
          _error = null;
          
          // Mettre à jour le cache local
          LocalStorageService.cacheCommandes(commandesFirebase);
          
          notifyListeners();
          print('🔄 ${commandesFirebase.length} commandes synchronisées depuis Firebase');
        },
        onError: (e) {
          _error = 'Erreur de chargement: $e';
          _isLoading = false;
          notifyListeners();
          print(' Erreur stream commandes: $e');
        },
      );
    } catch (e) {
      _error = 'Erreur: $e';
      _isLoading = false;
      notifyListeners();
      print(' Erreur loadCommandes: $e');
    }
  }

  /// Créer une nouvelle commande
  Future<bool> createCommande({
    required List<ProduitCommande> produits,
    required double total,
    required String adresse,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Créer la commande dans Firebase
      final commandeId = await FirebaseService.createCommande(
        produits,
        total,
        adresse,
      );

      // Mettre à jour les statistiques locales
      await LocalStorageService.incrementOrderCount();
      await LocalStorageService.addToTotalSpent(total);
      await LocalStorageService.saveLastAddress(adresse);

      _isLoading = false;
      notifyListeners();

      print(' Commande créée: $commandeId');
      return true;
    } catch (e) {
      _error = 'Erreur création commande: $e';
      _isLoading = false;
      notifyListeners();
      print(' Erreur createCommande: $e');
      return false;
    }
  }

  /// Filtrer les commandes par statut
  List<Commande> getCommandesByStatut(String statut) {
    return _commandes.where((cmd) => cmd.statut == statut).toList();
  }

  /// Obtenir une commande par ID
  Commande? getCommandeById(String id) {
    try {
      return _commandes.firstWhere((cmd) => cmd.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Réinitialiser l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Actualiser les commandes
  Future<void> refresh() async {
    await loadCommandes();
  }
}