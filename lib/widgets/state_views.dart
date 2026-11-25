import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      CircularProgressIndicator(color: Color(0xFF315C45)),
      SizedBox(height: 14),
      Text('Sedang menyiapkan resep...', style: TextStyle(color: Colors.black54)),
    ]),
  );
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 76, height: 76,
          decoration: const BoxDecoration(color: Color(0xFFF8EBDD), shape: BoxShape.circle),
          child: const Icon(Icons.wifi_off_rounded, size: 36, color: Color(0xFFB97837))),
        const SizedBox(height: 16),
        Text('Ups, resep belum bisa dimuat', textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 7),
        Text(message, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, height: 1.4)),
        const SizedBox(height: 18),
        FilledButton.icon(onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded), label: const Text('Coba lagi')),
      ]),
    ),
  );
}

class EmptyView extends StatelessWidget {
  final IconData icon;
  final String text;
  const EmptyView({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 88, height: 88,
          decoration: const BoxDecoration(color: Color(0xFFE7EFE7), shape: BoxShape.circle),
          child: Icon(icon, size: 42, color: const Color(0xFF66816D))),
        const SizedBox(height: 16),
        Text(text, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, height: 1.5)),
      ]),
    ),
  );
}
