import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {

  final String data;

  DetailPage(this.data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Detai Page: $data')),
    );
  }
}
