import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XoXo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Disable debug banner
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  AudioPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playSplashSound();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    });
  }

  Future<void> _playSplashSound() async {
    await _audioPlayer!.play(AssetSource('sounds/splash_sound.mp3')); // Add your sound file
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF468585),
      body: Stack(
        children: <Widget>[
          AnimatedBuilder(
            animation: _animationController!,
            builder: (context, child) {
              return CustomPaint(
                painter: FallingTextPainter(animation: _animationController!),
                child: Container(),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }
}

class FallingTextPainter extends CustomPainter {
  final Animation<double> animation;
  FallingTextPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 50,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: 'XoXo',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final double yPosition = animation.value * size.height;
    final offset = Offset(size.width / 2 - textPainter.width / 2, yPosition);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF468585),
      body: Column(
        children: <Widget>[
          SizedBox(height: 30),
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(20),
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HowToPlayPage()));
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Text color
              ),
              child: Text('How to Play', style: TextStyle(fontSize: 24),),
            ),
          ),

          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TicTacToeGame(isSinglePlayer: false)));
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Color(0xFF50B498), // Text color
                    ),
                    child: Text('Two Player', style: TextStyle(fontSize: 24),),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TicTacToeGame(isSinglePlayer: true)));
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Color(0xFF50B498), // Text color
                    ),
                    child: Text('One Player', style: TextStyle(fontSize: 24),),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HowToPlayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF468585),
      appBar: AppBar(
        backgroundColor: Color(0xFF468585),
        title: Text('How to Play', style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Rules:\n\n1. The game is played on a 3x3 grid.\n2. Player 1 is X, and Player 2 is O.\n3. Players take turns to mark a cell.\n4. The first player to get 3 of their marks in a row (horizontally, vertically, or diagonally) wins.\n5. If all cells are filled without a winner, the game is a draw.\n\nHave fun!',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  final bool isSinglePlayer;

  TicTacToeGame({required this.isSinglePlayer});

  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  bool _isGameOver = false;
  AudioPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF77B0AA),
      appBar: AppBar(
        backgroundColor: Color(0xFF77B0AA),
        title: Text('XoXo',style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0, // Space between cells
              mainAxisSpacing: 8.0, // Space between cells
            ),
            itemCount: 9,
            shrinkWrap: true,
            padding: EdgeInsets.all(16.0), // Padding around the grid
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _handleTap(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12), // Rounded edges
                  ),
                  child: Center(
                    child: Text(
                      _board[index],
                      style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  ),
                ),
              );
            },
          ),
          if (_isGameOver)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _checkWinner() + ' wins!',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
        ],
      ),
    );
  }

  void _handleTap(int index) {
    if (_board[index] == '' && !_isGameOver) {
      setState(() {
        _board[index] = _currentPlayer;
        if (_checkGameOver()) {
          _isGameOver = true;
          _playSound('lose_sound.mp3'); // Add your sound file
          Future.delayed(Duration(seconds: 4), () {
            Navigator.pop(context);
          });
        } else {
          _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
          if (widget.isSinglePlayer && _currentPlayer == 'O') {
            _aiMove();
          }
        }
      });
    }
  }

  bool _checkGameOver() {
    // Check rows, columns, and diagonals for a winner
    for (int i = 0; i < 3; i++) {
      if (_board[i * 3] != '' &&
          _board[i * 3] == _board[i * 3 + 1] &&
          _board[i * 3] == _board[i * 3 + 2]) {
        return true;
      }
      if (_board[i] != '' &&
          _board[i] == _board[i + 3] &&
          _board[i] == _board[i + 6]) {
        return true;
      }
    }
    if (_board[0] != '' &&
        _board[0] == _board[4] &&
        _board[0] == _board[8]) {
      return true;
    }
    if (_board[2] != '' &&
        _board[2] == _board[4] &&
        _board[2] == _board[6]) {
      return true;
    }
    if (!_board.contains('')) {
      return true; // Draw
    }
    return false;
  }

  void _aiMove() {
    List<int> emptyIndices = [];
    for (int i = 0; i < _board.length; i++) {
      if (_board[i] == '') {
        emptyIndices.add(i);
      }
    }
    if (emptyIndices.isNotEmpty) {
      int move = emptyIndices[Random().nextInt(emptyIndices.length)];
      setState(() {
        _board[move] = 'O';
        _currentPlayer = 'X';
        if (_checkGameOver()) {
          _isGameOver = true;
          _playSound('lose_sound.mp3'); // Add your sound file
          Future.delayed(Duration(seconds: 4), () {
            Navigator.pop(context);
          });
        }
      });
    }
  }

  String _checkWinner() {
    // Implement logic to determine winner
    for (int i = 0; i < 3; i++) {
      if (_board[i * 3] != '' &&
          _board[i * 3] == _board[i * 3 + 1] &&
          _board[i * 3] == _board[i * 3 + 2]) {
        return _board[i * 3];
      }
      if (_board[i] != '' &&
          _board[i] == _board[i + 3] &&
          _board[i] == _board[i + 6]) {
        return _board[i];
      }
    }
    if (_board[0] != '' &&
        _board[0] == _board[4] &&
        _board[0] == _board[8]) {
      return _board[0];
    }
    if (_board[2] != '' &&
        _board[2] == _board[4] &&
        _board[2] == _board[6]) {
      return _board[2];
    }
    return 'Draw';
  }

  Future<void> _playSound(String fileName) async {
    await _audioPlayer!.play(AssetSource('../assests/sounds/$fileName')); // Add your sound file
  }
}
