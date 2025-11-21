// lib/screens/owner/my_arenas_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kff_owner_admin/app/screens/my_arena/bloc/my_arena_bloc.dart';
import 'package:kff_owner_admin/app/screens/my_arena/pages/my_arena_edit_page.dart';
import 'components/arena_header.dart';
import 'components/arena_table.dart';

class MyArenasScreen extends StatelessWidget {
  const MyArenasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyArenaBloc()..add(MyArenaLoad()),
      child: const _MyArenasScreenContent(),
    );
  }
}

class _MyArenasScreenContent extends StatelessWidget {
  const _MyArenasScreenContent({Key? key}) : super(key: key);

  void _onAddArena(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<MyArenaBloc>(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ArenaEditPage(),
          ),
        ),
      ),
    );
  }

  void _onEditArena(BuildContext context, Map<String, dynamic> arena) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<MyArenaBloc>(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ArenaEditPage(
              arenaId: arena['_id'], // ← Map['_id']
              existingArena: arena, // ← Передаем Map
            ),
          ),
        ),
      ),
    );
  }

  void _onDeleteArena(BuildContext context, Map<String, dynamic> arena) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить арену?'),
        content: Text('Вы точно хотите удалить арену "${arena['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Нет'),
          ),
          ElevatedButton(
            onPressed: () {
              print('Delete arena: ${arena['_id']}');
              context.read<MyArenaBloc>().add(
                MyArenaDelete(arenaId: arena['_id']),
              );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Да'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<MyArenaBloc, MyArenaState>(
        builder: (context, state) {
          if (state is MyArenaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MyArenaLoaded) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ArenaHeader(onAddArena: () => _onAddArena(context)),
                    const SizedBox(height: 24),
                    ArenaTable(
                      arenas: state.arenas, // List<Map<String, dynamic>>
                      onEdit: (arena) => _onEditArena(context, arena),
                      onDelete: (arena) => _onDeleteArena(context, arena),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MyArenaError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MyArenaBloc>().add(MyArenaLoad());
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
