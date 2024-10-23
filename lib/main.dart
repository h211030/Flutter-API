import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universities in the US',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UniversityListScreen(),
    );
  }
}

class UniversityListScreen extends StatefulWidget {
  @override
  _UniversityListScreenState createState() => _UniversityListScreenState();
}

class _UniversityListScreenState extends State<UniversityListScreen> {
  List universities = [];
  List filteredUniversities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUniversities();
  }

  Future<void> fetchUniversities() async {
    final response = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=United+States'));

    if (response.statusCode == 200) {
      setState(() {
        universities = json.decode(response.body);
        filteredUniversities = universities; // Set initial filtered list
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load universities');
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Fungsi untuk melakukan pencarian
  void _filterUniversities(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredUniversities = universities;
      });
    } else {
      setState(() {
        filteredUniversities = universities
            .where((university) => university['name']
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Universities in the US'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Universities',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _filterUniversities, // Panggil fungsi filter saat teks diubah
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredUniversities.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredUniversities[index]['name']),
                        subtitle: InkWell(
                          onTap: () {
                            _launchURL(filteredUniversities[index]['web_pages'][0]);
                          },
                          child: Text(
                            filteredUniversities[index]['web_pages'][0],
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
