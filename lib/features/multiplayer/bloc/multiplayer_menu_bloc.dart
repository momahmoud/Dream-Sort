import 'dart:async';

import 'package:dream_sort/features/multiplayer/repository/multiplayer_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// EVENTS
abstract class MultiplayerMenuEvent extends Equatable {
  const MultiplayerMenuEvent();
  @override
  List<Object?> get props => [];
}

class CreateRoomRequested extends MultiplayerMenuEvent {
  final String playerName;
  final int levelId;
  const CreateRoomRequested(this.playerName, {this.levelId = 1});
  @override
  List<Object?> get props => [playerName, levelId];
}

class JoinRoomRequested extends MultiplayerMenuEvent {
  final String roomCode;
  final String playerName;
  const JoinRoomRequested(this.roomCode, this.playerName);
  @override
  List<Object?> get props => [roomCode, playerName];
}

class ResetMenu extends MultiplayerMenuEvent {}

// STATE
enum MenuStatus { initial, loading, success, error }

class MultiplayerMenuState extends Equatable {
  final MenuStatus status;
  final String? roomCode;
  final String? errorMessage;

  const MultiplayerMenuState({
    this.status = MenuStatus.initial,
    this.roomCode,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, roomCode, errorMessage];
}

// BLOC
class MultiplayerMenuBloc
    extends Bloc<MultiplayerMenuEvent, MultiplayerMenuState> {
  final MultiplayerRepository _repo;

  MultiplayerMenuBloc(this._repo) : super(const MultiplayerMenuState()) {
    on<CreateRoomRequested>(_onCreateRoom);
    on<JoinRoomRequested>(_onJoinRoom);
    on<ResetMenu>(_onReset);
  }

  Future<void> _onCreateRoom(
    CreateRoomRequested event,
    Emitter<MultiplayerMenuState> emit,
  ) async {
    emit(const MultiplayerMenuState(status: MenuStatus.loading));
    try {
      final code = await _repo.createRoom(
        playerName: event.playerName,
        levelId: event.levelId,
      );
      emit(MultiplayerMenuState(status: MenuStatus.success, roomCode: code));
    } catch (e) {
      emit(
        MultiplayerMenuState(
          status: MenuStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onJoinRoom(
    JoinRoomRequested event,
    Emitter<MultiplayerMenuState> emit,
  ) async {
    emit(const MultiplayerMenuState(status: MenuStatus.loading));
    try {
      await _repo.joinRoom(
        roomCode: event.roomCode,
        playerName: event.playerName,
      );
      emit(
        MultiplayerMenuState(
          status: MenuStatus.success,
          roomCode: event.roomCode, // Normalized in repo usually
        ),
      );
    } catch (e) {
      emit(
        MultiplayerMenuState(
          status: MenuStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onReset(ResetMenu event, Emitter<MultiplayerMenuState> emit) {
    emit(const MultiplayerMenuState(status: MenuStatus.initial));
  }
}
