class Livraison {
  final String id;
  final String commandeId;
  final String userId;
  final String adresse;
  final DateTime dateEstimee;
  final String statut; // 'En préparation', 'En transit', 'Livrée'
  final String transporteur;
  final DateTime? dateLivraison;

  Livraison({
    required this.id,
    required this.commandeId,
    required this.userId,
    required this.adresse,
    required this.dateEstimee,
    required this.statut,
    required this.transporteur,
    this.dateLivraison,
  });

  Map<String, dynamic> toMap() {
    return {
      'commandeId': commandeId,
      'userId': userId,
      'adresse': adresse,
      'dateEstimee': dateEstimee.toIso8601String(),
      'statut': statut,
      'transporteur': transporteur,
      'dateLivraison': dateLivraison?.toIso8601String(),
    };
  }

  factory Livraison.fromMap(String id, Map<String, dynamic> map) {
    return Livraison(
      id: id,
      commandeId: map['commandeId'] ?? '',
      userId: map['userId'] ?? '',
      adresse: map['adresse'] ?? '',
      dateEstimee: DateTime.parse(map['dateEstimee']),
      statut: map['statut'] ?? '',
      transporteur: map['transporteur'] ?? '',
      dateLivraison: map['dateLivraison'] != null 
          ? DateTime.parse(map['dateLivraison']) 
          : null,
    );
  }
}