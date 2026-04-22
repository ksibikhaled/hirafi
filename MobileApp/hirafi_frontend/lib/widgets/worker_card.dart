import 'package:flutter/material.dart';
import '../models/worker.dart';
import '../screens/worker_profile_screen.dart';
import '../core/theme/app_theme.dart';
import 'dart:ui';

class WorkerCard extends StatelessWidget {
  final Worker worker;

  const WorkerCard({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: worker.featured 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.08) 
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: worker.featured 
            ? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), width: 1.5)
            : Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: worker.featured 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1) 
                : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Column(
            children: [
              if (worker.featured)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '⭐ ARTISAN À LA UNE (SPEED CONNECT) ⭐',
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2
                      ),
                    ),
                  ),
                ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerProfileScreen(worker: worker)));
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                    backgroundImage: worker.profileImageUrl != null
                        ? NetworkImage(worker.profileImageUrl!)
                        : null,
                    child: worker.profileImageUrl == null 
                        ? const Icon(Icons.person_rounded, size: 32, color: AppTheme.accentColor) 
                        : null,
                  ),
                  if (worker.verified)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_rounded, color: Colors.blue, size: 18),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${worker.firstName} ${worker.lastName}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      worker.profession.toUpperCase(), 
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary, 
                        fontSize: 11, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          worker.ratingAvg.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${worker.reviewsCount})',
                          style: const TextStyle(color: AppTheme.textHint, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on_rounded, size: 16, color: AppTheme.textHint),
                        const SizedBox(width: 4),
                        Text(
                          worker.city ?? 'N/A',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textHint),
            ],
          ),
        ),
      ),
            ],
          ),
        ),
      ),
    );
  }
}
