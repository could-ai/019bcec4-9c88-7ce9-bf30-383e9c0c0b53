import 'dart:async';
import 'dart:math';
import '../models/position.dart';

class MockTradingService {
  // Singleton pattern
  static final MockTradingService _instance = MockTradingService._internal();
  factory MockTradingService() => _instance;
  MockTradingService._internal() {
    _generateMockPositions();
  }

  List<Position> _positions = [];
  final int _magicNumber = 123456;
  final String _currentSymbol = 'EURUSD';

  List<Position> get positions => List.unmodifiable(_positions);

  // Generate some dummy data
  void _generateMockPositions() {
    final random = Random();
    _positions = List.generate(10, (index) {
      bool isBuy = random.nextBool();
      double open = 1.1000 + (random.nextDouble() * 0.0500);
      double current = 1.1000 + (random.nextDouble() * 0.0500);
      double vol = (random.nextInt(10) + 1) / 10.0;
      
      return Position(
        ticket: 1000 + index,
        symbol: index % 2 == 0 ? 'EURUSD' : 'GBPUSD', // Mix symbols to test filtering
        magicNumber: index % 3 == 0 ? 999999 : _magicNumber, // Mix magic numbers
        type: isBuy ? PositionType.buy : PositionType.sell,
        volume: vol,
        openPrice: open,
        currentPrice: current,
        profit: (isBuy ? (current - open) : (open - current)) * vol * 100000,
      );
    });
  }

  // Dart equivalent of the MQL5 CloseAllPositions function
  Future<void> closeAllPositions(PositionType type) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // MQL5 Logic Translation:
    // for(int i = PositionsTotal() - 1; i >= 0; i--) ...
    // if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
    //    PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
    //    PositionGetInteger(POSITION_TYPE) == positionType)
    
    _positions.removeWhere((p) {
      bool shouldClose = p.symbol == _currentSymbol && 
                         p.magicNumber == _magicNumber && 
                         p.type == type;
      return shouldClose;
    });
  }

  // Helper to reset data for testing
  void reset() {
    _generateMockPositions();
  }
}
