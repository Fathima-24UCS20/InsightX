import 'package:flutter/material.dart';

class OrderTableRow extends StatelessWidget {
  final String orderId;
  final String customerId;
  final String orderDate;
  final String paymentMethod;
  final String totalAmount;
  final VoidCallback? onView;
  final VoidCallback? onMore;

  const OrderTableRow({
    super.key,
    required this.orderId,
    required this.customerId,
    required this.orderDate,
    required this.paymentMethod,
    required this.totalAmount,
    this.onView,
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
          // ORDER ID
          // ==========================================
          SizedBox(
            width: 100,
            child: Text(
              orderId,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),

          // ==========================================
          // CUSTOMER ID
          // ==========================================
          Expanded(
            flex: 2,
            child: Text(
              customerId,
              style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
            ),
          ),

          // ==========================================
          // ORDER DATE
          // ==========================================
          Expanded(
            flex: 2,
            child: Text(
              orderDate,
              style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
            ),
          ),

          // ==========================================
          // PAYMENT METHOD
          // ==========================================
          Expanded(flex: 2, child: _paymentBadge(paymentMethod)),

          // ==========================================
          // TOTAL AMOUNT
          // ==========================================
          Expanded(
            flex: 2,
            child: Text(
              totalAmount,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF172033),
              ),
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
                _actionButton(Icons.visibility_outlined, onView ?? () {}),
                const SizedBox(width: 7),
                _actionButton(Icons.more_vert, onMore ?? () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PAYMENT METHOD BADGE
  // ==========================================
  Widget _paymentBadge(String paymentMethod) {
    Color background;
    Color textColor;

    switch (paymentMethod.toLowerCase()) {
      case 'credit card':
        background = const Color(0xFFEDE9FE);
        textColor = const Color(0xFF6246EA);
        break;

      case 'debit card':
        background = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        break;

      case 'upi':
        background = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E9B59);
        break;

      case 'cash on delivery':
        background = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE88900);
        break;

      default:
        background = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          paymentMethod,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
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
