import 'dart:convert';
import 'pregnancy_week_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'community_feed_screen.dart';
import 'preg_ease_theme.dart';
import 'nutrition_screen.dart';
import 'baby_preparation_screen.dart';
import 'wellness_screen.dart';
import 'activities_screen.dart';
import 'father_dashboard_screen.dart';
import 'appointments_screen.dart';

// ============================================================
// API CONFIGURATION
// ============================================================
//
// Flutter Web / Chrome:
// FastAPI is running on the same computer:
//
//   http://127.0.0.1:8000
//
// Android Emulator:
// change to:
//
//   http://10.0.2.2:8000
//
// ============================================================

const String apiBaseUrl = 'http://127.0.0.1:8000';


// ============================================================
// AUTH HELPERS
// ============================================================

Future<String?> getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token');
}


Future<Map<String, String>> authHeaders() async {
  final token = await getAuthToken();

  return {
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty)
      'Authorization': 'Bearer $token',
  };
}


Future<void> clearAuth() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove('access_token');
  await prefs.remove('user_name');
  await prefs.remove('user_email');
}


// ============================================================
// MAIN
// ============================================================

void main() {
  runApp(const PregEaseApp());
}


// ============================================================
// APP
// ============================================================

class PregEaseApp extends StatelessWidget {
  const PregEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    const sage = Color(0xFF71866B);
    const deepSage = Color(0xFF405442);
    const ivory = Color(0xFFFAF7F0);
    const rose = Color(0xFFD5A5A0);
    const surface = Color(0xFFFFFDF9);
    const border = Color(0xFFEAE3D8);
    const ink = Color(0xFF343A33);
    const muted = Color(0xFF77796F);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: sage,
      brightness: Brightness.light,
    ).copyWith(
      primary: sage,
      onPrimary: Colors.white,
      secondary: rose,
      onSecondary: deepSage,
      surface: surface,
      onSurface: ink,
      error: const Color(0xFFC94F67),
      onError: Colors.white,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PregEase',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: ivory,
        appBarTheme: const AppBarTheme(
          backgroundColor: ivory,
          foregroundColor: deepSage,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: border),
          ),
          margin: EdgeInsets.zero,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: ink,
          displayColor: deepSage,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: deepSage,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding: const EdgeInsets.all(16),
          hintStyle: const TextStyle(color: muted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: sage, width: 1.5),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 25),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF343A33),
                    )),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF77796F),
                    )),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF71866B)),
            ],
          ),
        ),
      ),
    );
  }
}


//===========
// AUTH GATE
// ============================================================
//
// Decides whether the user sees:
//
// Login/Register
//
// or
//
// Main application
//
// ============================================================

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() =>
      _AuthGateState();
}


class _AuthGateState
    extends State<AuthGate> {

  bool _loading = true;

  bool _loggedIn = false;

  // Kept in memory only: a fresh app session asks for role again.
  ParentRole? _selectedRole;


  @override
  void initState() {
    super.initState();

    _checkAuthentication();
  }


  Future<void> _checkAuthentication() async {
    final token = await getAuthToken();

    if (!mounted) return;

    setState(() {
      _loggedIn =
          token != null &&
          token.isNotEmpty;

      _loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }


    if (_loggedIn) {
      if (_selectedRole == null) {
        return RoleSelectionScreen(
          onRoleSelected: (role) {
            if (!mounted) return;
            setState(() {
              _selectedRole = role;
            });
          },
        );
      }

      return AppShell(role: _selectedRole!);
    }


    return LoginScreen(
      onLoginSuccess: () {
        if (!mounted) return;
        setState(() {
          _loggedIn = true;
        });
      },
    );
  }
}


// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {

  final VoidCallback onLoginSuccess;


  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });


  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}


class _LoginScreenState
    extends State<LoginScreen> {

  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _passwordController =
      TextEditingController();


  bool _loading = false;

  bool _obscurePassword = true;


Future<void> _login() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text;

  if (email.isEmpty || password.isEmpty) {
    _showMessage(
      'Please enter your email and password.',
    );
    return;
  }

  if (!mounted) return;

  setState(() {
    _loading = true;
  });

  bool loginSucceeded = false;

  try {
    // --------------------------------------------------------
    // FastAPI:
    // POST /auth/login?email=...&password=...
    // --------------------------------------------------------

    final uri = Uri.parse(
      '$apiBaseUrl/auth/login',
    ).replace(
      queryParameters: {
        'email': email,
        'password': password,
      },
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    debugPrint(
      'Login status: ${response.statusCode}',
    );

    debugPrint(
      'Login response: ${response.body}',
    );

    // --------------------------------------------------------
    // LOGIN SUCCESS
    // --------------------------------------------------------

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final token =
          data['access_token']?.toString();

      if (token == null || token.isEmpty) {
        if (mounted) {
          _showMessage(
            'Login succeeded but no access token was returned.',
          );
        }
        return;
      }

      // ------------------------------------------------------
      // SAVE JWT
      // ------------------------------------------------------

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        'access_token',
        token,
      );

      // ------------------------------------------------------
      // SAVE USER INFORMATION
      // ------------------------------------------------------

      final user = data['user'];

      if (user != null) {
        await prefs.setString(
          'user_name',
          user['name']?.toString() ?? '',
        );

        await prefs.setString(
          'user_email',
          user['email']?.toString() ?? '',
        );
      }

      // IMPORTANT:
      // Do NOT call widget.onLoginSuccess() here.
      // We wait until the try/catch/finally has finished.

      loginSucceeded = true;
    }

    // --------------------------------------------------------
    // LOGIN FAILED
    // --------------------------------------------------------

    else {
      String message = 'Login failed.';

      try {
        final data = jsonDecode(response.body);

        if (data is Map &&
            data['detail'] != null) {
          message = data['detail'].toString();
        }
      } catch (_) {}

      if (mounted) {
        _showMessage(message);
      }
    }
  } catch (e) {
    debugPrint(
      'Login error: $e',
    );

    if (mounted) {
      _showMessage(
        'Login failed: $e',
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  // ----------------------------------------------------------
  // MOVE TO DASHBOARD ONLY AFTER TRY/CATCH/FINALLY
  // ----------------------------------------------------------

  if (loginSucceeded && mounted) {
    widget.onLoginSuccess();
  }
}

  void _showMessage(
    String message,
  ) {
    if (!mounted){
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }


  @override
  void dispose() {

    _emailController.dispose();

    _passwordController.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFFF7867);
    const deepCoral = Color(0xFFE96559);
    const peach = Color(0xFFFFE9DE);
    const blush = Color(0xFFFFF5F1);
    const mint = Color(0xFFE0F3E8);
    const ink = Color(0xFF303C36);
    const muted = Color(0xFF7B857F);
    const line = Color(0xFFECE7E1);

    return Scaffold(
      backgroundColor: blush,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 820;

            final brandPanel = Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF8B75), Color(0xFFFFB27F)],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -22,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -28,
                    bottom: -42,
                    child: Container(
                      width: 125,
                      height: 125,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD5A9)
                            .withValues(alpha: .45),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .22),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'YOUR SPACE TO BLOOM  ✿',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'A little support\nfor a big journey.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          height: 1.08,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Feel informed, cared for, and confident — '
                        'one little step at a time.',
                        style: TextStyle(
                          color: Color(0xFFFFF9F3),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Center(
                        child: Container(
                          width: 188,
                          height: 188,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .22),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 145,
                                height: 145,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0DF),
                                  borderRadius: BorderRadius.circular(48),
                                ),
                              ),
                              const Icon(
                                Icons.pregnant_woman_rounded,
                                size: 108,
                                color: Color(0xFFB95D50),
                              ),
                              Positioned(
                                top: 18,
                                right: 15,
                                child: Container(
                                  width: 39,
                                  height: 39,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFE7A6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFB7772B),
                                    size: 25,
                                  ),
                                ),
                              ),
                              const Positioned(
                                left: 15,
                                bottom: 25,
                                child: Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.white,
                                  size: 29,
                                ),
                              ),
                              const Positioned(
                                right: 13,
                                bottom: 34,
                                child: Icon(
                                  Icons.local_florist_rounded,
                                  color: Color(0xFF2D936D),
                                  size: 27,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_rounded,
                              color: Colors.white, size: 15),
                          SizedBox(width: 7),
                          Text(
                            'Here for you, every step of the way',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );

            final loginCard = Container(
              padding: EdgeInsets.all(isWide ? 34 : 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: line),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5E493E)
                        .withValues(alpha: .07),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: peach,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.waving_hand_rounded,
                      color: deepCoral,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome back!',
                    style: TextStyle(
                      color: ink,
                      fontSize: 27,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Log in to pick up where your journey left off.',
                    style: TextStyle(
                      color: muted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'EMAIL ADDRESS',
                    style: TextStyle(
                      color: ink,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'you@example.com',
                      prefixIcon: const Icon(
                        Icons.mail_outline_rounded,
                        color: Color(0xFFB67D73),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFFFAF7),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 17,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: const BorderSide(color: line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: const BorderSide(color: line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: const BorderSide(
                          color: coral,
                          width: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 19),
                  const Text(
                    'PASSWORD',
                    style: TextStyle(
                      color: ink,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_loading) _login();
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xFFB67D73),
                      ),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: muted,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFFFAF7),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 17,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: const BorderSide(color: line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: const BorderSide(color: line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: const BorderSide(
                          color: coral,
                          width: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 23),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: _loading ? null : _login,
                      style: FilledButton.styleFrom(
                        backgroundColor: coral,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            coral.withValues(alpha: .55),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Log in',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(width: 9),
                                Icon(Icons.arrow_forward_rounded, size: 19),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 17),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(
                        child: Text(
                          'New to PregEase?',
                          style: TextStyle(color: muted, fontSize: 12.5),
                        ),
                      ),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RegisterScreen(
                                      onRegisterSuccess: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                );
                              },
                        style: TextButton.styleFrom(
                          foregroundColor: deepCoral,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Create an account',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mint,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: Color(0xFF398463),
                          size: 20,
                        ),
                        SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Your journey is personal. Your account helps keep your experience connected.',
                            style: TextStyle(
                              color: Color(0xFF416D58),
                              fontSize: 10.5,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 28 : 18,
                vertical: isWide ? 28 : 18,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 5,
                              child: brandPanel,
                            ),
                            const SizedBox(width: 28),
                            Expanded(
                              flex: 4,
                              child: loginCard,
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 3,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 43,
                                    height: 43,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [coral, Color(0xFFFFAC77)],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(15),
                                    ),
                                    child: const Icon(
                                      Icons.spa_rounded,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(width: 11),
                                  const Text(
                                    'PregEase',
                                    style: TextStyle(
                                      color: ink,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -.7,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.favorite_rounded,
                                    color: coral,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 21),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                20, 21, 20, 18,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFFF8B75), Color(0xFFFFB27F)],
                                ),
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Your journey,\nwrapped in care.',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            height: 1.12,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -.5,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Support for you and your growing family.',
                                          style: TextStyle(
                                            color: Color(0xFFFFF8F2),
                                            fontSize: 11.5,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 88,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: .24),
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: const Icon(
                                      Icons.pregnant_woman_rounded,
                                      size: 66,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            loginCard,
                            const SizedBox(height: 18),
                            const Text(
                              'Made with care for you and your growing family ♥',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: muted,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


// ============================================================
// REGISTER SCREEN
// ============================================================

class RegisterScreen
    extends StatefulWidget {

  final VoidCallback
      onRegisterSuccess;


  const RegisterScreen({
    super.key,
    required this.onRegisterSuccess,
  });


  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}


class _RegisterScreenState
    extends State<RegisterScreen> {

  final TextEditingController
      _nameController =
      TextEditingController();

  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _passwordController =
      TextEditingController();


  bool _loading = false;

  bool _obscurePassword = true;


  Future<void> _register() async {

    final name =
        _nameController.text.trim();

    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text;


    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {

      _showMessage(
        'Please fill in all fields.',
      );

      return;
    }


    if (password.length < 6) {

      _showMessage(
        'Password must be at least 6 characters.',
      );

      return;
    }


    setState(() {
      _loading = true;
    });


    try {

      final response = await http.post(

        Uri.parse(
          '$apiBaseUrl/auth/register',
        ),

        headers: {
          'Content-Type':
              'application/json',
        },

        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );


      debugPrint(
        'Register status: '
        '${response.statusCode}',
      );

      debugPrint(
        'Register response: '
        '${response.body}',
      );


      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        _showMessage(
          'Account created successfully. Please login.',
        );


        await Future.delayed(
          const Duration(
            milliseconds: 700,
          ),
        );


        if (!mounted) return;


        widget.onRegisterSuccess();

      } else {

        String message =
            'Registration failed.';


        try {

          final data =
              jsonDecode(response.body);


          if (data is Map &&
              data['detail'] != null) {

            message =
                data['detail'].toString();
          }

        } catch (_) {
          // Response was not valid JSON.
          message= 'Registration failed';
        }


        _showMessage(message);
      }

    } catch (e) {

      debugPrint(
        'Registration error: $e');


      _showMessage(
        'Cannot connect to server.'
        'Make sure FastAPI is running.',
      );

    } finally {

      if (mounted) {

        setState(() {
          _loading = false;
        });
      }
    }
  }


  void _showMessage(
    String message,
  ) {
    if (!mounted){
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }


  @override
  void dispose() {

    _nameController.dispose();

    _emailController.dispose();

    _passwordController.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFE87970);
    const ink = Color(0xFF343A33);
    const muted = Color(0xFF77796F);

    InputDecoration fieldDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: coral),
        filled: true,
        fillColor: const Color(0xFFFFFDF9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEAE3D8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEAE3D8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: coral, width: 1.5),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'Back to login',
                      onPressed: () => widget.onRegisterSuccess(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD8C9), Color(0xFFFFF0C9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.favorite_rounded,
                            color: coral,
                            size: 30,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Your PregEase journey starts here',
                          style: TextStyle(
                            color: ink,
                            fontSize: 27,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your account for thoughtful support, one step at a time.',
                          style: TextStyle(color: muted, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Create account',
                    style: TextStyle(
                      color: ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'A few details to get you started.',
                    style: TextStyle(color: muted),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: fieldDecoration('Full name', Icons.person_outline_rounded),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: fieldDecoration('Email address', Icons.mail_outline_rounded),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: fieldDecoration('Password', Icons.lock_outline_rounded).copyWith(
                      helperText: 'Use at least 6 characters',
                      helperStyle: const TextStyle(color: muted),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: muted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: coral,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: coral.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Create my account',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You’re not alone. We’re glad you’re here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// ============================================================
// APP SHELL
// ============================================================

enum ParentRole { mother, father }

class RoleSelectionScreen extends StatelessWidget {
  final ValueChanged<ParentRole> onRoleSelected;

  const RoleSelectionScreen({
    super.key,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFFF7867);
    const peach = Color(0xFFFFE9DE);
    const mint = Color(0xFFE0F3E8);
    const ink = Color(0xFF303C36);
    const muted = Color(0xFF7B857F);

    Widget roleCard({
      required String title,
      required String subtitle,
      required IconData icon,
      required Color background,
      required Color accent,
      required ParentRole role,
    }) {
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => onRoleSelected(role),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFECE7E1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: accent, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: ink),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: peach,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: coral,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Who is using PregEase?',
                    style: TextStyle(
                      color: ink,
                      fontSize: 28,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose your dashboard for this session.',
                    style: TextStyle(color: muted, fontSize: 15),
                  ),
                  const SizedBox(height: 28),
                  roleCard(
                    title: 'Mother',
                    subtitle: 'Your pregnancy, wellness, and baby journey.',
                    icon: Icons.pregnant_woman_rounded,
                    background: peach,
                    accent: coral,
                    role: ParentRole.mother,
                  ),
                  const SizedBox(height: 14),
                  roleCard(
                    title: 'Father',
                    subtitle: 'Ways to support your partner and prepare together.',
                    icon: Icons.family_restroom_rounded,
                    background: mint,
                    accent: const Color(0xFF4D9272),
                    role: ParentRole.father,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  final ParentRole role;

  const AppShell({
    super.key,
    required this.role,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late ParentRole _activeRole;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _activeRole = widget.role;
  }

  void _switchProfile() {
    setState(() {
      _activeRole = _activeRole == ParentRole.mother
          ? ParentRole.father
          : ParentRole.mother;
      _selectedIndex = 0;
    });
  }

  List<Widget> get _screens => [
        _activeRole == ParentRole.father
            ? FatherDashboardScreen(onSwitchProfile: _switchProfile)
            : DashboardScreen(onSwitchProfile: _switchProfile),
        const ChatHistoryScreen(),
        const CommunityScreen(),
        const DoctorsScreen(),
        const AppointmentsScreen(),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'PregEase',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Community',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(Icons.medical_services),
            label: 'Doctors',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}


// ============================================================
// CHAT SESSION MODEL
// ============================================================

class ChatSession {

  final String id;

  final String? title;

  final String createdAt;


  const ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
  });


  factory ChatSession.fromJson(
    Map<String, dynamic> json,
  ) {

    return ChatSession(

      id:
          json['id']?.toString() ??
              '',

      title:
          json['title']?.toString(),

      createdAt:
          json['created_at']
                  ?.toString() ??
              '',
    );
  }


  String get displayTitle {

    if (title != null &&
        title!.trim().isNotEmpty) {

      return title!;
    }

    return 'Conversation $id';
  }
}


// ============================================================
// DASHBOARD
// ============================================================

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onSwitchProfile;

  const DashboardScreen({
    super.key,
    this.onSwitchProfile,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<ChatSession> _recentSessions = [];

  bool _isLoading = true;
  String? _error;

  bool _hasPregnancyProfile = false;
  bool _isPregnancyProfileLoading = true;
  int? _pregnancyWeek;

  // ------------------------------------------------------------
  // DESIGN COLORS
  // ------------------------------------------------------------

  static const Color primary = Color(0xFF71866B);
  static const Color primaryDark = Color(0xFF405442);

  static const Color lavender = Color(0xFFF0F2E8);
  static const Color lavenderBorder = Color(0xFFDCE4D6);

  static const Color softPink = Color(0xFFF8EAE6);
  static const Color softPeach = Color(0xFFF8EDE0);
  static const Color softMint = Color(0xFFEAF1E8);
  static const Color softBlue = Color(0xFFF0F2E8);

  static const Color textDark = Color(0xFF343A33);
  static const Color textMuted = Color(0xFF77796F);

  @override
  void initState() {
    super.initState();

    _loadRecentSessions();
    _loadPregnancyProfile();
  }

  // ==========================================================
  // LOAD RECENT CHAT SESSIONS
  // ==========================================================

  Future<void> _loadRecentSessions() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/chat/sessions'),
        headers: await authHeaders(),
      );

      if (!mounted) return;

      if (response.statusCode == 401) {
        await clearAuth();

        setState(() {
          _error =
              'Your session has expired. Please login again.';
          _isLoading = false;
        });

        return;
      }

      if (response.statusCode != 200) {
        setState(() {
          _error =
              'Could not load recent conversations '
              '(${response.statusCode}).';
          _isLoading = false;
        });

        return;
      }

      final decoded = jsonDecode(response.body);

      final List<dynamic> data =
          decoded is List ? decoded : [];

      final sessions = <ChatSession>[];

      for (final item in data) {
        if (item is Map<String, dynamic>) {
          sessions.add(
            ChatSession.fromJson(item),
          );
        }
      }

      setState(() {
        _recentSessions
          ..clear()
          ..addAll(sessions.take(5));

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Recent sessions error: $e');

      if (!mounted) return;

      setState(() {
        _error =
            'Could not connect to the AI server.';
        _isLoading = false;
      });
    }
  }

  // ==========================================================
  // LOAD PREGNANCY PROFILE
  // ==========================================================

  Future<void> _loadPregnancyProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/pregnancy/profile'),
        headers: await authHeaders(),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map) {
          setState(() {
            _hasPregnancyProfile = true;

            _pregnancyWeek =
                data['current_week'] is int
                    ? data['current_week'] as int
                    : int.tryParse(
                        data['current_week']?.toString() ?? '',
                      );

            _isPregnancyProfileLoading = false;
          });
        } else {
          setState(() {
            _hasPregnancyProfile = false;
            _isPregnancyProfileLoading = false;
          });
        }

        return;
      }

      if (response.statusCode == 404) {
        setState(() {
          _pregnancyWeek = null;
          _hasPregnancyProfile = false;
          _isPregnancyProfileLoading = false;
        });

        return;
      }

      if (response.statusCode == 401) {
        await clearAuth();

        if (!mounted) return;

        setState(() {
          _isPregnancyProfileLoading = false;
        });

        return;
      }

      setState(() {
        _isPregnancyProfileLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Pregnancy profile load error: $e',
      );

      if (!mounted) return;

      setState(() {
        _isPregnancyProfileLoading = false;
      });
    }
  }

  // ==========================================================
  // NEW CHAT
  // ==========================================================

  void _openNewChat({
    String? prompt,
  }) {
    final sessionId =
        'flutter-${DateTime.now().millisecondsSinceEpoch}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          sessionId: sessionId,
          initialPrompt: prompt,
        ),
      ),
    ).then((_) {
      _loadRecentSessions();
    });
  }

  // ==========================================================
  // EXISTING CHAT
  // ==========================================================

  void _openSession(ChatSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          sessionId: session.id,
        ),
      ),
    ).then((_) {
      _loadRecentSessions();
    });
  }

  // ==========================================================
  // PREGNANCY INFORMATION
  // ==========================================================

  void _openPregnancyProfile() {
    if (_pregnancyWeek == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pregnancy week information is not available yet.',
          ),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PregnancyWeekScreen(
          week: _pregnancyWeek!,
          apiBaseUrl: apiBaseUrl,
          authHeaders: authHeaders,
        ),
      ),
    );
  }

  // ==========================================================
  // SETUP PREGNANCY PROFILE
  // ==========================================================

  void _setupPregnancyProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PregnancyProfileScreen(),
      ),
    ).then((_) {
      _loadPregnancyProfile();
    });
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _sectionTitle(
    String title, {
    String? action,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textDark,
            letterSpacing: -0.3,
          ),
        ),

        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action,
              style: const TextStyle(
                color: primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  // ==========================================================
  // QUICK ACTION CARD
  // ==========================================================

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color background,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 142,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFEAE3D8),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(0x0A343A33),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),

              const Spacer(),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: textMuted,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF25352F);
    const muted = Color(0xFF68776F);
    const canvas = Color(0xFFFFFBF5);
    const coral = Color(0xFFFF765F);
    const mint = Color(0xFFDDF4E7);
    const lilac = Color(0xFFEDE5FF);
    const pink = Color(0xFFFFE2DE);
    const blue = Color(0xFFDFF1FF);

    Widget sectionHeading(String title, String eyebrow, {String? action, VoidCallback? onAction}) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow.toUpperCase(), style: const TextStyle(fontSize: 10, letterSpacing: 1.7, fontWeight: FontWeight.w900, color: coral)),
              const SizedBox(height: 5),
              Text(title, style: const TextStyle(fontSize: 22, height: 1.12, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: ink)),
            ],
          )),
          if (action != null) TextButton(onPressed: onAction, child: Text(action, style: const TextStyle(color: ink, fontWeight: FontWeight.w800))),
        ],
      );
    }

    Widget featureTile({
      required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required Color accent,
      required VoidCallback onTap,
      String? tag,
    }) {
      return Material(
        color: color,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: SizedBox(
            height: 174,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -25,
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .42),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 15,
                    top: 16,
                    child: Transform.rotate(
                      angle: -.12,
                      child: Container(
                        width: 60,
                        height: 66,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .82),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: .10),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: accent, size: 34),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 75,
                    top: 23,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 17,
                      color: accent.withValues(alpha: .72),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 15, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .76),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: accent,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .6,
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 22),
                        const Spacer(),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: ink,
                            letterSpacing: -.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            height: 1.3,
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: 3),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 13,
                    bottom: 13,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_outward_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: canvas,
      body: SafeArea(
        child: RefreshIndicator(
          color: coral,
          onRefresh: () async {
            await Future.wait([_loadRecentSessions(), _loadPregnancyProfile()]);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
            children: [
              // Bright, friendly brand header
              Row(children: [
                Container(
                  width: 47, height: 47,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [coral, Color(0xFFFFA46B)]),
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [BoxShadow(color: coral.withValues(alpha: .24), blurRadius: 15, offset: const Offset(0, 6))],
                  ),
                  child: const Icon(Icons.spa_rounded, color: Colors.white, size: 27),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('PregEase', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -.7, color: ink)),
                  Text('A brighter little journey, together', style: TextStyle(fontSize: 11.5, color: muted)),
                ])),
                if (widget.onSwitchProfile != null)
                  Tooltip(
                    message: 'Switch to Father',
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: widget.onSwitchProfile,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFFF1E8DE),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.swap_horiz_rounded,
                                  color: coral, size: 19),
                              SizedBox(width: 4),
                              Text(
                                'Father',
                                style: TextStyle(
                                  color: ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFFF1E8DE),
                      ),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: coral,
                      size: 21,
                    ),
                  ),
              ]),
              const SizedBox(height: 27),
              const Text('Hello, lovely ✨', style: TextStyle(fontSize: 29, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -1.1, color: ink)),
              const SizedBox(height: 8),
              const Text('Small steps, big feelings, and a whole lot of love.', style: TextStyle(fontSize: 14, height: 1.45, color: muted)),
              const SizedBox(height: 22),

              // Main hero: vivid coral panel + editorial image.
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFF826A), Color(0xFFFFA66F)]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: coral.withValues(alpha: .2), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: Stack(children: [
                  Positioned(right: -22, top: -30, child: Container(width: 155, height: 155, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), shape: BoxShape.circle))),
                  Positioned(right: 18, bottom: -52, child: Container(width: 130, height: 130, decoration: BoxDecoration(color: const Color(0xFFFFD4A4).withValues(alpha: .42), shape: BoxShape.circle))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 23, 18, 20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .22), borderRadius: BorderRadius.circular(30)), child: const Text('YOUR SPACE TO BLOOM  ✿', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1))),
                      const SizedBox(height: 15),
                      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('You’re growing\nsomething amazing.', style: TextStyle(color: Colors.white, fontSize: 25, height: 1.08, fontWeight: FontWeight.w900, letterSpacing: -.8)),
                          const SizedBox(height: 9),
                          Text(_hasPregnancyProfile && _pregnancyWeek != null ? 'Week ${_pregnancyWeek!} of your journey' : 'Guidance for every twist and turn', style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: _hasPregnancyProfile ? _openPregnancyProfile : _setupPregnancyProfile,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFE86452), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), shape: const StadiumBorder()),
                            icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                            label: Text(_hasPregnancyProfile ? 'Explore your week' : 'Personalise my journey', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)),
                          ),
                        ])),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 112, height: 168,
                          child: Stack(alignment: Alignment.center, children: [
                            Container(width: 106, height: 142, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .22), borderRadius: const BorderRadius.only(topLeft: Radius.circular(58), topRight: Radius.circular(58), bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)))),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(52),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1511895426328-dc8714191300?auto=format&fit=crop&w=420&q=85',
                                width: 98, height: 138, fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(width: 98, height: 138, color: const Color(0xFFFFD7BE), child: const Icon(Icons.pregnant_woman_rounded, size: 66, color: Color(0xFFCB624E))),
                              ),
                            ),
                            Positioned(right: 0, top: 15, child: Container(width: 34, height: 34, decoration: const BoxDecoration(color: Color(0xFFFFE7A8), shape: BoxShape.circle), child: const Icon(Icons.star_rounded, color: Color(0xFFB76B23), size: 21))),
                            const Positioned(left: 0, bottom: 4, child: Text('♥', style: TextStyle(fontSize: 29, color: Colors.white))),
                          ]),
                        ),
                      ]),
                    ]),
                  ),
                ]),
              ),

              const SizedBox(height: 29),
              sectionHeading('What do you need today?', 'Your wellbeing, your way'),
              const SizedBox(height: 14),
              SizedBox(height: 174, child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: featureTile(title: 'Nutrition', subtitle: 'Nourish you both', icon: Icons.local_dining_rounded, color: const Color(0xFFFFE7C7), accent: const Color(0xFFB96B20), tag: 'EAT WELL', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => NutritionScreen(apiBaseUrl: apiBaseUrl, authHeaders: authHeaders)));
                })),
                const SizedBox(width: 12),
                Expanded(child: featureTile(title: 'Wellness', subtitle: 'Check in with you', icon: Icons.self_improvement_rounded, color: pink, accent: const Color(0xFFD65B70), tag: 'FEEL GOOD', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => WellnessScreen(apiBaseUrl: apiBaseUrl, authHeaders: authHeaders)));
                })),
              ])),
              const SizedBox(height: 12),
              SizedBox(height: 174, child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: featureTile(title: 'Move & rest', subtitle: 'Gentle everyday habits', icon: Icons.directions_walk_rounded, color: mint, accent: const Color(0xFF27845C), onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ActivitiesScreen(apiBaseUrl: apiBaseUrl, authHeaders: authHeaders)));
                })),
                const SizedBox(width: 12),
                Expanded(child: featureTile(title: 'Baby prep', subtitle: 'Get ready with love', icon: Icons.child_friendly_rounded, color: lilac, accent: const Color(0xFF7558B6), tag: 'NESTING', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => BabyPreparationScreen(apiBaseUrl: apiBaseUrl, authHeaders: authHeaders)));
                })),
              ])),

              const SizedBox(height: 29),
              // Support CTA with an illustrated sunburst motif
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF244B42), borderRadius: BorderRadius.circular(26)),
                child: Stack(children: [
                  Positioned(right: -5, top: -18, child: Icon(Icons.wb_sunny_rounded, size: 108, color: Colors.white.withValues(alpha: .07))),
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('You don’t have to\nfigure it all out.', style: TextStyle(color: Colors.white, fontSize: 21, height: 1.12, fontWeight: FontWeight.w900, letterSpacing: -.4)),
                      const SizedBox(height: 8),
                      const Text('Questions, worries, or just need a little reassurance?', style: TextStyle(color: Color(0xFFD5E8DD), fontSize: 12.5, height: 1.4)),
                      const SizedBox(height: 15),
                      OutlinedButton.icon(
                        onPressed: () => _openNewChat(),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF8BB5A4)), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), shape: const StadiumBorder()),
                        icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                        label: const Text('Talk to PregEase', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      ),
                    ])),
                    const SizedBox(width: 10),
                    Container(width: 62, height: 62, decoration: BoxDecoration(color: const Color(0xFF3E7162), borderRadius: BorderRadius.circular(22)), child: const Icon(Icons.favorite_rounded, color: Color(0xFFFFB4A5), size: 32)),
                  ]),
                ]),
              ),

              const SizedBox(height: 29),
              sectionHeading('Pick up where you left off', 'Your recent chats', action: 'New chat', onAction: () => _openNewChat()),
              const SizedBox(height: 12),
              if (_isLoading)
                const Padding(padding: EdgeInsets.all(22), child: Center(child: CircularProgressIndicator(color: coral, strokeWidth: 2.5)))
              else if (_error != null)
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: pink, borderRadius: BorderRadius.circular(18)), child: Row(children: [
                  const Icon(Icons.cloud_off_rounded, color: Color(0xFFD65B70)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_error!, style: const TextStyle(color: ink, fontSize: 12))),
                  TextButton(onPressed: _loadRecentSessions, child: const Text('Retry')),
                ]))
              else if (_recentSessions.isEmpty)
                Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: blue, borderRadius: BorderRadius.circular(20)), child: Row(children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.forum_rounded, color: Color(0xFF4382AC))),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Your conversations start here', style: TextStyle(fontWeight: FontWeight.w900, color: ink, fontSize: 13)),
                    SizedBox(height: 4),
                    Text('Ask anything on your mind. We’re listening.', style: TextStyle(color: muted, fontSize: 11.5)),
                  ])),
                  IconButton(onPressed: () => _openNewChat(), icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF4382AC), size: 29)),
                ]))
              else
                ..._recentSessions.map((session) => Container(
                  margin: const EdgeInsets.only(bottom: 9),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: const Color(0xFFF0E8DF))),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: Container(width: 43, height: 43, decoration: BoxDecoration(color: const Color(0xFFE6F5EC), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.chat_rounded, color: Color(0xFF27845C), size: 20)),
                    title: Text(session.displayTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: ink)),
                    subtitle: const Text('Continue your conversation', style: TextStyle(fontSize: 11.5, color: muted)),
                    trailing: const Icon(Icons.arrow_forward_rounded, color: coral, size: 20),
                    onTap: () => _openSession(session),
                  ),
                )),

              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFFFFF0C9), borderRadius: BorderRadius.circular(23)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .8), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.wb_twilight_rounded, color: Color(0xFFB77A19), size: 23)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('A little reminder', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: ink)),
                    const SizedBox(height: 5),
                    Text(
                      _pregnancyWeek != null && _pregnancyWeek! <= 8
                        ? 'Your baby is growing quickly in these early weeks. Give yourself permission to rest, too.'
                        : _pregnancyWeek != null && _pregnancyWeek! <= 20
                          ? 'Every week brings new changes. Take a moment to notice how you’re feeling today.'
                          : 'You’re doing something wonderful. Small moments of rest and care count, too.',
                      style: const TextStyle(fontSize: 12.5, height: 1.45, color: Color(0xFF755D31)),
                    ),
                  ])),
                ]),
              ),
              const SizedBox(height: 12),
              const Center(child: Text('Made with care for you and your growing family  ♥', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF9B9D91), fontSize: 10.5, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
      ),
    );
  }

}
// ============================================================
// PREGNANCY PROFILE SCREEN
// ============================================================

class PregnancyProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? existingProfile;
  final VoidCallback? onSaved;

  const PregnancyProfileScreen({
    super.key,
    this.existingProfile,
    this.onSaved,
  });

  @override
  State<PregnancyProfileScreen> createState() =>
      _PregnancyProfileScreenState();
}

class _PregnancyProfileScreenState
    extends State<PregnancyProfileScreen> {

  DateTime? _lmpDate;

  String? _dietaryPreference;

  final TextEditingController _customDietController =
      TextEditingController();

  final TextEditingController _otherAllergyController =
      TextEditingController();

  final Set<String> _selectedAllergies = {};

  bool _loading = false;

  final List<String> _dietaryOptions = [
    'Vegetarian',
    'Vegan',
    'Non-vegetarian',
    'Jain',
    'Other',
  ];

  final List<String> _allergyOptions = [
    'Milk/Dairy',
    'Eggs',
    'Peanuts',
    'Tree nuts',
    'Fish',
    'Shellfish',
  ];

  @override
  void initState() {
    super.initState();

    _loadExistingProfile();
  }

  // ==========================================================
  // LOAD EXISTING PROFILE
  // ==========================================================

  void _loadExistingProfile() {
    final profile = widget.existingProfile;

    if (profile == null) {
      return;
    }

    final lmp = profile['lmp_date'];

    if (lmp != null) {
      try {
        _lmpDate = DateTime.parse(
          lmp.toString(),
        );
      } catch (_) {}
    }

    final dietary =
        profile['dietary_preference']?.toString();

    if (dietary != null &&
        _dietaryOptions.contains(dietary)) {
      _dietaryPreference = dietary;
    }

    _customDietController.text =
        profile['custom_dietary_preference']
                ?.toString() ??
            '';

    final allergies =
        profile['food_allergies'];

    if (allergies is List) {
      for (final allergy in allergies) {
        final value = allergy.toString();

        if (_allergyOptions.contains(value)) {
          _selectedAllergies.add(value);
        } else if (value.isNotEmpty) {
          _otherAllergyController.text =
              value;
        }
      }
    }
  }

  // ==========================================================
  // DATE PICKER
  // ==========================================================

  Future<void> _selectLmpDate() async {
    final now = DateTime.now();

    final firstDate = DateTime(
      now.year - 1,
      now.month,
      now.day,
    );

    final lastDate = now;

    final selected = await showDatePicker(
      context: context,
      initialDate: _lmpDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select Last Menstrual Period',
      cancelText: 'Cancel',
      confirmText: 'Select',
    );

    if (selected == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _lmpDate = selected;
    });
  }

  // ==========================================================
  // FORMAT DATE
  // ==========================================================

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  // ==========================================================
  // SAVE PROFILE
  // ==========================================================

  Future<void> _saveProfile() async {
    if (_lmpDate == null) {
      _showMessage(
        'Please select your LMP date.',
      );
      return;
    }

    if (_loading) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final allergies =
          <String>[
        ..._selectedAllergies,
      ];

      final otherAllergy =
          _otherAllergyController.text.trim();

      if (otherAllergy.isNotEmpty) {
        allergies.add(otherAllergy);
      }

      final body = {
        'lmp_date':
            '${_lmpDate!.year.toString().padLeft(4, '0')}-'
            '${_lmpDate!.month.toString().padLeft(2, '0')}-'
            '${_lmpDate!.day.toString().padLeft(2, '0')}',
        'dietary_preference':
            _dietaryPreference,
        'custom_dietary_preference':
            _dietaryPreference == 'Other'
                ? _customDietController.text.trim()
                : null,
        'food_allergies': allergies,
      };

      final headers =
          await authHeaders();

      final bool isEditing =
          widget.existingProfile != null;

      final response = isEditing
          ? await http.put(
              Uri.parse(
                '$apiBaseUrl/pregnancy/profile',
              ),
              headers: headers,
              body: jsonEncode(body),
            )
          : await http.post(
              Uri.parse(
                '$apiBaseUrl/pregnancy/profile',
              ),
              headers: headers,
              body: jsonEncode(body),
            );

      debugPrint(
        'Pregnancy profile status: '
        '${response.statusCode}',
      );

      debugPrint(
        'Pregnancy profile response: '
        '${response.body}',
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        if (!mounted) {
          return;
        }

        _showMessage(
          isEditing
              ? 'Pregnancy profile updated.'
              : 'Pregnancy profile saved.',
        );

        widget.onSaved?.call();

        await Future.delayed(
          const Duration(
            milliseconds: 500,
          ),
        );

        if (!mounted) {
          return;
        }

        Navigator.of(context).pop(true);

      } else {
        String message =
            'Unable to save pregnancy profile.';

        try {
          final data =
              jsonDecode(response.body);

          if (data is Map &&
              data['detail'] != null) {
            message =
                data['detail'].toString();
          }
        } catch (_) {}

        if (mounted) {
          _showMessage(message);
        }
      }
    } catch (e) {
      debugPrint(
        'Pregnancy profile error: $e',
      );

      if (mounted) {
        _showMessage(
          'Could not connect to the server.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ==========================================================
  // SHOW MESSAGE
  // ==========================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ==========================================================
  // ALLERGY CHECKBOX
  // ==========================================================

  Widget _buildAllergyOption(
    String allergy,
  ) {
    return CheckboxListTile(
      value: _selectedAllergies.contains(
        allergy,
      ),
      title: Text(allergy),
      controlAffinity:
          ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      onChanged: (selected) {
        if (!mounted) {
          return;
        }

        setState(() {
          if (selected == true) {
            _selectedAllergies.add(
              allergy,
            );
          } else {
            _selectedAllergies.remove(
              allergy,
            );
          }
        });
      },
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFE87970);
    const ink = Color(0xFF343A33);
    const muted = Color(0xFF77796F);
    final isEditing = widget.existingProfile != null;

    Widget sectionCard({required Widget child}) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFEAE3D8)),
        ),
        child: child,
      );
    }

    Widget sectionTitle(IconData icon, String title, String subtitle) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: coral.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: coral),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: ink, fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: muted, height: 1.35)),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      appBar: AppBar(
        title: Text(isEditing ? 'Pregnancy information' : 'Pregnancy profile'),
        backgroundColor: const Color(0xFFFAF7F0),
        foregroundColor: ink,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD8C9), Color(0xFFFFF0C9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.spa_rounded, color: coral, size: 32),
                        SizedBox(height: 13),
                        Text(
                          'A little more personal',
                          style: TextStyle(color: ink, fontSize: 25, fontWeight: FontWeight.w800, height: 1.15),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'These details help tailor pregnancy guidance and nutrition suggestions. You can update them whenever you need.',
                          style: TextStyle(color: muted, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(
                          Icons.calendar_month_rounded,
                          'Pregnancy dates',
                          'Your last menstrual period helps estimate pregnancy progress.',
                        ),
                        const SizedBox(height: 18),
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _selectLmpDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Last menstrual period',
                              prefixIcon: Icon(Icons.event_rounded),
                            ),
                            child: Text(
                              _lmpDate == null ? 'Choose a date' : _formatDate(_lmpDate!),
                              style: TextStyle(
                                color: _lmpDate == null ? muted : ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(
                          Icons.restaurant_menu_rounded,
                          'Dietary preferences',
                          'Help us make food and nutrition suggestions more relevant.',
                        ),
                        const SizedBox(height: 18),
                        DropdownButtonFormField<String>(
                          initialValue: _dietaryPreference,
                          decoration: const InputDecoration(
                            labelText: 'Dietary preference',
                            prefixIcon: Icon(Icons.restaurant_rounded),
                          ),
                          items: _dietaryOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (!mounted) return;
                            setState(() => _dietaryPreference = value);
                          },
                        ),
                        if (_dietaryPreference == 'Other') ...[
                          const SizedBox(height: 14),
                          TextField(
                            controller: _customDietController,
                            decoration: const InputDecoration(
                              labelText: 'Your dietary preference',
                              hintText: 'Tell us what works for you',
                              prefixIcon: Icon(Icons.edit_note_rounded),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(
                          Icons.health_and_safety_outlined,
                          'Food allergies',
                          'Select all that apply so suggestions can take them into account.',
                        ),
                        const SizedBox(height: 12),
                        ..._allergyOptions.map(_buildAllergyOption),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _otherAllergyController,
                          decoration: const InputDecoration(
                            labelText: 'Other allergy (optional)',
                            hintText: 'Add anything not listed above',
                            prefixIcon: Icon(Icons.add_circle_outline_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: _loading ? null : _saveProfile,
                      style: FilledButton.styleFrom(
                        backgroundColor: coral,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              isEditing ? 'Save changes' : 'Save my profile',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You can revisit these details from your profile at any time.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _customDietController.dispose();
    _otherAllergyController.dispose();

    super.dispose();
  }
}

// ============================================================
// QUICK PROMPT
// ============================================================

class _QuickPrompt
    extends StatelessWidget {

  final IconData icon;

  final String title;

  final String prompt;

  final VoidCallback onTap;


  const _QuickPrompt({
    required this.icon,
    required this.title,
    required this.prompt,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),

      child: ListTile(

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 5,
        ),

        leading:
            CircleAvatar(
          backgroundColor:
              const Color(
            0xFFE6F4FF,
          ),

          child: Icon(
            icon,
            color:
                const Color(
              0xFF2196F3,
            ),
          ),
        ),

        title: Text(
          title,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        subtitle: Text(
          prompt,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
        ),

        trailing:
            const Icon(
          Icons.arrow_forward_ios,
          size: 15,
        ),

        onTap: onTap,
      ),
    );
  }
}


// ============================================================
// CHAT HISTORY
// ============================================================

class ChatHistoryScreen
    extends StatefulWidget {

  const ChatHistoryScreen({
    super.key,
  });


  @override
  State<ChatHistoryScreen> createState() =>
      _ChatHistoryScreenState();
}


class _ChatHistoryScreenState
    extends State<ChatHistoryScreen> {

  final List<ChatSession>
      _sessions = [];


  bool _isLoading = true;

  String? _error;


  @override
  void initState() {

    super.initState();

    _loadSessions();
  }


  Future<void> _loadSessions() async {

    if (mounted) {

      setState(() {

        _isLoading = true;

        _error = null;
      });
    }


    try {

      final response =
          await http.get(

        Uri.parse(
          '$apiBaseUrl/chat/sessions',
        ),

        headers:
            await authHeaders(),
      );


      if (!mounted) return;


      debugPrint(
        'Sessions status: '
        '${response.statusCode}',
      );


      if (response.statusCode ==
          401) {

        setState(() {

          _error =
              'Your login session has expired.';
          _isLoading = false;
        });

        return;
      }


      if (response.statusCode !=
          200) {

        setState(() {

          _error =
              'Server returned '
              '${response.statusCode}.';

          _isLoading = false;
        });

        return;
      }


      final decoded =
          jsonDecode(response.body);


      final List<dynamic> data =
          decoded is List
              ? decoded
              : [];


      setState(() {

        _sessions.clear();


        for (final item in data) {

          if (item
              is Map<String, dynamic>) {

            _sessions.add(
              ChatSession.fromJson(
                item,
              ),
            );
          }
        }


        _isLoading = false;
      });

    } catch (e) {

      if (!mounted) return;


      setState(() {

        _error =
            'Could not connect to the AI server.';

        _isLoading = false;
      });
    }
  }


  void _createNewChat() {

    final sessionId =
        'flutter-${DateTime.now().millisecondsSinceEpoch}';


    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(
          sessionId: sessionId,
        ),
      ),
    ).then((_) {

      _loadSessions();
    });
  }


  void _openSession(
    ChatSession session,
  ) {

    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(
          sessionId: session.id,
        ),
      ),
    ).then((_) {

      _loadSessions();
    });
  }


  // ==========================================================
  // DELETE
  // ==========================================================

  Future<void> _deleteSession(
    ChatSession session,
  ) async {

    final confirmed =
        await showDialog<bool>(

      context: context,

      builder: (context) {

        return AlertDialog(

          title:
              const Text(
            'Delete conversation?',
          ),

          content:
              Text(
            'This will permanently delete "${session.displayTitle}".',
          ),

          actions: [

            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),

              child:
                  const Text(
                'Cancel',
              ),
            ),

            FilledButton(
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),

              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),

              child:
                  const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );


    if (confirmed != true) {
      return;
    }


    try {

      final response =
          await http.delete(

        Uri.parse(
          '$apiBaseUrl/chat/sessions/'
          '${Uri.encodeComponent(session.id)}',
        ),

        headers:
            await authHeaders(),
      );


      if (!mounted) return;


      debugPrint(
        'Delete status: '
        '${response.statusCode}',
      );


      if (response.statusCode == 200 ||
          response.statusCode == 204) {

        setState(() {

          _sessions.removeWhere(
            (item) =>
                item.id == session.id,
          );
        });


        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Conversation deleted.',
            ),
          ),
        );

      } else if (
          response.statusCode == 401) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Your login session has expired.',
            ),
          ),
        );

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Delete failed '
              '(${response.statusCode}).',
            ),
          ),
        );
      }

    } catch (e) {

      if (!mounted) return;


      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Could not connect to the AI server.',
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFE87970);
    const ink = Color(0xFF343A33);
    const muted = Color(0xFF77796F);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F0),
        foregroundColor: ink,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your conversations', style: TextStyle(fontWeight: FontWeight.w800)),
            SizedBox(height: 2),
            Text('Pick up where you left off', style: TextStyle(fontSize: 12, color: muted)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh conversations',
            onPressed: _loadSessions,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewChat,
        backgroundColor: coral,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New chat'),
      ),
      body: _buildHistoryBody(),
    );
  }


  Widget _buildHistoryBody() {

    if (_isLoading) {

      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }


    if (_error != null) {

      return Center(

        child:
            Padding(

          padding:
              const EdgeInsets.all(
            24,
          ),

          child:
              Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              const Icon(
                Icons.cloud_off,
                size: 55,
                color:
                    Colors.grey,
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                _error!,
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                height: 16,
              ),

              ElevatedButton.icon(

                onPressed:
                    _loadSessions,

                icon:
                    const Icon(
                  Icons.refresh,
                ),

                label:
                    const Text(
                  'Try again',
                ),
              ),
            ],
          ),
        ),
      );
    }


    if (_sessions.isEmpty) {

      return Center(

        child:
            Padding(

          padding:
              const EdgeInsets.all(
            24,
          ),

          child:
              Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              const Icon(
                Icons
                    .chat_bubble_outline,
                size: 65,
                color:
                    Color(
                  0xFF2196F3,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              const Text(
                'No conversations yet',

                style:
                    TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'Start a new conversation with PregEase.',
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                height: 20,
              ),

              ElevatedButton.icon(

                onPressed:
                    _createNewChat,

                icon:
                    const Icon(
                  Icons.add,
                ),

                label:
                    const Text(
                  'Start chatting',
                ),
              ),
            ],
          ),
        ),
      );
    }


    return RefreshIndicator(

      onRefresh:
          _loadSessions,

      child:
          ListView(

        padding:
            const EdgeInsets.all(
          20,
        ),

        children: [

          const Text(
            'Recent conversations',

            style:
                TextStyle(
              fontSize: 23,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            '${_sessions.length} conversations',

            style:
                const TextStyle(
              color:
                  Colors.grey,
            ),
          ),

          const SizedBox(
            height: 18,
          ),


          ..._sessions.map(
            (session) {

              return Container(

                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),

                child:
                    ListTile(

                  contentPadding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  leading:
                      const CircleAvatar(

                    backgroundColor:
                        Color(
                      0xFFE6F4FF,
                    ),

                    child:
                        Icon(
                      Icons
                          .chat_bubble_outline,
                      color:
                          Color(
                        0xFF2196F3,
                      ),
                    ),
                  ),

                  title:
                      Text(
                    session.displayTitle,

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  subtitle:
                      Padding(

                    padding:
                        const EdgeInsets.only(
                      top: 4,
                    ),

                    child:
                        Text(
                      session.createdAt,

                      maxLines: 1,

                      overflow:
                          TextOverflow
                              .ellipsis,
                    ),
                  ),

                  // ------------------------------------------------
                  // DELETE BUTTON IS ALWAYS VISIBLE
                  // ------------------------------------------------

                  trailing:
                      IconButton(

                    tooltip:
                        'Delete conversation',

                    icon:
                        const Icon(
                      Icons.delete_outline,
                      color:
                          Colors.red,
                    ),

                    onPressed:
                        () =>
                            _deleteSession(
                      session,
                    ),
                  ),

                  onTap: () =>
                      _openSession(
                    session,
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


// ============================================================
// AI CHAT
// ============================================================

class ChatScreen
    extends StatefulWidget {

  final String sessionId;

  final String? initialPrompt;


  const ChatScreen({
    super.key,
    required this.sessionId,
    this.initialPrompt,
  });


  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}


class _ChatScreenState
    extends State<ChatScreen> {

  final TextEditingController
      _messageController =
      TextEditingController();


  final List<
      Map<String, dynamic>>
      _messages = [];


  bool _isLoading = false;

  bool _isLoadingHistory = true;


  @override
  void initState() {

    super.initState();


    _loadChatHistory();


    if (widget.initialPrompt !=
        null) {

      WidgetsBinding.instance
          .addPostFrameCallback(
        (_) {

          if (!mounted) return;


          _messageController.text =
              widget.initialPrompt!;
        },
      );
    }
  }


  Future<void> _loadChatHistory()
      async {

    try {

      final response =
          await http.get(

        Uri.parse(
          '$apiBaseUrl/chat/history/'
          '${Uri.encodeComponent(widget.sessionId)}',
        ),

        headers:
            await authHeaders(),
      );


      if (!mounted) return;


      if (response.statusCode ==
          200) {

        final decoded =
            jsonDecode(response.body);


        final List<dynamic> data =
            decoded is List
                ? decoded
                : [];


        setState(() {

          _messages.clear();


          for (final item in data) {

            if (item
                is Map<String, dynamic>) {

              _messages.add({
                'role':
                    item['role']
                        ?.toString() ??
                    '',
                'content':
                    item['content']
                        ?.toString() ??
                    '',
              });
            }
          }


          _isLoadingHistory =
              false;
        });

      } else {

        setState(() {

          _isLoadingHistory =
              false;
        });
      }

    } catch (e) {

      if (!mounted) return;


      setState(() {

        _isLoadingHistory =
            false;
      });
    }
  }


  Future<void> _sendMessage() async {

    final text =
        _messageController.text.trim();


    if (text.isEmpty ||
        _isLoading) {

      return;
    }


    _messageController.clear();


    setState(() {

      _messages.add({

        'role': 'user',

        'content': text,
      });

      _isLoading = true;
    });


    try {

      final response =
          await http.post(

        Uri.parse(
          '$apiBaseUrl/chat/',
        ),

        headers:
            await authHeaders(),

        body:
            jsonEncode({

          'session_id':
              widget.sessionId,

          'message':
              text,
        }),
      );


      if (!mounted) return;


      debugPrint(
        'Chat status: '
        '${response.statusCode}',
      );


      debugPrint(
        'Chat response: '
        '${response.body}',
      );


      if (response.statusCode ==
          200) {

        final data =
            jsonDecode(response.body);


        final reply =
            data['reply']
                    ?.toString() ??
                '';


        setState(() {

          _messages.add({

            'role':
                'assistant',

            'content':
                reply,
          });
        });

      } else if (
          response.statusCode ==
              401) {

        setState(() {

          _messages.add({

            'role':
                'assistant',

            'content':
                'Your login session has expired. Please login again.',
          });
        });

      } else {

        setState(() {

          _messages.add({

            'role':
                'assistant',

            'content':
                'Sorry, I could not process your request.',
          });
        });
      }

    } catch (e) {

      if (!mounted) return;


      setState(() {

        _messages.add({

          'role':
              'assistant',

          'content':
              'Could not connect to the AI server.',
        });
      });

    } finally {

      if (mounted) {

        setState(() {

          _isLoading = false;
        });
      }
    }
  }


  Widget _buildMessage(
    Map<String, dynamic> message,
  ) {

    final role =
        message['role']
                ?.toString() ??
            '';


    final content =
        message['content']
                ?.toString() ??
            '';


    final isUser =
        role == 'user';


    return Align(

      alignment:
          isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,

      child:
          Container(

        constraints:
            const BoxConstraints(
          maxWidth: 330,
        ),

        margin:
            const EdgeInsets.only(
          bottom: 12,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        decoration:
            BoxDecoration(

          color:
              isUser
                  ? const Color(0xFFE87970)
                  : const Color(0xFFFFFDF9),

          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),

        child:
            Text(

          content,

          style:
              TextStyle(

            color:
                isUser
                    ? Colors.white
                    : Colors.black87,

            fontSize: 15,
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {

    _messageController.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFE87970);
    const ink = Color(0xFF343A33);
    const muted = Color(0xFF77796F);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F0),
        foregroundColor: ink,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: Color(0xFFFFE3D7),
              child: Icon(Icons.favorite_rounded, color: coral, size: 20),
            ),
            SizedBox(width: 11),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PregEase', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 2),
                Text('Here to support you', style: TextStyle(fontSize: 12, color: muted)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingHistory
                ? const Center(child: CircularProgressIndicator(color: coral))
                : _messages.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(28),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 420),
                            padding: const EdgeInsets.all(26),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFE3D7), Color(0xFFFFF1CC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 34,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.chat_bubble_rounded, size: 31, color: coral),
                                ),
                                SizedBox(height: 18),
                                Text(
                                  'What’s on your mind?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: ink, fontSize: 23, fontWeight: FontWeight.w800),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Ask about pregnancy, preparing for baby, or the little things you’re wondering about. We’ll take it one step at a time.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: muted, height: 1.45),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _messages.length) {
                            return const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 12, left: 8),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: coral),
                                ),
                              ),
                            );
                          }
                          return _buildMessage(_messages[index]);
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFDF9),
                border: Border(top: BorderSide(color: Color(0xFFEAE3D8))),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Write your message…',
                        filled: true,
                        fillColor: const Color(0xFFFAF7F0),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      style: FilledButton.styleFrom(
                        backgroundColor: coral,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                      ),
                      child: const Icon(Icons.arrow_upward_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// COMMUNITY
// ============================================================

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() =>
      _CommunityScreenState();
}

class _CommunityScreenState
    extends State<CommunityScreen> {
  List<Map<String, dynamic>> _communities = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/community'),
        headers: await authHeaders(),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        setState(() {
          _communities = data
              .map(
                (item) =>
                    Map<String, dynamic>.from(item),
              )
              .toList();

          _loading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _error = 'Please log in again.';
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Unable to load communities.';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not connect to the server.';
        _loading = false;
      });
    }
  }

  Future<void> _toggleCommunity(
    Map<String, dynamic> community,
  ) async {
    final int communityId =
        community['id'] as int;

    final bool joined =
        community['joined'] == true;

    final String url =
        '$apiBaseUrl/community/$communityId/join';

    try {
      final response = joined
          ? await http.delete(
              Uri.parse(url),
              headers: await authHeaders(),
            )
          : await http.post(
              Uri.parse(url),
              headers: await authHeaders(),
            );

      if (!mounted) return;

      if (response.statusCode == 200) {
        await _loadCommunities();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              joined
                  ? 'You left ${community['name']}.'
                  : 'You joined ${community['name']}!',
            ),
          ),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your session has expired. Please log in again.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to update community membership.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not connect to the server.',
          ),
        ),
      );
    }
  }

  void _openCommunity(
    Map<String, dynamic> community,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityFeedScreen(
          communityId: community['id'] as int,
          communityName:
              community['name'] as String,
          description:
              community['description'] as String? ?? '',
          memberCount:
              community['member_count'] as int? ?? 0,
        ),
      ),
    );
  }

  IconData _communityIcon(String name) {
    switch (name) {
      case 'Pregnancy':
        return Icons.pregnant_woman;

      case 'New Parents':
        return Icons.child_care;

      case 'Baby Sleep':
        return Icons.nightlight;

      case 'Baby Nutrition':
        return Icons.restaurant;

      default:
        return Icons.groups;
    }
  }

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFE87970);
    const ink = Color(0xFF343A33);
    const muted = Color(0xFF77796F);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadCommunities,
        color: coral,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD8C9), Color(0xFFFFF0C9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.diversity_3_rounded, size: 34, color: coral),
                  SizedBox(height: 14),
                  Text(
                    'Find your people',
                    style: TextStyle(
                      color: ink,
                      fontSize: 27,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Real conversations, shared experiences, and a little more support along the way.',
                    style: TextStyle(color: muted, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Communities',
              style: TextStyle(color: ink, fontSize: 21, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose a space that feels right for you.',
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 18),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 42),
                child: Center(child: CircularProgressIndicator(color: coral)),
              )
            else if (_error != null)
              _CommunityError(message: _error!, onRetry: _loadCommunities)
            else if (_communities.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 42),
                child: Center(child: Text('No communities available yet.')),
              )
            else
              ..._communities.map((community) {
                return _CommunityCard(
                  icon: _communityIcon(community['name'] as String),
                  title: community['name'] as String,
                  description: community['description'] as String? ?? '',
                  memberCount: community['member_count'] as int? ?? 0,
                  joined: community['joined'] == true,
                  onTap: () => _openCommunity(community),
                  onToggle: () => _toggleCommunity(community),
                );
              }),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// COMMUNITY CARD
// ============================================================

class _CommunityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final int memberCount;
  final bool joined;

  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _CommunityCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.memberCount,
    required this.joined,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: const Color(
                  0xFFEAF1F8,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 27,
                      backgroundColor:
                          const Color(
                        0xFFE6F4FF,
                      ),
                      child: Icon(
                        icon,
                        color: const Color(
                          0xFF2196F3,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style:
                                const TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '$memberCount members',
                            style:
                                const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black54,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onToggle,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: joined
                          ? Colors.white
                          : const Color(
                              0xFF2196F3,
                            ),
                      foregroundColor: joined
                          ? const Color(
                              0xFF2196F3,
                            )
                          : Colors.white,
                      side: joined
                          ? const BorderSide(
                              color: Color(
                                0xFF2196F3,
                              ),
                            )
                          : null,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    child: Text(
                      joined
                          ? 'Leave Community'
                          : 'Join Community',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ============================================================
// COMMUNITY ERROR
// ============================================================

class _CommunityError
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CommunityError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off,
              size: 48,
              color: Colors.grey,
            ),

            const SizedBox(height: 12),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// DOCTORS
// ============================================================

class DoctorsScreen
    extends StatelessWidget {

  const DoctorsScreen({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF343A33);
    const muted = Color(0xFF77796F);
    const coral = Color(0xFFE87970);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE4F0DF), Color(0xFFDDF0F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.health_and_safety_rounded, color: Color(0xFF71866B), size: 34),
                SizedBox(height: 14),
                Text(
                  'Care you can trust',
                  style: TextStyle(color: ink, fontSize: 27, height: 1.1, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'Explore professional support for your family’s health and wellbeing.',
                  style: TextStyle(color: muted, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Care categories',
            style: TextStyle(color: ink, fontSize: 21, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'These categories are starting points, not individual provider listings.',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 18),
          const _DoctorCard(
            name: 'Pediatrician',
            specialty: 'Child health specialist',
            icon: Icons.medical_services_rounded,
          ),
          const _DoctorCard(
            name: 'Child Psychologist',
            specialty: 'Child development & behaviour',
            icon: Icons.psychology_rounded,
          ),
          const _DoctorCard(
            name: 'Nutritionist',
            specialty: 'Child nutrition specialist',
            icon: Icons.restaurant_rounded,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: coral),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'For urgent symptoms or emergencies, contact local emergency services or your healthcare provider directly.',
                    style: TextStyle(color: ink, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _DoctorCard
    extends StatelessWidget {

  final String name;

  final String specialty;

  final IconData icon;


  const _DoctorCard({
    required this.name,
    required this.specialty,
    required this.icon,
  });


  @override
  Widget build(BuildContext context) {

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),

      child:
          Row(

        children: [

          CircleAvatar(

            radius:
                28,

            backgroundColor:
                const Color(
              0xFFE6F4FF,
            ),

            child:
                Icon(
              icon,
              color:
                  const Color(0xFFE87970),
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(

            child:
                Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(
                  name,

                  style:
                      const TextStyle(
                    fontSize:
                        17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  specialty,

                  style:
                      const TextStyle(
                    color:
                        Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
          ),
        ],
      ),
    );
  }
}


// ============================================================
// PROFILE
// ============================================================

class ProfileScreen
    extends StatefulWidget {

  const ProfileScreen({
    super.key,
  });


  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}


class _ProfileScreenState
    extends State<ProfileScreen> {

  String _name = 'Parent';

  String _email = '';


  @override
  void initState() {

    super.initState();

    _loadUser();
  }


  Future<void> _loadUser() async {

    final prefs =
        await SharedPreferences
            .getInstance();


    if (!mounted) return;


    setState(() {

      _name =
          prefs.getString(
            'user_name',
          ) ??
          'Parent';

      _email =
          prefs.getString(
            'user_email',
          ) ??
          '';
    });
  }
  Future<void> _openPregnancyProfile() async {
  try {
    final response = await http.get(
      Uri.parse(
        '$apiBaseUrl/pregnancy/profile',
      ),
      headers: await authHeaders(),
    );

    if (!mounted) return;

    Map<String, dynamic>? existingProfile;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map) {
        existingProfile =
            Map<String, dynamic>.from(data);
      }
    } else if (response.statusCode != 404) {
      _showProfileMessage(
        'Unable to load pregnancy information.',
      );
      return;
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PregnancyProfileScreen(
          existingProfile: existingProfile,
          onSaved: () {},
        ),
      ),
    );
  } catch (e) {
    debugPrint(
      'Pregnancy profile error: $e',
    );

    if (!mounted) return;

    _showProfileMessage(
      'Could not connect to the server.',
    );
  }
}
void _showProfileMessage(String message) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}


  Future<void> _logout() async {

    final confirmed =
        await showDialog<bool>(

      context: context,

      builder: (context) {

        return AlertDialog(

          title:
              const Text(
            'Logout?',
          ),

          content:
              const Text(
            'Are you sure you want to logout?',
          ),

          actions: [

            TextButton(

              onPressed:
                  () =>
                      Navigator.pop(
                context,
                false,
              ),

              child:
                  const Text(
                'Cancel',
              ),
            ),

            FilledButton(

              onPressed:
                  () =>
                      Navigator.pop(
                context,
                true,
              ),

              child:
                  const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );


    if (confirmed != true) {
      return;
    }


await clearAuth();

if (!mounted) return;

Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(
    builder: (_) => const AuthGate(),
  ),
  (route) => false,
);
  }


  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFE87970);
    const ink = Color(0xFF343A33);
    const muted = Color(0xFF77796F);

    Widget settingsTile({
      required IconData icon,
      required Color tint,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      bool danger = false,
    }) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAE3D8)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: tint),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: danger ? const Color(0xFFC94F67) : ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(subtitle, style: const TextStyle(color: muted, height: 1.3)),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15,
            color: danger ? const Color(0xFFC94F67) : muted,
          ),
          onTap: onTap,
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: [
          const Text(
            'Your profile',
            style: TextStyle(
              color: ink,
              fontSize: 29,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Make PregEase feel like yours.',
            style: TextStyle(color: muted, fontSize: 15),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD7C7), Color(0xFFFFEFCB), Color(0xFFE4F0DF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 39,
                    backgroundColor: const Color(0xFFFFF5EE),
                    child: Text(
                      _name.trim().isEmpty ? 'P' : _name.trim()[0].toUpperCase(),
                      style: const TextStyle(
                        color: coral,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (_email.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    _email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: muted),
                  ),
                ],
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_rounded, color: coral, size: 16),
                      SizedBox(width: 7),
                      Text(
                        'Your support space',
                        style: TextStyle(color: ink, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Personalise your experience',
            style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          settingsTile(
            icon: Icons.pregnant_woman_rounded,
            tint: const Color(0xFFE87970),
            title: 'Pregnancy information',
            subtitle: 'Manage your due-date details, diet and allergies',
            onTap: _openPregnancyProfile,
          ),
          const SizedBox(height: 10),
          const Text(
            'Account',
            style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          settingsTile(
            icon: Icons.logout_rounded,
            tint: const Color(0xFFC94F67),
            title: 'Log out',
            subtitle: 'Sign out from this device',
            danger: true,
            onTap: _logout,
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'PregEase · Support for every step',
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}