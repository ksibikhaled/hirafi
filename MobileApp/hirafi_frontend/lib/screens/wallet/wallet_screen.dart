import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/wallet_provider.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchWalletData();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showDepositDialog() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildAmountSheet(
        ctx,
        title: 'Recharger mon compte',
        subtitle: 'Ajoutez des fonds à votre portefeuille Hirafi',
        icon: Icons.add_circle_rounded,
        iconColor: Theme.of(context).colorScheme.primary,
        buttonLabel: 'Confirmer le dépôt',
        buttonColor: Theme.of(context).colorScheme.primary,
        controller: controller,
        onConfirm: (amount) async {
          Navigator.pop(ctx);
          final success = await context.read<WalletProvider>().deposit(amount);
          if (success && mounted) {
            _showSuccessSnackBar('Rechargement de ${amount.toStringAsFixed(2)} TND effectué !');
          } else if (mounted) {
            _showErrorSnackBar(context.read<WalletProvider>().error ?? 'Échec du dépôt');
          }
        },
      ),
    );
  }

  void _showWithdrawDialog() {
    final controller = TextEditingController();
    final wallet = context.read<WalletProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildAmountSheet(
        ctx,
        title: 'Retirer des fonds',
        subtitle: 'Solde disponible : ${NumberFormat("#,##0.00").format(wallet.balance)} TND',
        icon: Icons.arrow_upward_rounded,
        iconColor: Theme.of(context).colorScheme.secondary,
        buttonLabel: 'Confirmer le retrait',
        buttonColor: Theme.of(context).colorScheme.secondary,
        controller: controller,
        minAmount: 10.0,
        maxAmount: wallet.balance,
        onConfirm: (amount) async {
          Navigator.pop(ctx);
          final success = await context.read<WalletProvider>().withdraw(amount);
          if (success && mounted) {
            _showSuccessSnackBar('Retrait de ${amount.toStringAsFixed(2)} TND effectué !');
          } else if (mounted) {
            _showErrorSnackBar(context.read<WalletProvider>().error ?? 'Échec du retrait');
          }
        },
      ),
    );
  }

  Widget _buildAmountSheet(
    BuildContext ctx, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String buttonLabel,
    required Color buttonColor,
    required TextEditingController controller,
    required Function(double) onConfirm,
    double minAmount = 1.0,
    double? maxAmount,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48, height: 5,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 28),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, letterSpacing: 2),
              decoration: InputDecoration(
                hintText: "0.00",
                hintStyle: TextStyle(color: Colors.grey[300], fontSize: 36, fontWeight: FontWeight.bold),
                suffixText: 'TND',
                suffixStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[500]),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
            const SizedBox(height: 8),
            // Quick amount buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [20, 50, 100, 200].map((amt) {
                return GestureDetector(
                  onTap: () => controller.text = amt.toString(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: iconColor.withOpacity(0.2)),
                    ),
                    child: Text('$amt', style: TextStyle(fontWeight: FontWeight.bold, color: iconColor, fontSize: 15)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(controller.text);
                  if (amount != null && amount >= minAmount) {
                    if (maxAmount != null && amount > maxAmount) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Montant maximum : ${maxAmount.toStringAsFixed(2)} TND')),
                      );
                      return;
                    }
                    onConfirm(amount);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Montant minimum : ${minAmount.toStringAsFixed(2)} TND')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: buttonColor.withOpacity(0.4),
                ),
                child: Text(buttonLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<WalletProvider>(
        builder: (context, wallet, _) {
          if (wallet.isLoading && wallet.transactions.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            );
          }
          
          return RefreshIndicator(
            color: AppTheme.accentColor,
            onRefresh: () => wallet.fetchWalletData(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Custom SliverAppBar with gradient
                SliverAppBar(
                  expandedHeight: 0,
                  floating: true,
                  backgroundColor: Colors.white,
                  elevation: 0.5,
                  title: const Text(
                    'Mon Portefeuille',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Animated Credit Card
                        ScaleTransition(
                          scale: _cardAnimation,
                          child: _buildPremiumCard(wallet.balance, wallet.currency),
                        ),
                        const SizedBox(height: 28),

                        // Action Buttons
                        _buildActionButtons(),
                        const SizedBox(height: 32),

                        // Stats Row
                        if (wallet.transactions.isNotEmpty) ...[
                          _buildStatsRow(wallet),
                          const SizedBox(height: 32),
                        ],

                        // Error Banner
                        if (wallet.error != null) ...[
                          _buildErrorBanner(wallet.error!),
                          const SizedBox(height: 16),
                        ],

                        // Transactions Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Transactions",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            Text(
                              "${wallet.transactions.length} opérations",
                              style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Transactions List
                        if (wallet.transactions.isEmpty)
                          _buildEmptyState()
                        else
                          ...wallet.transactions.map((tx) => _buildTransactionTile(tx)),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumCard(double balance, String currency) {
    return Container(
      height: 210,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF312E81), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -40, top: -40,
            child: Container(
              height: 140, width: 140,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -20, bottom: -30,
            child: Container(
              height: 100, width: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Subtle grid pattern
          Positioned(
            right: 20, bottom: 20,
            child: Icon(Icons.nfc_rounded, color: Colors.white.withOpacity(0.15), size: 40),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'HIRAFI PAY',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
                      ),
                      child: const Text(
                        'ELITE',
                        style: TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solde Disponible',
                      style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat("#,##0.00").format(balance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            currency,
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: _buildActionCard(
          icon: Icons.add_rounded,
          label: 'Recharger',
          color: const Color(0xFF10B981),
          onTap: _showDepositDialog,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildActionCard(
          icon: Icons.arrow_upward_rounded,
          label: 'Retirer',
          color: const Color(0xFF3B82F6),
          onTap: _showWithdrawDialog,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildActionCard(
          icon: Icons.receipt_long_rounded,
          label: 'Relevé',
          color: const Color(0xFF8B5CF6),
          onTap: () {
            // Scroll to transactions
            _showSuccessSnackBar("Les transactions sont affichées ci-dessous");
          },
        )),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(WalletProvider wallet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem(
            'Dépôts',
            '+${wallet.totalDeposits.toStringAsFixed(0)}',
            const Color(0xFF10B981),
            Icons.arrow_downward_rounded,
          )),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          Expanded(child: _buildStatItem(
            'Retraits',
            '-${wallet.totalWithdrawals.toStringAsFixed(0)}',
            const Color(0xFFEF4444),
            Icons.arrow_upward_rounded,
          )),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          Expanded(child: _buildStatItem(
            'Gains',
            '+${wallet.totalEarnings.toStringAsFixed(0)}',
            const Color(0xFF8B5CF6),
            Icons.star_rounded,
          )),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(error, style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          GestureDetector(
            onTap: () => context.read<WalletProvider>().clearError(),
            child: Icon(Icons.close_rounded, color: AppTheme.errorColor.withOpacity(0.6), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_rounded, size: 48, color: AppTheme.accentColor.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucune transaction',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            'Rechargez votre compte pour commencer\nà utiliser Hirafi Pay !',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[400], height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(WalletTransaction tx) {
    final config = _getTransactionConfig(tx);
    String date = DateFormat('dd MMM yyyy, HH:mm').format(tx.createdAt);
    String amountStr = "${tx.isPositive ? '+' : ''}${tx.amount.toStringAsFixed(2)} TND";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [config.color.withOpacity(0.12), config.color.withOpacity(0.04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(config.icon, color: config.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(date, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    if (tx.isRefunded) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'REMBOURSÉ',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountStr,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: config.color,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                config.label,
                style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _TransactionConfig _getTransactionConfig(WalletTransaction tx) {
    switch (tx.type) {
      case 'DEPOSIT':
        return _TransactionConfig(
          icon: Icons.arrow_downward_rounded,
          color: const Color(0xFF10B981),
          label: 'DÉPÔT',
        );
      case 'WITHDRAWAL':
        return _TransactionConfig(
          icon: Icons.arrow_upward_rounded,
          color: const Color(0xFFEF4444),
          label: 'RETRAIT',
        );
      case 'ESCROW_HOLD':
        return _TransactionConfig(
          icon: Icons.lock_rounded,
          color: tx.isRefunded ? Colors.orange : const Color(0xFFF59E0B),
          label: tx.isRefunded ? 'REMBOURSÉ' : 'SÉQUESTRE',
        );
      case 'ESCROW_RELEASE':
        return _TransactionConfig(
          icon: Icons.lock_open_rounded,
          color: const Color(0xFF8B5CF6),
          label: 'PAIEMENT',
        );
      case 'PLATFORM_FEE':
        return _TransactionConfig(
          icon: Icons.business_center_rounded,
          color: const Color(0xFF64748B),
          label: 'COMMISSION',
        );
      case 'BOOST_PAYMENT':
        return _TransactionConfig(
          icon: Icons.rocket_launch_rounded,
          color: const Color(0xFFF97316),
          label: 'BOOST',
        );
      default:
        return _TransactionConfig(
          icon: Icons.swap_horiz_rounded,
          color: Theme.of(context).colorScheme.outline,
          label: tx.type,
        );
    }
  }
}

class _TransactionConfig {
  final IconData icon;
  final Color color;
  final String label;

  _TransactionConfig({required this.icon, required this.color, required this.label});
}
