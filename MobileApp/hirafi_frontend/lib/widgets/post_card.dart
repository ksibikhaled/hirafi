import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../providers/worker_provider.dart';
import '../widgets/comments_sheet.dart';
import '../screens/worker_profile_screen.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../widgets/shimmer_loading.dart';
import '../widgets/animated_scale_button.dart';
import '../core/theme/app_theme.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isOwner = authProvider.user?.id == post.workerUserId;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color?.withOpacity(0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final worker = await context.read<WorkerProvider>().getWorkerById(post.workerId);
                          if (worker != null && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => WorkerProfileScreen(worker: worker)),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                backgroundImage: post.workerProfileImage != null
                                    ? NetworkImage(post.workerProfileImage!)
                                    : null,
                                child: post.workerProfileImage == null 
                                    ? Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary) 
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${post.workerFirstName} ${post.workerLastName}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold, 
                                            fontSize: 16,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        if (post.workerVerified)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 4),
                                            child: Icon(Icons.verified_rounded, color: Colors.blue, size: 16),
                                          ),
                                      ],
                                    ),
                                  Text(
                                    post.workerProfession,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary, 
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM').format(post.createdAt),
                      style: const TextStyle(color: AppTheme.textHint, fontSize: 12),
                    ),
                    if (isOwner)
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleMenuAction(context, value),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                          const PopupMenuItem(value: 'delete', child: Text('Supprimer', style: TextStyle(color: Colors.red))),
                        ],
                        icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textHint),
                      ),
                  ],
                ),
              ),
              if (post.content.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    post.content, 
                    style: const TextStyle(
                      fontSize: 15, 
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              if (post.imageUrls.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        PageView.builder(
                          itemCount: post.imageUrls.length,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: post.imageUrls[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppTheme.backgroundColor,
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppTheme.backgroundColor,
                                child: const Icon(Icons.error_outline_rounded, color: AppTheme.textHint),
                              ),
                            );
                          },
                        ),
                        if (post.imageUrls.length > 1)
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '1/${post.imageUrls.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AnimatedScaleButton(
                          onTap: () => context.read<WorkerProvider>().toggleLike(post.id),
                          child: _ActionButton(
                            icon: post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            label: post.reactionCount.toString(),
                            color: post.isLiked ? Colors.red : AppTheme.textSecondary,
                            onTap: () {}, // Handled by AnimatedScaleButton
                          ),
                        ),
                        const SizedBox(width: 16),
                        AnimatedScaleButton(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => CommentsSheet(post: post),
                            );
                          },
                          child: _ActionButton(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: post.commentCount.toString(),
                            onTap: () {}, // Handled by AnimatedScaleButton
                          ),
                        ),
                      ],
                    ),
                    AnimatedScaleButton(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primary.withOpacity(0.8)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.send_rounded, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Contacter', 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    if (action == 'edit') {
      _showEditDialog(context);
    } else if (action == 'delete') {
      _showDeleteConfirm(context);
    }
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: post.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la publication'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Votre message...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<WorkerProvider>().updatePost(post.id, controller.text);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Publication mise à jour')));
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: const Text('Voulez-vous vraiment supprimer cette publication ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              final success = await context.read<WorkerProvider>().deletePost(post.id);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Publication supprimée')));
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color ?? AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class PostCardShimmer extends StatelessWidget {
  const PostCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 44, height: 44, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7))),
                    const SizedBox(height: 6),
                    Container(width: 80, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 8),
            Container(width: 200, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
          ],
        ),
      ),
    );
  }
}
