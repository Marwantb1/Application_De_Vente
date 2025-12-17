import 'package:flutter/material.dart';
import '../../models/produit.dart';
import '../../services/produits_service.dart';

class AdminProduitsPage extends StatelessWidget {
  const AdminProduitsPage({Key? key}) : super(key: key);

  void _showAjouterStockDialog(BuildContext context, Produit produit) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter du stock - ${produit.nom}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Stock actuel: ${produit.stock} unités'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Quantité à ajouter',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.add),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantite = int.tryParse(controller.text);
              if (quantite == null || quantite <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer une quantité valide'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await ProduitsService.augmenterStock(produit.id, quantite);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Stock augmenté de $quantite unités'),
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
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Stocks'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<List<Produit>>(
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
              child: Text('Aucun produit'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: produits.length,
            itemBuilder: (context, index) {
              final produit = produits[index];
              final stockFaible = produit.stock < 10;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: stockFaible 
                        ? Colors.red.shade100 
                        : Colors.blue.shade100,
                    child: Text(
                      produit.imageUrl,
                      style: const TextStyle(fontSize: 30),
                    ),
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
                      const SizedBox(height: 8),
                      Text('${produit.prix.toStringAsFixed(2)} DH'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: stockFaible
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              stockFaible ? Icons.warning : Icons.check_circle,
                              size: 16,
                              color: stockFaible ? Colors.red : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Stock: ${produit.stock} unités',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: stockFaible ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton.icon(
                    onPressed: () => _showAjouterStockDialog(context, produit),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}