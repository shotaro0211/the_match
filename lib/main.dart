import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> items = [];
  Map<String, dynamic>? selectedItem;
  late final io.Socket _socket;

  @override
  void initState() {
    _socket = io.io(
        'http://localhost:3031',
        OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    _socket.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('THE MATCH', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 100),
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  if (selectedItem != null) ...[
                    Image.network(selectedItem!['imageUrl']),
                    Text(selectedItem!['title'])
                  ] else ...[
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter a search Fighter',
                      ),
                      onChanged: (value) async {
                        final uri = Uri.parse(
                            'https://www.googleapis.com/youtube/v3/search?part=snippet&type=channel&maxResults=10&q=$value&key=AIzaSyAY8R7PCcSWRwDo48yOcea4prOqZHvwcYg');
                        final response = await get(uri);
                        if (response.statusCode != 200) {
                          print('ERROR ${response.body}');
                        } else {
                          final json =
                              jsonDecode(response.body) as Map<String, dynamic>;
                          setState(() {
                            items = (json['items'] as List<dynamic>)
                                .cast<Map<String, dynamic>>()
                                .map((e) => {
                                      'id': e['snippet']['channelId'],
                                      'title': e['snippet']['channelTitle'],
                                      'imageUrl': e['snippet']['thumbnails']
                                          ['default']['url']
                                    })
                                .toList();
                          });
                        }
                      },
                    ),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedItem = items[index];
                              });
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: Center(
                                child: Row(
                                  children: [
                                    Image.network(items[index]['imageUrl']),
                                    const SizedBox(width: 20),
                                    Text(items[index]['title']),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 100),
            OutlinedButton(
              onPressed: () {
                print(_socket.connected);
              },
              child:
                  Text('start', style: Theme.of(context).textTheme.headline2),
            ),
          ],
        ),
      ),
    );
  }
}
