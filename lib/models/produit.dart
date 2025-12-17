class Produit {
  final String id;
  final String nom;
  final String description;
  final double prix;
  final String categorie;
  final String taille;
  final String couleur;
  int stock; // Non final pour pouvoir modifier
  final String imageUrl;

  Produit({
    required this.id,
    required this.nom,
    required this.description,
    required this.prix,
    required this.categorie,
    required this.taille,
    required this.couleur,
    required this.stock,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'description': description,
      'prix': prix,
      'categorie': categorie,
      'taille': taille,
      'couleur': couleur,
      'stock': stock,
      'imageUrl': imageUrl,
    };
  }

  factory Produit.fromMap(String id, Map<String, dynamic> map) {
    return Produit(
      id: id,
      nom: map['nom'] ?? '',
      description: map['description'] ?? '',
      prix: (map['prix'] ?? 0).toDouble(),
      categorie: map['categorie'] ?? '',
      taille: map['taille'] ?? '',
      couleur: map['couleur'] ?? '',
      stock: map['stock'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}