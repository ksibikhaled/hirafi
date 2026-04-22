import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/worker.dart';
import '../models/review.dart';
import '../providers/worker_provider.dart';
import '../providers/auth_provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/animated_scale_button.dart';
import 'request_form_screen.dart';

class WorkerProfileScreen extends StatefulWidget {
  final Worker worker;

  const WorkerProfileScreen({super.key, required this.worker});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  List<Review> _reviews = [];
  bool _loadingReviews = false;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => _loadingReviews = true);
    final reviews = await context.read<WorkerProvider>().fetchWorkerReviews(widget.worker.id);
    if (mounted) {
      setState(() {
        _reviews = reviews;
        _loadingReviews = false;
      });
    }
  }

  void _showReviewDialog() {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Laisser un avis'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  icon: Icon(
                    index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () => setState(() => rating = index + 1),
                )),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Votre commentaire...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                final success = await context.read<WorkerProvider>().addReview(
                  widget.worker.id,
                  rating,
                  commentController.text,
                );
                if (success && mounted) {
                  Navigator.pop(ctx);
                  _fetchReviews();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Merci pour votre avis !')),
                  );
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.worker.profileImageUrl != null
                      ? Image.network(widget.worker.profileImageUrl!, fit: BoxFit.cover)
                      : Container(
                          color: AppTheme.primaryColor,
                          child: const Icon(Icons.person_outline_rounded, size: 120, color: Colors.white24),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.primaryColor.withOpacity(0.8),
                          AppTheme.primaryColor,
                        ],
                        stops: const [0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${widget.worker.firstName} ${widget.worker.lastName}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (widget.worker.verified)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.verified_rounded, color: Colors.blue, size: 24),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.accentColor.withOpacity(0.5)),
                          ),
                          child: Text(
                            widget.worker.profession.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        if (context.watch<AuthProvider>().user?.id == widget.worker.userId)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.worker.featured ? Colors.amber : Colors.white.withOpacity(0.2),
                                foregroundColor: widget.worker.featured ? Colors.black : Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              onPressed: () {
                                // In a real app, this would open a payment dialog
                                context.read<WorkerProvider>().toggleFeatured(widget.worker.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(widget.worker.featured 
                                      ? "Profil boosté retiré" 
                                      : "Félicitations ! Votre profil est désormais boosté (Elite)."),
                                  ),
                                );
                              },
                              icon: Icon(widget.worker.featured ? Icons.rocket_launch_rounded : Icons.bolt_rounded),
                              label: Text(widget.worker.featured ? 'BOOST ACTIF' : 'PROPULSER MON PROFIL'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard('Abonnés', widget.worker.followersCount.toString(), Icons.people_outline_rounded),
                              _buildStatCard('Posts', widget.worker.postsCount.toString(), Icons.feed_outlined),
                              _buildStatCard('Note', '${widget.worker.ratingAvg.toStringAsFixed(1)}/5', Icons.star_outline_rounded),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'À propos',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        AnimatedScaleButton(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.worker.isFollowed ? AppTheme.surfaceColor : AppTheme.primaryColor,
                              foregroundColor: widget.worker.isFollowed ? AppTheme.textPrimary : Colors.white,
                              elevation: widget.worker.isFollowed ? 0 : 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: widget.worker.isFollowed ? AppTheme.textHint.withOpacity(0.3) : Colors.transparent,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            onPressed: () {
                              context.read<WorkerProvider>().followWorker(widget.worker.id);
                            },
                            icon: Icon(
                              widget.worker.isFollowed ? Icons.check_rounded : Icons.add_rounded,
                              size: 18,
                            ),
                            label: Text(widget.worker.isFollowed ? 'Abonné' : 'S\'abonner'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.worker.bio ?? "Cet artisan n'a pas encore ajouté de description à son profil.",
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Avis Clients',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    if (_loadingReviews)
                      const Center(child: CircularProgressIndicator())
                    else if (_reviews.isEmpty)
                      const Center(
                        child: Text("Aucun avis pour le moment", style: TextStyle(color: AppTheme.textHint)),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) => _buildReviewTile(_reviews[index]),
                      ),
                    const SizedBox(height: 16),
                    Center(
                      child: AnimatedScaleButton(
                        child: TextButton.icon(
                          onPressed: _showReviewDialog,
                          icon: const Icon(Icons.rate_review_rounded),
                          label: const Text("Laisser un avis"),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Informations de Contact',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    _buildContactTile(Icons.phone_rounded, 'Téléphone', widget.worker.phone ?? 'Non renseigné'),
                    const SizedBox(height: 12),
                    _buildContactTile(Icons.location_on_rounded, 'Localisation', '${widget.worker.city}, ${widget.worker.country}'),
                    const SizedBox(height: 40),
                    AnimatedScaleButton(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          shadowColor: AppTheme.accentColor.withOpacity(0.4),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => RequestFormScreen(worker: widget.worker)));
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.handyman_rounded),
                            SizedBox(width: 12),
                            Text(
                              'Demander un Service',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTile(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textHint.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: review.userProfileImage != null ? NetworkImage(review.userProfileImage!) : null,
                child: review.userProfileImage == null ? const Icon(Icons.person, size: 18) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${review.userFirstName} ${review.userLastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: List.generate(5, (index) => Icon(
                        Icons.star_rounded,
                        color: index < review.rating ? Colors.amber : Colors.grey.shade300,
                        size: 14,
                      )),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('dd/MM/yy').format(review.createdAt),
                style: const TextStyle(color: AppTheme.textHint, fontSize: 12),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(review.comment!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.accentColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textHint, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textHint.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.accentColor),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textHint, fontSize: 13)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
