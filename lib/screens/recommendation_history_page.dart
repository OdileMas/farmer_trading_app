import 'package:flutter/material.dart';
import '../services/db_helper.dart';

class RecommendationHistoryPage extends StatefulWidget {
  final int farmerId;

  const RecommendationHistoryPage({Key? key, required this.farmerId}) : super(key: key);

  @override
  _RecommendationHistoryPageState createState() => _RecommendationHistoryPageState();
}

class _RecommendationHistoryPageState extends State<RecommendationHistoryPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final data = await dbHelper.getRecommendationsByFarmerId(widget.farmerId);
    setState(() {
      _recommendations = data;
      _isLoading = false;
    });
  }

  String formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Recommendation History"),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recommendations.isEmpty
              ? const Center(child: Text("No recommendations found."))
              : ListView.builder(
                  itemCount: _recommendations.length,
                  itemBuilder: (context, index) {
                    final item = _recommendations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.agriculture, color: Colors.green),
                        title: Text(item['crop_name']),
                        subtitle: Text("Recommended on ${formatDate(item['recommendation_date'])}"),
                      ),
                    );
                  },
                ),
    );
  }
}
