import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';
import 'onboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _AuthMode _mode = _AuthMode.landing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: switch (_mode) {
            _AuthMode.landing  => _LandingView(onMode: (m) => setState(() => _mode = m)),
            _AuthMode.email    => _EmailView(onBack: () => setState(() => _mode = _AuthMode.landing)),
            _AuthMode.phone    => _PhoneView(onBack: () => setState(() => _mode = _AuthMode.landing)),
          },
        ),
      ),
    );
  }
}

enum _AuthMode { landing, email, phone }

// ─────────────────────────────────────────────────────────────────────────────
// LANDING
// ─────────────────────────────────────────────────────────────────────────────
class _LandingView extends StatelessWidget {
  final ValueChanged<_AuthMode> onMode;
  const _LandingView({required this.onMode});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Logo
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(child: Text('📓', style: TextStyle(fontSize: 38))),
        ),
        const SizedBox(height: 20),
        Text('Hayat\nAjandası',
            style: GoogleFonts.fraunces(
                fontSize: 42, fontWeight: FontWeight.w900,
                color: Colors.white, height: 1.05)),
        const SizedBox(height: 8),
        const Text('Giriş yap veya kayıt ol.',
            style: TextStyle(color: AppTheme.mutedDark, fontSize: 15)),
        const SizedBox(height: 40),

        // Hata
        if (prov.authError != null)
          _ErrorBox(prov.authError!),

        // ── SOSYAL GİRİŞLER ──────────────────────────────────────────────
        _SocialBtn(
          icon: '🔵',
          label: 'Google ile Devam Et',
          color: const Color(0xFF4285F4),
          onTap: () => _doOAuth(context, prov, 'google'),
        ),
        const SizedBox(height: 10),
        _SocialBtn(
          icon: '🔷',
          label: 'Facebook ile Devam Et',
          color: const Color(0xFF1877F2),
          onTap: () => _doOAuth(context, prov, 'facebook'),
        ),

        // ── AYIRICI ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(children: [
            const Expanded(child: Divider(color: AppTheme.borderDark)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('veya', style: TextStyle(color: AppTheme.mutedDark, fontSize: 13)),
            ),
            const Expanded(child: Divider(color: AppTheme.borderDark)),
          ]),
        ),

        // ── EMAIL / TELEFON ───────────────────────────────────────────────
        _OutlineBtn(
          icon: '✉️',
          label: 'Email ile Devam Et',
          onTap: () => onMode(_AuthMode.email),
        ),
        const SizedBox(height: 10),
        _OutlineBtn(
          icon: '📱',
          label: 'Telefon ile Devam Et',
          onTap: () => onMode(_AuthMode.phone),
        ),

        // ── AYIRICI ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(children: [
            const Expanded(child: Divider(color: AppTheme.borderDark)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('ya da', style: TextStyle(color: AppTheme.mutedDark, fontSize: 13)),
            ),
            const Expanded(child: Divider(color: AppTheme.borderDark)),
          ]),
        ),

        // ── ANONİM ───────────────────────────────────────────────────────
        GestureDetector(
          onTap: prov.authLoading ? null : () => _doAnon(context, prov),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: prov.authLoading
                ? const Center(child: SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent)))
                : const Column(children: [
                    Text('👻', style: TextStyle(fontSize: 22)),
                    SizedBox(height: 4),
                    Text('Anonim Devam Et',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
                    SizedBox(height: 2),
                    Text('Hesap oluşturmadan başla',
                        style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
                  ]),
          ),
        ),

        const SizedBox(height: 24),
        Text(
          '🔒 Tüm veriler Supabase\'de güvenle saklanır.\n'
          'Anonim hesaplarda 30 gün sonra veri silinebilir.',
          style: const TextStyle(fontSize: 11, color: AppTheme.mutedDark, height: 1.6),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  Future<void> _doAnon(BuildContext ctx, AppProvider prov) async {
    final ok = await prov.signInAnon();
    if (ok && ctx.mounted) _navigateAfterAuth(ctx, prov);
  }

  Future<void> _doOAuth(BuildContext ctx, AppProvider prov, String provider) async {
    final ok = provider == 'google'
        ? await prov.signInGoogle()
        : await prov.signInFacebook();
    if (ok && ctx.mounted) _navigateAfterAuth(ctx, prov);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMAIL VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _EmailView extends StatefulWidget {
  final VoidCallback onBack;
  const _EmailView({required this.onBack});
  @override
  State<_EmailView> createState() => _EmailViewState();
}

class _EmailViewState extends State<_EmailView> {
  bool _isLogin = true;
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _passVisible = false;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Geri
        GestureDetector(
          onTap: widget.onBack,
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.arrow_back_ios, size: 16, color: AppTheme.mutedDark),
            Text('Geri', style: TextStyle(color: AppTheme.mutedDark, fontSize: 14)),
          ]),
        ),
        const SizedBox(height: 28),
        Text(_isLogin ? '✉️ Giriş Yap' : '✉️ Kayıt Ol',
            style: GoogleFonts.fraunces(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 6),
        Text(_isLogin ? 'Email ve şifren ile devam et.' : 'Yeni hesap oluştur.',
            style: const TextStyle(color: AppTheme.mutedDark, fontSize: 14)),
        const SizedBox(height: 28),

        if (prov.authError != null) _ErrorBox(prov.authError!),

        // Email
        const Text('Email', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDeco('ornek@email.com'),
        ),
        const SizedBox(height: 14),

        // Şifre
        const Text('Şifre', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(
          controller: _passCtrl,
          obscureText: !_passVisible,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDeco('••••••••').copyWith(
            suffixIcon: IconButton(
              icon: Icon(_passVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.mutedDark, size: 18),
              onPressed: () => setState(() => _passVisible = !_passVisible),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Buton
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: prov.authLoading ? null : () => _submit(context, prov),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: prov.authLoading
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
        const SizedBox(height: 16),

        // Geçiş
        Center(child: GestureDetector(
          onTap: () => setState(() => _isLogin = !_isLogin),
          child: RichText(text: TextSpan(children: [
            TextSpan(
              text: _isLogin ? 'Hesabın yok mu? ' : 'Zaten hesabın var mı? ',
              style: const TextStyle(color: AppTheme.mutedDark, fontSize: 13),
            ),
            TextSpan(
              text: _isLogin ? 'Kayıt Ol' : 'Giriş Yap',
              style: const TextStyle(
                  color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ])),
        )),
      ]),
    );
  }

  Future<void> _submit(BuildContext ctx, AppProvider prov) async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) return;
    final ok = _isLogin
        ? await prov.signInEmail(email, pass)
        : await prov.signUpEmail(email, pass);
    if (ok && ctx.mounted) _navigateAfterAuth(ctx, prov);
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppTheme.surface2Dark,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.borderDark)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.borderDark)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.accent)),
    hintStyle: const TextStyle(color: AppTheme.mutedDark),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PHONE VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _PhoneView extends StatefulWidget {
  final VoidCallback onBack;
  const _PhoneView({required this.onBack});
  @override
  State<_PhoneView> createState() => _PhoneViewState();
}

class _PhoneViewState extends State<_PhoneView> {
  final _phoneCtrl = TextEditingController(text: '+90');
  final _otpCtrl   = TextEditingController();
  bool _otpSent = false;
  String? _phone;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: _otpSent ? () => setState(() { _otpSent = false; }) : widget.onBack,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.arrow_back_ios, size: 16, color: AppTheme.mutedDark),
            Text(_otpSent ? 'Telefon numarasına dön' : 'Geri',
                style: const TextStyle(color: AppTheme.mutedDark, fontSize: 14)),
          ]),
        ),
        const SizedBox(height: 28),

        Text(_otpSent ? '📲 Kodu Gir' : '📱 Telefon ile Giriş',
            style: GoogleFonts.fraunces(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 6),
        Text(
          _otpSent
              ? '$_phone numarasına SMS gönderdik.'
              : 'Telefon numarana doğrulama kodu gönderilecek.',
          style: const TextStyle(color: AppTheme.mutedDark, fontSize: 14),
        ),
        const SizedBox(height: 28),

        if (prov.authError != null) _ErrorBox(prov.authError!),

        if (!_otpSent) ...[
          const Text('Telefon Numarası', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
          const SizedBox(height: 5),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white, letterSpacing: 1.5),
            decoration: _inputDeco('+90 555 000 00 00'),
          ),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: prov.authLoading ? null : () => _sendOtp(context, prov),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent, foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: prov.authLoading
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('SMS Kodu Gönder', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          )),
        ] else ...[
          const Text('Doğrulama Kodu (6 hane)', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
          const SizedBox(height: 5),
          TextField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 8),
            textAlign: TextAlign.center,
            decoration: _inputDeco('000000').copyWith(counterText: ''),
          ),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: prov.authLoading ? null : () => _verifyOtp(context, prov),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent, foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: prov.authLoading
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('Doğrula ve Giriş Yap', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          )),
        ],
      ]),
    );
  }

  Future<void> _sendOtp(BuildContext ctx, AppProvider prov) async {
    _phone = _phoneCtrl.text.trim();
    if (_phone!.isEmpty) return;
    final ok = await prov.sendPhoneOtp(_phone!);
    if (ok) setState(() => _otpSent = true);
  }

  Future<void> _verifyOtp(BuildContext ctx, AppProvider prov) async {
    final token = _otpCtrl.text.trim();
    if (token.length != 6) return;
    final ok = await prov.verifyPhoneOtp(_phone!, token);
    if (ok && ctx.mounted) _navigateAfterAuth(ctx, prov);
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppTheme.surface2Dark,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.borderDark)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.borderDark)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.accent)),
    hintStyle: const TextStyle(color: AppTheme.mutedDark),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _SocialBtn extends StatelessWidget {
  final String icon, label;
  final Color color;
  final VoidCallback onTap;
  const _SocialBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: color)),
        ]),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String icon, label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
      ]),
    ),
  );
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox(this.message);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.accent2.withOpacity(0.12),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.accent2.withOpacity(0.4)),
    ),
    child: Row(children: [
      const Text('⚠️', style: TextStyle(fontSize: 16)),
      const SizedBox(width: 8),
      Expanded(child: Text(message,
          style: const TextStyle(color: AppTheme.accent2, fontSize: 13))),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// NAVIGATION HELPER
// ─────────────────────────────────────────────────────────────────────────────
void _navigateAfterAuth(BuildContext ctx, AppProvider prov) {
  Navigator.of(ctx).pushReplacement(MaterialPageRoute(
    builder: (_) => prov.userName.isEmpty ? const OnboardScreen() : const MainScreen(),
  ));
}
