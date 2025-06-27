class CellModel {
  bool isBomb;
  bool isVisible;
  bool isFlagged;

  CellModel({
    this.isBomb = false,
    this.isVisible = true,
    this.isFlagged = false,
  });
}
