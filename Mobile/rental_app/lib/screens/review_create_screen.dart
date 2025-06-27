import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';

class CreateReviewScreen extends StatefulWidget {
  final String reviewType;
  final int targetId;
  final String targetName; // Nome do Owner, Tenant ou propertyType

  const CreateReviewScreen({
    super.key,
    required this.reviewType,
    required this.targetId,
    required this.targetName,
  });

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  @override
  void initState() {
    super.initState();// print removido por segurança
    // ... outras inicializações
  }
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  Widget _buildStar(int starCount) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _rating = starCount;
        });
      },
      child: Icon(
        starCount <= _rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    const int currentUserId = 1; 

    String titleText = '';
    if (widget.reviewType == 'OWNER') {
      titleText = 'Avaliar Proprietário(a): ${widget.targetName}';
    } else if (widget.reviewType == 'TENANT') {
      titleText = 'Avaliar Inquilino(a): ${widget.targetName}';
    } else if (widget.reviewType == 'PROPERTY') {
      titleText = 'Avaliar Imóvel: ${widget.targetName}';
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Avaliar'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            
            child: TextButton(
              onPressed: _rating > 0
                  ? () async {
                      await reviewProvider.submitReview(
                        rating: _rating,
                        comment: _commentController.text.isNotEmpty ? _commentController.text : null,
                        type: widget.reviewType,
                        targetId: widget.targetId,
                        authorId: currentUserId,
                      );
                      Navigator.pop(context);
                    }
                  : null,
              style: TextButton.styleFrom(
                backgroundColor: _rating > 0 ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Postar'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[300],
                    ),
                    child: const Icon(Icons.person, size: 40, color: Colors.grey), // Placeholder icon
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.targetName, // Display the passed name
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Score:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildStar(1),
                _buildStar(2),
                _buildStar(3),
                _buildStar(4),
                _buildStar(5),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Review:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Compartilhe sua experiência...',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
