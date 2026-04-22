import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../core/theme/app_theme.dart';
import 'admin/pending_workers_screen.dart';
import 'admin/manage_users_screen.dart';
import 'admin/manage_posts_screen.dart';
import 'admin/manage_workers_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Administration',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, _) {
          return RefreshIndicator(
            onRefresh: () => admin.fetchStats(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Stats Cards
                if (admin.stats.isNotEmpty) ...[
                  // Highlighted Balance Card
                  _buildFeaturedStatCard(
                    context,
                    'Revenu en Escrow (TND)',
                    '${(admin.stats['totalBalance'] ?? 0.0).toStringAsFixed(2)}',
                    Icons.account_balance_wallet_rounded,
                    Colors.amber.shade700,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Utilisateurs',
                          '${admin.stats['totalUsers'] ?? 0}',
                          Icons.people_rounded,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Artisans',
                          '${admin.stats['totalWorkers'] ?? 0}',
                          Icons.handyman_rounded,
                          AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'En attente',
                          '${admin.stats['pendingWorkers'] ?? 0}',
                          Icons.pending_actions_rounded,
                          Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Publications',
                          '${admin.stats['totalPosts'] ?? 0}',
                          Icons.article_rounded,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
                const Text(
                  'Gestion',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 16),
                _buildAdminTile(
                  context,
                  'Artisans en attente',
                  'Valider les nouveaux comptes artisans',
                  Icons.pending_actions_rounded,
                  Colors.orange,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingWorkersScreen())),
                ),
                _buildAdminTile(
                  context,
                  'Gérer les Artisans',
                  'Certifier et gérer les profils artisans',
                  Icons.verified_user_rounded,
                  AppTheme.accentColor,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageWorkersScreen())),
                ),
                _buildAdminTile(
                  context,
                  'Gérer les Publications',
                  'Modérer et supprimer le contenu',
                  Icons.library_books_rounded,
                  Colors.green,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagePostsScreen())),
                ),
                _buildAdminTile(
                  context,
                  'Utilisateurs',
                  'Gérer les comptes clients et artisans',
                  Icons.people_rounded,
                  Colors.blue,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withAlpha(200)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        trailing: Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
        onTap: onTap,
      ),
    );
  }
}
