import 'package:dream_sort/core/theme/app_theme.dart';
import 'package:dream_sort/features/multiplayer/bloc/multiplayer_menu_bloc.dart';
import 'package:dream_sort/features/multiplayer/repository/firebase_multiplayer_repository.dart';
import 'package:dream_sort/features/multiplayer/repository/multiplayer_repository.dart';
import 'package:dream_sort/features/multiplayer/view/multiplayer_game_page.dart';
import 'package:dream_sort/features/multiplayer/view/online_game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';

class MultiplayerMenuPage extends StatefulWidget {
  const MultiplayerMenuPage({super.key});

  @override
  State<MultiplayerMenuPage> createState() => _MultiplayerMenuPageState();
}

class _MultiplayerMenuPageState extends State<MultiplayerMenuPage> {
  late MultiplayerRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = FirebaseMultiplayerRepository();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => MultiplayerMenuBloc(_repository),
      child: BlocListener<MultiplayerMenuBloc, MultiplayerMenuState>(
        listener: (context, state) {
          if (state.status == MenuStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error')),
            );
          } else if (state.status == MenuStatus.success) {
            // Navigate to Lobby
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (_) => OnlineGamePage(
                      repository: _repository,
                      playerId:
                          _repository.currentRoomId ??
                          '', // Use real ID in prod
                    ),
                  ),
                )
                .then((_) {
                  // Reset menu when coming back
                  if (context.mounted) {
                    context.read<MultiplayerMenuBloc>().add(ResetMenu());
                  }
                });
          }
        },
        child: BlocBuilder<MultiplayerMenuBloc, MultiplayerMenuState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.multiplayer)),
              body: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                      ),
                    ),
                    child: SafeArea(
                      child: Center(
                        child: Builder(
                          builder: (context) {
                            return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 40),
                                  const Icon(
                                    Icons.people_alt,
                                    color: AppTheme.accent,
                                    size: 80,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    l10n.multiplayerMode,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    l10n.challengeFriends,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 60),

                                  // CREATE ROOM
                                  _MenuButton(
                                    label: l10n.createRoom,
                                    icon: Icons.add_circle_outline,
                                    color: Colors.green,
                                    onTap: () => _showCreateDialog(context),
                                  ),
                                  const SizedBox(height: 20),

                                  // JOIN ROOM
                                  _MenuButton(
                                    label: l10n.joinRoom,
                                    icon: Icons.login,
                                    color: Colors.blue,
                                    onTap: () => _showJoinDialog(context),
                                  ),

                                  const SizedBox(height: 20),

                                  // LOCAL SPLIT SCREEN
                                  _MenuButton(
                                    label: l10n.localVs,
                                    icon: Icons.splitscreen,
                                    color: Colors.orange,
                                    onTap: () =>
                                        _showLevelSelectionDialog(context),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (state.status == MenuStatus.loading)
                    Container(
                      color: Colors.black54,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLevelSelectionDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E2E48), Color(0xFF1E1E2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.splitscreen, color: Colors.orange, size: 48),
                const SizedBox(height: 16),
                Text(
                  l10n.selectLevel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.chooseDifficulty,
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 24),
                // Level Grid
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: List.generate(12, (index) {
                    final level = index + 1;
                    return _LevelButton(
                      level: level,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MultiplayerGamePage(levelId: level),
                          ),
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 20),
                // Cancel button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    int selectedLevel = 1;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 340,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E2E48), Color(0xFF1E1E2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_circle,
                      color: AppTheme.accent,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.createRoom,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.enterNameAndLevel,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _StyledTextField(
                      controller: controller,
                      hintText: l10n.playerName,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    // Level Selection
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.selectLevel,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(12, (index) {
                              final level = index + 1;
                              final isSelected = level == selectedLevel;
                              return GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    selectedLevel = level;
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.accent.withValues(alpha: 0.3)
                                        : Colors.black26,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.accent
                                          : Colors.white24,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$level',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white70,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _DialogActionButton(
                          label: l10n.cancel,
                          color: Colors.transparent,
                          textColor: Colors.white70,
                          onTap: () => Navigator.pop(context),
                        ),
                        _DialogActionButton(
                          label: l10n.create,
                          color: AppTheme.accent,
                          textColor: Colors.white,
                          onTap: () {
                            if (controller.text.isNotEmpty) {
                              context.read<MultiplayerMenuBloc>().add(
                                CreateRoomRequested(
                                  controller.text,
                                  levelId: selectedLevel,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E2E48), Color(0xFF1E1E2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.login, color: Color(0xFF4CAF50), size: 48),
                const SizedBox(height: 16),
                Text(
                  l10n.joinRoom,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.enterRoomDetails,
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 24),
                _StyledTextField(
                  controller: nameCtrl,
                  hintText: l10n.yourName,
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _StyledTextField(
                  controller: codeCtrl,
                  hintText: l10n.roomCodeHint,
                  icon: Icons.vpn_key,
                  isCapitalized: true,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _DialogActionButton(
                      label: l10n.cancel,
                      color: Colors.transparent,
                      textColor: Colors.white70,
                      onTap: () => Navigator.pop(context),
                    ),
                    _DialogActionButton(
                      label: l10n.join,
                      color: const Color(0xFF4CAF50),
                      textColor: Colors.white,
                      onTap: () {
                        if (nameCtrl.text.isNotEmpty &&
                            codeCtrl.text.isNotEmpty) {
                          context.read<MultiplayerMenuBloc>().add(
                            JoinRoomRequested(codeCtrl.text, nameCtrl.text),
                          );
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isCapitalized;

  const _StyledTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isCapitalized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        textCapitalization: isCapitalized
            ? TextCapitalization.characters
            : TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _DialogActionButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          border: color == Colors.transparent
              ? Border.all(color: Colors.white24)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final int level;
  final VoidCallback onTap;

  const _LevelButton({required this.level, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Different colors based on difficulty ranges
    Color getColor() {
      if (level <= 3) return Colors.green;
      if (level <= 6) return Colors.blue;
      if (level <= 9) return Colors.orange;
      return Colors.red;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: getColor().withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: getColor(), width: 2),
        ),
        child: Center(
          child: Text(
            '$level',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
