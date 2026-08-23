import 'package:flutter/material.dart';
import '../widgets/products_orders/product_summary_card.dart';
import '../widgets/products_orders/product_table.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
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

                  const SizedBox(width: 14),

                  // Export button
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.file_download_outlined, size: 18),
                      label: const Text('Export'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6246EA),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // =========================
              // SUMMARY CARDS
              // =========================
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 16.0;

                  final cardWidth = (constraints.maxWidth - (spacing * 4)) / 5;

                  return Row(
                    children: [
                      // 1. Total Products
                      SizedBox(
                        width: cardWidth,
                        child: const ProductSummaryCard(
                          icon: Icons.inventory_2_outlined,
                          iconColor: Color(0xFF6246EA),
                          iconBackground: Color(0xFFEDE9FE),
                          title: 'Total Products',
                          value: '128',
                          subtitle: 'All active products',
                        ),
                      ),

                      const SizedBox(width: spacing),

                      // 2. Total Units Sold
                      SizedBox(
                        width: cardWidth,
                        child: const ProductSummaryCard(
                          icon: Icons.shopping_cart_outlined,
                          iconColor: Color(0xFF2196F3),
                          iconBackground: Color(0xFFE3F2FD),
                          title: 'Total Units Sold',
                          value: '24,560',
                          change: '18.6%',
                          subtitle: 'vs last 7 days',
                        ),
                      ),

                      const SizedBox(width: spacing),

                      // 3. Total Revenue
                      SizedBox(
                        width: cardWidth,
                        child: const ProductSummaryCard(
                          icon: Icons.currency_rupee,
                          iconColor: Color(0xFF22A06B),
                          iconBackground: Color(0xFFE8F5E9),
                          title: 'Total Revenue',
                          value: '₹2.64 Cr',
                          change: '29.1%',
                          subtitle: 'vs last 7 days',
                          isPositive: false,
                        ),
                      ),

                      const SizedBox(width: spacing),

                      // 4. Average Product Price
                      SizedBox(
                        width: cardWidth,
                        child: const ProductSummaryCard(
                          icon: Icons.bar_chart_outlined,
                          iconColor: Color(0xFFF4511E),
                          iconBackground: Color(0xFFFBE9E7),
                          title: 'Avg. Product Price',
                          value: '₹8,245',
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
                            border: Border.all(color: const Color(0xFFE5E7EB)),
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

                              const Text(
                                'HP Headphones 2',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF172033),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '154 units sold',
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

              const ProductTable(),
            ],
          ),
        ),
      ),
    );
  }
}
