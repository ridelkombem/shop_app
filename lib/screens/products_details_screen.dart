import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductsDetailsScreen extends StatelessWidget {
  static const routeName = '/Products-details';

  const ProductsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final product =
        Provider.of<Products>(context, listen: false).findById(productId);
    final mediaquery = MediaQuery.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            product.title,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: mediaquery.size.height * 0.42,
                width: double.infinity,
                child: Hero(
                  tag: product.id,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: mediaquery.size.height * 0.02),
              Text(
                '\$${product.price}',
                style: const TextStyle(fontSize: 30, color: Colors.grey),
              ),
              SizedBox(height: mediaquery.size.height * 0.01),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: mediaquery.size.height * 0.01),
                child: Text(
                  product.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                  softWrap: true,
                ),
              )
            ],
          ),
        ));
  }
}
