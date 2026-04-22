import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/worker_provider.dart';
import '../widgets/post_card.dart';
import '../core/theme/app_theme.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'create_post_screen.dart';
import 'notifications_screen.dart';
import '../providers/theme_provider.dart';
import 'speed/speed_screen.dart';
import 'admin_dashboard.dart';
import '../widgets/shimmer_loading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../providers/notification_provider.dart';
import '../widgets/review_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'Tous';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Tous', 'icon': Icons.grid_view_rounded},
    {'name': 'Plomberie', 'icon': FontAwesomeIcons.faucet},
    {'name': 'Électricité', 'icon': Icons.bolt_rounded},
    {'name': 'Maçonnerie', 'icon': FontAwesomeIcons.hammer},
    {'name': 'Menuiserie', 'icon': FontAwesomeIcons.tree},
    {'name': 'Peinture', 'icon': Icons.palette_rounded},
    {'name': 'Jardinage', 'icon': Icons.grass_rounded}
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProvider>().fetchFeed();
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();
    final authProvider = context.watch<AuthProvider>();
    final List<Widget> _pages = [
      authProvider.user?.role == 'ADMIN' ? const AdminDashboard() : _buildHomeBody(workerProvider),
      const ExploreScreen(),
      _buildRequestsBody(authProvider, workerProvider),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
                // Fetch requests when navigating to requests tab
                if (index == 2) {
                  final auth = context.read<AuthProvider>();
                  final wp = context.read<WorkerProvider>();
                  if (auth.user?.role == 'WORKER') {
                    wp.fetchWorkerRequests();
                  } else {
                    wp.fetchUserRequests();
                  }
                }
              },
              backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.white.withOpacity(0.8),
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).unselectedWidgetColor,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Accueil'),
                BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Explorer'),
                BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Demandes'),
                BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0 ? _buildFAB(authProvider) : null,
    );
  }

  Widget? _buildFAB(AuthProvider authProvider) {
    if (authProvider.user?.role == 'WORKER') {
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen()));
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      );
    } else if (authProvider.user?.role == 'USER') {
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SpeedScreen()));
        },
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.bolt_rounded),
        label: const Text('SPEED', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      );
    } else if (authProvider.user?.role == 'ADMIN') {
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
        },
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.admin_panel_settings_rounded),
        label: const Text('ADMIN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
      );
    }
    return null;
  }

  Widget _buildHomeBody(WorkerProvider workerProvider) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120.0,
          floating: true,
          pinned: true,
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: FlexibleSpaceBar(
                title: Text(
                  'HIRAFI',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                background: Container(color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7)),
              ),
            ),
          ),
          actions: [
            Consumer<NotificationProvider>(
              builder: (context, provider, _) => IconButton(
                icon: Badge(
                  label: Text(provider.unreadCount.toString()),
                  isLabelVisible: provider.unreadCount > 0,
                  child: const Icon(Icons.notifications_none_rounded),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.palette_rounded),
              onPressed: () => _showThemePicker(context),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) => CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                  backgroundImage: auth.user?.profileImageUrl != null
                      ? NetworkImage(auth.user!.profileImageUrl!)
                      : null,
                  child: auth.user?.profileImageUrl == null
                      ? const Icon(Icons.person_rounded, size: 20, color: AppTheme.accentColor)
                      : null,
                ),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(
                  'Catégories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    bool isSelected = _selectedCategory == category['name'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        avatar: Icon(
                          category['icon'], 
                          size: 16, 
                          color: isSelected ? AppTheme.accentColor : AppTheme.textSecondary
                        ),
                        label: Text(category['name']),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() => _selectedCategory = category['name']);
                        },
                        backgroundColor: Colors.white,
                        selectedColor: AppTheme.accentColor.withOpacity(0.2),
                        checkmarkColor: Colors.transparent, // Hide checkmark for custom avatar
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.accentColor : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? AppTheme.accentColor : Colors.black12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (context.read<AuthProvider>().user?.role == 'WORKER')
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen()));
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) => CircleAvatar(
                              radius: 20,
                              backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                              backgroundImage: auth.user?.profileImageUrl != null
                                  ? NetworkImage(auth.user!.profileImageUrl!)
                                  : null,
                              child: auth.user?.profileImageUrl == null
                                  ? const Icon(Icons.person_rounded, size: 20, color: AppTheme.accentColor)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Publier votre travail...',
                              style: TextStyle(color: AppTheme.textHint, fontSize: 16),
                            ),
                          ),
                          const Icon(Icons.image_rounded, color: AppTheme.accentColor),
                        ],
                      ),
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Fil d\'actualité',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        if (workerProvider.isLoading && workerProvider.feed.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const PostCardShimmer(),
                childCount: 3,
              ),
            ),
          )
        else if (workerProvider.feed.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.feed_outlined, size: 64, color: AppTheme.textHint.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('Aucune publication pour le moment'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
                    onPressed: () {
                      setState(() => _currentIndex = 1); // Switch to explore tab
                    },
                    child: const Text('Découvrir des artisans'),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PostCard(post: workerProvider.feed[index]),
                  );
                },
                childCount: workerProvider.feed.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRequestsBody(AuthProvider authProvider, WorkerProvider workerProvider) {
    final isWorker = authProvider.user?.role == 'WORKER';
    final requests = isWorker ? workerProvider.workerRequests : workerProvider.userRequests;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          isWorker ? 'Demandes Reçues' : 'Mes Demandes',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: workerProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.assignment_outlined,
                          size: 56,
                          color: AppTheme.accentColor.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Aucune demande',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isWorker
                            ? 'Vous n\'avez pas encore reçu de demandes'
                            : 'Trouvez un artisan et envoyez votre première demande',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                      if (!isWorker) ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _currentIndex = 1),
                          icon: const Icon(Icons.explore_rounded),
                          label: const Text('Explorer les artisans'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    if (isWorker) {
                      await workerProvider.fetchWorkerRequests();
                    } else {
                      await workerProvider.fetchUserRequests();
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return _buildRequestCard(request, isWorker, workerProvider);
                    },
                  ),
                ),
    );
  }

  Widget _buildRequestCard(dynamic request, bool isWorker, WorkerProvider workerProvider) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (request.status) {
      case 'PENDING':
        statusColor = Colors.orange;
        statusLabel = 'En attente';
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case 'ACCEPTED':
        statusColor = Colors.green;
        statusLabel = 'Acceptée';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        statusLabel = 'Refusée';
        statusIcon = Icons.cancel_rounded;
        break;
      case 'COMPLETED':
        statusColor = Colors.blue;
        statusLabel = 'Terminée';
        statusIcon = Icons.task_alt_rounded;
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = request.status;
        statusIcon = Icons.info_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                        child: Icon(
                          isWorker ? Icons.person_rounded : Icons.handyman_rounded,
                          color: AppTheme.accentColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isWorker
                                  ? '${request.userFirstName} ${request.userLastName}'
                                  : '${request.workerFirstName} ${request.workerLastName}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                            ),
                            if (!isWorker)
                              Text(
                                request.workerProfession,
                                style: const TextStyle(color: AppTheme.accentColor, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                request.description,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (request.preferredDate != null) ...[
                  Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.textHint),
                  const SizedBox(width: 4),
                  Text(request.preferredDate!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(width: 16),
                ],
                if (request.location != null) ...[
                  Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textHint),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      request.location!,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            // Worker action buttons
            if (isWorker && request.status == 'PENDING') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => workerProvider.updateRequestStatus(request.id, 'ACCEPTED'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('Accepter', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => workerProvider.updateRequestStatus(request.id, 'REJECTED'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(color: AppTheme.errorColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('Refuser', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ] else if (isWorker && request.status == 'ACCEPTED') ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => workerProvider.updateRequestStatus(request.id, 'COMPLETED'),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Marquer comme Terminé'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
            // User feedback button
            if (!isWorker && request.status == 'COMPLETED') ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ReviewDialog(
                      workerId: request.workerId,
                      workerName: '${request.workerFirstName} ${request.workerLastName}',
                    ),
                  );
                },
                icon: const Icon(Icons.rate_review_rounded, size: 18),
                label: const Text('Laisser un avis'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentColor,
                  side: const BorderSide(color: AppTheme.accentColor),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
            // User cancel button
            if (!isWorker && request.status == 'PENDING') ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Annuler la demande ?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Non')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              workerProvider.cancelRequest(request.id);
                            },
                            child: const Text('Oui, annuler', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Annuler'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Style de l\'application',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _themeOption(context, 'Clair', AppThemeMode.light, Colors.white, AppTheme.accentColor),
                _themeOption(context, 'Sombre', AppThemeMode.dark, Colors.black, Colors.indigo),
                _themeOption(context, 'Océan', AppThemeMode.ocean, const Color(0xFF0EA5E9), const Color(0xFF2DD4BF)),
                _themeOption(context, 'Coucher', AppThemeMode.sunset, const Color(0xFFF43F5E), const Color(0xFFFB923C)),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(BuildContext context, String name, AppThemeMode mode, Color color1, Color color2) {
    final themeProvider = context.watch<ThemeProvider>();
    final isSelected = themeProvider.themeMode == mode;

    return Column(
      children: [
        GestureDetector(
          onTap: () => themeProvider.setTheme(mode),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color1, color2]),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppTheme.accentColor : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color1.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white) : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
