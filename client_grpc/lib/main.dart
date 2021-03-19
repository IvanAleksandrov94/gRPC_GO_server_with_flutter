import 'dart:typed_data';

import 'package:client_grpc/protobuf/adder.pbgrpc.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Protobuf image',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Protobuf image'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AdderClient client;
  Uint8List imageViewFromBytes;

  void initState() {
    super.initState();
    client = AdderClient(ClientChannel('10.0.2.2',
        port: 4444, options: ChannelOptions(credentials: ChannelCredentials.insecure())));
  }

  void _callGrpcService(Uint8List image) async {
    var response = await client.add(AddRequest(image: image));
    imageViewFromBytes = response.imageResult;

    setState(() {});
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
            imageViewFromBytes != null ? Image.memory(imageViewFromBytes) : const SizedBox(),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () async {
                imageViewFromBytes = null;
                setState(() {});
                final file = ImagePicker();
                final image = await file.getImage(source: ImageSource.gallery);
                final Uint8List imageBytes = await image.readAsBytes();
                _callGrpcService(imageBytes);
              },
              child: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
