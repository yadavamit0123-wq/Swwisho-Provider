import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../transaction/controller/transaction_controller.dart';
import '../../../controller/user_controller.dart';
import '../model/wallet_history_tran_model.dart';

class WalletHistoryScreen extends StatefulWidget {
  const WalletHistoryScreen({super.key});

  @override
  State<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends State<WalletHistoryScreen> {
  String _filterType = 'all';
  String _filterReason = 'all';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final controller = Get.find<TransactionController>();
    controller.fetchWalletHistory(); // Initial fetch
    // Add listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          !controller.isLoading) {
        controller.fetchWalletHistory();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<WalletTransactionHistory> getFilteredTransactions(
      List<WalletTransactionHistory> transactions) {
    return transactions.where((t) {
      final isCredit = (double.tryParse(t.credit) ?? 0) > 0;
      final type = isCredit ? 'credit' : 'debit';
      final reason = (t.trxType).toLowerCase();
      final typeMatch = _filterType == 'all' || type == _filterType;
      final reasonMatch = _filterReason == 'all' || reason == _filterReason;
      return typeMatch && reasonMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double currentBalance = UserProfileController.resolveWalletBalance(
      Get.find<UserProfileController>().providerModel?.content?.providerInfo?.owner?.account,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Get.find<TransactionController>().fetchWalletHistory();
            },
          ),
        ],
      ),
      body: GetBuilder<TransactionController>(
        builder: (controller) {
          final filtered = getFilteredTransactions(controller.walletTransactions);
          // final balance = controller.walletTransactions.fold<double>(
          //   0.0, (sum, t) =>
          //   sum + (double.tryParse(t.credit) ?? 0) - (double.tryParse(t.debit) ?? 0),
          // );
          filtered.sort((a, b) {
            final da = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1900);
            final db = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1900);
            return db.compareTo(da); // latest first
          });
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Current Balance',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${currentBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       DropdownButton<String>(
              //         value: _filterType,
              //         items: const [
              //           DropdownMenuItem(value: 'all', child: Text('All Types')),
              //           DropdownMenuItem(value: 'credit', child: Text('Credit')),
              //           DropdownMenuItem(value: 'debit', child: Text('Debit')),
              //         ],
              //         onChanged: (value) => setState(() => _filterType = value!),
              //       ),
              //       DropdownButton<String>(
              //         value: _filterReason,
              //         items: const [
              //           DropdownMenuItem(value: 'all', child: Text('All Reasons')),
              //           DropdownMenuItem(value: 'wallet recharge', child: Text('Recharge')),
              //           DropdownMenuItem(value: 'received_amount', child: Text('Received')),
              //         ],
              //         onChanged: (value) => setState(() => _filterReason = value!),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(height: 10,),
              Expanded(
                child: controller.isLoading && controller.walletTransactions.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                    ? const Center(child: Text('No transactions found'))
                    : ListView.builder(
                  controller: _scrollController,
                  itemCount: filtered.length + (controller.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == filtered.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final t = filtered[index];
                    final isCredit = (double.tryParse(t.credit) ?? 0) > 0;
                    final isCash = t.trxType.toLowerCase().contains('cash');
                    final amount = isCredit
                        ? double.tryParse(t.credit) ?? 0
                        : double.tryParse(t.debit) ?? 0;
                    final Color amountColor = isCash
                        ? Colors.amber.shade800
                        : isCredit
                            ? Colors.green
                            : Colors.red;
                    final String typeLabel = isCash
                        ? 'CASH'
                        : isCredit
                            ? 'CREDIT'
                            : 'DEBIT';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            height: 140,
                            width: MediaQuery.of(context).size.width * .65,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(300),
                                bottomLeft: Radius.circular(20),
                                topLeft: Radius.circular(20),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: Get.isDarkMode
                                    ? [Colors.transparent, Colors.transparent]
                                    : [Colors.blue.shade50, Colors.white],
                              ),
                            ),
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: CircleAvatar(
                              backgroundColor: amountColor.withValues(alpha: 0.15),
                              child: Icon(
                                isCash ? Icons.payments_outlined : isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                                color: amountColor,
                              ),
                            ),
                            title: Text(
                              '$typeLabel: \t ₹${amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: amountColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reason: ${t.trxType}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Date: ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.parse(t.createdAt))}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            // trailing: Text(
                            //   '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(2)}',
                            //   style: TextStyle(
                            //     color: isCredit ? Colors.green : Colors.red,
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}