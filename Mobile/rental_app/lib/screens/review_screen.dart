import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';
import '../providers/review_provider.dart';
import '../screens/review_create_screen.dart';

class ReviewsScreen extends StatefulWidget {
  final String reviewType; // 'TENANT', 'OWNER', 'PROPERTY'
  final int targetId;
  final String title;

  const ReviewsScreen({
    super.key,
    required this.reviewType,
    required this.targetId,
    this.title = 'Avaliações',
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  String? _targetName;

  @override
  void initState() {
    super.initState();
    _loadReviewsAndDetails();
  }

  Future<void> _loadReviewsAndDetails() async {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    await reviewProvider.fetchReviews(
      type: widget.reviewType,
      targetId: widget.targetId,
    );

    final details = await reviewProvider.fetchTargetDetails(
      type: widget.reviewType,
      id: widget.targetId,
    );

    setState(() {
      if (widget.reviewType == 'TENANT' || widget.reviewType == 'OWNER') {
        _targetName = details['name'] as String?;
      } else if (widget.reviewType == 'PROPERTY') {
        _targetName = details['property_type'] as String?;
      }
    });
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(_targetName ?? widget.title)),
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, reviewProvider, child) {
          if (reviewProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reviewProvider.error != null) {
            return Center(
              child: Text('Erro ao carregar as avaliações: ${reviewProvider.error}'),
            );
          }

          final reviews = reviewProvider.reviews;

          if (reviews.isEmpty) {
            return const Center(child: Text('Ainda não há avaliações.'));
          }

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review.authorUsername,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        _buildRatingStars(review.rating),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.comment.isNotEmpty ? review.comment : 'Sem comentário.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Divider(),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: Colors.green,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (_) => ReviewProvider(),
                child: Builder(
                  builder: (newContext) {
                    final reviewType = widget.reviewType == 'immobile'
                        ? 'PROPERTY'
                        : widget.reviewType;
                    final targetId = widget.targetId;
                    final targetName = _targetName ?? widget.title;

                    return CreateReviewScreen(
                      reviewType: reviewType,
                      targetId: targetId,
                      targetName: targetName,
                    );
                  },
                ),
              ),
            ),
          );

          // Recarrega as avaliações após o retorno da CreateReviewScreen
          await _loadReviewsAndDetails();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
