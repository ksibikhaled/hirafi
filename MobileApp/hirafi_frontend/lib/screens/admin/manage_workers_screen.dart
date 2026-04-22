import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../core/theme/app_theme.dart';
import '../worker_profile_screen.dart';

class ManageWorkersScreen extends StatefulWidget {
  const ManageWorkersScreen({super.key});

  @override
  State<ManageWorkersScreen> createState() => _ManageWorkersScreenState();
}

class _ManageWorkersScreenState extends State<ManageWorkersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllWorkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Gérer les Artisans', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, _) {
          if (admin.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (admin.allWorkers.isEmpty) {
            return const Center(child: Text("Aucun artisan trouvé"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: admin.allWorkers.length,
            itemBuilder: (context, index) {
              final worker = admin.allWorkers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                        backgroundImage: worker.profileImageUrl != null ? NetworkImage(worker.profileImageUrl!) : null,
                        child: worker.profileImageUrl == null ? const Icon(Icons.person, color: AppTheme.accentColor) : null,
                      ),
                      if (worker.verified)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.verified_rounded, color: Colors.blue, size: 16),
                          ),
                        ),
                    ],
                  ),
                  title: Text('${worker.firstName} ${worker.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(worker.profession, style: const TextStyle(color: AppTheme.accentColor, fontSize: 13)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          worker.verified ? Icons.verified_rounded : Icons.verified_outlined,
                          color: worker.verified ? Colors.blue : Colors.grey,
                        ),
                        onPressed: () => admin.verifyWorker(worker.id, !worker.verified),
                        tooltip: worker.verified ? 'Retirer la certification' : 'Certifier le profil',
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'profile') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerProfileScreen(worker: worker)));
                          } else if (value == 'block') {
                            await admin.blockWorker(worker.id);
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Supprimer cet artisan ?'),
                                content: const Text('Cette action est irréversible.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true) await admin.deleteWorker(worker.id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'profile', child: Text('Voir le profil')),
                          const PopupMenuItem(value: 'block', child: Text('Bloquer')),
                          const PopupMenuItem(value: 'delete', child: Text('Supprimer', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
