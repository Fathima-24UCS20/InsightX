import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'products_table_row.dart';

class ProductTable extends StatefulWidget {
  const ProductTable({super.key});

  @override
  State<ProductTable> createState() => _ProductTableState();
}

class _ProductTableState extends State<ProductTable> {
  List<dynamic> products = [];
  bool isLoadingProducts = true;
  String? productError;

  final TextEditingController searchController = TextEditingController();

  List<String> categories = [];
  String selectedCategory = 'All Categories';

  int currentPage = 1;
  int totalPages = 1;
  int totalProducts = 0;

  final int productsPerPage = 5;

  String selectedSort = 'Product Name';
  String sortOrder = 'asc';

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCategories();
  }

  Future<void> fetchProducts({
    String search = '',
    String category = 'All Categories',
    int page = 1,
    String sortBy = 'name',
    String order = 'asc',
  }) async {
    try {
      setState(() {
        isLoadingProducts = true;
        productError = null;
      });

      final Map<String, String> params = {
        'page': page.toString(),
        'limit': productsPerPage.toString(),
        'sort_by': sortBy,
        'sort_order': order,
      };

      if (search.trim().isNotEmpty) {
        params['search'] = search.trim();
      }

      if (category != 'All Categories') {
        params['category'] = category;
      }

      final uri = Uri.parse(
        'http://127.0.0.1:8000/products',
      ).replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          products = data['products'];
          totalProducts = data['total'];
          currentPage = data['page'];
          totalPages = data['total_pages'];
          isLoadingProducts = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          productError = 'Failed to load products';
          isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        productError = 'Unable to connect to server';
        isLoadingProducts = false;
      });
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/products/categories'),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          categories = List<String>.from(jsonDecode(response.body));
        });
      }
    } catch (e) {
      // Keep the category list empty if the request fails.
    }
  }

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
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 320,
                    height: 40,
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        currentPage = 1;

                        fetchProducts(
                          search: value,
                          category: selectedCategory,
                          page: 1,
                        );
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Search products by name, category or brand...',
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

                  const SizedBox(width: 12),

                  _buildCategoryDropdown(),

                  const SizedBox(width: 12),

                  _buildSortDropdown(),

                  const SizedBox(width: 12),

                  ElevatedButton.icon(
                    onPressed: _showAddProduct,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Add Product',
                      style: TextStyle(fontSize: 12),
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
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          _buildProductTable(),
        ],
      ),
    );
  }

  // ==========================================
  // CATEGORY DROPDOWN
  // ==========================================
  Widget _buildCategoryDropdown() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9DEE7)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 17,
            color: Color(0xFF6B7280),
          ),
          style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
          items: [
            const DropdownMenuItem(
              value: 'All Categories',
              child: Text('All Categories'),
            ),
            ...categories.map(
              (category) =>
                  DropdownMenuItem(value: category, child: Text(category)),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedCategory = value;
              currentPage = 1;
            });

            fetchProducts(
              search: searchController.text,
              category: selectedCategory,
              page: 1,
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // SORT DROPDOWN
  // ==========================================
  Widget _buildSortDropdown() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9DEE7)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSort,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 17,
            color: Color(0xFF6B7280),
          ),
          style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
          items: const [
            DropdownMenuItem(
              value: 'Product Name',
              child: Text('Sort: Product Name'),
            ),
            DropdownMenuItem(value: 'Category', child: Text('Sort: Category')),
            DropdownMenuItem(value: 'Brand', child: Text('Sort: Brand')),
            DropdownMenuItem(value: 'Price', child: Text('Sort: Price')),
            DropdownMenuItem(value: 'Rating', child: Text('Sort: Rating')),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedSort = value;
              currentPage = 1;
            });

            fetchProducts(
              search: searchController.text,
              category: selectedCategory,
              page: 1,
              sortBy: _getSortColumn(),
              order: sortOrder,
            );
          },
        ),
      ),
    );
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPages) return;

    fetchProducts(
      search: searchController.text,
      category: selectedCategory,
      page: page,
      sortBy: _getSortColumn(),
      order: sortOrder,
    );
  }

  String _getSortColumn() {
    switch (selectedSort) {
      case 'Product Name':
        return 'name';
      case 'Category':
        return 'category';
      case 'Brand':
        return 'brand';
      case 'Price':
        return 'price';
      case 'Rating':
        return 'rating';
      default:
        return 'name';
    }
  }

  // ==========================================
  // ADD PRODUCT
  // ==========================================
  void _showAddProduct() {
    final idController = TextEditingController();
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final priceController = TextEditingController();
    final ratingController = TextEditingController();

    String selectedCategory = categories.isNotEmpty
        ? categories.first
        : 'Headphones';

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
                    Icons.add_box_outlined,
                    color: Color(0xFF6246EA),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Add Product',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF172033),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
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
                      _editField('Product ID', idController),
                      _editField('Product Name', nameController),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedCategory,
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedCategory = value;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
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
                            onPressed: () async {
                              final price = double.tryParse(
                                priceController.text.trim().replaceAll(',', ''),
                              );

                              final rating = double.tryParse(
                                ratingController.text.trim(),
                              );

                              if (idController.text.trim().isEmpty ||
                                  nameController.text.trim().isEmpty ||
                                  brandController.text.trim().isEmpty ||
                                  price == null ||
                                  rating == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter valid product details',
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.pop(dialogContext);

                              await addProduct(
                                productId: idController.text.trim(),
                                productName: nameController.text.trim(),
                                category: selectedCategory,
                                brand: brandController.text.trim(),
                                price: price,
                                rating: rating,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6246EA),
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            child: const Text('Add Product'),
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

  Future<void> addProduct({
    required String productId,
    required String productName,
    required String category,
    required String brand,
    required double price,
    required double rating,
  }) async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/products');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'product_id': productId,
          'product_name': productName,
          'category': category,
          'brand': brand,
          'price': price.toString(),
          'rating': rating.toString(),
        },
      );

      if (response.statusCode == 200) {
        await fetchProducts(
          search: searchController.text,
          category: selectedCategory,
          page: 1,
          sortBy: _getSortColumn(),
          order: sortOrder,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')),
          );
        }
      } else if (response.statusCode == 409) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product ID already exists')),
          );
        }
      } else {
        print('ADD PRODUCT STATUS: ${response.statusCode}');
        print('ADD PRODUCT RESPONSE: ${response.body}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed: ${response.statusCode} ${response.body}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to connect to server')),
        );
      }
    }
  }

  // ==========================================
  // PRODUCT TABLE
  // ==========================================
  Widget _buildProductTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: Column(
            children: [
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

              if (isLoadingProducts)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                )
              else if (productError != null)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    productError!,
                    style: const TextStyle(fontSize: 13, color: Colors.red),
                  ),
                )
              else if (products.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No products found',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                )
              else
                ...products.map((product) {
                  return ProductTableRow(
                    productId: product['id'].toString(),
                    productName: product['name'].toString(),
                    category: product['category']?.toString() ?? 'N/A',
                    brand: product['brand']?.toString() ?? 'N/A',
                    price: '₹${product['price']}',
                    rating:
                        double.tryParse(product['rating'].toString()) ?? 0.0,

                    // Existing active status
                    isActive: product['is_active'] == true,

                    onView: () {
                      fetchProductDetails(product['id'].toString());
                    },

                    onEdit: () {
                      _showEditProduct(
                        productId: product['id'].toString(),
                        productName: product['name'].toString(),
                        category: product['category']?.toString() ?? 'N/A',
                        brand: product['brand']?.toString() ?? 'N/A',
                        price: '₹${product['price']}',
                        rating:
                            double.tryParse(product['rating'].toString()) ??
                            0.0,
                      );
                    },

                    onMore: () {
                      _showProductMoreMenu(
                        productId: product['id'].toString(),
                        productName: product['name'].toString(),

                        // NEW: pass active status to More menu
                        isActive: product['is_active'] == true,
                      );
                    },
                  );
                }).toList(),

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
                    Text(
                      totalProducts == 0
                          ? 'Showing 0 products'
                          : 'Showing ${(currentPage - 1) * productsPerPage + 1} '
                                'to ${(currentPage - 1) * productsPerPage + products.length} '
                                'of $totalProducts products',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Row(
                      children: [
                        _paginationButton(
                          Icons.chevron_left,
                          enabled: currentPage > 1,
                          onPressed: currentPage > 1
                              ? () => goToPage(currentPage - 1)
                              : null,
                        ),
                        const SizedBox(width: 6),
                        for (
                          int page = 1;
                          page <= totalPages && page <= 5;
                          page++
                        ) ...[
                          _paginationNumber(
                            '$page',
                            selected: page == currentPage,
                            onPressed: () => goToPage(page),
                          ),
                          if (page < totalPages && page < 5)
                            const SizedBox(width: 6),
                        ],
                        const SizedBox(width: 6),
                        _paginationButton(
                          Icons.chevron_right,
                          enabled: currentPage < totalPages,
                          onPressed: currentPage < totalPages
                              ? () => goToPage(currentPage + 1)
                              : null,
                        ),
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

  Widget _paginationNumber(
    String number, {
    required bool selected,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(7),
      child: Container(
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
      ),
    );
  }

  Widget _paginationButton(
    IconData icon, {
    required bool enabled,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(7),
      child: Container(
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
      ),
    );
  }

  // ==========================================
  // PRODUCT DETAILS
  // ==========================================
  Future<void> fetchProductDetails(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/products/$productId/details'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        _showProductDetails(
          productId: data['id'].toString(),
          productName: data['name'].toString(),
          category: data['category']?.toString() ?? 'N/A',
          brand: data['brand']?.toString() ?? 'N/A',
          price: '₹${data['price']}',
          rating: double.tryParse(data['rating'].toString()) ?? 0.0,
          unitsSold: int.tryParse(data['units_sold'].toString()) ?? 0,
          revenue: double.tryParse(data['revenue'].toString()) ?? 0.0,
          orders: int.tryParse(data['orders'].toString()) ?? 0,
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load product details: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to connect to server')),
      );
    }
  }

  void _showProductDetails({
    required String productId,
    required String productName,
    required String category,
    required String brand,
    required String price,
    required double rating,
    required int unitsSold,
    required double revenue,
    required int orders,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: Color(0xFF6246EA)),
              const SizedBox(width: 10),
              const Expanded(child: Text('Product Details')),
              IconButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: SizedBox(
            width: 430,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _detailRow('Product ID', productId),
                  _detailRow('Product Name', productName),
                  _detailRow('Category', category),
                  _detailRow('Brand', brand),
                  _detailRow('Price', price),
                  _detailRow('Rating', '⭐ ${rating.toStringAsFixed(1)}'),
                  const Divider(height: 28),
                  _detailRow('Units Sold', unitsSold.toString()),
                  _detailRow('Revenue', '₹${revenue.toStringAsFixed(0)}'),
                  _detailRow('Orders', orders.toString()),
                ],
              ),
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

  // ==========================================
  // UPDATE PRODUCT
  // ==========================================
  Future<void> updateProduct({
    required String productId,
    required String productName,
    required String category,
    required String brand,
    required double price,
    required double rating,
  }) async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/products/$productId');

      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'product_name': productName,
          'category': category,
          'brand': brand,
          'price': price.toString(),
          'rating': rating.toString(),
        },
      );

      if (response.statusCode == 200) {
        await fetchProducts(
          search: searchController.text,
          category: selectedCategory,
          page: currentPage,
          sortBy: _getSortColumn(),
          order: sortOrder,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update product')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to connect to server')),
        );
      }
    }
  }

  // ==========================================
  // EDIT PRODUCT
  // ==========================================
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
                            onPressed: () async {
                              final price = double.tryParse(
                                priceController.text.trim().replaceAll(',', ''),
                              );

                              final rating = double.tryParse(
                                ratingController.text.trim(),
                              );

                              if (nameController.text.trim().isEmpty ||
                                  brandController.text.trim().isEmpty ||
                                  price == null ||
                                  rating == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter valid product details',
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.pop(dialogContext);

                              await updateProduct(
                                productId: productId,
                                productName: nameController.text.trim(),
                                category: selectedCategory,
                                brand: brandController.text.trim(),
                                price: price,
                                rating: rating,
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

  // ==========================================
  // PRODUCT MORE MENU
  // ==========================================
  void _showProductMoreMenu({
    required String productId,
    required String productName,

    // NEW
    required bool isActive,
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

                // ==========================================
                // VIEW ORDERS
                // ==========================================
                ListTile(
                  leading: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Color(0xFF6246EA),
                  ),
                  title: const Text('View Orders'),
                  subtitle: const Text('See orders containing this product'),
                  onTap: () {
                    Navigator.pop(context);

                    fetchProductOrders(
                      productId: productId,
                      productName: productName,
                    );
                  },
                ),

                // ==========================================
                // ACTIVE PRODUCT
                // ==========================================
                if (isActive)
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

                // ==========================================
                // INACTIVE PRODUCT
                // ==========================================
                if (!isActive)
                  ListTile(
                    leading: const Icon(
                      Icons.play_circle_outline,
                      color: Color(0xFF16A34A),
                    ),
                    title: const Text('Reactivate Product'),
                    subtitle: const Text(
                      'Restore this product to active listings',
                    ),
                    onTap: () {
                      Navigator.pop(context);

                      reactivateProduct(productId, productName);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // PRODUCT ORDERS
  // ==========================================
  Future<void> fetchProductOrders({
    required String productId,
    required String productName,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/products/$productId/orders'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        _showProductOrders(
          productId: productId,
          productName: productName,
          orders: List<dynamic>.from(data['orders'] ?? []),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load product orders')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showProductOrders({
    required String productId,
    required String productName,
    required List<dynamic> orders,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, color: Color(0xFF6246EA)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Orders - $productName',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: SizedBox(
            width: 650,
            height: 400,
            child: orders.isEmpty
                ? const Center(
                    child: Text(
                      'No orders found for this product.',
                      style: TextStyle(fontSize: 15),
                    ),
                  )
                : SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Order ID')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Customer')),
                          DataColumn(label: Text('Quantity')),
                          DataColumn(label: Text('Unit Price')),
                          DataColumn(label: Text('Total')),
                        ],
                        rows: orders.map((order) {
                          return DataRow(
                            cells: [
                              DataCell(Text(order['order_id'].toString())),
                              DataCell(
                                Text(order['order_date']?.toString() ?? 'N/A'),
                              ),
                              DataCell(
                                Text(order['customer_id']?.toString() ?? 'N/A'),
                              ),
                              DataCell(Text(order['quantity'].toString())),
                              DataCell(Text('₹${order['unit_price']}')),
                              DataCell(Text('₹${order['item_total']}')),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  // ==========================================
  // DEACTIVATE PRODUCT
  // ==========================================
  Future<void> _confirmDeactivateProduct({
    required String productId,
    required String productName,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Deactivate Product'),
          content: Text('Are you sure you want to deactivate "$productName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final response = await http.patch(
        Uri.parse('http://127.0.0.1:8000/products/$productId/deactivate'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deactivated successfully')),
        );

        fetchProducts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to deactivate product')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ==========================================
  // REACTIVATE PRODUCT
  // ==========================================
  Future<void> reactivateProduct(String productId, String productName) async {
    try {
      final response = await http.patch(
        Uri.parse('http://127.0.0.1:8000/products/$productId/reactivate'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$productName" reactivated successfully')),
        );

        // Refresh using the current filters/page
        await fetchProducts(
          search: searchController.text,
          category: selectedCategory,
          page: currentPage,
          sortBy: _getSortColumn(),
          order: sortOrder,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to reactivate product')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
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
