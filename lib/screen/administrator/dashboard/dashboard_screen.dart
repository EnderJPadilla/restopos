import 'package:flutter/material.dart';

// Modelos
class Order {
  final String id;
  final String table;
  final String status;
  final List<String> items;
  final double total;

  Order({
    required this.id,
    required this.table,
    required this.status,
    required this.items,
    required this.total,
  });
}

class Product {
  final String name;
  final int sales;

  Product({required this.name, required this.sales});
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late List<Order> orders;
  late List<Product> topProducts;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    orders = [
      Order(
        id: '001',
        table: 'Mesa 1',
        status: 'En preparación',
        items: ['Hamburguesa', 'Papas fritas'],
        total: 25.50,
      ),
      Order(
        id: '002',
        table: 'Mesa 3',
        status: 'Listo',
        items: ['Pizza grande', 'Refresco'],
        total: 45.00,
      ),
      Order(
        id: '003',
        table: 'Mesa 5',
        status: 'En preparación',
        items: ['Ensalada', 'Agua'],
        total: 15.00,
      ),
      Order(
        id: '004',
        table: 'Mesa 2',
        status: 'Listo',
        items: ['Tacos x3', 'Salsa'],
        total: 18.50,
      ),
    ];

    topProducts = [
      Product(name: 'Hamburguesa', sales: 45),
      Product(name: 'Pizza', sales: 38),
      Product(name: 'Tacos', sales: 32),
      Product(name: 'Ensalada', sales: 28),
      Product(name: 'Bebidas', sales: 56),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila de widgets resumidos
          Row(
            children: [
              _buildSummaryCard('Ventas del día', '\$1,250.50', Icons.attach_money),
              const SizedBox(width: 20),
              _buildSummaryCard('Pedidos', '12', Icons.add_shopping_cart),
              const SizedBox(width: 20),
              _buildSummaryCard('Mesas ocupadas', '5 / 12', Icons.table_restaurant),
            ],
          ),
          const SizedBox(height: 40),
          // Pedidos Activos
          _buildSectionTitle('Pedidos Activos', 'Pedidos en preparación o Listos'),
          const SizedBox(height: 15),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: _buildOrderCard(orders[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          // Productos Más Vendidos
          _buildSectionTitle('Productos Más Vendidos', 'Top 5 del día'),
          const SizedBox(height: 15),
          _buildTopProductsList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1014),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF00477B),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                Icon(
                  icon,
                  color: const Color(0xFFE49E22),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1014),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: order.status == 'Listo'
              ? const Color(0xFF4CAF50)
              : const Color(0xFF00477B),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedido #${order.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    order.table,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.status == 'Listo'
                      ? const Color(0xFF4CAF50).withOpacity(0.2)
                      : const Color(0xFFFFC107).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: order.status == 'Listo'
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFFC107),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Artículos:',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                ...order.items.map((item) => Text(
                      '• $item',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsList() {
    return Column(
      children: topProducts.asMap().entries.map((entry) {
        final index = entry.key;
        final product = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1014),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF00477B),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE49E22),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF05080B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  '${product.sales} ventas',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE49E22),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

}
