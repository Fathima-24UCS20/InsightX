import 'package:flutter/material.dart';

class ProductTableRow extends StatelessWidget {
  final String productId;
  final String productName;
  final String category;
  final String brand;
  final String price;
  final double rating;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onMore;

  const ProductTableRow({
    super.key,
    required this.productId,
    required this.productName,
    required this.category,
    required this.brand,
    required this.price,
    required this.rating,
    this.onView,
    this.onEdit,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          // ==========================================
          // PRODUCT ID
          // ==========================================
          SizedBox(
            width: 85,
            child: Text(
              productId,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ==========================================
          // PRODUCT NAME
          // ==========================================
          Expanded(
            flex: 3,
            child: Text(
              productName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF172033),
              ),
            ),
          ),

          // ==========================================
          // CATEGORY
          // ==========================================
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _categoryBadge(category),
            ),
          ),

          // ==========================================
          // BRAND
          // ==========================================
          Expanded(
            flex: 2,
            child: Text(
              brand,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
            ),
          ),

          // ==========================================
          // PRICE
          // ==========================================
          Expanded(
            flex: 2,
            child: Text(
              price,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF172033),
              ),
            ),
          ),

          // ==========================================
          // RATING
          // ==========================================
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 17,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // ACTIONS
          // ==========================================
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionButton(
                  Icons.visibility_outlined,
                  onView != null ? onView! : () {},
                ),
                const SizedBox(width: 7),
                _actionButton(
                  Icons.edit_outlined,
                  onEdit != null ? onEdit! : () {},
                ),
                const SizedBox(width: 7),
                _actionButton(
                  Icons.more_vert,
                  onMore != null ? onMore! : () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CATEGORY BADGE
  // ==========================================
  Widget _categoryBadge(String category) {
    Color background;
    Color textColor;

    switch (category.toLowerCase()) {
      case 'headphones':
        background = const Color(0xFFEDE9FE);
        textColor = const Color(0xFF6246EA);
        break;

      case 'smartwatch':
        background = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        break;

      case 'tablet':
        background = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E9B59);
        break;

      case 'smartphone':
        background = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE88900);
        break;

      case 'laptop':
        background = const Color(0xFFFCE4EC);
        textColor = const Color(0xFFD81B60);
        break;

      case 'camera':
        background = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFE59A00);
        break;

      default:
        background = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ==========================================
  // ACTION BUTTON
  // ==========================================
  Widget _actionButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, size: 15, color: const Color(0xFF4B5563)),
      ),
    );
  }
}
