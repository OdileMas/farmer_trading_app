import 'package:flutter/material.dart';

class RecommendationResultCard extends StatelessWidget {
  final String crop;

  const RecommendationResultCard({required this.crop});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Recommended Crop: $crop',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

