import 'package:flutter/material.dart';
import '../../models/produit.dart';
import '../../models/commande.dart';
import '../../services/produits_service.dart';
import '../../services/firebase_service.dart';
import 'produit_detail_page.dart';

class ProduitsPage extends StatelessWidget {
  const ProduitsPage({Key? key}) : super(key: key);

  void _showCommandDialog(BuildContext context, Produit produit) {
    int quantite = 1;
    final adresseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Commander ${produit.nom}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produit.nom,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Prix unitaire: ${produit.prix.toStringAsFixed(2)} DH'),
                Text(
                  'Stock disponible: ${produit.stock} unités',
                  style: TextStyle(
                    color: produit.stock < 10 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quantité:', style: TextStyle(fontSize: 16)),
                    Row(
                      children: [
                        IconButton(
                          onPressed: quantite > 1
                              ? () => setState(() => quantite--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$quantite', style: const TextStyle(fontSize: 18)),
                        IconButton(
                          onPressed: quantite < produit.stock
                              ? () => setState(() => quantite++)
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ],
                ),
                if (quantite >= produit.stock)
                  Text(
                    'Stock maximum atteint',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${(produit.prix * quantite).toStringAsFixed(2)} DH',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: adresseController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse de livraison',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: produit.stock < 1
                  ? null
                  : () async {
                      if (adresseController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez entrer une adresse'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Navigator.pop(context);

                      try {
                        final produitCommande = ProduitCommande(
                          produitId: produit.id,
                          produitNom: produit.nom,
                          quantite: quantite,
                          prix: produit.prix,
                          imageUrl: produit.imageUrl,
                        );

                        await FirebaseService.createCommande(
                          [produitCommande],
                          produit.prix * quantite,
                          adresseController.text,
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Commande passée avec succès!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: const Text('Commander'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Produit>>(
      stream: ProduitsService.getProduitsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final produits = snapshot.data ?? [];

        if (produits.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Aucun produit disponible',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: produits.length,
          itemBuilder: (context, index) {
            final produit = produits[index];
            final enRupture = produit.stock < 1;
            final stockFaible = produit.stock < 10 && produit.stock > 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: enRupture
                              ? Colors.grey.shade300
                              : Colors.blue.shade100,
                          child: Text(
                            produit.imageUrl,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                        if (enRupture)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.block,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      produit.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(produit.description),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(
                              label: Text('${produit.prix.toStringAsFixed(2)} DH'),
                              backgroundColor: Colors.green.shade100,
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Chip(
                              label: Text(produit.taille),
                              backgroundColor: Colors.blue.shade100,
                            ),
                            Chip(
                              label: Text(produit.couleur),
                              backgroundColor: Colors.orange.shade100,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              enRupture
                                  ? Icons.cancel
                                  : stockFaible
                                      ? Icons.warning
                                      : Icons.check_circle,
                              size: 16,
                              color: enRupture
                                  ? Colors.red
                                  : stockFaible
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              enRupture
                                  ? 'Rupture de stock'
                                  : 'Stock: ${produit.stock} unités',
                              style: TextStyle(
                                color: enRupture
                                    ? Colors.red
                                    : stockFaible
                                        ? Colors.orange
                                        : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProduitDetailPage(produit: produit),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: enRupture
                                ? null
                                : () => _showCommandDialog(context, produit),
                            icon: const Icon(Icons.shopping_cart),
                            label: Text(enRupture ? 'Indisponible' : 'Commander'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: enRupture ? Colors.grey : Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProduitDetailPage(produit: produit),
                            ),
                          ),
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Détails'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}