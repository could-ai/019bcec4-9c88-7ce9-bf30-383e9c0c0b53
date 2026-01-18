enum PositionType { buy, sell }

class Position {
  final int ticket;
  final String symbol;
  final int magicNumber;
  final PositionType type;
  final double volume;
  final double openPrice;
  final double currentPrice;
  final double profit;

  Position({
    required this.ticket,
    required this.symbol,
    required this.magicNumber,
    required this.type,
    required this.volume,
    required this.openPrice,
    required this.currentPrice,
    required this.profit,
  });
}
