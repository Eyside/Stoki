// lib/main.dart (VERSION CLOUD COMPLÈTE)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/group_stock_selection_screen.dart';
import 'screens/recette/group_recipe_selection_screen.dart';
import 'screens/planning/group_planning_selection_screen.dart';
import 'screens/shopping_planning_selection_screen.dart'; // ✅ NOUVEAU
import 'screens/profiles_screen.dart';
import 'screens/calorie_tracking_screen.dart';
import 'screens/groups/groups_screen.dart';
import 'screens/auth/auth_wrapper.dart';
import 'services/auth_service.dart';
import 'providers.dart';

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
          seedColor: const Color(0xFF95D9C3),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
          centerTitle: false,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF10B981),
          unselectedItemColor: Color(0xFF94A3B8),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF10B981),
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/recipe-selection': (context) => const GroupRecipeSelectionScreen(),
        '/planning-selection': (context) => const GroupPlanningSelectionScreen(),
        '/shopping-selection': (context) => const ShoppingPlanningSelectionScreen(), // ✅ NOUVEAU
      },
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
    final pages = <Widget>[
      const HomeScreen(),
      const GroupStockSelectionScreen(),
      const GroupRecipeSelectionScreen(),
      const GroupPlanningSelectionScreen(),
      const ShoppingPlanningSelectionScreen(), // ✅ NOUVEAU: écran de sélection
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
            icon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_rounded),
            label: 'Recettes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Planning',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_rounded),
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
    final authService = AuthService();
    final user = authService.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF95D9C3),
                  const Color(0xFFB8E6D5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, size: 40, color: Color(0xFF10B981))
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user?.displayName ?? 'Stoki',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? 'Gestion intelligente',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Groupes
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4B5).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.group_rounded, color: Color(0xFFF59E0B)),
            ),
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

          const Divider(height: 1),

          // Profils
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFBBDEFB).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.people_rounded, color: Color(0xFF2196F3)),
            ),
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
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFCAB8FF).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.analytics_rounded, color: Color(0xFF9C27B0)),
            ),
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

          const Divider(height: 1),

          // Paramètres
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.settings_rounded, color: Colors.grey.shade700),
            ),
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
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.info_rounded, color: Colors.grey.shade700),
            ),
            title: const Text('À propos'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Stoki',
                applicationVersion: '2.0.0',
                applicationIcon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF95D9C3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.kitchen_rounded, size: 32, color: Colors.white),
                ),
                children: const [
                  Text('Application de gestion de stocks, recettes et planning de repas.'),
                ],
              );
            },
          ),

          const Divider(height: 1),
          const SizedBox(height: 8),

          // Déconnexion
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () async {
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                        ),
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
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}