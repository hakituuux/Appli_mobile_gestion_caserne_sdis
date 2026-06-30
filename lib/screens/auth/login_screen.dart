// ignore_for_file: deprecated_member_use



import 'package:flutter/material.dart';

import 'package:provider/provider.dart';



import '../../auth/auth_controller.dart';
import '../../config/app_config.dart';
import '../../theme/app_colors.dart';



class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});



  @override

  State<LoginScreen> createState() => _LoginScreenState();

}



class _LoginScreenState extends State<LoginScreen> {

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;

  bool _obscure = true;



  @override

  void dispose() {

    _emailCtrl.dispose();

    _passwordCtrl.dispose();

    super.dispose();

  }



  Future<void> _submit() async {

    if (_loading) return;

    setState(() => _loading = true);

    final auth = context.read<AuthController>();

    try {

      await auth.signIn(

        email: _emailCtrl.text.trim(),

        password: _passwordCtrl.text,

      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('Connexion impossible : $e')),

      );

    } finally {

      if (mounted) setState(() => _loading = false);

    }

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.background,

      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(20),

          child: Center(

            child: ConstrainedBox(

              constraints: const BoxConstraints(maxWidth: 420),

              child: Container(

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(

                  color: AppColors.surface,

                  borderRadius: BorderRadius.circular(18),

                ),

                child: Column(

                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [

                    const Text(

                      'GESTION PERSO SDIS',

                      style: TextStyle(

                        color: AppColors.textPrimary,

                        fontSize: 22,

                        fontWeight: FontWeight.bold,

                      ),

                      textAlign: TextAlign.center,

                    ),

                    const SizedBox(height: 10),

                    Text(

                      AppConfig.useMockData
                          ? 'Mode démo — données locales (aucune API requise)'
                          : 'Connexion — base SDIS partagée avec l’appli web',

                      style: TextStyle(color: AppColors.textSecondary.withOpacity(0.95)),

                      textAlign: TextAlign.center,

                    ),

                    const SizedBox(height: 18),

                    TextField(

                      controller: _emailCtrl,

                      keyboardType: TextInputType.emailAddress,

                      autocorrect: false,

                      style: const TextStyle(color: AppColors.textPrimary),

                      decoration: const InputDecoration(

                        labelText: 'Email',

                        labelStyle: TextStyle(color: AppColors.textSecondary),

                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),

                      ),

                    ),

                    const SizedBox(height: 12),

                    TextField(

                      controller: _passwordCtrl,

                      obscureText: _obscure,

                      style: const TextStyle(color: AppColors.textPrimary),

                      decoration: InputDecoration(

                        labelText: 'Mot de passe',

                        labelStyle: const TextStyle(color: AppColors.textSecondary),

                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),

                        suffixIcon: IconButton(

                          icon: Icon(

                            _obscure ? Icons.visibility_off : Icons.visibility,

                            color: AppColors.textSecondary,

                          ),

                          onPressed: () => setState(() => _obscure = !_obscure),

                        ),

                      ),

                      onSubmitted: (_) => _submit(),

                    ),

                    const SizedBox(height: 18),

                    FilledButton.icon(

                      style: FilledButton.styleFrom(

                        backgroundColor: AppColors.coral,

                        foregroundColor: Colors.white,

                        padding: const EdgeInsets.symmetric(vertical: 14),

                      ),

                      onPressed: _loading ? null : _submit,

                      icon: _loading

                          ? const SizedBox(

                              width: 20,

                              height: 20,

                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),

                            )

                          : const Icon(Icons.login),

                      label: Text(_loading ? 'Connexion…' : 'Se connecter'),

                    ),

                    const SizedBox(height: 12),
                    if (!AppConfig.useMockData) ...[
                      Text(
                        'API : ${AppConfig.apiBaseUrl}',
                        style: TextStyle(color: AppColors.textSecondary.withOpacity(0.85), fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ActionChip(
                            label: const Text('Chef (Pierre)'),
                            onPressed: _loading
                                ? null
                                : () {
                                    _emailCtrl.text = 'pierre.durand@sdis34.demo';
                                    _passwordCtrl.text = 'demo2026!';
                                  },
                          ),
                          ActionChip(
                            label: const Text('Pompier (Jean)'),
                            onPressed: _loading
                                ? null
                                : () {
                                    _emailCtrl.text = 'personnel.limite@sdis34.demo';
                                    _passwordCtrl.text = 'demo2026!';
                                  },
                          ),
                          ActionChip(
                            label: const Text('Officier (Sarah)'),
                            onPressed: _loading
                                ? null
                                : () {
                                    _emailCtrl.text = 'sarah.lopez@sdis34.demo';
                                    _passwordCtrl.text = 'demo2026!';
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mot de passe démo : demo2026!',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      const Text(
                        'Appuyez sur « Se connecter » pour entrer en mode démo.\nChangez de rôle dans Paramètres si besoin.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],

                  ],

                ),

              ),

            ),

          ),

        ),

      ),

    );

  }

}


