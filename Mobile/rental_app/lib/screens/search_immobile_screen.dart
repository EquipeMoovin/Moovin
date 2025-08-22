import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:rental_app/screens/owner_profile_screen.dart';

import 'package:rental_app/providers/immobile_provider.dart';

import '../services/api_service.dart';
import '../models/immobile.dart';
import '../models/review.dart';
import '../providers/review_provider.dart';
import '../providers/notification_provider.dart'; 
import 'detail_immobile_screen.dart';
import 'login_screen.dart';
import 'tenant_profile_screen.dart';
import 'owner_profile_screen.dart';
import 'owner_dashboard_screen.dart';
import 'notification_screen.dart'; 
import 'chat_screen.dart'; 
import '../providers/review_provider.dart';
import 'unauthorized_screen.dart';

import 'package:url_launcher/url_launcher.dart';

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

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String? _userType;
  int _selectedIndex = 0;

  final Map<String, String> tipoMap = {
    'Casa': 'house',
    'Apartamento': 'apartment',
    'Kitnet': 'kitnet',
  };

  @override
  void initState() {
    super.initState();
    _loadUserType();
    fetchImmobiles({});
    _searchController.addListener(() {
      setState(() {
        localization = _searchController.text;
      });
    });
  }

  Future<void> _loadUserType() async {
    _userType = await _secureStorage.read(key: 'user_type');
    setState(() {});
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
    } catch (e) {// print removido por segurança
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
        setState(() {
          isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
      },
      onTapCancel: () {
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
                        offset: const Offset(0, 4),
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
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 70,
              width: 70,
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: const Text(
                'Moovin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (String result) async {
              switch (result) {
                case 'dashboard_proprietario':
                  if (_userType == 'Proprietario') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OwnerDashboardScreen()),
                    );
                  }
                  break;
                case 'configuracoes':// print removido por segurança
                  break;
                case 'planos_assinaturas':
                   final Uri url = Uri.parse('https://moovin.onrender.com/api/owners/management/');
                   if (await canLaunchUrl(url)) {
                     await launchUrl(url, mode: LaunchMode.externalApplication); 
                    } else {
                     throw 'Não foi possível abrir o link: $url';
                              }
                              break;
                case 'logout':// print removido por segurança
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry<String>> menuItems = [
                const PopupMenuItem<String>(
                  value: 'configuracoes',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Configurações'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'planos_assinaturas',
                  child: Row(
                    children: [
                      Icon(Icons.subscriptions, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Planos e Assinaturas'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Sair'),
                    ],
                  ),
                ),
              ];

              if (_userType == 'Proprietario') {
                menuItems.insert(0,
                  const PopupMenuItem<String>(
                    value: 'dashboard_proprietario',
                    child: Row(
                      children: [
                        Icon(Icons.dashboard, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Dashboard do Proprietário'),
                      ],
                    ),
                  ),
                );
              }
              return menuItems;
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Pesquisar',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificações',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Conversas',
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
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (context) => NotificationProvider(),
                    child: const NotificationScreen(),
                  ),
                ),
              );
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
              break;
            case 3:
              if (_userType == 'Proprietario') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OwnerProfileScreen()),
                );
              } else if (_userType == 'Inquilino') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TenantProfileScreen()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const UnauthorizedScreen()),
                );
              }
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
              onChanged: (value) {
                localization = value;
              },
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

                    if (filtros != null) {// print removido por segurança

                      setState(() {
                        isLoading = true;
                      });

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

                      filtrosSelecionados.removeWhere((key, value) => value == null);

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
              children: [
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      isPressedMap['Casa'] = true;
                    });
                    final tipoSelecionado = tipoMap['Casa'];// print removido por segurança
                    await fetchImmobiles({'tipo': tipoSelecionado});
                    setState(() {
                      isPressedMap['Casa'] = false;
                    });
                  },
                  child: _buildCategoryButton(
                    context,
                    icon: Icons.house_outlined,
                    label: "Casa",
                    selected: isPressedMap['Casa']!,
                    onTap: () {
                      setState(() {
                        isPressedMap['Casa'] = !isPressedMap['Casa']!;
                        if (isPressedMap['Casa']!) {
                          isPressedMap['Apartamento'] = false;
                          isPressedMap['Kitnet'] = false;
                        }
                      });
                      final tipoSelecionado = isPressedMap['Casa']! ? tipoMap['Casa'] : null;// print removido por segurança
                      fetchImmobiles({'tipo': tipoSelecionado});
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      isPressedMap['Apartamento'] = true;
                    });
                    final tipoSelecionado = tipoMap['Apartamento'];// print removido por segurança
                    await fetchImmobiles({'tipo': tipoSelecionado});
                    setState(() {
                      isPressedMap['Apartamento'] = false;
                    });
                  },
                  child: _buildCategoryButton(
                    context,
                    icon: Icons.apartment,
                    label: "Apartamento",
                    selected: isPressedMap['Apartamento']!,
                    onTap: () {
                      setState(() {
                        isPressedMap['Apartamento'] = !isPressedMap['Apartamento']!;
                         if (isPressedMap['Apartamento']!) {
                          isPressedMap['Casa'] = false;
                          isPressedMap['Kitnet'] = false;
                        }
                      });
                      final tipoSelecionado = isPressedMap['Apartamento']! ? tipoMap['Apartamento'] : null;// print removido por segurança
                      fetchImmobiles({'tipo': tipoSelecionado});
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      isPressedMap['Kitnet'] = true;
                    });
                    final tipoSelecionado = tipoMap['Kitnet'];// print removido por segurança
                    await fetchImmobiles({'tipo': tipoSelecionado});
                    setState(() {
                      isPressedMap['Kitnet'] = false;
                    });
                  },
                  child: _buildCategoryButton(
                    context,
                    icon: Icons.home_work_outlined,
                    label: "Kitnet",
                    selected: isPressedMap['Kitnet']!,
                    onTap: () {
                      setState(() {
                        isPressedMap['Kitnet'] = !isPressedMap['Kitnet']!;
                        if (isPressedMap['Kitnet']!) {
                          isPressedMap['Casa'] = false;
                          isPressedMap['Apartamento'] = false;
                        }
                      });
                      final tipoSelecionado = isPressedMap['Kitnet']! ? tipoMap['Kitnet'] : null;// print removido por segurança
                      fetchImmobiles({'tipo': tipoSelecionado});
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Recomendações",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : imoveis.isEmpty
                      ? const Text(
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
                                    builder: (context) => ChangeNotifierProvider(
                                      create: (context) => ReviewProvider(),
                                      child: DetailImmobileScreen(immobileId: imovel.idImmobile),
                                    ),
                                  ),
                                );
                              },
                              child: FutureBuilder<Immobile>(
  future: ApiService().fetchOneImmobile(imovel.idImmobile),
  builder: (context, immobileSnapshot) {
    if (immobileSnapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox(
        height: 120, // Ajuste a altura conforme necessário
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (immobileSnapshot.hasError || !immobileSnapshot.hasData || immobileSnapshot.data?.photosBlob.isEmpty == true) {
      return PropertyCard(
        imageUrl: 'https://th.bing.com/th/id/OIP.Dzz0pHitTq_-nEuYC0dgtQHaFC?rs=1&pid=ImgDetMain',
        title: imovel.propertyType.toLowerCase() == 'house'
            ? 'Casa'
            : (imovel.propertyType.toLowerCase() == 'apartment' ? 'Apartamento' : imovel.propertyType),
        location: '${imovel.city}, ${imovel.state}',
        beds: imovel.bedrooms,
        baths: imovel.bathrooms,
        size: imovel.area?.toInt() ?? 0,
        rating: 4.0, // Ou algum valor padrão
      );
    }
    final immobileDetails = immobileSnapshot.data!;
    return FutureBuilder<List<Review>>(
      future: ApiService().fetchReviews(type: 'immobile', targetId: imovel.idImmobile),
      builder: (context, reviewSnapshot) {
        double averageRating = 4.0;
        int reviewCount = 0;
        if (reviewSnapshot.hasData && reviewSnapshot.data!.isNotEmpty) {
          final reviews = reviewSnapshot.data!;
          final totalRating = reviews.fold<double>(0, (sum, review) => sum + review.rating);
          averageRating = totalRating / reviews.length;
          reviewCount = reviews.length;
        }

        return PropertyCard(
          imageUrl: 'data:${immobileDetails.photosBlob.first.contentType};base64,${immobileDetails.photosBlob.first.imageBase64}',
              
          title: imovel.propertyType.toLowerCase() == 'house'
              ? 'Casa'
              : (imovel.propertyType.toLowerCase() == 'apartment' ? 'Apartamento' : imovel.propertyType),
          location: '${imovel.city}, ${imovel.state}',
          beds: immobileDetails.bedrooms ?? imovel.bedrooms,
          baths: immobileDetails.bathrooms ?? imovel.bathrooms,
          size: immobileDetails.area?.toInt() ?? 0,
          rating: averageRating, // Passa a avaliação média
          
        );
      },
    );
  },
),
                            );
                          },
                        ),
            ),
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
            width: maxWidth > 600 ? 500 : maxWidth * 0.9,
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
                          const Icon(Icons.bed, size: 16),
                          Text(" $beds  "),
                          const Icon(Icons.bathtub, size: 16),
                          Text(" $baths  "),
                          const Icon(Icons.square_foot, size: 16),
                          Text(" ${size}m²"),
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