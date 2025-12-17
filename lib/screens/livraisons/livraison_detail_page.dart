import 'package:flutter/material.dart';
import '../../models/livraison.dart';

class LivraisonDetailPage extends StatelessWidget {
  final Livraison livraison;

  const LivraisonDetailPage({Key? key, required this.livraison}) : super(key: key);

  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'En transit': return Colors.orange;
      case 'Livrée': return Colors.green;
      case 'En préparation': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData _getStatutIcon(String statut) {
    switch (statut) {
      case 'En transit': return Icons.local_shipping;
      case 'Livrée': return Icons.check_circle;
      case 'En préparation': return Icons.inventory;
      default: return Icons.help;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    bool isPreparation = true;
    bool isTransit = livraison.statut == 'En transit' || livraison.statut == 'Livrée';
    bool isLivree = livraison.statut == 'Livrée';

    return Column(
      children: [
        _buildTimelineItem(
          'Commande en préparation',
          isPreparation,
          Icons.inventory,
          isFirst: true,
        ),
        _buildTimelineItem(
          'En transit',
          isTransit,
          Icons.local_shipping,
        ),
        _buildTimelineItem(
          'Livrée',
          isLivree,
          Icons.check_circle,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String title, bool isActive, IconData icon, {bool isFirst = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: isActive ? Colors.green : Colors.grey.shade300,
              ),
            Icon(
              icon,
              color: isActive ? Colors.green : Colors.grey.shade300,
              size: 32,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 20,
                color: isActive ? Colors.green : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Livraison ${livraison.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: _getStatutColor(livraison.statut).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_getStatutIcon(livraison.statut), color: _getStatutColor(livraison.statut), size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Statut', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              Text(
                                livraison.statut,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatutColor(livraison.statut),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informations de livraison', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _buildInfoRow('ID Livraison', livraison.id),
                    _buildInfoRow('Commande', livraison.commandeId),
                    _buildInfoRow('Transporteur', livraison.transporteur),
                    _buildInfoRow(
                      'Date estimée',
                      '${livraison.dateEstimee.day}/${livraison.dateEstimee.month}/${livraison.dateEstimee.year}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Adresse de livraison', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(),
                    Text(
                      livraison.adresse,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Suivi de la livraison', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _buildTrackingTimeline(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}