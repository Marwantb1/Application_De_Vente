import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/produit.dart';

class ProduitsService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Initialiser les produits dans Firebase (à faire une seule fois)
  static Future<void> initialiserProduits() async {
    final produitsExistants = await _db.collection('produits').get();
    
    if (produitsExistants.docs.isEmpty) {
      final produits = [
        {
          'nom': 'T-Shirt Classic',
          'description': 'T-shirt en coton 100% bio, confortable et respirant',
          'prix': 29.99,
          'categorie': 'T-Shirts',
          'taille': 'M',
          'couleur': 'Bleu',
          'stock': 50,
          'imageUrl': '👕',
        },
        {
          'nom': 'Jean Slim',
          'description': 'Jean slim fit, coupe moderne et élégante',
          'prix': 79.99,
          'categorie': 'Pantalons',
          'taille': 'L',
          'couleur': 'Noir',
          'stock': 30,
          'imageUrl': '👖',
        },
        {
          'nom': 'Robe d\'été',
          'description': 'Robe légère parfaite pour l\'été',
          'prix': 59.99,
          'categorie': 'Robes',
          'taille': 'S',
          'couleur': 'Rouge',
          'stock': 25,
          'imageUrl': '👗',
        },
        {
          'nom': 'Veste en Cuir',
          'description': 'Veste en cuir véritable, style intemporel',
          'prix': 199.99,
          'categorie': 'Vestes',
          'taille': 'L',
          'couleur': 'Marron',
          'stock': 15,
          'imageUrl': '🧥',
        },
        {
          'nom': 'Pull Laine',
          'description': 'Pull chaud en laine mérinos',
          'prix': 89.99,
          'categorie': 'Pulls',
          'taille': 'M',
          'couleur': 'Gris',
          'stock': 40,
          'imageUrl': '🧶',
        },
        {
          'nom': 'Chemise Blanche',
          'description': 'Chemise élégante pour toutes occasions',
          'prix': 49.99,
          'categorie': 'Chemises',
          'taille': 'L',
          'couleur': 'Blanc',
          'stock': 35,
          'imageUrl': '👔',
        },
        {
          'nom': 'Short Sport',
          'description': 'Short léger pour activités sportives',
          'prix': 34.99,
          'categorie': 'Sport',
          'taille': 'M',
          'couleur': 'Noir',
          'stock': 60,
          'imageUrl': '🩳',
        },
        {
          'nom': 'Manteau Hiver',
          'description': 'Manteau chaud pour l\'hiver',
          'prix': 249.99,
          'categorie': 'Manteaux',
          'taille': 'L',
          'couleur': 'Marine',
          'stock': 20,
          'imageUrl': '🧥',
        },
        {
          'nom': 'Pantalon Chino',
          'description': 'Pantalon chino confortable et stylé',
          'prix': 69.99,
          'categorie': 'Pantalons',
          'taille': 'M',
          'couleur': 'Beige',
          'stock': 45,
          'imageUrl': '👖',
        },
        {
          'nom': 'Polo Classique',
          'description': 'Polo intemporel en coton piqué',
          'prix': 39.99,
          'categorie': 'Polos',
          'taille': 'L',
          'couleur': 'Vert',
          'stock': 55,
          'imageUrl': '👕',
        },
      ];

      for (var produit in produits) {
        await _db.collection('produits').add(produit);
      }
    }
  }

  // Récupérer tous les produits en temps réel
  static Stream<List<Produit>> getProduitsStream() {
    return _db.collection('produits').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Produit.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Diminuer le stock lors d'une commande
  static Future<void> diminuerStock(String produitId, int quantite) async {
    try {
      final produitRef = _db.collection('produits').doc(produitId);
      
      await _db.runTransaction((transaction) async {
        final produitDoc = await transaction.get(produitRef);
        
        if (!produitDoc.exists) {
          throw Exception('Produit introuvable');
        }

        final stockActuel = produitDoc.data()!['stock'] as int;
        
        if (stockActuel < quantite) {
          throw Exception('Stock insuffisant');
        }

        transaction.update(produitRef, {
          'stock': stockActuel - quantite,
        });
      });
    } catch (e) {
      print('Erreur diminution stock: $e');
      rethrow;
    }
  }

  // Augmenter le stock (pour l'admin)
  static Future<void> augmenterStock(String produitId, int quantite) async {
    try {
      final produitRef = _db.collection('produits').doc(produitId);
      
      await _db.runTransaction((transaction) async {
        final produitDoc = await transaction.get(produitRef);
        
        if (!produitDoc.exists) {
          throw Exception('Produit introuvable');
        }

        final stockActuel = produitDoc.data()!['stock'] as int;
        
        transaction.update(produitRef, {
          'stock': stockActuel + quantite,
        });
      });
    } catch (e) {
      print('Erreur augmentation stock: $e');
      rethrow;
    }
  }
}