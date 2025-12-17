import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/commande.dart';
import '../models/livraison.dart';
import 'auth_service.dart';
import 'produits_service.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // COMMANDES avec diminution du stock
  static Future<String> createCommande(
    List<ProduitCommande> produits,
    double total,
    String adresse,
  ) async {
    try {
      final userId = AuthService.currentUserId!;
      final userEmail = AuthService.currentUserEmail!;

      // Diminuer le stock de chaque produit commandé
      for (var produit in produits) {
        await ProduitsService.diminuerStock(produit.produitId, produit.quantite);
      }

      final commandeRef = await _db.collection('commandes').add({
        'userId': userId,
        'clientNom': userEmail,
        'date': DateTime.now().toIso8601String(),
        'produits': produits.map((p) => p.toMap()).toList(),
        'total': total,
        'statut': 'En préparation',
      });

      final livraisonRef = await _db.collection('livraisons').add({
        'commandeId': commandeRef.id,
        'userId': userId,
        'adresse': adresse,
        'dateEstimee': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'statut': 'En préparation',
        'transporteur': 'Amana Express',
      });

      await commandeRef.update({'livraisonId': livraisonRef.id});

      return commandeRef.id;
    } catch (e) {
      print('Erreur création commande: $e');
      rethrow;
    }
  }

  static Stream<List<Commande>> getCommandesStream() {
    final userId = AuthService.currentUserId;
    if (userId == null) return Stream.value([]);

    return _db
        .collection('commandes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final commandes = snapshot.docs.map((doc) {
        return Commande.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      
      commandes.sort((a, b) => b.date.compareTo(a.date));
      return commandes;
    });
  }

  // TOUTES les commandes (pour l'admin)
  static Stream<List<Commande>> getAllCommandesStream() {
    return _db
        .collection('commandes')
        .snapshots()
        .map((snapshot) {
      final commandes = snapshot.docs.map((doc) {
        return Commande.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      
      commandes.sort((a, b) => b.date.compareTo(a.date));
      return commandes;
    });
  }

  static Stream<List<Livraison>> getLivraisonsStream() {
    final userId = AuthService.currentUserId;
    if (userId == null) return Stream.value([]);

    return _db
        .collection('livraisons')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final livraisons = <Livraison>[];
      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        var livraison = Livraison.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        
        if (livraison.statut != 'Livrée' && now.isAfter(livraison.dateEstimee)) {
          await _db.collection('livraisons').doc(doc.id).update({
            'statut': 'Livrée',
            'dateLivraison': now.toIso8601String(),
          });
          
          await _db.collection('commandes').doc(livraison.commandeId).update({
            'statut': 'Livrée',
          });
          
          livraison = Livraison(
            id: livraison.id,
            commandeId: livraison.commandeId,
            userId: livraison.userId,
            adresse: livraison.adresse,
            dateEstimee: livraison.dateEstimee,
            statut: 'Livrée',
            transporteur: livraison.transporteur,
            dateLivraison: now,
          );
        }
        
        livraisons.add(livraison);
      }
      
      livraisons.sort((a, b) => b.dateEstimee.compareTo(a.dateEstimee));
      return livraisons;
    });
  }

  static Future<Livraison?> getLivraisonByCommandeId(String commandeId) async {
    try {
      final snapshot = await _db
          .collection('livraisons')
          .where('commandeId', isEqualTo: commandeId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Livraison.fromMap(
          snapshot.docs.first.id,
          snapshot.docs.first.data() as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      print('Erreur récupération livraison: $e');
      return null;
    }
  }

  static Future<void> updateLivraisonStatut(
    String livraisonId,
    String commandeId,
    String nouveauStatut,
  ) async {
    try {
      final updates = {
        'statut': nouveauStatut,
      };

      if (nouveauStatut == 'Livrée') {
        updates['dateLivraison'] = DateTime.now().toIso8601String();
      }

      await _db.collection('livraisons').doc(livraisonId).update(updates);
      
      await _db.collection('commandes').doc(commandeId).update({
        'statut': nouveauStatut,
      });
    } catch (e) {
      print('Erreur mise à jour statut: $e');
      rethrow;
    }
  }
}