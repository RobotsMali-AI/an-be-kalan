import 'package:flutter/material.dart';

class PageLettreNkalan extends StatelessWidget {
  const PageLettreNkalan({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nkalan'),
        elevation: 10,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 20,
        children: [
          Image.network(
            "https://intrld.com/wp-content/uploads/2017/07/MHD.jpg",
            width: 400,
            height: 200,
          ),
          OutlinedButton(onPressed: () {}, child: const Text("A")),
        ],
      ),
    );
  }
}
