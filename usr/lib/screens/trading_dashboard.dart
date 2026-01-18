import 'package:flutter/material.dart';
import '../models/position.dart';
import '../services/mock_trading_service.dart';

class TradingDashboard extends StatefulWidget {
  const TradingDashboard({super.key});

  @override
  State<TradingDashboard> createState() => _TradingDashboardState();
}

class _TradingDashboardState extends State<TradingDashboard> {
  final MockTradingService _service = MockTradingService();
  late List<Position> _positions;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _positions = _service.positions;
    });
  }

  Future<void> _handleCloseAll(PositionType type) async {
    setState(() {
      _isLoading = true;
    });

    // Call the service which implements the logic from your MQL5 snippet
    await _service.closeAllPositions(type);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _refreshData();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Closed all ${type.name.toUpperCase()} positions for EURUSD (Magic: 123456)'),
          backgroundColor: type == PositionType.buy ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Bot Control'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _service.reset();
              _refreshData();
            },
            tooltip: 'Reset Mock Data',
          )
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSummaryCard(),
                Expanded(
                  child: _positions.isEmpty
                      ? const Center(child: Text('No open positions matching criteria'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _positions.length,
                          itemBuilder: (context, index) {
                            return _buildPositionCard(_positions[index]);
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: _buildControlPanel(),
    );
  }

  Widget _buildSummaryCard() {
    double totalProfit = _positions.fold(0, (sum, item) => sum + item.profit);
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      color: Colors.blueGrey[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text('Open Positions', style: TextStyle(color: Colors.white70)),
                Text('${_positions.length}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              children: [
                const Text('Total Profit', style: TextStyle(color: Colors.white70)),
                Text(
                  '\$${totalProfit.toStringAsFixed(2)}', 
                  style: TextStyle(
                    color: totalProfit >= 0 ? Colors.greenAccent : Colors.redAccent, 
                    fontSize: 24, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionCard(Position p) {
    bool isBuy = p.type == PositionType.buy;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isBuy ? Colors.green[100] : Colors.red[100],
          child: Icon(
            isBuy ? Icons.arrow_upward : Icons.arrow_downward,
            color: isBuy ? Colors.green : Colors.red,
          ),
        ),
        title: Text('${p.symbol} ${isBuy ? 'BUY' : 'SELL'} ${p.volume}'),
        subtitle: Text('Ticket: ${p.ticket} | Magic: ${p.magicNumber}'),
        trailing: Text(
          '\$${p.profit.toStringAsFixed(2)}',
          style: TextStyle(
            color: p.profit >= 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleCloseAll(PositionType.buy),
                icon: const Icon(Icons.close),
                label: const Text('CLOSE ALL BUY'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleCloseAll(PositionType.sell),
                icon: const Icon(Icons.close),
                label: const Text('CLOSE ALL SELL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
