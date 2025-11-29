import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final String author;
  final String timeAgo;
  final double rating;
  final String comment;
  ReviewCard({
    required this.author,
    required this.timeAgo,
    required this.rating,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Icon(Icons.person)),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(author, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      timeAgo,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < rating.round() ? Icons.star : Icons.star_border,
                      size: 14,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(comment),
          ],
        ),
      ),
    );
  }
}
