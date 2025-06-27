import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'review_screen.dart';
import '../providers/review_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/owner_provider.dart';
import '../models/owner.dart'; // O seu modelo Owner já foi atualizado e tem 'photos'
import 'edit_owner_profile_screen.dart';
import 'owner_immobiles_screen.dart';
import 'edit_immobile_screen.dart';
import '../services/auth_service.dart';
import 'search_immobile_screen.dart';
import 'notification_screen.dart';
import 'chat_screen.dart';
import 'tenant_profile_screen.dart';
import 'login_screen.dart';
import '../providers/notification_provider.dart';
import 'unauthorized_screen.dart';
import 'dart:convert';

class OwnerProfileScreen extends StatefulWidget {
  final int? immobileId;
  const OwnerProfileScreen({Key? key, this.immobileId}) : super(key: key);

  @override
  _OwnerProfileScreenState createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  bool _isLoading = true;
  int _selectedIndex = 3;
  String? _userType;
  bool permissions = false;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    _userType = await _secureStorage.read(key: 'user_type');
    setState(() {});
  }

  Widget _buildItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.black),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _checkAccess() async {
    final authService = AuthService();
    bool loggedIn = await authService.isLoggedIn();
    bool isOwner = await authService.isOwner();

    if (!loggedIn) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    } else if (isOwner) {
      permissions = true;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OwnerProvider()..fetchOwner(immobileId: widget.immobileId)),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: Consumer<OwnerProvider>(
        builder: (context, provider, _) {
          final owner = provider.owner;
          bool hasFetchedReviews = false;

          // Extrai a URL da primeira foto, se existir
          final String? base64Image = owner != null && owner.photos.isNotEmpty
          ? owner.photos.first.imageBase64
          : null;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: const Text('Perfil'),
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  tooltip: 'Notificações',
                  onPressed: () {
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),
                if (permissions)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Editar Perfil',
                    onPressed: owner == null
                        ? null
                        : () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditOwnerProfileScreen(owner: owner),
                              ),
                            );
                            if (result == true) {
                              provider.fetchOwner(immobileId: widget.immobileId); // Recarrega após edição
                            }
                          },
                  ),
                if (permissions)
                  IconButton(
                    icon: const Icon(Icons.home_work),
                    tooltip: 'Meus Imóveis',
                    onPressed: owner == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OwnerImmobilesScreen(),
                              ),
                            );
                          },
                  ),
              ],
            ),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(child: Text('Erro: ${provider.error}'))
                    : owner == null
                        ? const Center(child: Text('Nenhum dado encontrado.'))
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(height: 150, color: Colors.green),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 50),
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.9,
                                          child: Card(
                                            elevation: 4,
                                            child: Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Column(
                                                children: [
                                                 CircleAvatar(
                                                  radius: 40,
                                                  backgroundColor: Colors.grey,
                                                  child: base64Image != null && base64Image.isNotEmpty
                                                      ? ClipOval(
                                                          child: Image.memory(
                                                            base64Decode(base64Image.split(',').last), // Remove prefixo se houver
                                                            width: 80,
                                                            height: 80,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )
                                                      : const Icon(Icons.person, size: 50, color: Colors.white),
                                                ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    owner.name,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(Icons.location_on, size: 16),
                                                      const SizedBox(width: 4),
                                                      Text('${owner.city}, ${owner.state}'),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Descrição', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text(owner.aboutMe.isNotEmpty ? owner.aboutMe : 'Nenhuma informação fornecida'),
                                      const SizedBox(height: 24),

                                      Consumer<ReviewProvider>(
                                        builder: (context, reviewProvider, child) {
                                          if (!hasFetchedReviews) {
                                            WidgetsBinding.instance.addPostFrameCallback((_) {
                                              if (owner != null && reviewProvider.reviews.isEmpty && !reviewProvider.isLoading) {
                                                reviewProvider.fetchReviews(targetId: owner.id, type: 'OWNER');
                                                hasFetchedReviews = true;
                                              }
                                            });
                                          }

                                          if (reviewProvider.isLoading) {
                                            return const CircularProgressIndicator();
                                          }

                                          final reviews = reviewProvider.reviews;
                                          double averageRating = 0;

                                          if (reviews.isNotEmpty) {
                                            final totalRating = reviews.fold<double>(0, (sum, review) => sum + review.rating);
                                            averageRating = totalRating / reviews.length;

                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Avaliação do proprietário', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 8),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ReviewsScreen(
                                                          reviewType: 'OWNER',
                                                          targetId: owner.id,
                                                          title: 'Avaliações do Proprietário',
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Text('${averageRating.toStringAsFixed(1)} ', style: const TextStyle(fontSize: 18)),
                                                      const Icon(Icons.star, color: Colors.amber),
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
                                                          'reviewType': 'OWNER',
                                                          'targetId': owner.id,
                                                          'targetName': owner.name,
                                                        },
                                                      );
                                                    },
                                                    child: const Text('Avaliar Proprietário'),
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else {
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Avaliação do proprietário', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 8),
                                                const Text('Nenhuma avaliação ainda.'),
                                                const SizedBox(height: 8),
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/review',
                                                        arguments: {
                                                          'reviewType': 'OWNER',
                                                          'targetId': owner.id,
                                                          'targetName': owner.name,
                                                        },
                                                      );
                                                    },
                                                    child: const Text('Avaliar Proprietário'),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      const Text('Histórico na plataforma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.green),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            _buildItem('🟢 ${owner.rentedProperties} imóveis alugados pela plataforma'),
                                            _buildItem('🟢 Perfil verificado'),
                                            _buildItem(owner.fastResponder
                                                ? '🟢 Responde rapidamente'
                                                : '🔴 Responde lentamente'),
                                            _buildItem('🟢 ${owner.rating.toStringAsFixed(1)} de avaliação dos inquilinos'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text('${owner.properties.length} imóveis anunciados',
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      ListView.builder(
                                        itemCount: owner.properties.length,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final p = owner.properties[index];
                                          final imageUrl = p.photosBlob.isNotEmpty
                                              ? p.photosBlob.first.imageBase64
                                              : null;
                                          return Card(
                                            margin: const EdgeInsets.only(bottom: 10),
                                            child: ListTile(
                                              leading: p.photosBlob.isNotEmpty
                                                        ? Image.memory(
                                                            base64Decode(p.photosBlob.first.imageBase64.split(',').last),
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
                                              title: Text('${p.propertyType} em ${p.city}',
                                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                                              subtitle: Text('${p.street}, ${p.number ?? 'S/N'}'),
                                              trailing: const Icon(Icons.edit, color: Colors.green),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => EditImmobileScreen(immobile: p),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => const OwnerImmobilesScreen(),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          child: const Text('Ver todos'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                  label: 'Chat',
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
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
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
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) => NotificationProvider(),
                          child: const NotificationScreen(),
                        ),
                      ),
                    );
                    break;
                  case 2:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                    break;
                  case 3:
                    if (_userType == 'Proprietario') {
                      // Already on OwnerProfileScreen, do nothing
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
              },
            ),
          );
        },
      ),
    );
  }
}