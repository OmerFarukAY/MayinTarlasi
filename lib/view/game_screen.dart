import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/game_view_model.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameViewModel>(
      create: (_) => GameViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Mayın Tarlası'),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: Consumer<GameViewModel>(
          builder: (context, gameVM, _) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.flag, color: Colors.red, size: 32),
                          SizedBox(width: 8),
                          Text(
                            '${gameVM.remainingFlags}',
                            style: TextStyle(color: Colors.red, fontSize: 32),
                          ),
                        ],
                      ),
                      Text(
                        'Süre: ${gameVM.elapsedSeconds}',
                        style: TextStyle(color: Colors.blue, fontSize: 32),
                      ),

                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gameVM.gameModel.gridSide,
                    ),
                    itemCount: gameVM.gameModel.gridSize,
                    itemBuilder: (context, index) {
                      final cell = gameVM.gameModel.cells[index];
                      int row = index ~/ gameVM.gameModel.gridSide;
                      int col = index % gameVM.gameModel.gridSide;
                      bool isEven = (row + col) % 2 == 0;
                      Color color = isEven ? Colors.green.shade600 : Colors.green.shade400;

                      if (!cell.isVisible) {
                        int bombCount = gameVM.getNeighborBombCount(index);
                        return Container(
                          color: Colors.green[200],
                          child: Center(
                            child: bombCount > 0
                                ? Text(
                              '$bombCount',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            )
                                : null,
                          ),
                        );
                      }

                      return GestureDetector(
                        onTap: () {
                          gameVM.onTileTap(index);
                          if (cell.isBomb && !cell.isVisible) {
                            _showGameOverDialog(context, gameVM.elapsedSeconds, gameVM);
                          } else if (gameVM.checkWin()) {
                            _showGameWonDialog(context, gameVM.elapsedSeconds, gameVM);

                          }
                        },
                        child: Container(
                          color: color,
                          child: cell.isFlagged
                              ? Center(child: Icon(Icons.flag, color: Colors.red))
                              : null,
                        ),
                        onLongPress:(){
                          gameVM.placeFlagOnTile(index);
                      },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, int elapsedSeconds, GameViewModel gameVM) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('💥 Patladın!'),
        content: Text('Oyunu kaybettin. Süre: $elapsedSeconds saniye.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              gameVM.resetGame();
            },
            child: Text('Yeniden Başla'),
          ),
        ],
      ),
    );
  }

  void _showGameWonDialog(BuildContext context, int elapsedSeconds, GameViewModel gameVM) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('🏆 Tebrikler!'),
        content: Text('Oyunu $elapsedSeconds saniyede kazandın!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              gameVM.resetGame();
            },
            child: Text('Yeniden Oyna'),
          ),
        ],
      ),
    );
  }
}
