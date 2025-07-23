import 'package:flutter/material.dart';

// --- Models ---

/// Represents a product available in the store.
class Product {
  final String id;
  final String name;
  final double price; // Price of the water product
  final String imageUrl; // Changed to asset path

  // Made the constructor const to allow for const Product instances
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl, // Now required as it's an asset
  });
}

/// Represents an item in the shopping cart.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  // Method to calculate the total price for this cart item.
  double get totalPrice => product.price * quantity;
}

/// Enum for order status
enum OrderStatus { pending, preparing, onDelivery, delivered, cancelled }

/// Represents a customer order
class Order {
  final String id;
  final String customerName; // Placeholder for customer name
  final String customerAddress;
  final List<CartItem> items;
  final double totalAmount;
  OrderStatus status;
  final DateTime orderDate;
  final bool isArchivedByAdmin; // New: Flag to hide from admin view
  final bool isDeletedByCustomer; // New: Flag to hide from customer view

  Order({
    required this.id,
    required this.customerName,
    required this.customerAddress,
    required this.items,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    required this.orderDate,
    this.isArchivedByAdmin = false, // Default to not archived
    this.isDeletedByCustomer = false, // Default to not deleted by customer
  });

  // Helper to get a displayable status string
  String get statusString => status.toString().split('.').last.toUpperCase();
}

/// Represents a submitted rating
class RatingEntry {
  final String id;
  final double rating;
  final String? comment;
  final DateTime submissionDate;

  RatingEntry({
    required this.id,
    required this.rating,
    this.comment,
    required this.submissionDate,
  });
}

// Removed FeedbackEntry model as it's no longer needed.

// --- Main Application ---

void main() {
  runApp(
    const QualiPureApp(), // No ChangeNotifierProvider wrapper needed
  );
}

class QualiPureApp extends StatelessWidget {
  const QualiPureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QualiPure Water Refilling',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Theme color changed to blue
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue, // App bar blue
          foregroundColor: Colors.white, // Text on app bar white
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Buttons blue
            foregroundColor: Colors.white, // Text on buttons white
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        // Corrected CardTheme to CardThemeData and ensured const correctness
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ), // Use BorderRadius.all with Radius.circular
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// --- Login Page ---

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  // Global (simulated) lists of all placed orders, ratings
  // Using ValueNotifier to allow widgets to listen for changes
  static final ValueNotifier<List<Order>> allPlacedOrdersNotifier =
      ValueNotifier([]);
  static final ValueNotifier<List<RatingEntry>> allRatingsNotifier =
      ValueNotifier([]);
  // Removed allFeedbackNotifier as feedback functionality is removed.

  static void addPlacedOrder(Order order) {
    // Create a new list to trigger ValueNotifier update
    final updatedList = List<Order>.from(allPlacedOrdersNotifier.value)
      ..add(order);
    allPlacedOrdersNotifier.value = updatedList;
  }

  static void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final updatedList = List<Order>.from(allPlacedOrdersNotifier.value);
    final orderIndex = updatedList.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      // Create a new Order instance to update the status (since Order is const)
      updatedList[orderIndex] = Order(
        id: updatedList[orderIndex].id,
        customerName: updatedList[orderIndex].customerName,
        customerAddress: updatedList[orderIndex].customerAddress,
        items: updatedList[orderIndex].items,
        totalAmount: updatedList[orderIndex].totalAmount,
        orderDate: updatedList[orderIndex].orderDate,
        status: newStatus,
        isArchivedByAdmin:
            updatedList[orderIndex].isArchivedByAdmin, // Preserve this flag
        isDeletedByCustomer: updatedList[orderIndex]
            .isDeletedByCustomer, // Preserve customer delete flag
      );
      allPlacedOrdersNotifier.value = updatedList; // Trigger update
    }
  }

  // New: Method to archive an order for the admin view
  static void archiveOrderForAdmin(String orderId) {
    final updatedList = List<Order>.from(allPlacedOrdersNotifier.value);
    final orderIndex = updatedList.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      // Create a new Order instance to update the isArchivedByAdmin flag
      updatedList[orderIndex] = Order(
        id: updatedList[orderIndex].id,
        customerName: updatedList[orderIndex].customerName,
        customerAddress: updatedList[orderIndex].customerAddress,
        items: updatedList[orderIndex].items,
        totalAmount: updatedList[orderIndex].totalAmount,
        orderDate: updatedList[orderIndex].orderDate,
        status: updatedList[orderIndex].status,
        isArchivedByAdmin: true, // Mark as archived for admin
        isDeletedByCustomer: updatedList[orderIndex]
            .isDeletedByCustomer, // Preserve customer delete flag
      );
      allPlacedOrdersNotifier.value = updatedList; // Trigger update
    }
  }

  // New: Method to mark an order as deleted by customer
  static void markOrderDeletedByCustomer(String orderId) {
    final updatedList = List<Order>.from(allPlacedOrdersNotifier.value);
    final orderIndex = updatedList.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      updatedList[orderIndex] = Order(
        id: updatedList[orderIndex].id,
        customerName: updatedList[orderIndex].customerName,
        customerAddress: updatedList[orderIndex].customerAddress,
        items: updatedList[orderIndex].items,
        totalAmount: updatedList[orderIndex].totalAmount,
        orderDate: updatedList[orderIndex].orderDate,
        status: updatedList[orderIndex].status,
        isArchivedByAdmin:
            updatedList[orderIndex].isArchivedByAdmin, // Preserve admin archive
        isDeletedByCustomer: true, // Mark as deleted by customer
      );
      allPlacedOrdersNotifier.value = updatedList; // Trigger update
    }
  }

  static void removeOrder(String orderId) {
    final updatedList = List<Order>.from(allPlacedOrdersNotifier.value);
    updatedList.removeWhere((order) => order.id == orderId);
    allPlacedOrdersNotifier.value = updatedList;
  }

  static void addRating(RatingEntry rating) {
    final updatedList = List<RatingEntry>.from(allRatingsNotifier.value)
      ..add(rating);
    allRatingsNotifier.value = updatedList;
  }

  // Removed addFeedback static method as feedback functionality is removed.

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Basic hardcoded login for demonstration
      if (_usernameController.text == 'Zyrus Jake' &&
          _passwordController.text == 'password') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (_usernameController.text == 'admin' &&
          _passwordController.text == 'adminpass') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdminMainScreen(
              allOrdersNotifier: LoginPage.allPlacedOrdersNotifier,
              updateOrderStatus: LoginPage.updateOrderStatus,
              allRatingsNotifier: LoginPage.allRatingsNotifier,
              // Removed allFeedbackNotifier from AdminMainScreen constructor
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password')),
        );
      }
    }
  }

  // Placeholder for Google Sign-In functionality
  void _signInWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In functionality coming soon!'),
      ),
    );
    // In a real application, you would integrate with Firebase Auth or a similar service here.
    // For example:
    // final GoogleSignIn googleSignIn = GoogleSignIn();
    // final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    // if (googleUser != null) {
    //   // Authenticate with Firebase or your backend
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(builder: (context) => const MainScreen()),
    //   );
    // }
  }

  // Navigate to Sign Up Page
  void _navigateToSignUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SignUpPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // QualiPure Logo
                Image.asset(
                  'images/QualiPureLogo.png', // Removed 'assets/'
                  height: 150,
                  width: 150,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if image asset is not found or network error
                    return const Icon(
                      Icons.water_drop, // Water drop icon
                      size: 150,
                      color: Colors.blue, // Icon color blue
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'QualiPure',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Text color blue
                  ),
                ),
                const Text(
                  'Water Refilling Station',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black, // Text color black
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.blue,
                    ), // Icon color blue
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.blue,
                    ), // Icon color blue
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(
                      double.infinity,
                      50,
                    ), // Full width button
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 15), // Space between buttons
                ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor:
                        Colors.white, // White background for Google button
                    foregroundColor:
                        Colors.black87, // Black text for Google button
                    side: const BorderSide(color: Colors.grey), // Grey border
                  ),
                  icon: Image.asset(
                    'images/google_logo.png', // Removed 'assets/'
                    height: 24.0,
                    width: 24.0,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.g_mobiledata, // Fallback Google icon
                        size: 24,
                        color: Colors.blue,
                      );
                    },
                  ),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 15), // Space between buttons
                TextButton(
                  onPressed: _navigateToSignUp,
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Main Screen with Bottom Navigation Bar and Drawer (now manages cart state) ---

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Index of the selected bottom navigation bar item
  final Map<String, CartItem> _cartItems = {}; // Cart state moved here
  final List<String> _notifications = []; // List to store notifications

  // Cart Management Methods (formerly in CartProvider)
  List<CartItem> get _items {
    // Filter out items with quantity 0 for display in cart and summary calculations
    return _cartItems.values.toList();
  }

  int get _itemCount {
    // Count only items with quantity > 0 for order summary
    return _cartItems.values.where((item) => item.quantity > 0).length;
  }

  double get _totalAmount {
    double total = 0.0;
    // Calculate total only for items with quantity > 0
    _cartItems.forEach((key, cartItem) {
      if (cartItem.quantity > 0) {
        total += cartItem.totalPrice;
      }
    });
    return total;
  }

  void _addProduct(Product product) {
    setState(() {
      if (_cartItems.containsKey(product.id)) {
        _cartItems.update(
          product.id,
          (existingCartItem) => CartItem(
            product: existingCartItem.product,
            quantity: existingCartItem.quantity + 1,
          ),
        );
      } else {
        _cartItems.putIfAbsent(
          product.id,
          () => CartItem(product: product, quantity: 1),
        );
      }
    });
  }

  void _decrementQuantity(String productId) {
    setState(() {
      if (!_cartItems.containsKey(productId)) {
        return;
      }
      // Allow quantity to go down to 0, but don't remove the item
      if (_cartItems[productId]!.quantity > 0) {
        _cartItems.update(
          productId,
          (existingCartItem) => CartItem(
            product: existingCartItem.product,
            quantity: existingCartItem.quantity - 1,
          ),
        );
      }
      // If quantity is 0, the item remains in the map but will be grayed out
      // and excluded from summary calculations by the getters.
    });
  }

  void _incrementQuantity(String productId) {
    setState(() {
      if (!_cartItems.containsKey(productId)) {
        return;
      }
      _cartItems.update(
        productId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    });
  }

  void _removeItemFromCart(String productId) {
    setState(() {
      _cartItems.remove(productId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item removed from cart.')));
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Helper function to get the title for the AppBar based on the selected index
  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'QualiPure Products';
      case 1:
        return 'Your Cart';
      case 2:
        return 'Order Status';
      default:
        return 'QualiPure';
    }
  }

  @override
  void initState() {
    super.initState();
    // Listen for changes in allPlacedOrdersNotifier
    LoginPage.allPlacedOrdersNotifier.addListener(_onOrderListChanged);
  }

  @override
  void dispose() {
    LoginPage.allPlacedOrdersNotifier.removeListener(_onOrderListChanged);
    super.dispose();
  }

  void _onOrderListChanged() {
    // This method is called whenever allPlacedOrdersNotifier.value changes
    setState(() {
      // Check for new orders or status changes and add notifications
      // For simplicity, we'll just add a notification for any change
      // In a real app, you'd compare old vs new state to detect specific changes
      final currentOrders = LoginPage.allPlacedOrdersNotifier.value;
      for (var order in currentOrders) {
        // Example: Notify if an order is now on delivery or delivered
        if (order.status == OrderStatus.onDelivery &&
            !_notifications.contains(
              'Order ${order.id.length > 6 ? order.id.substring(order.id.length - 6) : order.id} is now ON DELIVERY!',
            )) {
          _notifications.add(
            'Order ${order.id.length > 6 ? order.id.substring(order.id.length - 6) : order.id} is now ON DELIVERY!',
          );
        } else if (order.status == OrderStatus.delivered &&
            !_notifications.contains(
              'Order ${order.id.length > 6 ? order.id.substring(order.id.length - 6) : order.id} has been DELIVERED!',
            )) {
          _notifications.add(
            'Order ${order.id.length > 6 ? order.id.substring(order.id.length - 6) : order.id} has been DELIVERED!',
          );
        }
      }
    });
  }

  // Customer specific order actions
  void _cancelCustomerOrder(String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              LoginPage.updateOrderStatus(orderId, OrderStatus.cancelled);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Order ${orderId.length > 6 ? orderId.substring(orderId.length - 6) : orderId} has been cancelled.',
                  ),
                ),
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _deleteCustomerOrder(String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Order from History'),
        content: const Text(
          'Are you sure you want to delete this order from your history? It will still be visible to the admin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
              // Instead of removing, mark as deleted by customer
              LoginPage.markOrderDeletedByCustomer(orderId);
              // Safely get the last 6 characters or the full ID if shorter
              final displayId = orderId.length > 6
                  ? orderId.substring(orderId.length - 6)
                  : orderId;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Order $displayId has been deleted from your view.',
                  ),
                ),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // List of pages to display based on the selected index
    // These pages now receive cart data and callbacks directly
    final List<Widget> widgetOptions = <Widget>[
      HomePage(addProduct: _addProduct), // Pass addProduct callback
      CartPage(
        items: _items,
        itemCount: _itemCount,
        totalAmount: _totalAmount,
        decrementQuantity: _decrementQuantity,
        incrementQuantity: _incrementQuantity,
        removeItem: _removeItemFromCart, // Pass new removeItem callback
      ), // Pass all necessary cart data and callbacks
      OrderStatusPage(
        allOrdersNotifier: LoginPage.allPlacedOrdersNotifier,
        cancelOrder: _cancelCustomerOrder, // Pass cancel order callback
        deleteOrder: _deleteCustomerOrder, // Pass delete order callback
      ), // Order Monitoring page
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getPageTitle(_selectedIndex),
        ), // Dynamic title based on selected tab
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue, // Drawer header blue
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 30, backgroundColor: Colors.white),
                  const SizedBox(height: 10),
                  const Text(
                    'Zyrus Jake', // Replace with actual user name
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const Text(
                    'zyrusjake@gmail.com', // Replace with actual user email
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Notifications section
            ListTile(
              leading: const Icon(
                Icons.account_circle,
                color: Colors.black87,
              ), // Icon color black
              title: const Text(
                'Profile',
                style: TextStyle(color: Colors.black87),
              ), // Text color black
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.star,
                color: Colors.black87,
              ), // Icon for rating page
              title: const Text(
                'Rate Service',
                style: TextStyle(color: Colors.black87),
              ), // Text for rating page
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const RatingPage()),
                );
              },
            ),
            // Removed Feedback & Suggestions ListTile
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ), // Logout remains red for emphasis
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                // Handle logout
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: widgetOptions.elementAt(
        _selectedIndex,
      ), // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Products'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.delivery_dining,
            ), // Changed icon for delivery status
            label: 'Status',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Selected item color blue
        unselectedItemColor: Colors.black54, // Unselected item color black
        backgroundColor: Colors.white, // Bottom nav bar background white
        selectedLabelStyle: TextStyle(color: Colors.blue),
        unselectedLabelStyle: TextStyle(color: Colors.black54),
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- Home Page (QualiPure Products) ---

class HomePage extends StatelessWidget {
  // Callback function to add product to cart
  final Function(Product) addProduct;

  const HomePage({super.key, required this.addProduct});

  // List of available QualiPure products
  final List<Product> products = const [
    // Added const keyword to Product constructors
    Product(
      id: 'p1',
      name: 'Water with Slim Gallon',
      price: 200.0,
      imageUrl: 'images/slim_gallon_water.png',
    ), // Removed 'assets/'
    Product(
      id: 'p2',
      name: 'Refill only/Slim Gallon',
      price: 30.0,
      imageUrl: 'images/slim_gallon_water.png',
    ), // Removed 'assets/'
    Product(
      id: 'p3',
      name: 'Water with Round Gallon',
      price: 200.0,
      imageUrl: 'images/round_gallon_water.png',
    ), // Removed 'assets/'
    Product(
      id: 'p4',
      name: 'Refill only/Round Gallon',
      price: 30.0,
      imageUrl: 'images/round_gallon_water.png',
    ), // Removed 'assets/'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.75, // Adjust as needed for card height
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          product.imageUrl,
                          fit: BoxFit
                              .contain, // Change from BoxFit.cover if cropping is an issue
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color.fromARGB(255, 66, 113, 147),
                              child: const Center(
                                child: Icon(
                                  Icons.water_drop,
                                  size: 60,
                                  color: Colors.blue,
                                ), // Icon color blue
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Text color black
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '₱${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue, // Price color blue
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        addProduct(product); // Use the passed callback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- Cart Page (Checkout Page) ---

class CartPage extends StatelessWidget {
  final List<CartItem> items;
  final int itemCount;
  final double totalAmount;
  final Function(String) decrementQuantity;
  final Function(String) incrementQuantity;
  final Function(String) removeItem; // New: Callback to remove an item

  const CartPage({
    super.key,
    required this.items,
    required this.itemCount,
    required this.totalAmount,
    required this.decrementQuantity,
    required this.incrementQuantity,
    required this.removeItem, // New: Required
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child:
                items.isEmpty &&
                    itemCount ==
                        0 // Check if cart is truly empty (no items or all are 0 quantity)
                ? const Center(
                    child: Text(
                      'Your cart is empty!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ), // Text color black
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final cartItem = items[index];
                      final bool isGrayedOut = cartItem.quantity == 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: isGrayedOut
                            ? Colors.grey.shade200
                            : null, // Gray background if quantity is 0
                        child: Opacity(
                          opacity: isGrayedOut
                              ? 0.5
                              : 1.0, // Reduce opacity if quantity is 0
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    cartItem
                                        .product
                                        .imageUrl, // Use Image.asset
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors
                                            .blue
                                            .shade50, // Placeholder background light blue
                                        child: Icon(
                                          Icons.water_drop,
                                          size: 30,
                                          color: isGrayedOut
                                              ? Colors.grey
                                              : Colors
                                                    .blue, // Icon color changes
                                        ), // Icon color blue
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItem.product.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isGrayedOut
                                              ? Colors.grey.shade600
                                              : Colors
                                                    .black87, // Text color changes
                                        ), // Text color black
                                      ),
                                      Text(
                                        '₱${cartItem.product.price.toStringAsFixed(2)} per unit',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isGrayedOut
                                              ? Colors.grey.shade500
                                              : Colors
                                                    .black54, // Text color changes
                                        ), // Text color black
                                      ),
                                      Text(
                                        'Total: ₱${cartItem.totalPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isGrayedOut
                                              ? Colors.grey.shade600
                                              : Colors
                                                    .blue, // Total price color blue
                                        ), // Total price color blue
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize
                                      .min, // Use min size for the row
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () {
                                        decrementQuantity(
                                          cartItem.product.id,
                                        ); // Use the passed callback
                                      },
                                      color: isGrayedOut
                                          ? Colors.grey
                                          : Colors.blue, // Button color changes
                                    ),
                                    Text(
                                      '${cartItem.quantity}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isGrayedOut
                                            ? Colors.grey.shade600
                                            : Colors.black87,
                                      ), // Text color black
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: () {
                                        incrementQuantity(
                                          cartItem.product.id,
                                        ); // Use the passed callback
                                      },
                                      color: isGrayedOut
                                          ? Colors.grey
                                          : Colors.blue, // Button color changes
                                    ),
                                    IconButton(
                                      // New: Delete button for cart item
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        removeItem(
                                          cartItem.product.id,
                                        ); // Call removeItem
                                      },
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Order Summary and Checkout Button
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, -3), // changes position of shadow
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order Summary:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ), // Text color black
                    ),
                    Text(
                      '${itemCount} items', // Use the passed itemCount
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ), // Text color black
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ), // Text color blue
                    ),
                    Text(
                      '₱${totalAmount.toStringAsFixed(2)}', // Use the passed totalAmount
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ), // Text color blue
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: itemCount == 0
                      ? null // Disable button if cart has no items with quantity > 0
                      : () {
                          // Navigate to OrderSummaryPage
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OrderSummaryPage(
                                items: items
                                    .where((item) => item.quantity > 0)
                                    .toList(), // Pass only items with quantity > 0
                                totalAmount: totalAmount,
                                clearCart: () {
                                  // Clear only items with quantity > 0 from the original map
                                  // This ensures grayed-out items remain in the cart view
                                  final itemsToRemove = items
                                      .where((item) => item.quantity > 0)
                                      .map((e) => e.product.id)
                                      .toList();
                                  for (var id in itemsToRemove) {
                                    removeItem(
                                      id,
                                    ); // Use the removeItem callback
                                  }
                                },
                                onOrderPlaced: LoginPage
                                    .addPlacedOrder, // Pass the static method
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                  ),
                  child: const Text(
                    'Proceed Checkout',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Order Summary Page ---

class OrderSummaryPage extends StatefulWidget {
  final List<CartItem> items;
  final double totalAmount;
  final Function() clearCart;
  final Function(Order) onOrderPlaced; // Callback to add order to global list
  const OrderSummaryPage({
    super.key,
    required this.items,
    required this.totalAmount,
    required this.clearCart,
    required this.onOrderPlaced,
  });

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  String? _selectedAddress; // State to hold the selected address
  final List<String> _addresses = const [
    'San Agustin 4230 Purok Sinko 0218',
    'Matala 3846 Purok 2 Ibaba 1134',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-select the first address by default
    if (_addresses.isNotEmpty) {
      _selectedAddress = _addresses[0];
    }
  }

  void _placeOrder() {
    if (widget.items.isEmpty) {
      // Ensure there are items in the summary
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty. Cannot place order.'),
        ),
      );
      Navigator.of(
        context,
      ).popUntil((route) => route.isFirst); // Go back to MainScreen
      return;
    }

    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address.')),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Confirm Order',
          style: TextStyle(color: Colors.black87),
        ),
        content: Text(
          'Are you sure you want to place this order to $_selectedAddress?',
          style: const TextStyle(color: Colors.black87),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('No', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
            },
          ),
          ElevatedButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
              // Create a new Order object
              final newOrder = Order(
                id: DateTime.now().millisecondsSinceEpoch
                    .toString(), // Unique ID
                customerName: 'Customer Name', // Placeholder
                customerAddress: _selectedAddress!,
                items: List.from(widget.items), // Create a copy of cart items
                totalAmount: widget.totalAmount,
                orderDate: DateTime.now(),
                status: OrderStatus.pending,
              );
              widget.onOrderPlaced(newOrder); // Add order to global list
              widget.clearCart(); // Clear the cart after placing the order
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Order for ₱${widget.totalAmount.toStringAsFixed(2)} placed successfully!',
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
              // Navigate back to the main screen (customer's product list)
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Summary')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Items:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            // List of order items
            ListView.builder(
              shrinkWrap: true, // Important for nested ListViews
              physics:
                  const NeverScrollableScrollPhysics(), // Disable scrolling for this list
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            item.product.imageUrl, // Use Image.asset
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: Colors.blue.shade50,
                                child: const Icon(
                                  Icons.water_drop,
                                  size: 25,
                                  color: Colors.blue,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Quantity: ${item.quantity}'),
                            ],
                          ),
                        ),
                        Text('₱${item.totalPrice.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Total Amount
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: ₱${widget.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Select Delivery Address:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            // Address selection
            Column(
              children: _addresses.map((address) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: _selectedAddress == address
                          ? Colors.blue
                          : Colors.grey.shade300,
                      width: _selectedAddress == address ? 2.0 : 1.0,
                    ),
                  ),
                  child: RadioListTile<String>(
                    title: Text(address),
                    value: address,
                    groupValue: _selectedAddress,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedAddress = value;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            // Place Order Button
            ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text('Place Order', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Order Status Page (Customer View) ---

class OrderStatusPage extends StatefulWidget {
  final ValueNotifier<List<Order>> allOrdersNotifier;
  final Function(String) cancelOrder; // New: Callback for customer to cancel
  final Function(String) deleteOrder; // New: Callback for customer to delete
  const OrderStatusPage({
    super.key,
    required this.allOrdersNotifier,
    required this.cancelOrder,
    required this.deleteOrder,
  });

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  @override
  void initState() {
    super.initState();
    widget.allOrdersNotifier.addListener(_onOrderListChanged);
  }

  @override
  void dispose() {
    widget.allOrdersNotifier.removeListener(_onOrderListChanged);
    super.dispose();
  }

  void _onOrderListChanged() {
    // Force a rebuild when the global order list changes
    setState(() {});
  }

  // Helper to get a color for the status text
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.onDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red; // Fallback color
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter orders to show only those relevant to the current "customer"
    // and those not marked as deleted by the customer.
    final customerOrders = widget.allOrdersNotifier.value
        .where((order) => !order.isDeletedByCustomer)
        .toList();

    return Scaffold(
      body: customerOrders.isEmpty
          ? const Center(
              child: Text(
                'You have no active orders.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: customerOrders.length,
              itemBuilder: (context, index) {
                final order = customerOrders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ID: ${order.id.length > 6 ? order.id.substring(order.id.length - 6) : order.id}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Order Date: ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          'Delivery Address: ${order.customerAddress}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Status: ${order.statusString}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Items:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ...order.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              '- ${item.product.name} (x${item.quantity}) - ₱${item.totalPrice.toStringAsFixed(2)}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Total: ₱${order.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Action buttons for customer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (order.status == OrderStatus.pending)
                              ElevatedButton.icon(
                                onPressed: () => widget.cancelOrder(order.id),
                                icon: const Icon(Icons.cancel),
                                label: const Text('Cancel Order'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            if (order.status == OrderStatus.delivered ||
                                order.status == OrderStatus.cancelled)
                              ElevatedButton.icon(
                                onPressed: () => widget.deleteOrder(order.id),
                                icon: const Icon(Icons.delete),
                                label: const Text('Delete Order'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// --- Profile Page ---

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(radius: 70, backgroundColor: Colors.blue.shade100),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit profile image coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Zyrus Jake', // Placeholder
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Text(
              'zyrusjake@gmail.com', // Placeholder
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            _buildProfileInfoCard(
              icon: Icons.person,
              title: 'Username',
              value: 'Zyrus Jake',
            ),
            _buildProfileInfoCard(
              icon: Icons.email,
              title: 'Email',
              value: 'zyrusjake@gmail.com',
            ),
            _buildProfileInfoCard(
              icon: Icons.phone,
              title: 'Phone Number',
              value: '09387197582',
            ),
            _buildProfileInfoCard(
              icon: Icons.location_on,
              title: 'Delivery Address',
              value: 'San Agustin 4230 Purok Sinko 0218',
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Update profile functionality coming soon!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Update Profile',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Change password functionality coming soon!'),
                  ),
                );
              },
              child: const Text(
                'Change Password',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Admin Main Screen ---

class AdminMainScreen extends StatefulWidget {
  final ValueNotifier<List<Order>> allOrdersNotifier;
  final Function(String, OrderStatus) updateOrderStatus;
  final ValueNotifier<List<RatingEntry>> allRatingsNotifier;

  const AdminMainScreen({
    super.key,
    required this.allOrdersNotifier,
    required this.updateOrderStatus,
    required this.allRatingsNotifier,
  });

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0; // Index for bottom navigation bar

  // Helper to get a color for the status text
  @override
  void initState() {
    super.initState();
    // Listen for changes in the global order list
    widget.allOrdersNotifier.addListener(_onOrderListChanged);
    widget.allRatingsNotifier.addListener(_onRatingsListChanged);
  }

  @override
  void dispose() {
    widget.allOrdersNotifier.removeListener(_onOrderListChanged);
    widget.allRatingsNotifier.removeListener(_onRatingsListChanged);
    super.dispose();
  }

  void _onOrderListChanged() {
    // Rebuild the widget when the order list changes
    setState(() {});
  }

  void _onRatingsListChanged() {
    // Rebuild the widget when the ratings list changes
    setState(() {});
  }

  // Helper function to get the title for the AppBar based on the selected index
  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Admin Orders';
      case 1:
        return 'Admin Ratings';
      case 2:
        return 'Archived Orders'; // New title for the archived tab
      default:
        return 'Admin Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter out archived orders for admin view (for the "Orders" tab)
    final liveOrders = widget.allOrdersNotifier.value
        .where((order) => !order.isArchivedByAdmin)
        .toList();

    // Filter archived orders for the "Archived" tab
    final archivedOrders = widget.allOrdersNotifier.value
        .where((order) => order.isArchivedByAdmin)
        .toList();

    // Pages for Admin
    final List<Widget> _adminWidgetOptions = <Widget>[
      // Admin Order Management Page (Live Orders)
      AdminOrderManagementPage(
        liveOrders: liveOrders,
        updateOrderStatus: widget.updateOrderStatus,
      ),
      // Admin Ratings & Feedback Page
      AdminRatingsPage(allRatingsNotifier: widget.allRatingsNotifier),
      // New: Admin Archived Orders Page
      AdminArchivedOrdersPage(archivedOrders: archivedOrders),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(_selectedIndex)), // Dynamic title
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _adminWidgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Ratings'),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive), // New icon for archived
            label: 'Archived', // New label for archived
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

// --- Admin Order Management Page ---
class AdminOrderManagementPage extends StatefulWidget {
  final List<Order> liveOrders;
  final Function(String, OrderStatus) updateOrderStatus;

  const AdminOrderManagementPage({
    super.key,
    required this.liveOrders,
    required this.updateOrderStatus,
  });

  @override
  State<AdminOrderManagementPage> createState() =>
      _AdminOrderManagementPageState();
}

class _AdminOrderManagementPageState extends State<AdminOrderManagementPage> {
  @override
  Widget build(BuildContext context) {
    return widget.liveOrders.isEmpty
        ? const Center(
            child: Text(
              'No active orders for administration.',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: widget.liveOrders.length,
            itemBuilder: (context, index) {
              final order = widget.liveOrders[index];
              return OrderCardAdmin(
                order: order,
                updateOrderStatus: widget.updateOrderStatus,
              );
            },
          );
  }
}

// Admin Ratings Page
class AdminRatingsPage extends StatefulWidget {
  final ValueNotifier<List<RatingEntry>> allRatingsNotifier;

  const AdminRatingsPage({super.key, required this.allRatingsNotifier});

  @override
  State<AdminRatingsPage> createState() => _AdminRatingsPageState();
}

class _AdminRatingsPageState extends State<AdminRatingsPage> {
  @override
  void initState() {
    super.initState();
    widget.allRatingsNotifier.addListener(_onRatingsChanged);
  }

  @override
  void dispose() {
    widget.allRatingsNotifier.removeListener(_onRatingsChanged);
    super.dispose();
  }

  void _onRatingsChanged() {
    setState(() {}); // Rebuild when ratings change
  }

  @override
  Widget build(BuildContext context) {
    final ratings = widget.allRatingsNotifier.value;
    return Scaffold(
      body: ratings.isEmpty
          ? const Center(
              child: Text(
                'No ratings submitted yet.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                final rating = ratings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rating ID: ${rating.id.length > 6 ? rating.id.substring(rating.id.length - 6) : rating.id}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < rating.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${rating.submissionDate.day}/${rating.submissionDate.month}/${rating.submissionDate.year}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        if (rating.comment != null &&
                            rating.comment!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Comment: "${rating.comment}"',
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// --- Order Card for Admin View ---
class OrderCardAdmin extends StatefulWidget {
  final Order order;
  final Function(String, OrderStatus) updateOrderStatus;

  const OrderCardAdmin({
    super.key,
    required this.order,
    required this.updateOrderStatus,
  });

  @override
  State<OrderCardAdmin> createState() => _OrderCardAdminState();
}

class _OrderCardAdminState extends State<OrderCardAdmin> {
  // Helper to get a color for the status text
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.onDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${widget.order.id.length > 6 ? widget.order.id.substring(widget.order.id.length - 6) : widget.order.id}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Customer: ${widget.order.customerName}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Text(
              'Address: ${widget.order.customerAddress}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Text(
              'Order Date: ${widget.order.orderDate.day}/${widget.order.orderDate.month}/${widget.order.orderDate.year}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Text(
              'Status: ${widget.order.statusString}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(widget.order.status),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Items:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            ...widget.order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  '- ${item.product.name} (x${item.quantity}) - ₱${item.totalPrice.toStringAsFixed(2)}',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: ₱${widget.order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildAdminActionButtons(widget.order),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionButtons(Order order) {
    List<Widget> actions = [];

    if (order.status == OrderStatus.pending) {
      actions.add(
        _buildActionButton(
          'Mark Preparing',
          Icons.water,
          Colors.orange,
          () => widget.updateOrderStatus(order.id, OrderStatus.preparing),
        ),
      );
    } else if (order.status == OrderStatus.preparing) {
      actions.add(
        _buildActionButton(
          'Mark On Delivery',
          Icons.delivery_dining,
          Colors.purple,
          () => widget.updateOrderStatus(order.id, OrderStatus.onDelivery),
        ),
      );
    } else if (order.status == OrderStatus.onDelivery) {
      actions.add(
        _buildActionButton(
          'Mark Delivered',
          Icons.check_circle,
          Colors.green,
          () => widget.updateOrderStatus(order.id, OrderStatus.delivered),
        ),
      );
    } else if (order.status == OrderStatus.delivered ||
        order.status == OrderStatus.cancelled) {
      actions.add(
        _buildActionButton('Archive Order', Icons.archive, Colors.grey, () {
          LoginPage.archiveOrderForAdmin(order.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Order ${order.id.length > 6 ? order.id.substring(order.id.length - 6) : order.id} archived.',
              ),
            ),
          );
        }),
      );
    }

    return Wrap(
      spacing: 8.0, // Space between buttons
      runSpacing: 4.0, // Space between lines of buttons
      children: actions,
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// --- Rating Page ---
class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double _currentRating = 3.0; // Default rating
  final TextEditingController _commentController = TextEditingController();

  void _submitRating() {
    if (_currentRating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating.')));
      return;
    }

    // Simulate submitting the rating
    final newRating = RatingEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      rating: _currentRating,
      comment: _commentController.text.isNotEmpty
          ? _commentController.text
          : null,
      submissionDate: DateTime.now(),
    );

    LoginPage.addRating(newRating);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Thank you for your rating!')));

    // Clear form
    _commentController.clear();
    setState(() {
      _currentRating = 3.0; // Reset rating
    });

    Navigator.of(context).pop(); // Go back to previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Our Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How would you rate our service?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _currentRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentRating = (index + 1).toDouble();
                      });
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Optional: Add a comment (Maximum 150 characters)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 150,
              decoration: InputDecoration(
                hintText: 'Enter your comments here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitRating,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text(
                'Submit Rating',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Sign Up Page ---
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController =
      TextEditingController(); // New: Email Controller
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _otpSent = false;
  String?
  _generatedOtp; // In a real app, this would be handled securely by a backend

  void _sendOtp() {
    if (_formKey.currentState!.validate()) {
      // Simulate OTP generation and sending
      _generatedOtp = '123456'; // For demonstration purposes
      setState(() {
        _otpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to ${_emailController.text}.'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _verifyOtpAndSignUp() {
    if (_otpController.text == _generatedOtp) {
      // Simulate account creation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
      Navigator.of(context).pop(); // Go back to login page
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Create Your Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController, // New: Email TextFormField
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_reset,
                      color: Colors.blue,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.home, color: Colors.blue),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.phone, color: Colors.blue),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    // Basic phone number validation (e.g., all digits)
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                if (!_otpSent)
                  ElevatedButton(
                    onPressed: _sendOtp,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Send OTP',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                else
                  Column(
                    children: [
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Enter OTP',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(
                            Icons.vpn_key,
                            color: Colors.blue,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the OTP';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _verifyOtpAndSignUp,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Verify OTP & Sign Up',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _otpSent = false;
                            _otpController.clear();
                            _generatedOtp = null;
                          });
                        },
                        child: const Text(
                          'Resend OTP / Edit details',
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Go back to LoginPage
                  },
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Admin Archived Orders Page (New) ---
class AdminArchivedOrdersPage extends StatefulWidget {
  final List<Order> archivedOrders;

  const AdminArchivedOrdersPage({super.key, required this.archivedOrders});

  @override
  State<AdminArchivedOrdersPage> createState() =>
      _AdminArchivedOrdersPageState();
}

class _AdminArchivedOrdersPageState extends State<AdminArchivedOrdersPage> {
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.onDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.archivedOrders.isEmpty
        ? const Center(
            child: Text(
              'No archived orders.',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: widget.archivedOrders.length,
            itemBuilder: (context, index) {
              final order = widget.archivedOrders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: ${order.id.length > 6 ? order.id.substring(order.id.length - 6) : order.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Customer: ${order.customerName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'Address: ${order.customerAddress}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'Order Date: ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Status: ${order.statusString}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(order.status),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Items:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '- ${item.product.name} (x${item.quantity}) - ₱${item.totalPrice.toStringAsFixed(2)}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Total: ₱${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
