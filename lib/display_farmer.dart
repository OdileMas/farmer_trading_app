class FarmerListScreen extends StatefulWidget {
  @override
  _FarmerListScreenState createState() => _FarmerListScreenState();
}

class _FarmerListScreenState extends State<FarmerListScreen> {
  late Future<List<Map<String, dynamic>>> _farmers;
@override
void initState() {
  super.initState();
  _farmers = DatabaseHelper.instance.getFarmers(); // Make sure this is properly initialized
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Farmers List'),
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _farmers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final farmers = snapshot.data!;
        return ListView.builder(
          itemCount: farmers.length,
          itemBuilder: (context, index) {
            final farmer = farmers[index];
            return ListTile(
              title: Text(farmer['name']),
              subtitle: Text('${farmer['harvest']} - \$${farmer['price']}'),
            );
          },
        );
      },
    ),
  );
}
}