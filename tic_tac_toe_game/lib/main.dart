import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// PUBLIC_INTERFACE
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Light, minimal color scheme as specified.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TicTacToe Classic',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: Colors.white, // #fff
          onPrimary: Color(0xFF222222), // #222
          secondary: Color(0xFF222222), // #222
          onSecondary: Colors.white,
          tertiary: Color(0xff4caf50), // Accent
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF222222)),
          bodyMedium: TextStyle(color: Color(0xFF222222)),
        ),
      ),
      home: const TicTacToeGame(),
    );
  }
}

// PUBLIC_INTERFACE
class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

enum Player { X, O }

// PUBLIC_INTERFACE
class _TicTacToeGameState extends State<TicTacToeGame> {
  static const int gridSize = 3;
  static const Color accent = Color(0xff4caf50);
  static const Color primary = Colors.white;
  static const Color secondary = Color(0xFF222222);

  List<List<Player?>> board = List.generate(gridSize, (_) => List.filled(gridSize, null));
  Player currentPlayer = Player.X;
  bool gameOver = false;
  String resultMessage = '';

  // PUBLIC_INTERFACE
  void _resetGame() {
    setState(() {
      board = List.generate(gridSize, (_) => List.filled(gridSize, null));
      currentPlayer = Player.X;
      gameOver = false;
      resultMessage = '';
    });
  }

  // PUBLIC_INTERFACE
  void _handleTap(int row, int col) {
    if (board[row][col] != null || gameOver) {
      return;
    }
    setState(() {
      board[row][col] = currentPlayer;
      if (_checkWinner(row, col, currentPlayer)) {
        gameOver = true;
        resultMessage = 'Player ${_playerSymbol(currentPlayer)} wins!';
      } else if (_isDraw()) {
        gameOver = true;
        resultMessage = 'It\'s a draw!';
      } else {
        currentPlayer = currentPlayer == Player.X ? Player.O : Player.X;
      }
    });
  }

  // PUBLIC_INTERFACE
  String _playerSymbol(Player? player) {
    if (player == Player.X) return 'X';
    if (player == Player.O) return 'O';
    return '';
  }

  // PUBLIC_INTERFACE
  bool _checkWinner(int row, int col, Player player) {
    // Check row
    if (board[row].every((cell) => cell == player)) return true;
    // Check column
    if (List.generate(gridSize, (i) => board[i][col]).every((cell) => cell == player)) return true;
    // Check diagonal (top-left to bottom-right)
    if (row == col && List.generate(gridSize, (i) => board[i][i]).every((cell) => cell == player))
      return true;
    // Check anti-diagonal
    if (row + col == gridSize - 1 &&
        List.generate(gridSize, (i) => board[i][gridSize - i - 1]).every((cell) => cell == player))
      return true;
    return false;
  }

  // PUBLIC_INTERFACE
  bool _isDraw() {
    for (final row in board) {
      if (row.contains(null)) return false;
    }
    return true;
  }

  // PUBLIC_INTERFACE
  Widget _buildCell(int row, int col) {
    final symbol = _playerSymbol(board[row][col]);
    final textColor = symbol == 'X' ? secondary : accent;

    return GestureDetector(
      onTap: () => _handleTap(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: primary,
          border: Border.all(color: secondary.withOpacity(0.15), width: 1.5),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 170),
            child: symbol.isNotEmpty
                ? Text(
                    symbol,
                    key: ValueKey(symbol),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: 2.5,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  // PUBLIC_INTERFACE
  Widget _buildBoard() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(gridSize, (row) {
            return Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(gridSize, (col) {
                  return Expanded(child: _buildCell(row, col));
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  // PUBLIC_INTERFACE
  Widget _buildPlayerIndicator() {
    if (gameOver) return const SizedBox(height: 28);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text.rich(
        TextSpan(
          text: 'Turn: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: secondary,
          ),
          children: [
            TextSpan(
              text: _playerSymbol(currentPlayer),
              style: TextStyle(
                color: currentPlayer == Player.X ? secondary : accent,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
              ),
            )
          ],
        ),
      ),
    );
  }

  // PUBLIC_INTERFACE
  Widget _buildResultMessage() {
    if (resultMessage.isEmpty) return const SizedBox(height: 22);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        resultMessage,
        style: TextStyle(
          fontSize: 24,
          color: resultMessage.contains('wins') ? accent : secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // PUBLIC_INTERFACE
  Widget _buildResetButton() {
    return FilledButton.icon(
      onPressed: _resetGame,
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      icon: const Icon(Icons.refresh),
      label: const Text('Reset'),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Centered layout, minimal, light theme as requested
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primary,
        title: const Text(
          'TicTacToe Classic',
          style: TextStyle(
            color: secondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 380,
              minHeight: 450,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 22),
                _buildPlayerIndicator(),
                _buildBoard(),
                _buildResultMessage(),
                _buildResetButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
