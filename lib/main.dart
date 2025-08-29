import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const XOflutterApp());
}

class XOflutterApp extends StatelessWidget {
  const XOflutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XOflutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(primaryColor: Colors.blueAccent),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  String winner = '';
  List<int> winningLine = [];

  int xScore = 0;
  int oScore = 0;
  int draws = 0;

  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 2),
  );

  final List<List<int>> winPatterns = const [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _resetBoard() {
    setState(() {
      board = List.filled(9, '');
      winner = '';
      winningLine = [];
      currentPlayer = 'X';
    });
  }

  void _resetScores() {
    setState(() {
      xScore = 0;
      oScore = 0;
      draws = 0;
      _resetBoard();
    });
  }

  void _makeMove(int index) {
    if (board[index] != '' || winner.isNotEmpty) return;

    setState(() {
      board[index] = currentPlayer;

      if (_checkWinner(currentPlayer)) {
        winner = currentPlayer;
        winningLine = _getWinningLine(currentPlayer);
        if (winner == 'X') xScore++;
        if (winner == 'O') oScore++;
        _confettiController.play();
      } else if (!board.contains('')) {
        winner = 'Draw';
        draws++;
      } else {
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      }
    });
  }

  bool _checkWinner(String player) {
    for (var pattern in winPatterns) {
      if (board[pattern[0]] == player &&
          board[pattern[1]] == player &&
          board[pattern[2]] == player) {
        return true;
      }
    }
    return false;
  }

  List<int> _getWinningLine(String player) {
    for (var pattern in winPatterns) {
      if (board[pattern[0]] == player &&
          board[pattern[1]] == player &&
          board[pattern[2]] == player) {
        return pattern;
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('XOflutter'), centerTitle: true),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              // Player indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPlayerIndicator('X', xScore, Colors.redAccent),
                  _buildPlayerIndicator('O', oScore, Colors.yellowAccent),
                ],
              ),
              const SizedBox(height: 20),

              // Status text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  winner.isEmpty
                      ? 'Current Player: $currentPlayer'
                      : (winner == 'Draw' ? "It's a Draw!" : "$winner Wins!"),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Board
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    itemCount: 9,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemBuilder: (context, index) {
                      final isWinningCell = winningLine.contains(index);
                      return GestureDetector(
                        onTap: () => _makeMove(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: isWinningCell
                                ? Colors.green.withOpacity(0.7)
                                : Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.8),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              board[index],
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: board[index] == 'X'
                                    ? Colors.redAccent
                                    : Colors.yellowAccent,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Draws counter
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Draws: $draws',
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              // Buttons row
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _resetBoard,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Restart Game"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _resetScores,
                      icon: const Icon(Icons.restore),
                      label: const Text("Reset Scores"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerIndicator(String player, int wins, Color color) {
    final bool isActive = currentPlayer == player && winner.isEmpty;

    return AnimatedScale(
      scale: isActive ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey.shade800 : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : Colors.grey.shade600,
            width: 3,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 12)]
              : [],
        ),
        child: Column(
          children: [
            Text(
              player,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text('Wins: $wins', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
