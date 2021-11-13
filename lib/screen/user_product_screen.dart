import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/providers.dart';
import '/widgets/widgets.dart';
import '/screen/screen.dart';


class UserProductScreen extends StatelessWidget {
  static const String routeName = "/user-product";

  const UserProductScreen({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const UserProductScreen(),
    );
  }

  Future<void> _refreshProduct(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetData(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Your product"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AddNewProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),

      /// add pull to refresh
      // step 1 wrap the widget into into new widget named RefreshIndicator
      // step 2 call the api to reload dta again in property named onRefresh with takes Future<void> as an argument
      body: FutureBuilder(
        future: _refreshProduct(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProduct(context),
                    child: Consumer<Products>(
                      builder: (context, productsData, _) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: productsData.items.length,
                          itemBuilder: (context, index) => UserProductItem(
                            productsData.items[index].id,
                            productsData.items[index].title,
                            productsData.items[index].imageUrl,
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
