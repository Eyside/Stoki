// lib/main.dart (CORRIGÉ)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers.dart';
import 'screens/home_screen.dart';
import 'screens/frigo_screen.dart';
import 'screens/recette/recette_unified_screen.dart';
import 'screens/planning_screen_new.dart';
import 'screens/shopping_list_screen_new.dart';
import 'screens/ingredient_list_screen.dart';
import 'screens/profiles_screen.dart'; // ✅ UNIQUE IMPORT POUR LES PROFILS
import 'screens/calorie_tracking_screen.dart';
import 'screens/groups/groups_screen.dart';
import 'screens/auth/auth_wrapper.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stoki',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFF1F8F4),
          selectedItemColor: Color(0xFF2E7D32),
          unselectedItemColor: Color(0xFF757575),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ingredientRepo = ref.watch(ingredientRepositoryProvider);
    final frigoRepo = ref.watch(frigoRepositoryProvider);
    final recetteRepo = ref.watch(recetteRepositoryProvider);

    final pages = <Widget>[
      const HomeScreen(),
      FrigoScreen(
        frigoRepository: frigoRepo,
        ingredientRepository: ingredientRepo,
      ),
      RecetteUnifiedScreen(recetteRepository: recetteRepo),
      const PlanningScreen(),
      const ShoppingListScreenNew(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: _getTitle(),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Notifications
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Recettes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Planning',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Courses',
          ),
        ],
      ),
    );
  }

  Widget _getTitle() {
    switch (_currentIndex) {
      case 0:
        return const Text('Accueil');
      case 1:
        return const Text('Stock');
      case 2:
        return const Text('Recettes');
      case 3:
        return const Text('Planning');
      case 4:
        return const Text('Liste de courses');
      default:
        return const Text('Stoki');
    }
  }

  Widget _buildDrawer(BuildContext context) {
    final ingredientRepo = ref.watch(ingredientRepositoryProvider);
    final authService = AuthService();
    final user = authService.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, size: 40, color: Colors.green)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  user?.displayName ?? 'Stoki',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? 'Gestion intelligente',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Groupes
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Mes groupes'),
            subtitle: const Text('Partager avec famille & amis'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GroupsScreen()),
              );
            },
          ),

          const Divider(),

          // ✅ PROFILS - MENU UNIQUE
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Mes Profils'),
            subtitle: const Text('Gérer mes profils et ceux de ma famille'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilesScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Suivi calorique'),
            subtitle: const Text('Historique de consommation'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalorieTrackingScreen()),
              );
            },
          ),

          const Divider(),

          // Ingrédients
          ListTile(
            leading: const Icon(Icons.eco),
            title: const Text('Ingrédients'),
            subtitle: const Text('Gérer la base d\'ingrédients'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IngredientListScreen(repository: ingredientRepo),
                ),
              );
            },
          ),

          const Divider(),

          // Paramètres
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paramètres - À venir')),
              );
            },
          ),

          // À propos
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('À propos'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Stoki',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.kitchen, size: 48, color: Colors.green),
                children: const [
                  Text('Application de gestion de stocks, recettes et planning de repas.'),
                ],
              );
            },
          ),

          const Divider(),

          // Déconnexion
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Se déconnecter', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(c, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Déconnexion'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}