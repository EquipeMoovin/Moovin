import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/immobile.dart';
import '../providers/owner_provider.dart';
import 'edit_immobile_screen.dart';

class OwnerImmobilesScreen extends StatelessWidget {
  const OwnerImmobilesScreen({Key? key}) : super(key: key);

  Future<void> _launchRegisterUrl() async {
    const url = 'https://moovin.onrender.com/api/immobile/register/part1/';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Não foi possível abrir $url';
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

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  // Ícone imóvel
                                  Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.home, size: 32),
                                  ),
                                  const SizedBox(width: 12),
                                  // Título e subtítulo
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${immobile.propertyType} em ${immobile.city}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${immobile.street}, ${immobile.number ?? 'S/N'}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Botão de editar
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.green),
                                    onPressed: () async {
                                      final updated = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditImmobileScreen(immobile: immobile),
                                        ),
                                      );
                                      if (updated == true) {
                                        await provider.fetchOwner();
                                      }
                                    },
                                  ),
                                ],
                              ),
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
