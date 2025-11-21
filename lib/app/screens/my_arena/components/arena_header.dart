// lib/screens/owner/components/arena_header.dart
import 'package:flutter/material.dart';

class ArenaHeader extends StatelessWidget {
  final VoidCallback onAddArena;

  const ArenaHeader({Key? key, required this.onAddArena}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Desktop/Tablet Layout
        if (MediaQuery.of(context).size.width >= 768)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Мои Арены',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              _AddArenaButton(onPressed: onAddArena, isCompact: false),
            ],
          )
        // Mobile Layout
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Мои Арены',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              _AddArenaButton(onPressed: onAddArena, isCompact: false),
            ],
          ),
      ],
    );
  }
}

class _AddArenaButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isCompact;

  const _AddArenaButton({required this.onPressed, required this.isCompact});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 16 : 24,
          vertical: isCompact ? 12 : 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add, size: 20),
          if (!isCompact) ...[
            const SizedBox(width: 8),
            const Text(
              'Добавить новую арену',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}
