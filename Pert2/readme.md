main()
 └── MyApp (StatelessWidget)
      └── MaterialApp
           └── MyHomePage (StatefulWidget)
                └── Scaffold
                     ├── AppBar
                     │    └── Text (Menampilkan judul 'myITS')
                     └── Center (Sebagai Body)
                          └── Text (Menampilkan pesan 'Welcome')

Dari code yang diberikan di classroom, saya memodifikasi dan menyesuaikan dengan file main.dart yang ada di template flutter saat kita membuat project. Tampilan project flutter yang dibuat berupa dummy aplikasi myits dan perubahan yang dilakukan berupa perubahan warna dan tulisan/teks

```
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: const Text('My App'),
        ),
        body: Center(
          child: Text(
            'Henshin',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              color: Colors.blueAccent,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          backgroundColor: Colors.amber,
          onPressed: () {},
        ),
      ),
    ),
  );
}
```
