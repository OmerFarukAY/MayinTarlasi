import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../model/game_model.dart';

class GameViewModel extends ChangeNotifier {
  late GameModel gameModel;

  bool bayrakModu = false;
  bool gameStarted = false;
  int elapsedSeconds = 0;
  Timer? timer;

  GameViewModel() {
    resetGame();
  }

  void resetGame() {
    timer?.cancel();
    gameModel = GameModel();
    bayrakModu = false;
    gameStarted = false;
    elapsedSeconds = 0;
    notifyListeners();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      elapsedSeconds++;
      notifyListeners();
    });
  }

  void placeBombs({int? safeIndex}) {
    int bombsPlaced = 0;
    final random = Random();

    while (bombsPlaced < gameModel.bombCount) {
      int index = random.nextInt(gameModel.gridSize);

      if (!gameModel.cells[index].isBomb && index != safeIndex) {
        gameModel.cells[index].isBomb = true;
        bombsPlaced++;
      }
    }
  }

  int getNeighborBombCount(int index) {
    int count = 0;
    int row = index ~/ gameModel.gridSide;
    int col = index % gameModel.gridSide;

    for (int i = row - 1; i <= row + 1; i++) {
      for (int j = col - 1; j <= col + 1; j++) {
        if (i < 0 || i >= gameModel.gridSide || j < 0 || j >= gameModel.gridSide) continue;
        if (i == row && j == col) continue;

        int neighborIndex = i * gameModel.gridSide + j;
        if (gameModel.cells[neighborIndex].isBomb) count++;
      }
    }
    return count;
  }

  void revealTile(int index) {
    if (!gameModel.cells[index].isVisible || gameModel.cells[index].isFlagged) return;

    gameModel.cells[index].isVisible = false;

    int bombCount = getNeighborBombCount(index);
    if (bombCount == 0) {
      int row = index ~/ gameModel.gridSide;
      int col = index % gameModel.gridSide;

      for (int r = row - 1; r <= row + 1; r++) {
        for (int c = col - 1; c <= col + 1; c++) {
          if (r < 0 || r >= gameModel.gridSide || c < 0 || c >= gameModel.gridSide) continue;
          int neighborIndex = r * gameModel.gridSide + c;

          if (neighborIndex != index) {
            revealTile(neighborIndex);
          }
        }
      }
    }
  }

  bool checkWin() {
    int revealedCount = gameModel.cells.where((c) => !c.isVisible).length;
    if (revealedCount == gameModel.gridSize - gameModel.bombCount) {
      timer?.cancel();
      return true;
    }
    return false;
  }

  void onTileTap(int index) {
    if (!gameStarted) {
      gameStarted = true;
      placeBombs(safeIndex: index);
      startTimer();
    }

    if (bayrakModu) {
      gameModel.cells[index].isFlagged = !gameModel.cells[index].isFlagged;
    } else {
      if (gameModel.cells[index].isFlagged || !gameModel.cells[index].isVisible) return;

      if (gameModel.cells[index].isBomb) {
        timer?.cancel();

        for (var cell in gameModel.cells) {
          if (cell.isBomb) cell.isVisible = false;
        }
      } else {
        revealTile(index);
        if (checkWin()) {
          timer?.cancel();
        }
      }
    }

    notifyListeners();
  }
/*
butonla bayrak modu kontrolü
  void toggleFlagMode() {
    bayrakModu = !bayrakModu;
    notifyListeners();
  }

 */
  //yeni ekledim. Basılı tutarak bayrak kodu kontrolü.
  void placeFlagOnTile(int index) {
    if (gameModel.cells[index].isVisible) {
      gameModel.cells[index].isFlagged = !gameModel.cells[index].isFlagged;
      notifyListeners();
    }
  }

  int get remainingFlags {
    return gameModel.bombCount -
        gameModel.cells.where((c) => c.isFlagged).length;
  }
}
