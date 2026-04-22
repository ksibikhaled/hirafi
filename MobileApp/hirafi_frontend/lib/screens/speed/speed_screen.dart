import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';
import '../../providers/worker_provider.dart';
import '../../models/worker.dart';
import '../worker_profile_screen.dart';

class SpeedScreen extends StatefulWidget {
  const SpeedScreen({super.key});

  @override
  State<SpeedScreen> createState() => _SpeedScreenState();
}

class _SpeedScreenState extends State<SpeedScreen> with TickerProviderStateMixin {
  late AnimationController _rippleController;
  bool _isSearching = false;
  String? _selectedCategory;
  Worker? _matchedWorker;
  
  final List<Map<String, dynamic>> _emergencies = [
    {'title': 'Fuite d\'eau', 'icon': Icons.water_drop_rounded, 'category': 'Plomberie', 'color': Colors.blue},
    {'title': 'Panne de courant', 'icon': Icons.bolt_rounded, 'category': 'Électricité', 'color': Colors.amber},
    {'title': 'Serrure bloquée', 'icon': Icons.key_rounded, 'category': 'Serrurerie', 'color': Colors.grey},
    {'title': 'Vitre cassée', 'icon': Icons.broken_image_rounded, 'category': 'Vitrerie', 'color': Colors.teal},
  ];

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _startSearch(String category) {
    setState(() {
      _selectedCategory = category;
      _isSearching = true;
    });
    _rippleController.repeat();

    // Simulate search delay
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      _rippleController.stop();
      _matchWorker(category);
    });
  }

  void _matchWorker(String category) {
    final workers = context.read<WorkerProvider>().workers;
    Worker? match;
    try {
      // Find a featured high-rated worker in this category, else just any
      final categoryWorkers = workers.where((w) => w.profession == category).toList();
      if (categoryWorkers.isNotEmpty) {
        // Sort by featured then rating
        categoryWorkers.sort((a, b) {
          if (a.featured && !b.featured) return -1;
          if (!a.featured && b.featured) return 1;
          return b.ratingAvg.compareTo(a.ratingAvg);
        });
        match = categoryWorkers.first;
      } else if (workers.isNotEmpty) {
        // Fallback
        match = workers.first;
      }
    } catch (e) {
      match = null;
    }

    setState(() {
      _isSearching = false;
      _matchedWorker = match;
    });
    
    if (match != null) {
      _showMatchDialog(match);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun artisan disponible pour cette urgence actuellement.")));
    }
  }

  void _showMatchDialog(Worker matched) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Text(
                  "MATCH SPEED !",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text("Un artisan a accepté votre requête à 2km.", style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), width: 2),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: matched.profileImageUrl != null ? NetworkImage(matched.profileImageUrl!) : null,
                    backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                    child: matched.profileImageUrl == null ? const Icon(Icons.person) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("${matched.firstName} ${matched.lastName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            if (matched.verified)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.verified_rounded, color: AppTheme.accentColor, size: 16),
                              ),
                          ],
                        ),
                  Text(matched.profession, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(matched.ratingAvg.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Colors.red),
                      Text("5 min", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      // Can go to profile or initiate call
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkerProfileScreen(worker: matched)));
                    },
                    icon: const Icon(Icons.phone_rounded),
                    label: const Text("Appeler l'artisan"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() { _matchedWorker = null; });
              },
              child: const Text("Annuler la requête", style: TextStyle(color: AppTheme.errorColor)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark radar theme
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        title: const Text('Hirafi Speed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isSearching ? _buildSearchingView() : _buildSelectionView(),
    );
  }

  Widget _buildSearchingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              _buildRippleEffect(),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.radar_rounded, size: 50, color: AppTheme.accentColor),
              ),
            ],
          ),
          const SizedBox(height: 60),
          const Text(
            "Recherche en cours...",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Nous contactons les artisans dans un rayon de 5km",
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
          ),
          const SizedBox(height: 40),
          TextButton(
            onPressed: () {
              setState(() {
                _isSearching = false;
              });
              _rippleController.stop();
            },
            child: const Text("Annuler", style: TextStyle(color: AppTheme.errorColor, fontSize: 18)),
          )
        ],
      ),
    );
  }

  Widget _buildRippleEffect() {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            final double baseSize = 100.0;
            final double value = _rippleController.value;
            // stagger animations
            final double offset = index / 3;
            double progress = value - offset;
            if (progress < 0) progress += 1.0;

            final double size = baseSize + (progress * 250);
            final double opacity = 1.0 - progress;

            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(opacity),
                  width: 2,
                ),
                color: Theme.of(context).colorScheme.primary.withOpacity(opacity * 0.2),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSelectionView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quelle est votre urgence ?",
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Nous vous trouvons un artisan de confiance en moins de 5 minutes.",
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: _emergencies.length,
              itemBuilder: (context, index) {
                final item = _emergencies[index];
                return GestureDetector(
                  onTap: () => _startSearch(item['category']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: item['color'].withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item['icon'], color: item['color'], size: 40),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item['title'],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
