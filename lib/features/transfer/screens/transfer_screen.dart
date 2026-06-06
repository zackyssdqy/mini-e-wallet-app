import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/transfer_provider.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receiverController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _receiverController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final receiverId = int.parse(_receiverController.text.trim());
    final amount = int.parse(_amountController.text.trim());

    try {
      await ref.read(transferControllerProvider.notifier).submit(
            receiverId: receiverId,
            amount: amount,
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transfer berhasil'),
          backgroundColor: Color(0xFF059669),
        ),
      );
      _amountController.clear();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(transferControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Dana'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              'Masukkan tujuan transfer dan nominal yang ingin dikirim.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    controller: _receiverController,
                    labelText: 'Receiver ID',
                    hintText: 'Contoh: 2',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return 'Receiver wajib dipilih';
                      }
                      final parsed = int.tryParse(text);
                      if (parsed == null) {
                        return 'Receiver harus berupa angka';
                      }
                      if (parsed <= 0) {
                        return 'Receiver harus lebih dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _amountController,
                    labelText: 'Amount',
                    hintText: 'Contoh: 50000',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return 'Amount wajib diisi';
                      }
                      final parsed = int.tryParse(text);
                      if (parsed == null) {
                        return 'Amount harus angka';
                      }
                      if (parsed <= 0) {
                        return 'Amount harus lebih dari 0';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Kirim Transfer',
                    isLoading: isSubmitting,
                    onPressed: isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
