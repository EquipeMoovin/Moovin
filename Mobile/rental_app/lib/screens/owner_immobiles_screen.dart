import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/immobile.dart';
import '../providers/owner_provider.dart';
import 'edit_immobile_screen.dart';

class OwnerImmobilesScreen extends StatelessWidget {
  const OwnerImmobilesScreen({Key? key}) : super(key: key);

  Future<void> _launchRegisterUrl() async {
    const url = 'http://127.0.0.1:8000/api/immobile/register/part1/'; 

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Handle error (e.g., show a snackbar)
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerProvider>(context);
    final owner = provider.owner;
    final isLoading = provider.isLoading;
    final error = provider.error;

    List<Immobile> immobiles = owner?.properties ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Imóveis'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Erro: $error'))
              : immobiles.isEmpty
                  ? const Center(child: Text('Nenhum imóvel encontrado.'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        await provider.fetchOwner();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: immobiles.length,
                        itemBuilder: (context, index) {
                          final immobile = immobiles[index];
                          final imageUrl = immobile.photosBlob.isNotEmpty
                              ? immobile.photosBlob.first.imageBase64
                              : null;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: imageUrl != null && imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.home, size: 32),
                                    ),
                              title: Text(
                                '${immobile.propertyType} em ${immobile.city}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle:
                                  Text('${immobile.street}, ${immobile.number ?? 'S/N'}'),
                              trailing: const Icon(Icons.edit, color: Colors.green),
                              onTap: () async {
                                final updated = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditImmobileScreen(immobile: immobile),
                                  ),
                                );
                                if (updated == true) {
                                  await provider.fetchOwner(); // Recarrega
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _launchRegisterUrl();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao abrir a página: $e')),
            );
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add_home),
        tooltip: 'Cadastrar Imóvel',
      ),
    );
  }
}