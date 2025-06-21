import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../providers/immobile_provider.dart';
import '../providers/review_provider.dart';
import '../providers/owner_provider.dart';
import '../models/immobile.dart';
import '../services/auth_service.dart';
import 'review_screen.dart';
import 'owner_profile_screen.dart';
import 'tenant_profile_screen.dart';
import 'search_immobile_screen.dart';
import 'notification_screen.dart';
import 'chat_screen.dart';
import '../providers/notification_provider.dart';
import 'unauthorized_screen.dart';
import '../providers/chat_provider.dart';
import '../providers/tenant_provider.dart';
import '../screens/conversation_detail_screen.dart';

class DetailImmobileScreen extends StatefulWidget {
  final int immobileId;
  const DetailImmobileScreen({super.key, required this.immobileId});

  @override
  _DetailImmobileScreenState createState() => _DetailImmobileScreenState();
}

class _DetailImmobileScreenState extends State<DetailImmobileScreen> {
  bool _isLoading = true;
  bool _isCreatingConversation = false;
  int _selectedIndex = 0;
  String? _userType;
  late int immobileId;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    immobileId = widget.immobileId;
    _checkAccess();
    _loadUserType();
    _fetchData();
  }

  Future<void> _loadUserType() async {
    final authService = AuthService();
    _userType = await authService.getUserType();
    setState(() {});
  }

  void _checkAccess() async {
    final authService = AuthService();
    bool loggedIn = await authService.isLoggedIn();

    if (!loggedIn) {
      Navigator.of(context).pushReplacementNamed('/erro-screen');
      return;
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    final immobileProvider = Provider.of<ImmobileProvider>(context, listen: false);
    final tenantProvider = Provider.of<TenantProvider>(context, listen: false);
    final ownerProvider = Provider.of<OwnerProvider>(context, listen: false);

    try {
      await Future.wait([
        immobileProvider.fetchImmobile(immobileId),
        tenantProvider.fetchTenant(),
        ownerProvider.fetchOwner(immobileId: immobileId),
      ]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados iniciais: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    final authService = AuthService();

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SearchImmobileScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NotificationScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
        break;
      case 3:
        _userType = await authService.getUserType();
        if (_userType == 'Proprietario') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OwnerProfileScreen()),
          );
        } else if (_userType == 'Inquilino') {
          Navigator.pushReplacement(
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
    }
  }

  Widget _buildThumbnail(String? imageBase64, String contentType) {
    if (imageBase64 == null || imageBase64.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[300],
        ),
        child: const Icon(Icons.image_not_supported_outlined),
      );
    }
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: MemoryImage(Uri.parse('data:$contentType;base64,$imageBase64').data!.contentAsBytes()),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.brown[300],
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(bool value, IconData icon, String label) {
    return value
        ? Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          )
        : Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.grey[600]),
          );
  }

  Widget _buildMapLabelWithIcon(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[800]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildMapLabel(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
    );
  }

  Widget _buildMapBlockLabel(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Detalhes do Imóvel', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border, color: Colors.white),
            onPressed: () {
              // Handle adding/removing from favorites
            },
          ),
        ],
      ),
      body: Consumer3<ImmobileProvider, OwnerProvider, TenantProvider>(
        builder: (context, immobileProvider, ownerProvider, tenantProvider, child) {
          if (immobileProvider.isLoading || ownerProvider.isLoading || tenantProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final immobile = immobileProvider.immobile;
          final owner = ownerProvider.owner;
          final tenant = tenantProvider.tenant;

          if (immobile == null) {
            return const Center(child: Text('Erro ao carregar detalhes do imóvel.'));
          }

          if (owner == null) {
            return const Center(child: Text('Proprietário não encontrado para este imóvel.'));
          }

          bool hasFetchedReviews = false;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      PageView(
                        children: immobile.photosBlob.map((photo) {
                          return Image.memory(
                            Uri.parse('data:${photo.contentType};base64,${photo.imageBase64}').data!.contentAsBytes(),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          );
                        }).toList().isNotEmpty
                            ? immobile.photosBlob.map((photo) {
                                return Image.memory(
                                  Uri.parse('data:${photo.contentType};base64,${photo.imageBase64}').data!.contentAsBytes(),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.contain,
                                );
                              }).toList()
                            : [
                                Container(
                                  color: Colors.grey[300],
                                  child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 50)),
                                )
                              ],
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...immobile.photosBlob.map((photo) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: _buildThumbnail(photo.imageBase64, photo.contentType),
                                );
                              }).toList(),
                              if (immobile.photosBlob.length > 3)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '+${immobile.photosBlob.length - 3}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(Icons.star_border, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            immobile.propertyType == 'house'
                                ? 'Casa'
                                : immobile.propertyType == 'apartment'
                                    ? 'Apartamento'
                                    : immobile.propertyType,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'R\$ ${immobile.rent.toStringAsFixed(2)}/mês',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${immobile.city}, ${immobile.state}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double screenWidth = constraints.maxWidth;
                          final double itemWidth = (screenWidth - (16 * 2) - (8 * 2)) / 3;

                          List<Widget> amenityChips = [];
                          amenityChips.add(SizedBox(width: itemWidth, child: _buildDetailChip(Icons.zoom_out_map, '${immobile.area} m²')));
                          amenityChips.add(SizedBox(width: itemWidth, child: _buildDetailChip(Icons.bed, '${immobile.bedrooms}')));
                          amenityChips.add(SizedBox(width: itemWidth, child: _buildDetailChip(Icons.bathtub, '${immobile.bathrooms}')));
                          if (immobile.airConditioning)
                            amenityChips.add(SizedBox(width: itemWidth, child: _buildDetailChip(Icons.ac_unit, 'Ar Cond.')));
                          if (immobile.garage)
                            amenityChips.add(SizedBox(width: itemWidth, child: _buildDetailChip(Icons.garage_outlined, 'Garagem')));
                          if (immobile.pool)
                            amenityChips.add(SizedBox(width: itemWidth, child: _buildDetailChip(Icons.pool, 'Piscina')));
                          if (immobile.furnished)
                            amenityChips.add(SizedBox(width: itemWidth, child: _buildDetailChip(Icons.chair, 'Mobiliado')));
                          if (immobile.petFriendly)
                            amenityChips.add(SizedBox(width: itemWidth, child: _buildDetailChip(Icons.pets, 'Pet Friendly')));
                          if (immobile.nearbyMarket)
                            amenityChips.add(SizedBox(width: itemWidth, child: _buildDetailChip(Icons.shopping_cart, 'Mercado P.')));
                          if (immobile.nearbyBus)
                            amenityChips.add(SizedBox(width: itemWidth, child: _buildDetailChip(Icons.directions_bus, 'Ônibus P.')));
                          if (immobile.internet)
                            amenityChips.add(SizedBox(width: itemWidth, child: _buildDetailChip(Icons.wifi, 'Internet')));

                          return Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: amenityChips,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Consumer<ReviewProvider>(
                        builder: (context, reviewProvider, child) {
                          if (!hasFetchedReviews) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              reviewProvider.fetchReviews(type: 'immobile', targetId: immobile.idImmobile);
                              hasFetchedReviews = true;
                            });
                          }

                          if (reviewProvider.isLoading) {
                            return const CircularProgressIndicator();
                          }
                          print('Reviews: ${reviewProvider.reviews}');
                          final reviews = reviewProvider.reviews;
                          double averageRating = 0;

                          if (reviews.isNotEmpty) {
                            final totalRating = reviews.fold<double>(0, (sum, review) => sum + review.rating);
                            averageRating = totalRating / reviews.length;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReviewsScreen(
                                          reviewType: 'PROPERTY',
                                          targetId: immobile.idImmobile,
                                          title: 'Avaliações do Imóvel',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      StarRating(rating: averageRating, starSize: 20),
                                      const SizedBox(width: 8),
                                      Text('(${reviews.length} avaliações)', style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/review',
                                        arguments: {
                                          'reviewType': 'immobile',
                                          'targetId': immobile.idImmobile,
                                          'targetName': immobile.propertyType,
                                        },
                                      );
                                    },
                                    child: const Text('Ver avaliações'),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Sem avaliações ainda.', style: TextStyle(color: Colors.grey)),
                                const SizedBox(height: 4),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/review',
                                      arguments: {
                                        'reviewType': 'immobile',
                                        'targetId': immobile.idImmobile,
                                        'targetName': immobile.propertyType,
                                      },
                                    );
                                  },
                                  child: const Text('Ver avaliações'),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Detalhes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        immobile.description,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      if (immobile.additionalRules != null && immobile.additionalRules!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'Regras Adicionais',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              immobile.additionalRules!,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.green[600],
        onTap: _onItemTapped,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32.0, right: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: FloatingActionButton.extended(
                onPressed: () async {
                  setState(() {
                    _isCreatingConversation = true;
                  });

                  final authService = AuthService();
                  final userType = await authService.getUserType();
                  final token = await _secureStorage.read(key: 'access_token');

                  if (userType != 'Inquilino' || token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Apenas inquilinos podem iniciar conversas.')),
                    );
                    setState(() {
                      _isCreatingConversation = false;
                    });
                    return;
                  }

                  try {
                    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                    final immobileProvider = Provider.of<ImmobileProvider>(context, listen: false);
                    final tenantProvider = Provider.of<TenantProvider>(context, listen: false);
                    final ownerProvider = Provider.of<OwnerProvider>(context, listen: false);

                    final immobile = immobileProvider.immobile;
                    final tenant = tenantProvider.tenant;
                    final owner = ownerProvider.owner;

                    if (immobile == null || tenant == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dados do imóvel ou inquilino não encontrados.')),
                      );
                      setState(() {
                        _isCreatingConversation = false;
                      });
                      return;
                    }

                    if (owner == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Proprietário do imóvel não encontrado.')),
                      );
                      setState(() {
                        _isCreatingConversation = false;
                      });
                      return;
                    }

                    final conversation = await chatProvider.createConversation(
                      tenant.id,
                      owner.id,
                      immobile.idImmobile,
                    );

                    setState(() {
                      _isCreatingConversation = false;
                    });

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationDetailScreen(
                          conversationId: conversation.id,
                        ),
                      ),
                    );

                    Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
                  } catch (e) {
                    setState(() {
                      _isCreatingConversation = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao iniciar conversa: $e')),
                    );
                  }
                },
                backgroundColor: Colors.blue,
                icon: _isCreatingConversation
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.chat, color: Colors.white),
                label: Text(
                  _isCreatingConversation ? 'Carregando...' : 'Falar com proprietário',
                  style: const TextStyle(color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            const SizedBox(width: 10),
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OwnerProfileScreen(immobileId: immobileId),
                  ),
                );
              },
              backgroundColor: Colors.orange,
              icon: const Icon(Icons.person, color: Colors.white),
              label: const Text('Ver Perfil', style: TextStyle(color: Colors.white)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating;
  final double starSize;
  final Color color;

  const StarRating({
    super.key,
    required this.rating,
    this.starSize = 18,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : index < rating
                  ? Icons.star_half
                  : Icons.star_border,
          color: color,
          size: starSize,
        );
      }),
    );
  }
}