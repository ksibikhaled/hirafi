package com.hirafi.backend.config;

import com.hirafi.backend.entity.*;
import com.hirafi.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final WorkerRepository workerRepository;
    private final PostRepository postRepository;
    private final PostImageRepository postImageRepository;
    private final ReactionRepository reactionRepository;
    private final CommentRepository commentRepository;
    private final FollowerRepository followerRepository;
    private final ReviewRepository reviewRepository;
    private final WorkRequestRepository workRequestRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        initAdmin();
        initData();
    }

    private void initAdmin() {
        User admin = userRepository.findByEmail("admin@hirafi.com").orElse(null);
        if (admin == null) {
            admin = User.builder()
                    .email("admin@hirafi.com")
                    .firstName("Admin")
                    .lastName("Hirafi")
                    .role(Role.ADMIN)
                    .status(AccountStatus.ACTIVE)
                    .build();
            System.out.println("Admin account created: admin@hirafi.com / admin1234");
        }
        admin.setPassword(passwordEncoder.encode("admin1234"));
        userRepository.save(admin);
    }

    private void initData() {
        if (!userRepository.existsByEmail("karim@hirafi.com")) {
            System.out.println("Initializing real mock data for artisans and users...");

            // Elite / Boosted Artisan
            User u1 = User.builder().email("karim@hirafi.com").password(passwordEncoder.encode("password123")).firstName("Karim").lastName("Mansouri").role(Role.WORKER).profileImageUrl("https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=250&q=80").status(AccountStatus.ACTIVE).walletBalance(java.math.BigDecimal.valueOf(1500.50)).build();
            userRepository.save(u1);
            Worker w1 = Worker.builder().user(u1).profession("Plombier").city("Tunis").country("Tunisie").bio("Plombier expérimenté avec plus de 10 ans de métier au service de votre confort.").approved(true).verified(true).featured(true).ratingAvg(java.math.BigDecimal.valueOf(4.8)).build();
            workerRepository.save(w1);

            // Artisan 2
            User u2 = User.builder().email("sami@hirafi.com").password(passwordEncoder.encode("password123")).firstName("Sami").lastName("Ben Ali").role(Role.WORKER).profileImageUrl("https://images.unsplash.com/photo-1531384441138-2736e62e0919?auto=format&fit=crop&w=250&q=80").status(AccountStatus.ACTIVE).build();
            userRepository.save(u2);
            Worker w2 = Worker.builder().user(u2).profession("Peintre").city("La Marsa").country("Tunisie").bio("Peintre décorateur passionné par les belles finitions.").approved(true).ratingAvg(java.math.BigDecimal.valueOf(4.9)).build();
            workerRepository.save(w2);

            // Artisant 3
            User u3 = User.builder().email("amina@hirafi.com").password(passwordEncoder.encode("password123")).firstName("Amina").lastName("Zayani").role(Role.WORKER).profileImageUrl("https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=250&q=80").status(AccountStatus.ACTIVE).build();
            userRepository.save(u3);
            Worker w3 = Worker.builder().user(u3).profession("Électricien").city("Ariana").country("Tunisie").bio("Interventions électriques rapides, aux normes et sécurisées dans tout le grand Tunis.").approved(true).verified(true).ratingAvg(java.math.BigDecimal.valueOf(4.7)).build();
            workerRepository.save(w3);

            // Artisan 4
            User u4 = User.builder().email("yassin@hirafi.com").password(passwordEncoder.encode("password123")).firstName("Yassin").lastName("Karray").role(Role.WORKER).profileImageUrl("https://images.unsplash.com/photo-1540331547168-8b63109228b7?auto=format&fit=crop&w=250&q=80").status(AccountStatus.ACTIVE).build();
            userRepository.save(u4);
            Worker w4 = Worker.builder().user(u4).profession("Jardinier").city("Gammarth").country("Tunisie").bio("Création et entretien d'espaces verts. Paysagiste diplômé.").approved(true).featured(true).ratingAvg(java.math.BigDecimal.valueOf(4.5)).build();
            workerRepository.save(w4);

            // --- 5 NEW REALISTIC USERS ---

            // Artisan 5
            User u5 = User.builder().email("mehdi@hirafi.com").password(passwordEncoder.encode("password123")).firstName("Mehdi").lastName("Cherif").role(Role.WORKER).profileImageUrl("https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=250&q=80").status(AccountStatus.ACTIVE).build();
            userRepository.save(u5);
            Worker w5 = Worker.builder().user(u5).profession("Climatisation").city("Bizerte").country("Tunisie").bio("Réparation et installation de climatiseurs toutes marques. Service rapide.").approved(true).ratingAvg(java.math.BigDecimal.valueOf(4.6)).build();
            workerRepository.save(w5);

            // Artisan 6
            User u6 = User.builder().email("ines@hirafi.com").password(passwordEncoder.encode("password123")).firstName("Ines").lastName("Bouaziz").role(Role.WORKER).profileImageUrl("https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=250&q=80").status(AccountStatus.ACTIVE).build();
            userRepository.save(u6);
            Worker w6 = Worker.builder().user(u6).profession("Décoratrice").city("Sousse").country("Tunisie").bio("Décoration d'intérieur et aménagement d'espaces. Design moderne et épuré.").approved(true).featured(true).ratingAvg(java.math.BigDecimal.valueOf(4.9)).build();
            workerRepository.save(w6);

            // Artisan 7
            User u7 = User.builder().email("tarek@hirafi.com").password(passwordEncoder.encode("password123")).firstName("Tarek").lastName("Jaziri").role(Role.WORKER).profileImageUrl("https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=250&q=80").status(AccountStatus.ACTIVE).build();
            userRepository.save(u7);
            Worker w7 = Worker.builder().user(u7).profession("Menuisier").city("Sfax").country("Tunisie").bio("Fabrication sur mesure de meubles en bois massif. Plus de 20 ans d'expérience.").approved(true).verified(true).ratingAvg(java.math.BigDecimal.valueOf(4.7)).build();
            workerRepository.save(w7);

            // Normal User 3
            User client3 = User.builder().email("rym@hirafi.com").password(passwordEncoder.encode("password123")).firstName("Rym").lastName("Saidi").role(Role.USER).status(AccountStatus.ACTIVE).profileImageUrl("https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=250&q=80").build();
            userRepository.save(client3);

            // Normal User 4
            User client4 = User.builder().email("nizar@hirafi.com").password(passwordEncoder.encode("password123")).firstName("Nizar").lastName("Louati").role(Role.USER).status(AccountStatus.ACTIVE).profileImageUrl("https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=250&q=80").build();
            userRepository.save(client4);

            // Normal User 1
            User client = User.builder().email("omar@hirafi.com").password(passwordEncoder.encode("password123")).firstName("Omar").lastName("Trabelsi").role(Role.USER).status(AccountStatus.ACTIVE).profileImageUrl("https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=250&q=80").build();
            userRepository.save(client);

            // Normal User 2
            User client2 = User.builder().email("fatma@hirafi.com").password(passwordEncoder.encode("password123")).firstName("Fatma").lastName("Gharbi").role(Role.USER).status(AccountStatus.ACTIVE).profileImageUrl("https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=250&q=80").build();
            userRepository.save(client2);

            // Follows
            followerRepository.save(Follower.builder().user(client).worker(w1).build());
            followerRepository.save(Follower.builder().user(client).worker(w2).build());
            followerRepository.save(Follower.builder().user(client).worker(w3).build());
            followerRepository.save(Follower.builder().user(client2).worker(w1).build());
            followerRepository.save(Follower.builder().user(client2).worker(w4).build());

            // Posts & Engagements
            Post p1 = Post.builder().worker(w1).content("Installation d'une nouvelle chaudière ce matin à El Menzah. Le client est ravi de la qualité du service !").build();
            postRepository.save(p1);
            postImageRepository.save(PostImage.builder().post(p1).imageUrl("https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=600&q=80").build());

            Post p2 = Post.builder().worker(w2).content("Nouvelle chambre d'enfant achevée ! Peinture écologique, sans odeur et lessivable. N'hésitez pas à me contacter pour un devis.").build();
            postRepository.save(p2);
            postImageRepository.save(PostImage.builder().post(p2).imageUrl("https://images.unsplash.com/photo-1562663474-6cbb3eaa4d14?auto=format&fit=crop&w=600&q=80").build());

            Post p3 = Post.builder().worker(w3).content("Mise aux normes complète d'un tableau électrique dans une ancienne villa. La sécurité avant tout ⚡ !").build();
            postRepository.save(p3);
            postImageRepository.save(PostImage.builder().post(p3).imageUrl("https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=600&q=80").build());

            Post p4 = Post.builder().worker(w1).content("Intervention d'urgence à minuit hier pour une fuite d'eau majeure dans un appartement. Problème résolu en moins de 30 minutes. Je reste à votre service 24/7 !").build();
            postRepository.save(p4);

            Post p5 = Post.builder().worker(w4).content("Le printemps est là 🌸 ! C'est le moment idéal pour préparer vos jardins. Voici une réalisation récente à Gammarth.").build();
            postRepository.save(p5);
            postImageRepository.save(PostImage.builder().post(p5).imageUrl("https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?auto=format&fit=crop&w=600&q=80").build());

            // Comments and Likes
            reactionRepository.save(Reaction.builder().post(p1).user(client).type("LIKE").build());
            reactionRepository.save(Reaction.builder().post(p2).user(client).type("LIKE").build());
            reactionRepository.save(Reaction.builder().post(p4).user(client).type("LIKE").build());
            reactionRepository.save(Reaction.builder().post(p5).user(client2).type("LIKE").build());
            
            commentRepository.save(Comment.builder().post(p1).user(client).content("Excellent travail Karim, la chaudière marche parfaitement.").build());
            commentRepository.save(Comment.builder().post(p2).user(client).content("J'adore le choix des couleurs !").build());
            commentRepository.save(Comment.builder().post(p4).user(client).content("Merci de m'avoir sauvé de l'inondation haha !").build());
            commentRepository.save(Comment.builder().post(p5).user(client2).content("Magnifique jardin !").build());

            // Real Positive Reviews
            reviewRepository.save(Review.builder().user(client).worker(w1).rating(5).comment("Excellent plombier ! Ponctuel, propre et très efficace. Je le recommande sans hésiter.").build());
            reviewRepository.save(Review.builder().user(client2).worker(w1).rating(5).comment("Karim a réparé ma clim en un clin d'oeil. Très poli.").build());
            reviewRepository.save(Review.builder().user(client).worker(w2).rating(5).comment("Sami a fait un travail extraordinaire sur les murs de mon salon. Couleurs parfaites !").build());
            reviewRepository.save(Review.builder().user(client).worker(w3).rating(4).comment("Bon électricien, sérieux et professionnel. Juste un petit retard sur le RDV.").build());
            reviewRepository.save(Review.builder().user(client2).worker(w4).rating(5).comment("Yassin a transformé ma terrasse en un véritable paradis. Un vrai pro !").build());

            // Work Requests for Escrow Demo
            workRequestRepository.save(WorkRequest.builder()
                .user(client)
                .worker(w1)
                .description("Fuite urgence cuisine")
                .location("Tunis Centre")
                .amount(java.math.BigDecimal.valueOf(80.00))
                .status(RequestStatus.COMPLETED)
                .build());

            workRequestRepository.save(WorkRequest.builder()
                .user(client2)
                .worker(w1)
                .description("Installation nouveau robinet")
                .location("Marsa")
                .amount(java.math.BigDecimal.valueOf(50.00))
                .status(RequestStatus.PENDING)
                .build());

            System.out.println("Real mock data injected successfully!");
        }
    }
}
