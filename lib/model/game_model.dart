import 'cell_model.dart';

class GameModel {
  final int gridSize;
  final int gridSide;
  final int bombCount;

  List<CellModel> cells;

  GameModel({
    this.gridSize = 100,
    this.gridSide = 10,
    this.bombCount = 10,
  }) : cells = List.generate(100, (_) => CellModel());
}
