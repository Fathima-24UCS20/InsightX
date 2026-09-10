import 'package:flutter/material.dart';
import '../widgets/products_orders/product_summary_card.dart';
import '../widgets/products_orders/product_table.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  Map<String, dynamic>? summary;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSummary();
  }

  Future<void> fetchSummary() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/products/summary'),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          summary = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          errorMessage = 'Failed to load summary';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Unable to connect to server';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================
                // PAGE HEADER
                // =========================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Products',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172554),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Manage your product catalog and view performance.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Date range button
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 17,
                            color: Color(0xFF374151),
                          ),
                          const SizedBox(width: 9),
                          const Text(
                            'May 15 – May 21, 2025',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // =========================
                // SUMMARY CARDS
                // =========================
                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 16.0;

                    final cardWidth =
                        (constraints.maxWidth - (spacing * 4)) / 5;

                    return Row(
                      children: [
                        // 1. Total Products
                        SizedBox(
                          width: cardWidth,
                          child: ProductSummaryCard(
                            icon: Icons.inventory_2_outlined,
                            iconColor: const Color(0xFF6246EA),
                            iconBackground: const Color(0xFFEDE9FE),
                            title: 'Total Products',
                            value: isLoading
                                ? '...'
                                : '${summary?['total_products'] ?? 0}',
                            subtitle: 'All products',
                          ),
                        ),

                        const SizedBox(width: spacing),

                        // 2. Total Units Sold
                        SizedBox(
                          width: cardWidth,
                          child: ProductSummaryCard(
                            icon: Icons.shopping_cart_outlined,
                            iconColor: const Color(0xFF2196F3),
                            iconBackground: const Color(0xFFE3F2FD),
                            title: 'Total Units Sold',
                            value: isLoading
                                ? '...'
                                : '${summary?['total_units_sold'] ?? 0}',
                            change: isLoading
                                ? null
                                : summary?['units_sold_change'] == null
                                ? null
                                : '${summary!['units_sold_change'].abs()}%',
                            subtitle: 'vs last 7 days',
                            isPositive:
                                !isLoading &&
                                (summary?['units_sold_change'] ?? 0) >= 0,
                          ),
                        ),

                        const SizedBox(width: spacing),

                        // 3. Total Revenue
                        SizedBox(
                          width: cardWidth,
                          child: ProductSummaryCard(
                            icon: Icons.currency_rupee,
                            iconColor: const Color(0xFF22A06B),
                            iconBackground: const Color(0xFFE8F5E9),
                            title: 'Total Revenue',
                            value: isLoading
                                ? '...'
                                : '₹${((summary?['total_revenue'] ?? 0) / 10000000).toStringAsFixed(2)} Cr',
                            change: isLoading
                                ? null
                                : summary?['revenue_change'] == null
                                ? null
                                : '${summary!['revenue_change'].abs()}%',
                            subtitle: 'vs last 7 days',
                            isPositive:
                                !isLoading &&
                                (summary?['revenue_change'] ?? 0) >= 0,
                          ),
                        ),

                        const SizedBox(width: spacing),

                        // 4. Average Product Price
                        SizedBox(
                          width: cardWidth,
                          child: ProductSummaryCard(
                            icon: Icons.bar_chart_outlined,
                            iconColor: const Color(0xFFF4511E),
                            iconBackground: const Color(0xFFFBE9E7),
                            title: 'Avg. Product Price',
                            value: isLoading
                                ? '...'
                                : '₹${(summary?['avg_product_price'] ?? 0).toStringAsFixed(0)}',
                            subtitle: 'Average selling price',
                          ),
                        ),

                        const SizedBox(width: spacing),

                        // 5. Best Selling Product
                        SizedBox(
                          width: cardWidth,
                          child: Container(
                            height: 170,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDE9FE),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.workspace_premium_outlined,
                                    color: Color(0xFF6246EA),
                                    size: 23,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  'Best Selling Product',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  isLoading
                                      ? '...'
                                      : summary?['best_selling_product']?['name'] ??
                                            'N/A',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF172033),
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  isLoading
                                      ? '...'
                                      : '${summary?['best_selling_product']?['units_sold'] ?? 0} units sold',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // =========================
                // PRODUCTS / ORDERS TABLE
                // =========================
                const ProductTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
