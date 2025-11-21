// lib/screens/owner/arenas/widgets/photo_uploader.dart
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kff_owner_admin/app/services/image_upload.dart'
    show ImageUploadService;

class PhotoUploader extends StatefulWidget {
  final Function(List<String>) onUploaded;
  final List<String> initialUrls; // Добавь это

  const PhotoUploader({
    Key? key,
    required this.onUploaded,
    this.initialUrls = const [], // Добавь это
  }) : super(key: key);

  @override
  State<PhotoUploader> createState() => _PhotoUploaderState();
}

class _PhotoUploaderState extends State<PhotoUploader> {
  List<Uint8List> _selectedImages = [];
  List<String> _uploadedUrls = [];
  bool _uploading = false;
  @override
  void initState() {
    super.initState();
    _uploadedUrls = List<String>.from(
      widget.initialUrls,
    ); // Загружаем существующие
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedImages.addAll(
          result.files
              .where(
                (f) =>
                    f.bytes != null &&
                    (_selectedImages.length + _uploadedUrls.length) < 10,
              )
              .map((f) => f.bytes!),
        );
      });
    }
  }

  Future<void> _upload() async {
    if (_selectedImages.isEmpty) return;
    setState(() => _uploading = true);

    try {
      final urls = await ImageUploadService.uploadImages(_selectedImages);
      setState(() {
        _uploadedUrls.addAll(urls);
        _selectedImages.clear();
      });
      widget.onUploaded(_uploadedUrls);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Загружено ${urls.length} фото')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      setState(() => _uploading = false);
    }
  }

  void _removeUploadedImage(int index) {
    setState(() {
      _uploadedUrls.removeAt(index);
      widget.onUploaded(_uploadedUrls);
    });
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Фотогалерея арены',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'До ${10 - _uploadedUrls.length} фото (загружено: ${_uploadedUrls.length}/10)',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Загруженные фото (с сервера)
          if (_uploadedUrls.isNotEmpty) ...[
            const Text(
              '✓ Загруженные фото:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _uploadedUrls.asMap().entries.map((entry) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        entry.value,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 18,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(28, 28),
                        ),
                        onPressed: () => _removeUploadedImage(entry.key),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Выбранные фото (еще не загружены)
          if (_selectedImages.isNotEmpty) ...[
            const Text(
              'Выбранные фото (не загружены):',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedImages.asMap().entries.map((entry) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        entry.value,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(24, 24),
                        ),
                        onPressed: () => _removeSelectedImage(entry.key),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          Row(
            children: [
              ElevatedButton.icon(
                onPressed: (_uploading || _uploadedUrls.length >= 10)
                    ? null
                    : _pickImages,
                icon: const Icon(Icons.add_photo_alternate, size: 18),
                label: Text(_selectedImages.isEmpty ? 'Выбрать' : 'Добавить'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2563EB),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFF2563EB)),
                ),
              ),
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _uploading ? null : _upload,
                  icon: _uploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cloud_upload, size: 18),
                  label: Text(_uploading ? 'Загрузка...' : 'Загрузить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
