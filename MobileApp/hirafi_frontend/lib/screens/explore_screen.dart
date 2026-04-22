import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../core/theme/app_theme.dart';
import '../providers/worker_provider.dart';
import '../widgets/worker_card.dart';
import '../widgets/shimmer_loading.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String? _selectedProfession;
  final List<Map<String, dynamic>> _professions = [
    {'name': 'Plombier', 'icon': Icons.water_drop_rounded},
    {'name': 'Électricien', 'icon': Icons.bolt_rounded},
    {'name': 'Menuisier', 'icon': Icons.handyman_rounded},
    {'name': 'Peintre', 'icon': Icons.palette_rounded},
    {'name': 'Maçon', 'icon': Icons.foundation_rounded},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProvider>().searchWorkers();
    });
  }

  void _onSearch() {
    context.read<WorkerProvider>().searchWorkers(
      search: _searchController.text,
      profession: _selectedProfession,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 180,
            backgroundColor: Colors.white.withOpacity(0.8),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.black.withOpacity(0.05)),
                ),
              ),
              title: const Text(
                'Explorer les Artisans',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
              ),
              centerTitle: true,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Nom, métier ou ville...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.tune_rounded),
                      onPressed: _onSearch,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardTheme.color,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _onSearch(),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _professions.length,
                itemBuilder: (context, index) {
                  final p = _professions[index];
                  bool isSelected = _selectedProfession == p['name'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      avatar: Icon(p['icon'], size: 16, color: isSelected ? Colors.white : AppTheme.accentColor),
                      label: Text(p['name']),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedProfession = selected ? p['name'] : null);
                        _onSearch();
                      },
                      selectedColor: AppTheme.accentColor,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      pressElevation: 4,
                    ),
                  );
                },
              ),
            ),
          ),
          Consumer<WorkerProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const ShimmerLoading(
                        isLoading: true,
                        child: SkeletonCard(),
                      ),
                      childCount: 5,
                    ),
                  ),
                );
              }
              
              if (provider.workers.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_rounded, size: 64, color: AppTheme.textHint.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        const Text('Aucun artisan trouvé', style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: WorkerCard(worker: provider.workers[index]),
                      );
                    },
                    childCount: provider.workers.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
