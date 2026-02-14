import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kff_owner_admin/app/api/api.dart'; // Твой ApiClient

class VerificationView extends StatefulWidget {
  final String status;
  final String? rejectReason;
  final VoidCallback onSuccess;

  const VerificationView({
    Key? key,
    required this.status,
    this.rejectReason,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  final _formKey = GlobalKey<FormState>();

  final _companyController = TextEditingController();
  final _binController = TextEditingController();
  final _ibanController = TextEditingController();
  final _bicController = TextEditingController();

  PlatformFile? _idFile; // Файл Удостоверения
  PlatformFile? _ipFile; // Файл ИП

  bool _isLoading = false;

  @override
  void dispose() {
    _companyController.dispose();
    _binController.dispose();
    _ibanController.dispose();
    _bicController.dispose();
    super.dispose();
  }

  // Метод выбора файла Удостоверения
  Future<void> _pickIdFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null) setState(() => _idFile = result.files.first);
  }

  // Метод выбора файла ИП
  Future<void> _pickIpFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null) setState(() => _ipFile = result.files.first);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Проверяем, что ОБА файла загружены
    if (_idFile == null ||
        _idFile!.bytes == null ||
        _ipFile == null ||
        _ipFile!.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Пожалуйста, прикрепите ОБА документа (Удостоверение и ИП)',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Конвертируем оба файла
      String idBase64 = base64Encode(_idFile!.bytes!);
      String ipBase64 = base64Encode(_ipFile!.bytes!);

      final payload = {
        'companyName': _companyController.text.trim(),
        'bin': _binController.text.trim(),
        'iban': _ibanController.text.trim(),
        'bic': _bicController.text.trim(),
        'idDocumentBase64': idBase64,
        'idFileName': _idFile!.name,
        'ipDocumentBase64': ipBase64,
        'ipFileName': _ipFile!.name,
      };

      final response = await ApiClient.post(
        'api/profile/verify-business',
        payload,
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Данные успешно отправлены на проверку!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess();
      } else {
        throw Exception(response['message'] ?? 'Неизвестная ошибка');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка отправки: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status == 'pending') return _buildPendingView();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Регистрация партнера (ИП/ТОО)',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Заполните реквизиты для приема платежей.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                if (widget.status == 'rejected') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Отклонено: ${widget.rejectReason ?? "Ошибки в документах"}',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: 'Название ИП или ТОО',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Обязательное поле' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _binController,
                  decoration: const InputDecoration(
                    labelText: 'ИИН или БИН',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v!.length != 12 ? 'Должно быть 12 цифр' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ibanController,
                  decoration: const InputDecoration(
                    labelText: 'Номер счета (IBAN)',
                    hintText: 'KZ...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (!v!.toUpperCase().startsWith('KZ') || v.length != 20)
                      ? 'Должно начинаться с KZ (20 символов)'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bicController,
                  decoration: const InputDecoration(
                    labelText: 'БИК банка',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Обязательное поле' : null,
                ),

                const SizedBox(height: 32),
                const Text(
                  'Документы (PDF)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),

                // КНОПКА 1: УДОСТОВЕРЕНИЕ
                _buildFilePickerBtn(
                  title: 'Удостоверение личности',
                  file: _idFile,
                  onTap: _pickIdFile,
                ),
                const SizedBox(height: 16),

                // КНОПКА 2: ИП
                _buildFilePickerBtn(
                  title: 'Свидетельство/Талон ИП',
                  file: _ipFile,
                  onTap: _pickIpFile,
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Отправить на проверку',
                            style: TextStyle(color: Colors.white, fontSize: 16),
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

  // Виджет для кнопки загрузки
  Widget _buildFilePickerBtn({
    required String title,
    required PlatformFile? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: file != null ? Colors.green.shade50 : Colors.blue.shade50,
          border: Border.all(
            color: file != null ? Colors.green.shade400 : Colors.blue.shade200,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              file != null ? Icons.check_circle : Icons.upload_file,
              size: 32,
              color: file != null
                  ? Colors.green.shade600
                  : Colors.blue.shade700,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file != null ? file.name : 'Нажмите, чтобы выбрать PDF',
                    style: TextStyle(
                      color: file != null
                          ? Colors.green.shade800
                          : Colors.blue.shade800,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingView() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_top, size: 64, color: Colors.orange.shade400),
            const SizedBox(height: 24),
            const Text(
              'Документы на проверке',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Мы проверяем ваши реквизиты. Ожидайте одобрения администратором.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: widget.onSuccess,
              icon: const Icon(Icons.refresh),
              label: const Text('Обновить статус'),
            ),
          ],
        ),
      ),
    );
  }
}
