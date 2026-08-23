import 'package:flutter/material.dart';
import 'products_table_row.dart';
import 'orders_table_row.dart';

class ProductTable extends StatefulWidget {
  const ProductTable({super.key});

  @override
  State<ProductTable> createState() => _ProductTableState();
}

class _ProductTableState extends State<ProductTable> {
  bool showProducts = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // ==========================================
          // TOOLBAR
          // ==========================================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Products / Orders switcher
                Container(
                  height: 40,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      _buildTab(
                        title: 'Products',
                        icon: Icons.inventory_2_outlined,
                        selected: showProducts,
                        onTap: () {
                          setState(() {
                            showProducts = true;
                          });
                        },
                      ),
                      _buildTab(
                        title: 'Orders',
                        icon: Icons.shopping_cart_outlined,
                        selected: !showProducts,
                        onTap: () {
                          setState(() {
                            showProducts = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Search
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: showProducts
                            ? 'Search products by name, category or brand...'
                            : 'Search orders by ID or customer...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 19,
                          color: Color(0xFF6B7280),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFD9DEE7),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFD9DEE7),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF6246EA),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Category / Customer filter
                _buildDropdown(
                  showProducts ? 'All Categories' : 'All Customers',
                  Icons.keyboard_arrow_down,
                ),

                const SizedBox(width: 12),

                // Status filter
                _buildDropdown('All Status', Icons.keyboard_arrow_down),

                const SizedBox(width: 12),

                // More filters
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list_outlined, size: 17),
                  label: const Text(
                    'More Filters',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF374151),
                    side: const BorderSide(color: Color(0xFFD9DEE7)),
                    minimumSize: const Size(110, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Add button
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    showProducts ? 'Add Product' : 'Add Order',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6246EA),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(125, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // TABLE AREA
          // ==========================================
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // ==========================================
          // TABLE AREA
          // ==========================================
          if (showProducts) _buildProductTable() else _buildOrderTable(),
        ],
      ),
    );
  }

  // ==========================================
  // TAB BUTTON
  // ==========================================
  Widget _buildTab({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? const Color(0xFF6246EA)
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? const Color(0xFF6246EA)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // DROPDOWN
  // ==========================================
  Widget _buildDropdown(String text, IconData icon) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9DEE7)),
      ),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 17, color: const Color(0xFF6B7280)),
        ],
      ),
    );
  }

  Widget _buildProductTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: Column(
            children: [
              // ==========================================
              // TABLE HEADER
              // ==========================================
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: const Color(0xFFF9FAFB),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 85,
                      child: _TableHeaderText('Product ID'),
                    ),

                    const Expanded(flex: 3, child: _TableHeaderText('Product')),

                    const Expanded(
                      flex: 2,
                      child: _TableHeaderText('Category'),
                    ),

                    const Expanded(flex: 2, child: _TableHeaderText('Brand')),

                    const Expanded(flex: 2, child: _TableHeaderText('Price')),

                    const Expanded(flex: 2, child: _TableHeaderText('Rating')),

                    const SizedBox(
                      width: 120,
                      child: _TableHeaderText('Actions', alignRight: true),
                    ),
                  ],
                ),
              ),

              // ==========================================
              // PRODUCT ROWS
              // ==========================================
              ProductTableRow(
                productId: 'P001',
                productName: 'HP Headphones 2',
                category: 'Headphones',
                brand: 'HP',
                price: '₹5,600',
                rating: 4.9,
                onView: () {
                  _showProductDetails(
                    productId: 'P001',
                    productName: 'HP Headphones 2',
                    category: 'Headphones',
                    brand: 'HP',
                    price: '₹5,600',
                    rating: 4.9,
                  );
                },
                onEdit: () {
                  _showEditProduct(
                    productId: 'P001',
                    productName: 'HP Headphones 2',
                    category: 'Headphones',
                    brand: 'HP',
                    price: '₹5,600',
                    rating: 4.9,
                  );
                },
                onMore: () {
                  _showProductMoreMenu(
                    productId: 'P001',
                    productName: 'HP Headphones 2',
                  );
                },
              ),

              const ProductTableRow(
                productId: 'P002',
                productName: 'Sony Smartwatch 78',
                category: 'Smartwatch',
                brand: 'Sony',
                price: '₹18,500',
                rating: 4.7,
              ),

              const ProductTableRow(
                productId: 'P003',
                productName: 'Dell Tablet 94',
                category: 'Tablet',
                brand: 'Dell',
                price: '₹42,000',
                rating: 4.6,
              ),

              const ProductTableRow(
                productId: 'P004',
                productName: 'Sony Smartphone 29',
                category: 'Smartphone',
                brand: 'Sony',
                price: '₹22,999',
                rating: 4.8,
              ),

              const ProductTableRow(
                productId: 'P005',
                productName: 'OnePlus Headphones 44',
                category: 'Headphones',
                brand: 'OnePlus',
                price: '₹4,999',
                rating: 4.5,
              ),

              // ==========================================
              // PAGINATION FOOTER
              // ==========================================
              Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Showing 1 to 5 of 128 products',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),

                    Row(
                      children: [
                        _paginationButton(Icons.chevron_left, enabled: false),

                        const SizedBox(width: 6),

                        _paginationNumber('1', selected: true),

                        const SizedBox(width: 6),

                        _paginationNumber('2', selected: false),

                        const SizedBox(width: 6),

                        _paginationNumber('3', selected: false),

                        const SizedBox(width: 6),

                        const Text(
                          '...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),

                        const SizedBox(width: 6),

                        _paginationNumber('13', selected: false),

                        const SizedBox(width: 6),

                        _paginationButton(Icons.chevron_right, enabled: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: Column(
            children: [
              // ==========================================
              // TABLE HEADER
              // ==========================================
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: const Color(0xFFF9FAFB),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: _TableHeaderText('Order ID'),
                    ),

                    const Expanded(
                      flex: 2,
                      child: _TableHeaderText('Customer ID'),
                    ),

                    const Expanded(
                      flex: 2,
                      child: _TableHeaderText('Order Date'),
                    ),

                    const Expanded(
                      flex: 2,
                      child: _TableHeaderText('Payment Method'),
                    ),

                    const Expanded(
                      flex: 2,
                      child: _TableHeaderText('Total Amount'),
                    ),

                    const SizedBox(
                      width: 120,
                      child: _TableHeaderText('Actions', alignRight: true),
                    ),
                  ],
                ),
              ),

              // ==========================================
              // ORDER ROWS
              // ==========================================
              OrderTableRow(
                orderId: '1',
                customerId: 'C0380',
                orderDate: '17-03-2025',
                paymentMethod: 'Credit Card',
                totalAmount: '₹2,26,696',
                onView: () {
                  _showOrderDetails(
                    orderId: '1',
                    customerId: 'C0380',
                    orderDate: '17-03-2025',
                    paymentMethod: 'Credit Card',
                    totalAmount: '₹2,26,696',
                  );
                },
              ),

              const OrderTableRow(
                orderId: '2',
                customerId: 'C0425',
                orderDate: '03-07-2024',
                paymentMethod: 'Credit Card',
                totalAmount: '₹1,93,042',
              ),

              const OrderTableRow(
                orderId: '3',
                customerId: 'C0175',
                orderDate: '26-01-2025',
                paymentMethod: 'Cash on Delivery',
                totalAmount: '₹1,09,905',
              ),

              const OrderTableRow(
                orderId: '4',
                customerId: 'C0302',
                orderDate: '12-09-2024',
                paymentMethod: 'UPI',
                totalAmount: '₹78,450',
              ),

              const OrderTableRow(
                orderId: '5',
                customerId: 'C0118',
                orderDate: '28-05-2025',
                paymentMethod: 'Debit Card',
                totalAmount: '₹56,890',
              ),

              // ==========================================
              // PAGINATION
              // ==========================================
              Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Showing 1 to 5 of 5000 orders',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),

                    Row(
                      children: [
                        _paginationButton(Icons.chevron_left, enabled: false),

                        const SizedBox(width: 6),

                        _paginationNumber('1', selected: true),

                        const SizedBox(width: 6),

                        _paginationNumber('2', selected: false),

                        const SizedBox(width: 6),

                        _paginationNumber('3', selected: false),

                        const SizedBox(width: 6),

                        const Text(
                          '...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),

                        const SizedBox(width: 6),

                        _paginationNumber('500', selected: false),

                        const SizedBox(width: 6),

                        _paginationButton(Icons.chevron_right, enabled: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _paginationNumber(String number, {required bool selected}) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEDE9FE) : Colors.white,
        border: Border.all(
          color: selected ? const Color(0xFF6246EA) : const Color(0xFFE5E7EB),
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        number,
        style: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? const Color(0xFF6246EA) : const Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _paginationButton(IconData icon, {required bool enabled}) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(
        icon,
        size: 18,
        color: enabled ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
      ),
    );
  }

  void _showProductDetails({
    required String productId,
    required String productName,
    required String category,
    required String brand,
    required String price,
    required double rating,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          title: Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFF6246EA),
                size: 22,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Product Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF172033),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          content: SizedBox(
            width: 430,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Product ID', productId),
                _detailRow('Product Name', productName),
                _detailRow('Category', category),
                _detailRow('Brand', brand),
                _detailRow('Price', price),
                _detailRow('Rating', '⭐ ${rating.toStringAsFixed(1)}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF172033),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProduct({
    required String productId,
    required String productName,
    required String category,
    required String brand,
    required String price,
    required double rating,
  }) {
    final nameController = TextEditingController(text: productName);
    final brandController = TextEditingController(text: brand);
    final priceController = TextEditingController(
      text: price.replaceAll('₹', '').replaceAll(',', ''),
    );
    final ratingController = TextEditingController(text: rating.toString());

    String selectedCategory = category;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
              contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              title: Row(
                children: [
                  const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF6246EA),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Edit Product',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF172033),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              content: SizedBox(
                width: 430,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _editField(
                        'Product ID',
                        TextEditingController(text: productId),
                        enabled: false,
                      ),

                      _editField('Product Name', nameController),

                      _editCategoryField(selectedCategory, (value) {
                        setDialogState(() {
                          selectedCategory = value!;
                        });
                      }),

                      _editField('Brand', brandController),

                      _editField(
                        'Price',
                        priceController,
                        keyboardType: TextInputType.number,
                      ),

                      _editField(
                        'Rating',
                        ratingController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            child: const Text('Cancel'),
                          ),

                          const SizedBox(width: 10),

                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Product updated successfully'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6246EA),
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _editField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _editCategoryField(
    String selectedCategory,
    ValueChanged<String?> onChanged,
  ) {
    const categories = [
      'Headphones',
      'Smartwatch',
      'Tablet',
      'Smartphone',
      'Laptop',
      'Camera',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: selectedCategory,
        items: categories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(category, style: const TextStyle(fontSize: 13)),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: 'Category',
          labelStyle: const TextStyle(fontSize: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  void _showProductMoreMenu({
    required String productId,
    required String productName,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF172033),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                ListTile(
                  leading: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Color(0xFF6246EA),
                  ),
                  title: const Text('View Orders'),
                  subtitle: const Text('See orders containing this product'),
                  onTap: () {
                    Navigator.pop(context);

                    _showProductOrders(
                      productId: productId,
                      productName: productName,
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.pause_circle_outline,
                    color: Color(0xFFE88900),
                  ),
                  title: const Text('Deactivate Product'),
                  subtitle: const Text(
                    'Remove this product from active listings',
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    _confirmDeactivateProduct(
                      productId: productId,
                      productName: productName,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProductOrders({
    required String productId,
    required String productName,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '$productName - Orders',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          content: const SizedBox(
            width: 450,
            height: 250,
            child: Center(
              child: Text(
                'Orders containing this product will appear here.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDeactivateProduct({
    required String productId,
    required String productName,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Deactivate Product?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to deactivate "$productName"?',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product deactivated successfully'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE88900),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );
  }

  void _showOrderDetails({
    required String orderId,
    required String customerId,
    required String orderDate,
    required String paymentMethod,
    required String totalAmount,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          title: Row(
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                color: Color(0xFF6246EA),
                size: 22,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF172033),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          content: SizedBox(
            width: 430,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Order ID', orderId),
                _detailRow('Customer ID', customerId),
                _detailRow('Order Date', orderDate),
                _detailRow('Payment Method', paymentMethod),
                _detailRow('Total Amount', totalAmount),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TableHeaderText extends StatelessWidget {
  final String text;
  final bool alignRight;

  const _TableHeaderText(this.text, {this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6B7280),
      ),
    );
  }
}
