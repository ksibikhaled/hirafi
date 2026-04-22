import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../core/theme/app_theme.dart';
import 'auth/login_screen.dart';
import 'wallet/wallet_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Paramètres', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Compte',
              [
                _buildSettingsTile(
                  context,
                  icon: Icons.person_outline_rounded,
                  title: 'Modifier le profil',
                  subtitle: 'Nom, bio, coordonnées',
                  onTap: () {
                    // Navigate to Edit Profile (I'll create this next)
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.wallet_outlined,
                  title: 'Hirafi Pay',
                  subtitle: 'Gérer mon portefeuille',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Apparence',
              [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Thème de l\'application', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _themeItem(context, 'Clair', AppThemeMode.light, Colors.white, themeProvider),
                          _themeItem(context, 'Sombre', AppThemeMode.dark, const Color(0xFF0F172A), themeProvider),
                          _themeItem(context, 'Océan', AppThemeMode.ocean, const Color(0xFF0EA5E9), themeProvider),
                          _themeItem(context, 'Sunset', AppThemeMode.sunset, const Color(0xFFF43F5E), themeProvider),
                          _themeItem(context, 'Auto', AppThemeMode.system, Colors.grey.shade400, themeProvider),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Général',
              [
                _buildSettingsTile(
                  context,
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: 'Gérer les alertes',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'Aide & Support',
                  subtitle: 'FAQ, Contactez-nous',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'À propos',
                  subtitle: 'Version 1.0.0',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Préférences',
              [
                 _buildLanguageTile(context),
              ],
            ),
            const SizedBox(height: 40),
            _buildLogoutTile(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.bold, 
              color: Theme.of(context).colorScheme.primary, 
              letterSpacing: 1.2
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textHint),
      ),
    );
  }

  Widget _themeItem(BuildContext context, String label, AppThemeMode mode, Color color, ThemeProvider theme) {
    bool isSelected = theme.themeMode == mode;
    return GestureDetector(
      onTap: () => theme.setTheme(mode),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.2),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 8)] : null,
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: () => _handleLogout(context),
        leading: const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
        title: const Text('Déconnexion', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.errorColor),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Déconnexion', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.language_rounded, color: Theme.of(context).colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Langue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Français (Par défaut)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textHint),
        ],
      ),
    );
  }
}
