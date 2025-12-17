import 'package:flutter/material.dart';
import '../../models/produit.dart';
import '../../widgets/info_card.dart';

class ProduitDetailPage extends StatelessWidget {
  final Produit produit;

  const ProduitDetailPage({Key? key, required this.produit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(produit.nom),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: Center(
                child: Text(
                  produit.imageUrl,
                  style: const TextStyle(fontSize: 120),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produit.nom,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${produit.prix.toStringAsFixed(2)} DH',
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    produit.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      InfoCard(label: 'Catégorie', value: produit.categorie),
                      const SizedBox(width: 16),
                      InfoCard(label: 'Taille', value: produit.taille),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      InfoCard(label: 'Couleur', value: produit.couleur),
                      const SizedBox(width: 16),
                      InfoCard(label: 'Stock', value: '${produit.stock} unités'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}