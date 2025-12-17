class Commande {
  final String id;
  final String userId;
  final String clientNom;
  final DateTime date;
  final List<ProduitCommande> produits;
  final double total;
  final String statut;
  final String? livraisonId;

  Commande({
    required this.id,
    required this.userId,
    required this.clientNom,
    required this.date,
    required this.produits,
    required this.total,
    required this.statut,
    this.livraisonId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'clientNom': clientNom,
      'date': date.toIso8601String(),
      'produits': produits.map((p) => p.toMap()).toList(),
      'total': total,
      'statut': statut,
      'livraisonId': livraisonId,
    };
  }

  factory Commande.fromMap(String id, Map<String, dynamic> map) {
    return Commande(
      id: id,
      userId: map['userId'] ?? '',
      clientNom: map['clientNom'] ?? '',
      date: DateTime.parse(map['date']),
      produits: (map['produits'] as List<dynamic>)
          .map((p) => ProduitCommande.fromMap(p as Map<String, dynamic>))
          .toList(),
      total: (map['total'] ?? 0).toDouble(),
      statut: map['statut'] ?? '',
      livraisonId: map['livraisonId'],
    );
  }
}

class ProduitCommande {
  final String produitId;
  final String produitNom;
  final int quantite;
  final double prix;
  final String imageUrl;

  ProduitCommande({
    required this.produitId,
    required this.produitNom,
    required this.quantite,
    required this.prix,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'produitId': produitId,
      'produitNom': produitNom,
      'quantite': quantite,
      'prix': prix,
      'imageUrl': imageUrl,
    };
  }

  factory ProduitCommande.fromMap(Map<String, dynamic> map) {
    return ProduitCommande(
      produitId: map['produitId'] ?? '',
      produitNom: map['produitNom'] ?? '',
      quantite: map['quantite'] ?? 0,
      prix: (map['prix'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}