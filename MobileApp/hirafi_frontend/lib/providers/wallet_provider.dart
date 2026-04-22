import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class WalletTransaction {
  final int id;
  final double amount;
  final String type;
  final String status;
  final String? referenceId;
  final String description;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    this.referenceId,
    required this.description,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      status: json['status'],
      referenceId: json['referenceId'],
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  bool get isPositive => amount > 0;
  bool get isRefunded => status == 'REFUNDED';
}

class WalletProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  double _balance = 0.0;
  String _currency = 'TND';
  List<WalletTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  double get balance => _balance;
  String get currency => _currency;
  List<WalletTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed stats
  double get totalDeposits => _transactions
      .where((t) => t.type == 'DEPOSIT' && t.status == 'COMPLETED')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalWithdrawals => _transactions
      .where((t) => t.type == 'WITHDRAWAL' && t.status == 'COMPLETED')
      .fold(0.0, (sum, t) => sum + t.amount.abs());

  double get totalEarnings => _transactions
      .where((t) => t.type == 'ESCROW_RELEASE' && t.status == 'COMPLETED')
      .fold(0.0, (sum, t) => sum + t.amount);

  int get pendingEscrows => _transactions
      .where((t) => t.type == 'ESCROW_HOLD' && t.status == 'COMPLETED')
      .length;

  Future<void> fetchWalletData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final balanceResp = await _apiService.dio.get("/api/wallet/balance");
      if (balanceResp.data['success']) {
        _balance = (balanceResp.data['data']['balance'] as num).toDouble();
        _currency = balanceResp.data['data']['currency'] ?? 'TND';
      }

      final historyResp = await _apiService.dio.get("/api/wallet/history");
      if (historyResp.data['success']) {
        final data = historyResp.data['data'];
        final List results = data is Map ? (data['content'] ?? []) : data;
        _transactions = results.map((e) => WalletTransaction.fromJson(e)).toList();
      }
    } catch (e) {
      _error = "Échec du chargement du portefeuille";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deposit(double amount) async {
    try {
      final response = await _apiService.dio.post(
        "/api/wallet/deposit",
        data: {'amount': amount},
      );
      if (response.data['success']) {
        _balance = (response.data['data']['balance'] as num).toDouble();
        await fetchWalletData(); // Refresh history
        return true;
      }
    } catch (e) {
      _error = _extractErrorMessage(e, "Erreur lors du dépôt");
      notifyListeners();
    }
    return false;
  }

  Future<bool> withdraw(double amount) async {
    try {
      final response = await _apiService.dio.post(
        "/api/wallet/withdraw",
        data: {'amount': amount},
      );
      if (response.data['success']) {
        _balance = (response.data['data']['balance'] as num).toDouble();
        await fetchWalletData(); // Refresh history
        return true;
      }
    } catch (e) {
      _error = _extractErrorMessage(e, "Erreur lors du retrait");
      notifyListeners();
    }
    return false;
  }

  String _extractErrorMessage(dynamic e, String fallback) {
    try {
      if (e is Exception && e.toString().contains('DioException')) {
        // Try to extract server error message
        return fallback;
      }
    } catch (_) {}
    return fallback;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
