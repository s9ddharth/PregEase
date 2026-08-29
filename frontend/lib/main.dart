import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


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
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'PregEase',

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor:
            const Color(0xFFF7F8FA),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
        ),
      ),

      home: const AuthGate(),
    );
  }
}


// ============================================================
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
      return const AppShell();
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

    return Scaffold(

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding:
                const EdgeInsets.all(24),

            child: ConstrainedBox(

              constraints:
                  const BoxConstraints(
                maxWidth: 430,
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,

                children: [

                  const Icon(
                    Icons.child_care,
                    size: 75,
                    color:
                        Color(0xFF6C63FF),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    'Welcome to PregEase',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'Your parenting support assistant',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 35,
                  ),

                  TextField(
                    controller:
                        _emailController,

                    keyboardType:
                        TextInputType
                            .emailAddress,

                    decoration:
                        const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(
                        Icons
                            .email_outlined,
                      ),
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextField(
                    controller:
                        _passwordController,

                    obscureText:
                        _obscurePassword,

                    decoration:
                        InputDecoration(
                      labelText:
                          'Password',

                      prefixIcon:
                          const Icon(
                        Icons
                            .lock_outline,
                      ),

                      border:
                          const OutlineInputBorder(),

                      suffixIcon:
                          IconButton(
                        onPressed: () {

                          setState(() {

                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },

                        icon: Icon(
                          _obscurePassword
                              ? Icons
                                  .visibility
                              : Icons
                                  .visibility_off,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  SizedBox(
                    height: 52,

                    child:
                        FilledButton(
                      onPressed:
                          _loading
                              ? null
                              : _login,

                      child: _loading

                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color:
                                    Colors.white,
                              ),
                            )

                          : const Text(
                              'Login',
                              style:
                                  TextStyle(
                                fontSize:
                                    16,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  TextButton(
                    onPressed:
                        _loading
                            ? null
                            : () {

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            RegisterScreen(
                                      onRegisterSuccess:
                                          () {
                                        Navigator.pop(
                                            context);
                                      },
                                    ),
                                  ),
                                );
                              },

                    child: const Text(
                      "Don't have an account? Create one",
                    ),
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

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Create account',
        ),
      ),

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding:
                const EdgeInsets.all(24),

            child: ConstrainedBox(

              constraints:
                  const BoxConstraints(
                maxWidth: 430,
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,

                children: [

                  const Text(
                    'Create your PregEase account',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'Your conversations will be associated with your account.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  TextField(
                    controller:
                        _nameController,

                    textCapitalization:
                        TextCapitalization
                            .words,

                    decoration:
                        const InputDecoration(
                      labelText: 'Name',
                      prefixIcon:
                          Icon(
                        Icons
                            .person_outline,
                      ),
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextField(
                    controller:
                        _emailController,

                    keyboardType:
                        TextInputType
                            .emailAddress,

                    decoration:
                        const InputDecoration(
                      labelText: 'Email',
                      prefixIcon:
                          Icon(
                        Icons
                            .email_outlined,
                      ),
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextField(
                    controller:
                        _passwordController,

                    obscureText:
                        _obscurePassword,

                    decoration:
                        InputDecoration(
                      labelText:
                          'Password',

                      prefixIcon:
                          const Icon(
                        Icons
                            .lock_outline,
                      ),

                      border:
                          const OutlineInputBorder(),

                      suffixIcon:
                          IconButton(
                        onPressed: () {

                          setState(() {

                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },

                        icon: Icon(
                          _obscurePassword
                              ? Icons
                                  .visibility
                              : Icons
                                  .visibility_off,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  SizedBox(
                    height: 52,

                    child:
                        FilledButton(
                      onPressed:
                          _loading
                              ? null
                              : _register,

                      child: _loading

                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color:
                                    Colors.white,
                              ),
                            )

                          : const Text(
                              'Create account',
                              style:
                                  TextStyle(
                                fontSize:
                                    16,
                              ),
                            ),
                    ),
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

class AppShell
    extends StatefulWidget {

  const AppShell({super.key});


  @override
  State<AppShell> createState() =>
      _AppShellState();
}


class _AppShellState
    extends State<AppShell> {

  int _selectedIndex = 0;


  final List<Widget> _screens = const [

    DashboardScreen(),

    ChatHistoryScreen(),

    CommunityScreen(),

    DoctorsScreen(),

    ProfileScreen(),
  ];


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body:
          _screens[_selectedIndex],

      bottomNavigationBar:
          NavigationBar(

        selectedIndex:
            _selectedIndex,

        onDestinationSelected:
            (index) {

          setState(() {

            _selectedIndex =
                index;
          });
        },

        destinations: const [

          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon:
                Icon(Icons.home),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons
                  .smart_toy_outlined,
            ),
            selectedIcon:
                Icon(Icons.smart_toy),
            label: 'PregEase',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.people_outline,
            ),
            selectedIcon:
                Icon(Icons.people),
            label: 'Community',
          ),

          NavigationDestination(
            icon: Icon(
              Icons
                  .medical_services_outlined,
            ),
            selectedIcon:
                Icon(
              Icons.medical_services,
            ),
            label: 'Doctors',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon:
                Icon(Icons.person),
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

class DashboardScreen
    extends StatefulWidget {

  const DashboardScreen({super.key});


  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}


class _DashboardScreenState
    extends State<DashboardScreen> {

  final List<ChatSession>
      _recentSessions = [];


  bool _isLoading = true;

  String? _error;
  //Pregnancy Profile
  bool _hasPregnancyProfile =false;
  bool _isPregnancyProfileLoading= true;


  @override
  void initState() {

    super.initState();

    _loadRecentSessions();
    _loadPregnancyProfile();
  }


  Future<void>
      _loadRecentSessions() async {

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


      if (response.statusCode ==
          401) {

        await clearAuth();

        setState(() {

          _error =
              'Your session has expired. Please login again.';

          _isLoading = false;
        });

        return;
      }


      if (response.statusCode !=
          200) {

        setState(() {

          _error =
              'Could not load recent conversations '
              '(${response.statusCode}).';

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


      final sessions =
          <ChatSession>[];


      for (final item in data) {

        if (item
            is Map<String, dynamic>) {

          sessions.add(
            ChatSession.fromJson(
              item,
            ),
          );
        }
      }


      setState(() {

        _recentSessions
          ..clear()
          ..addAll(
            sessions.take(5),
          );

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
Future<void> _loadPregnancyProfile() async {
  try {
    final response = await http.get(
      Uri.parse(
        '$apiBaseUrl/pregnancy/profile',
      ),
      headers: await authHeaders(),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      setState(() {
        _hasPregnancyProfile = true;
        _isPregnancyProfileLoading = false;
      });

      return;
    }

    if (response.statusCode == 404) {
      // User has not created a pregnancy profile.
      setState(() {
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

  void _openNewChat({
    String? prompt,
  }) {

    final sessionId =
        'flutter-${DateTime.now().millisecondsSinceEpoch}';


    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(
          sessionId: sessionId,
          initialPrompt: prompt,
        ),
      ),
    ).then((_) {

      _loadRecentSessions();
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

      _loadRecentSessions();
    });
  }
  void _openPregnancyProfile() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PregnancyProfileScreen(
        onSaved: () {
          if (!mounted) return;

          setState(() {
            _hasPregnancyProfile = true;
          });
        },
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {

    return SafeArea(

      child:
          RefreshIndicator(

        onRefresh:
            _loadRecentSessions,

        child:
            ListView(

          padding:
              const EdgeInsets.all(
            20,
          ),

          children: [

            const SizedBox(
              height: 10,
            ),

            const Text(
              'Good to see you 👋',

              style: TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(
              'How can PregEase help you today?',

              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // ------------------------------------------------
            // AI CARD
            // ------------------------------------------------

            Container(

              padding:
                  const EdgeInsets.all(
                20,
              ),

              decoration:
                  BoxDecoration(

                color:
                    const Color(
                  0xFF6C63FF,
                ),

                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),

              child:
                  Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  const CircleAvatar(
                    radius: 27,

                    backgroundColor:
                        Colors.white,

                    child: Icon(
                      Icons.smart_toy,
                      color:
                          Color(
                        0xFF6C63FF,
                      ),
                      size: 28,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Text(
                    'Talk to PregEase',

                    style: TextStyle(
                      color:
                          Colors.white,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 7,
                  ),

                  const Text(
                    'Your personal AI parenting companion is here to help.',

                    style: TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  ElevatedButton(
                    onPressed:
                        () =>
                            _openNewChat(),

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.white,
                      foregroundColor:
                          const Color(
                        0xFF6C63FF,
                      ),
                    ),

                    child: const Text(
                      'Start a conversation',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
  height: 24,
),

// ------------------------------------------------
// PREGNANCY PROFILE
// ------------------------------------------------

if (!_isPregnancyProfileLoading &&
    !_hasPregnancyProfile)
  Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFE9E7FF),
              child: Icon(
                Icons.pregnant_woman,
                color: Color(0xFF6C63FF),
              ),
            ),

            SizedBox(width: 12),

            Expanded(
              child: Text(
                'Pregnancy Profile',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        const Text(
          'Personalize your PregEase experience with your pregnancy information.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _openPregnancyProfile,
            child: const Text(
              'Set Up Pregnancy Profile',
            ),
          ),
        ),

        const SizedBox(height: 4),

        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              // User can continue without setting up
              // the pregnancy profile.
            },
            child: const Text(
              'Maybe Later',
            ),
          ),
        ),
      ],
    ),
  ),

if (!_isPregnancyProfileLoading &&
    !_hasPregnancyProfile)
  const SizedBox(
    height: 28,
  ),

const Text(
  'Quick questions',
  style: TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 14,
),

_QuickPrompt(
  icon: Icons.nightlight,
  title: 'Sleep',
  prompt: 'How can I improve my child\'s sleep?',
  onTap: () {
    _openNewChat(
      prompt: 'How can I improve my child\'s sleep?',
    );
  },
),

_QuickPrompt(
  icon: Icons.restaurant,
  title: 'Nutrition',
  prompt: 'What should I feed my child?',
  onTap: () {
    _openNewChat(
      prompt: 'What should I feed my child?',
    );
  },
),

_QuickPrompt(
  icon: Icons.child_care,
  title: 'Development',
  prompt: 'Is my child developing normally?',
  onTap: () {
    _openNewChat(
      prompt: 'Is my child developing normally?',
    );
  },
),

const SizedBox(
  height: 24,
),

const Text(
  'Recent conversations',
  style: TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 14,
),

            if (_isLoading)

              const Center(
                child:
                    CircularProgressIndicator(),
              )

            else if (_error != null)

              Container(

                padding:
                    const EdgeInsets.all(
                  16,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),

                child:
                    Column(

                  children: [

                    Text(
                      _error!,
                      textAlign:
                          TextAlign.center,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    TextButton.icon(
                      onPressed:
                          _loadRecentSessions,
                      icon:
                          const Icon(
                        Icons.refresh,
                      ),
                      label:
                          const Text(
                        'Retry',
                      ),
                    ),
                  ],
                ),
              )

            else if (
                _recentSessions.isEmpty)

              Container(

                padding:
                    const EdgeInsets.all(
                  20,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),

                child:
                    const Column(

                  children: [

                    Icon(
                      Icons
                          .chat_bubble_outline,
                      size: 45,
                      color:
                          Color(
                        0xFF6C63FF,
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    Text(
                      'No conversations yet',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )

            else

              ..._recentSessions.map(
                (session) {

                  return Container(

                    margin:
                        const EdgeInsets.only(
                      bottom: 10,
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

                      leading:
                          const CircleAvatar(
                        backgroundColor:
                            Color(
                          0xFFE9E7FF,
                        ),
                        child: Icon(
                          Icons.chat,
                          color:
                              Color(
                            0xFF6C63FF,
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

                      trailing:
                          const Icon(
                        Icons
                            .arrow_forward_ios,
                        size: 15,
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
    final isEditing =
        widget.existingProfile != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Pregnancy Information'
              : 'Pregnancy Profile',
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const Text(
                'Personalize your PregEase experience',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'You can skip this setup and complete it later from your Profile.',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 28),

              // ------------------------------------------------
              // LMP DATE
              // ------------------------------------------------

              const Text(
                'Last Menstrual Period',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              InkWell(
                onTap: _selectLmpDate,

                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.calendar_month,
                    ),
                    labelText: 'LMP Date',
                  ),

                  child: Text(
                    _lmpDate == null
                        ? 'Select date'
                        : _formatDate(
                            _lmpDate!,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ------------------------------------------------
              // DIETARY PREFERENCE
              // ------------------------------------------------

              const Text(
                'Dietary Preference',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: _dietaryPreference,

                decoration:
                    const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText:
                      'Select preference',
                ),

                items:
                    _dietaryOptions.map(
                  (option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  },
                ).toList(),

                onChanged: (value) {
                  if (!mounted) {
                    return;
                  }

                  setState(() {
                    _dietaryPreference =
                        value;
                  });
                },
              ),

              // ------------------------------------------------
              // CUSTOM DIET
              // ------------------------------------------------

              if (_dietaryPreference ==
                  'Other') ...[
                const SizedBox(height: 12),

                TextField(
                  controller:
                      _customDietController,

                  decoration:
                      const InputDecoration(
                    border:
                        OutlineInputBorder(),
                    labelText:
                        'Custom dietary preference',
                    hintText:
                        'Enter your preference',
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // ------------------------------------------------
              // ALLERGIES
              // ------------------------------------------------

              const Text(
                'Food Allergies',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Select all that apply.',
              ),

              const SizedBox(height: 8),

              ..._allergyOptions.map(
                _buildAllergyOption,
              ),

              const SizedBox(height: 8),

              TextField(
                controller:
                    _otherAllergyController,

                decoration:
                    const InputDecoration(
                  border:
                      OutlineInputBorder(),
                  labelText:
                      'Other allergy',
                  hintText:
                      'Enter another allergy',
                ),
              ),

              const SizedBox(height: 32),

              // ------------------------------------------------
              // SAVE
              // ------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 52,

                child: FilledButton(
                  onPressed:
                      _loading
                          ? null
                          : _saveProfile,

                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing
                              ? 'Update Profile'
                              : 'Save Profile',
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------
              // SKIP
              // ------------------------------------------------

              if (!isEditing)
                SizedBox(
                  width: double.infinity,

                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            Navigator.of(
                              context,
                            ).pop(false);
                          },

                    child: const Text(
                      'Maybe Later',
                    ),
                  ),
                ),
            ],
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
            0xFFE9E7FF,
          ),

          child: Icon(
            icon,
            color:
                const Color(
              0xFF6C63FF,
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

    return Scaffold(

      backgroundColor:
          const Color(0xFFF7F8FA),

      appBar: AppBar(

        backgroundColor:
            Colors.white,

        elevation: 0,

        title:
            const Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              'PregEase',
              style:
                  TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(
              'Your conversations',
              style:
                  TextStyle(
                fontSize: 12,
                color:
                    Colors.grey,
              ),
            ),
          ],
        ),

        actions: [

          IconButton(
            onPressed:
                _loadSessions,

            icon:
                const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(

        onPressed:
            _createNewChat,

        backgroundColor:
            const Color(
          0xFF6C63FF,
        ),

        foregroundColor:
            Colors.white,

        icon:
            const Icon(
          Icons.add,
        ),

        label:
            const Text(
          'New chat',
        ),
      ),

      body:
          _buildHistoryBody(),
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
                  0xFF6C63FF,
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
                      0xFFE9E7FF,
                    ),

                    child:
                        Icon(
                      Icons
                          .chat_bubble_outline,
                      color:
                          Color(
                        0xFF6C63FF,
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
                  ? const Color(
                      0xFF6C63FF,
                    )
                  : Colors.white,

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

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF7F8FA,
      ),

      appBar:
          AppBar(

        backgroundColor:
            Colors.white,

        elevation: 0,

        title:
            const Text(
          'PregEase',
          style:
              TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body:
          Column(

        children: [

          Expanded(

            child:
                _isLoadingHistory

                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )

                    : _messages.isEmpty

                        ? const Center(

                            child:
                                Padding(

                              padding:
                                  EdgeInsets.all(
                                30,
                              ),

                              child:
                                  Column(

                                mainAxisSize:
                                    MainAxisSize.min,

                                children: [

                                  Icon(
                                    Icons
                                        .smart_toy,
                                    size:
                                        55,
                                    color:
                                        Color(
                                      0xFF6C63FF,
                                    ),
                                  ),

                                  SizedBox(
                                    height:
                                        14,
                                  ),

                                  Text(
                                    'How can I help you?',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          21,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(
                                    height:
                                        8,
                                  ),

                                  Text(
                                    'Ask me anything about parenting, sleep, feeding, behaviour or development.',
                                    textAlign:
                                        TextAlign.center,
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )

                        : ListView.builder(

                            padding:
                                const EdgeInsets.all(
                              16,
                            ),

                            itemCount:
                                _messages.length +
                                    (_isLoading
                                        ? 1
                                        : 0),

                            itemBuilder:
                                (
                              context,
                              index,
                            ) {

                              if (index >=
                                  _messages.length) {

                                return const Align(

                                  alignment:
                                      Alignment.centerLeft,

                                  child:
                                      Padding(

                                    padding:
                                        EdgeInsets.only(
                                      bottom: 12,
                                    ),

                                    child:
                                        CircularProgressIndicator(),
                                  ),
                                );
                              }


                              return _buildMessage(
                                _messages[index],
                              );
                            },
                          ),
          ),


          // ==================================================
          // MESSAGE INPUT
          // ==================================================

          SafeArea(

            top: false,

            child:
                Container(

              padding:
                  const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12,
              ),

              color:
                  Colors.white,

              child:
                  Row(

                children: [

                  Expanded(

                    child:
                        TextField(

                      controller:
                          _messageController,

                      minLines:
                          1,

                      maxLines:
                          4,

                      textInputAction:
                          TextInputAction
                              .newline,

                      decoration:
                          InputDecoration(

                        hintText:
                            'Ask PregEase...',

                        filled:
                            true,

                        fillColor:
                            const Color(
                          0xFFF7F8FA,
                        ),

                        border:
                            OutlineInputBorder(

                          borderRadius:
                              BorderRadius
                                  .circular(
                            24,
                          ),

                          borderSide:
                              BorderSide.none,
                        ),
                      ),

                      onSubmitted:
                          (_) {

                        if (!_isLoading) {

                          _sendMessage();
                        }
                      },
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  CircleAvatar(

                    backgroundColor:
                        const Color(
                      0xFF6C63FF,
                    ),

                    child:
                        IconButton(

                      onPressed:
                          _isLoading
                              ? null
                              : _sendMessage,

                      icon:
                          const Icon(
                        Icons.send,
                        color:
                            Colors.white,
                      ),
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

class CommunityScreen
    extends StatelessWidget {

  const CommunityScreen({
    super.key,
  });


  @override
  Widget build(BuildContext context) {

    return SafeArea(

      child:
          ListView(

        padding:
            const EdgeInsets.all(
          20,
        ),

        children: [

          const Text(
            'Community',

            style:
                TextStyle(
              fontSize: 28,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          const Text(
            'Connect with other parents',

            style:
                TextStyle(
              color:
                  Colors.grey,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          const _CommunityCard(
            icon:
                Icons.pregnant_woman,
            title:
                'Pregnancy',
            members:
                '2.4K parents',
          ),

          const _CommunityCard(
            icon:
                Icons.child_care,
            title:
                'New Parents',
            members:
                '4.1K parents',
          ),

          const _CommunityCard(
            icon:
                Icons.nightlight,
            title:
                'Baby Sleep',
            members:
                '1.8K parents',
          ),

          const _CommunityCard(
            icon:
                Icons.restaurant,
            title:
                'Baby Nutrition',
            members:
                '1.2K parents',
          ),
        ],
      ),
    );
  }
}


class _CommunityCard
    extends StatelessWidget {

  final IconData icon;

  final String title;

  final String members;


  const _CommunityCard({
    required this.icon,
    required this.title,
    required this.members,
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
                27,

            backgroundColor:
                const Color(
              0xFFE9E7FF,
            ),

            child:
                Icon(
              icon,
              color:
                  const Color(
                0xFF6C63FF,
              ),
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
                  title,

                  style:
                      const TextStyle(
                    fontSize:
                        17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  members,

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
// DOCTORS
// ============================================================

class DoctorsScreen
    extends StatelessWidget {

  const DoctorsScreen({
    super.key,
  });


  @override
  Widget build(BuildContext context) {

    return SafeArea(

      child:
          ListView(

        padding:
            const EdgeInsets.all(
          20,
        ),

        children: [

          const Text(
            'Doctors',

            style:
                TextStyle(
              fontSize: 28,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          const Text(
            'Find professional support',

            style:
                TextStyle(
              color:
                  Colors.grey,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          const _DoctorCard(
            name:
                'Pediatrician',
            specialty:
                'Child health specialist',
            icon:
                Icons.medical_services,
          ),

          const _DoctorCard(
            name:
                'Child Psychologist',
            specialty:
                'Child development & behaviour',
            icon:
                Icons.psychology,
          ),

          const _DoctorCard(
            name:
                'Nutritionist',
            specialty:
                'Child nutrition specialist',
            icon:
                Icons.restaurant,
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
              0xFFE9E7FF,
            ),

            child:
                Icon(
              icon,
              color:
                  const Color(
                0xFF6C63FF,
              ),
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

    return SafeArea(

      child:
          ListView(

        padding:
            const EdgeInsets.all(
          20,
        ),

        children: [

          const Text(
            'Profile',

            style:
                TextStyle(
              fontSize: 28,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          Container(

            padding:
                const EdgeInsets.all(
              20,
            ),

            decoration:
                BoxDecoration(
              color:
                  Colors.white,
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),

            child:
                Column(

              children: [

                const CircleAvatar(

                  radius:
                      42,

                  backgroundColor:
                      Color(
                    0xFFE9E7FF,
                  ),

                  child:
                      Icon(
                    Icons.person,
                    size:
                        45,
                    color:
                        Color(
                      0xFF6C63FF,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                Text(
                  _name,

                  style:
                      const TextStyle(
                    fontSize:
                        21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                if (_email.isNotEmpty) ...[

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    _email,

                    style:
                        const TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),

const SizedBox(
  height: 20,
),

// ==========================================================
// PREGNANCY INFORMATION
// ==========================================================

Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
  ),
  child: ListTile(
    leading: const Icon(
      Icons.pregnant_woman,
      color: Color(0xFF6C63FF),
    ),
    title: const Text(
      'Pregnancy Information',
      style: TextStyle(
        fontWeight: FontWeight.w600,
      ),
    ),
    subtitle: const Text(
      'Manage pregnancy, diet and allergy information',
    ),
    trailing: const Icon(
      Icons.chevron_right,
    ),
    onTap: _openPregnancyProfile,
  ),
),

const SizedBox(
  height: 12,
),

// ==========================================================
// LOGOUT
// ==========================================================

Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
  ),
  child: ListTile(
    leading: const Icon(
      Icons.logout,
      color: Colors.red,
    ),
    title: const Text(
      'Logout',
      style: TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
    onTap: _logout,
  ),
),
        ],
      ),
    );
  }
}