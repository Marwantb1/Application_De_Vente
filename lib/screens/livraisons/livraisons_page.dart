import 'package:flutter/material.dart';
import '../../models/livraison.dart';
import '../../services/firebase_service.dart';
import 'livraison_detail_page.dart';

class LivraisonsPage extends StatelessWidget {
  const LivraisonsPage({Key? key}) : super(key: key);

  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'En transit':
        return Colors.orange;
      case 'Livrée':
        return Colors.green;
      case 'En préparation':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatutIcon(String statut) {
    switch (statut) {
      case 'En transit':
        return Icons.local_shipping;
      case 'Livrée':
        return Icons.check_circle;
      case 'En préparation':
        return Icons.inventory;
      default:
        return Icons.help;
    }
  }

  String _getStatutMessage(String statut) {
    switch (statut) {
      case 'En transit':
        return 'En cours de livraison';
      case 'Livrée':
        return 'Livrée avec succès';
      case 'En préparation':
        return 'En cours de préparation';
      default:
        return statut;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Livraison>>(
      stream: FirebaseService.getLivraisonsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final livraisons = snapshot.data ?? [];

        if (livraisons.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Aucune livraison',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Vos livraisons apparaîtront ici',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Compter les livraisons par statut
        final livrees = livraisons.where((l) => l.statut == 'Livrée').length;
        final enCours = livraisons.length - livrees;

        return Column(
          children: [
            // Statistiques en haut
            Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Livrées',
                      livrees.toString(),
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'En cours',
                      enCours.toString(),
                      Colors.orange,
                      Icons.local_shipping,
                    ),
                  ),
                ],
              ),
            ),

            // Liste des livraisons
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: livraisons.length,
                itemBuilder: (context, index) {
                  final livraison = livraisons[index];
                  final estLivree = livraison.statut == 'Livrée';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LivraisonDetailPage(livraison: livraison),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatutColor(livraison.statut).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            // En-tête avec statut
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _getStatutColor(livraison.statut).withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _getStatutColor(livraison.statut),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getStatutIcon(livraison.statut),
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Livraison #${livraison.id.substring(0, 8).toUpperCase()}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getStatutMessage(livraison.statut),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _getStatutColor(livraison.statut),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Badge de statut
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatutColor(livraison.statut),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          estLivree ? Icons.check : Icons.schedule,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          estLivree ? 'LIVRÉE' : 'EN COURS',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Détails
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.receipt_long,
                                          size: 18, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Commande: ${livraison.commandeId.substring(0, 8).toUpperCase()}',
                                        style: TextStyle(color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 18, color: Colors.red),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          livraison.adresse,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_shipping,
                                        size: 18,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        livraison.transporteur,
                                        style: TextStyle(color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: estLivree
                                          ? Colors.green.shade50
                                          : Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          estLivree
                                              ? Icons.check_circle
                                              : Icons.access_time,
                                          size: 18,
                                          color: estLivree
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            estLivree
                                                ? 'Livrée le ${livraison.dateLivraison?.day}/${livraison.dateLivraison?.month}/${livraison.dateLivraison?.year}'
                                                : 'Livraison estimée: ${livraison.dateEstimee.day}/${livraison.dateEstimee.month}/${livraison.dateEstimee.year}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: estLivree
                                                  ? Colors.green.shade800
                                                  : Colors.orange.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}