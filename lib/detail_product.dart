import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DetailProdukPage extends StatefulWidget {
  final int productId;

  DetailProdukPage({super.key, required this.productId});

  @override
  _DetailProdukPageState createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukPage> {
  Map<String, dynamic> product = {};
  List<dynamic> reviews = [];
  int cartQuantity = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProductDetail();
  }

  Future<void> fetchProductDetail() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('http://192.168.43.150:3006/product/${widget.productId}?format=json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] != null && data['data']['product'] != null) {
          setState(() {
            product = data['data']['product']['data'] ?? {};
            reviews = data['data']['reviews'] ?? [];

            isLoading = false;
          });
        } else {
          throw Exception("Unexpected response format.");
        }
      } else {
        throw Exception("Failed to load product details: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching product details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // Format harga
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detail Produk",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : product.isEmpty
          ? Center(child: Text("Produk tidak ditemukan"))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gambar produk
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
                image: DecorationImage(
                  image: product['image_url'] != null
                      ? NetworkImage(product['image_url'])
                      : AssetImage('assets/product.jpg') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            // Nama dan harga produk
            Text(
              product['name'] ?? 'Nama produk tidak tersedia',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(58, 66, 86, 1.0),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              currencyFormat.format(product['price']),
              // "Rp ${product['price'] ?? 0}",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16.0),
            Divider(),
            SizedBox(height: 16.0),
            // Deskripsi produk
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Deskripsi Produk",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(58, 66, 86, 1.0),
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                product['description'] ?? 'Deskripsi tidak tersedia',
                style: TextStyle(fontSize: 16.0),
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(height: 20.0),
            Divider(),
            SizedBox(height: 16.0),
            // Tombol "Add to Cart"
            ElevatedButton.icon(
              onPressed: () {
                print("Add to Cart pressed");
              },
              icon: Icon(Icons.add_shopping_cart),
              label: Text(
                "Add To Cart",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 12.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Divider(),
            SizedBox(height: 16.0),
            // Review produk
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Ulasan Pelanggan",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(58, 66, 86, 1.0),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            if (reviews.isNotEmpty)
              ...reviews.map((review) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review['review']['comment'] ??
                              'Tidak ada komentar',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 4.0),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index <
                                  (review['review']['ratings'] ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20.0,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList()
            else
              Text(
                "Belum ada ulasan.",
                style: TextStyle(fontSize: 16.0),
              ),
          ],
        ),
      ),
    );
  }
}