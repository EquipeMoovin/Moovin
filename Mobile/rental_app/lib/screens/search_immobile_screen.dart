import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/immobile.dart';
import 'detail_immobile_screen.dart';

class SearchImmobileScreen extends StatefulWidget {
  const SearchImmobileScreen({super.key});

  @override
  State<SearchImmobileScreen> createState() => _SearchImmobileScreenState();
}

class _SearchImmobileScreenState extends State<SearchImmobileScreen> {

  TextEditingController _searchController = TextEditingController();
  String localization = '';
  final apiService = ApiService();
  List<Immobile> imoveis = [];
  bool isLoading = true;
  bool isPressed = false;
  final Map<String, String> tipoMap = {
  'Casa': 'house',
  'Apartamento': 'apartment',
  'Kitnet': 'kitnet',
    };


  @override
  void initState() {
    super.initState();
    fetchImmobiles({});
    _searchController.addListener(() {
      setState(() {
        localization = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchImmobiles(Map<String, dynamic>? filtros) async {
    try {
      
      final lista = await apiService.fetchImmobile(
                                type: filtros?['tipo'],
                                bedrooms: filtros?['quartos'],
                                bathrooms: filtros?['banheiros'],
                                garage: filtros?['garagem'],
                                rentValue: filtros?['valorAluguel'],
                                areaSize: filtros?['tamanho'],
                                distance: filtros?['distancia'],
                                date: filtros?['data'],
                                wifi: filtros?['itens']?['Wi-Fi'],
                                airConditioning: filtros?['itens']?['Ar-condicionado'],
                                petFriendly: filtros?['itens']?['Aceita pets'],
                                furnished: filtros?['itens']?['Mobiliado'],
                                pool: filtros?['itens']?['Piscina'],
                                city: filtros?['city'],
                              );

      setState(() {
        imoveis = lista;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao buscar imóveis: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _abrirBottomSheet(BuildContext context) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      DateTime? selectedDate;
      int quartos = 2;
      int banheiros = 1;
      double tamanho = 100;
      double distancia = 10;
      int garagem = 1;
      double valorAluguel = 1500;
      String tipoSelecionado = "";

      Map<String, bool> itens = {
        "Wi-Fi": true,
        "Ar-condicionado": false,
        "Aceita pets": true,
        "Mobiliado": false,
        "Piscina": false,
      };

      Map<String, bool> filtrosAtivos = {
        "tipo": false,
        "quartos": false,
        "banheiros": false,
        "garagem": false,
        "valorAluguel": false,
        "tamanho": false,
        "distancia": false,
        "data": false,
        "itens": false,
      };

      return StatefulBuilder(
        builder: (context, setState) {
          Widget buildSwitch(String label, String chave) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    value: filtrosAtivos[chave]!,
                    onChanged: (v) => setState(() => filtrosAtivos[chave] = v),
                  ),
                ),
              ],
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Filtros de Busca",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  buildSwitch("Filtrar por tipo de imóvel", "tipo"),
                  if (filtrosAtivos["tipo"]!)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCategoryButton(
                          context,
                          icon: Icons.home_work_outlined,
                          label: "Casa",
                          selected: tipoSelecionado == "Casa",
                          onTap: () {
                            setState(() {
                              tipoSelecionado = tipoSelecionado == "Casa" ? "" : "Casa";
                            });
                          },
                        ),
                        _buildCategoryButton(
                          context,
                          icon: Icons.apartment,
                          label: "Apartamento",
                          selected: tipoSelecionado == "Apartamento",
                          onTap: () {
                            setState(() {
                              tipoSelecionado = tipoSelecionado == "Apartamento" ? "" : "Apartamento";
                            });
                          },
                        ),
                        _buildCategoryButton(
                          context,
                          icon: Icons.house_outlined,
                          label: "Kitnet",
                          selected: tipoSelecionado == "Kitnet",
                          onTap: () {
                            setState(() {
                              tipoSelecionado = tipoSelecionado == "Kitnet" ? "" : "Kitnet";
                            });
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  buildSwitch("Filtrar por número de quartos", "quartos"),
                  if (filtrosAtivos["quartos"]!)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => setState(() {
                            if (quartos > 0) quartos--;
                          }),
                        ),
                        Text("$quartos"),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() {
                            quartos++;
                          }),
                        ),
                      ],
                    ),

                  buildSwitch("Filtrar por número de banheiros", "banheiros"),
                  if (filtrosAtivos["banheiros"]!)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => setState(() {
                            if (banheiros > 0) banheiros--;
                          }),
                        ),
                        Text("$banheiros"),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() {
                            banheiros++;
                          }),
                        ),
                      ],
                    ),

                  buildSwitch("Filtrar por garagem", "garagem"),
                  if (filtrosAtivos["garagem"]!)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => setState(() {
                            if (garagem > 0) garagem--;
                          }),
                        ),
                        Text("$garagem"),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() {
                            garagem++;
                          }),
                        ),
                      ],
                    ),

                  buildSwitch("Filtrar por valor de aluguel", "valorAluguel"),
                  if (filtrosAtivos["valorAluguel"]!)
                    Slider(
                      value: valorAluguel,
                      min: 500,
                      max: 10000,
                      divisions: 95,
                      label: "R\$ ${valorAluguel.toInt()}",
                      onChanged: (value) => setState(() => valorAluguel = value),
                    ),

                  buildSwitch("Filtrar por tamanho do imóvel", "tamanho"),
                  if (filtrosAtivos["tamanho"]!)
                    Slider(
                      value: tamanho,
                      min: 20,
                      max: 1000,
                      divisions: 50,
                      label: "${tamanho.toInt()} m²",
                      onChanged: (value) => setState(() => tamanho = value),
                    ),

                  buildSwitch("Filtrar por distância", "distancia"),
                  if (filtrosAtivos["distancia"]!)
                    Slider(
                      value: distancia,
                      min: 1,
                      max: 100,
                      divisions: 20,
                      label: "${distancia.toInt()} km",
                      onChanged: (value) => setState(() => distancia = value),
                    ),

                  buildSwitch("Filtrar por data de anúncio", "data"),
                  if (filtrosAtivos["data"]!)
                    ElevatedButton.icon(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        selectedDate != null
                            ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                            : "Selecionar data",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        elevation: 0,
                      ),
                    ),

                  buildSwitch("Filtrar por itens do imóvel", "itens"),
                  if (filtrosAtivos["itens"]!)
                    ...itens.entries.map((entry) => CheckboxListTile(
                          title: Text(entry.key),
                          value: entry.value,
                          onChanged: (value) => setState(() {
                            itens[entry.key] = value ?? false;
                          }),
                        )),

                  const SizedBox(height: 20),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          "tipo": tipoSelecionado,
                          "quartos": quartos,
                          "banheiros": banheiros,
                          "garagem": garagem,
                          "valorAluguel": valorAluguel,
                          "tamanho": tamanho,
                          "distancia": distancia,
                          "data": selectedDate,
                          "itens": itens,
                          "filtrosAtivos": filtrosAtivos,
                        });
                      },
                      child: const Text("Aplicar Filtros"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );




}
  Map<String, bool> isPressedMap = {
  'Casa': false,
  'Apartamento': false,
  'Kitnet': false,
};

Widget _buildCategoryButton(
  BuildContext context, {
  required IconData icon,
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    onTapDown: (_) {
      // Ao pressionar o botão
      setState(() {
        isPressed = true;
      });
    },
    onTapUp: (_) {
      // Quando o botão é liberado
      setState(() {
        isPressed = false;
      });
    },
    onTapCancel: () {
      // Caso o toque seja cancelado
      setState(() {
        isPressed = false;
      });
    },
    child: Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).primaryColor : Colors.grey[200],
            shape: BoxShape.circle,
            boxShadow: isPressed
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 4), // Sombra para efeito de pressionamento
                    )
                  ]
                : [],
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 30,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(color: selected ? Theme.of(context).primaryColor : Colors.black),
        ),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Pesquisar',
      backgroundColor: Colors.green,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat),
      label: 'Chat',
      backgroundColor: Colors.green,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite),
      label: 'Favoritos',
      backgroundColor: Colors.green,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Perfil',
      
      backgroundColor: Colors.green,
    ),
  ],
  backgroundColor: Colors.green[600],
  selectedItemColor: Colors.white,
  unselectedItemColor: Colors.white70,
  currentIndex: 3, // Esta linha pode ser ajustada dinamicamente conforme o índice da rota
  onTap: (index) {
    // Handle navigation
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/search-immobile');  // Rota para "Pesquisar"
        break;
      case 1:
        Navigator.pushNamed(context, '/chat');  // Rota para "Chat"
        break;
      case 2:
        Navigator.pushNamed(context, '/favorites');  // Rota para "Favoritos"
        break;
      case 3:
        Navigator.pushNamed(context, '/tenant');  // Rota para "Perfil"
        break;
      default:
        break;
    }
  },
),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 24),
            const Text(
              "Encontre seu imóvel dos sonhos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (value){localization = value;},
              onSubmitted: (value) async {
                      setState(() {
                        isLoading = true;
                      });
                      await fetchImmobiles({'city': value});
                    },     
              decoration: InputDecoration(
                hintText: "Busque pela localização",
                prefixIcon: const Icon(Icons.search),
               suffixIcon: GestureDetector(
               onTap: () async {
                            final filtros = await _abrirBottomSheet(context);
                            
                            if (filtros != null) {
                              // Exibe os filtros para debug
                              print(filtros);
                              
                              // Avisa que está carregando antes de fazer a requisição
                              setState(() {
                                isLoading = true;
                              });

                              // Chama a função fetchImmobiles com os filtros
                              Map<String, dynamic> filtrosSelecionados = {
                                "tipo": filtros["tipo"]?.isNotEmpty ?? false ? filtros["tipo"] : null,
                                "quartos": filtros["quartos"] != null && filtros["filtrosAtivos"]["quartos"] ? filtros["quartos"] : null,
                                "banheiros": filtros["banheiros"] != null && filtros["filtrosAtivos"]["banheiros"] ? filtros["banheiros"] : null,
                                "garagem": filtros["garagem"] != null && filtros["filtrosAtivos"]["garagem"] ? filtros["garagem"] : null,
                                "valorAluguel": filtros["valorAluguel"] != null && filtros["filtrosAtivos"]["valorAluguel"] ? filtros["valorAluguel"] : null,
                                "tamanho": filtros["tamanho"] != null && filtros["filtrosAtivos"]["tamanho"] ? filtros["tamanho"] : null,
                                "distancia": filtros["distancia"] != null && filtros["filtrosAtivos"]["distancia"] ? filtros["distancia"] : null,
                                "data": filtros["data"] != null && filtros["filtrosAtivos"]["data"] ? filtros["data"] : null,
                                "itens": filtros["itens"] != null && filtros["filtrosAtivos"]["itens"] ? filtros["itens"] : null,
                                "filtrosAtivos": filtros["filtrosAtivos"],
                              };

                              // Remove filtros desnecessários (valores nulos)
                              filtrosSelecionados.removeWhere((key, value) => value == null);

                              // Chama a função fetchImmobiles com os filtros
                              await fetchImmobiles(filtrosSelecionados);
                            }
                          },
                child: const Icon(Icons.tune),
              ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:[  
                GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      isPressed = !isPressed; // Alterna o estado de pressionado
                                    });
                                    final tipoSelecionado = tipoMap['Casa']; // ou qualquer label clicado dinamicamente
                                    print('Tipo selecionado: $tipoSelecionado');
                                    await fetchImmobiles({'tipo': tipoSelecionado});
                                  },
                                  child: _buildCategoryButton(
                                    context,
                                    icon: Icons.house_outlined,
                                    label: "Casa",
                                    selected: 'House' == tipoMap['Casa'],
                                    onTap: () {
                                      setState(() {
                                        isPressedMap['Casa'] = true;  // Atualiza o estado de pressionado
                                      });
                                      final tipoSelecionado = tipoMap['Casa'];
                                      print('Tipo selecionado: $tipoSelecionado');
                                      fetchImmobiles({'tipo': tipoSelecionado});
                                    },
                                  ),
                                ),
                GestureDetector(onTap: () async {
                                    setState(() {
                                      isPressed = !isPressed; // Alterna o estado de pressionado
                                    });
                                    final tipoSelecionado = tipoMap['Apartamento']; // ou qualquer label clicado dinamicamente
                                    print('Tipo selecionado: $tipoSelecionado');
                                    await fetchImmobiles({'tipo': tipoSelecionado});
                                  },
                                  child: _buildCategoryButton(
                                    context,
                                    icon: Icons.apartment,
                                    label: "Apartamento",
                                    selected: 'Apartament' == tipoMap['Apartamento'],
                                    onTap: () {
                                      setState(() {
                                        isPressedMap['Apartamento'] = true; 
                                      });
                                      final tipoSelecionado = tipoMap['Apartamento'];
                                      print('Tipo selecionado: $tipoSelecionado');
                                      fetchImmobiles({'tipo': tipoSelecionado});
                                    },
                                  ),),
                             
                  GestureDetector(onTap: () async {
                                    setState(() {
                                      isPressed = !isPressed; // Alterna o estado de pressionado
                                    });
                                    final tipoSelecionado = tipoMap['Kitnet']; // ou qualquer label clicado dinamicamente
                                    print('Tipo selecionado: $tipoSelecionado');
                                    await fetchImmobiles({'tipo': tipoSelecionado});
                                  },
                                  child: _buildCategoryButton(
                                    context,
                                    icon: Icons.home_work_outlined,
                                    label: "Kitnet",
                                    selected: 'Kitnet' == tipoMap['Kitnet'],
                                    onTap: () {
                                      setState(() {
                                       isPressedMap['Kitnet'] = true; 
                                      });
                                      final tipoSelecionado = tipoMap['Kitnet'];
                                      print('Tipo selecionado: $tipoSelecionado');
                                      fetchImmobiles({'tipo': tipoSelecionado});
                                    },
                                  ),),              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Recomendações",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Align(
                  alignment: Alignment.center,
                  child:imoveis.isEmpty ? const Text(
                                                'Nenhum imóvel encontrado',
                                                style: TextStyle(fontSize: 16, color: Colors.grey),
                                              )
                            : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: imoveis.length, 
                              itemBuilder: (context, index) {
                                final imovel = imoveis[index];
                                    return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailImmobileScreen(immobileId: imovel.idImmobile), // Assumindo que 'imovel' tem um ID
                  ),
                );
              },
              child: PropertyCard(
                imageUrl: 'https://th.bing.com/th/id/OIP.Dzz0pHitTq_-nEuYC0dgtQHaFC?rs=1&pid=ImgDetMain',
                title: imovel.propertyType,
                location: '${imovel.city}, ${imovel.state}',
                beds: imovel.bedrooms,
                baths: imovel.bathrooms,
                size: 2,
                rating: 4.5,
              ),
            );

                              },
  ),)
                  
                  ,
          ],
        ),
      ),
    );
  }
}

class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryIcon({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 36),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}

class PropertyCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final int beds;
  final int baths;
  final int size;
  final double rating;

  const PropertyCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.beds,
    required this.baths,
    required this.size,
    required this.rating,
  });

  @override
 Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;

      return Center(
        child: Container(
          width: maxWidth > 600 ? 500 : maxWidth * 0.9, // Limita o tamanho máximo
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Image.network(imageUrl, width: 70, height: 70, fit: BoxFit.cover),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(location),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.bed, size: 16), Text(" $beds  "),
                        const Icon(Icons.bathtub, size: 16), Text(" $baths  "),
                        const Icon(Icons.square_foot, size: 16), Text(" ${size}m²"),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.green),
                  Text(rating.toStringAsFixed(1)),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
}
