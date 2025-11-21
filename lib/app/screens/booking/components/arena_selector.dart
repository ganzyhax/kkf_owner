import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kff_owner_admin/app/screens/my_arena/bloc/my_arena_bloc.dart';

class ArenaSelector extends StatefulWidget {
  final Function(String?) onArenaChanged;

  const ArenaSelector({super.key, required this.onArenaChanged});

  @override
  State<ArenaSelector> createState() => _ArenaSelectorState();
}

class _ArenaSelectorState extends State<ArenaSelector> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выберите Арену',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<MyArenaBloc, MyArenaState>(
            builder: (context, state) {
              if (state is MyArenaLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is MyArenaLoaded) {
                final arenas = state.arenas;

                if (arenas.isEmpty) {
                  return const Text(
                    'У вас нет арен',
                    style: TextStyle(color: Colors.grey),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: selected,
                  hint: const Text('Выберите арену'),
                  items: arenas.map((arena) {
                    final id = arena['_id'] ?? arena['id'];
                    final name = arena['name'] ?? 'Без названия';
                    return DropdownMenuItem<String>(
                      value: id as String,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() => selected = v);
                    widget.onArenaChanged(v);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black26),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                );
              }

              return const Text(
                'Ошибка загрузки арен',
                style: TextStyle(color: Colors.red),
              );
            },
          ),
        ],
      ),
    );
  }
}
