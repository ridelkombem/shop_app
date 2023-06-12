import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/main_drawer.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: FutureBuilder(
          future: Provider.of<Orders>(context, listen: false).fetchAndSet(),
          builder: (ctx, snapShot) {
            if (snapShot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (snapShot.error != null) {
                return const Center(child: Text('An error occured'));
              } else {
                return Consumer<Orders>(
                  builder: (ctx, orderData, chils) {
                    return orderData.orders.isEmpty
                        ? const Center(
                            child: Text('No orders yet!'),
                          )
                        : ListView.builder(
                            itemBuilder: (ctx, index) {
                              return OrderItem(orderData.orders[index].amount,
                                  orderData.orders[index]);
                            },
                            itemCount: orderData.orders.length,
                          );
                  },
                );
              }
            }
          }),
      drawer: const MainDrawer(),
    );
  }
}
