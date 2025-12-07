import 'package:flutter/material.dart';
import 'dart:async';
import 'package:smarttoolkit/core/services/notification_service.dart';

class CountdownTimerScreen extends StatefulWidget {
  const CountdownTimerScreen({super.key});

  @override
  State<CountdownTimerScreen> createState() => _CountdownTimerScreenState();
}

class _CountdownTimerScreenState extends State<CountdownTimerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Countdown Timer state
  Timer? _timer;
  int _hours = 0;
  int _minutes = 5;
  int _seconds = 0;
  bool _isRunning = false;
  int _totalSeconds = 300;
  
  // Stopwatch state
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _stopwatchTimer;
  String _timeDisplay = '00:00:00';

  final FixedExtentScrollController _hoursController = FixedExtentScrollController();
  final FixedExtentScrollController _minutesController = FixedExtentScrollController(initialItem: 5);
  final FixedExtentScrollController _secondsController = FixedExtentScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _hoursController.addListener(_updateFromScrollers);
    _minutesController.addListener(_updateFromScrollers);
    _secondsController.addListener(_updateFromScrollers);
  }

  void _updateFromScrollers() {
    if (!_isRunning) {
      setState(() {
        if (_hoursController.hasClients && _hoursController.selectedItem >= 0) {
          _hours = _hoursController.selectedItem;
        }
        if (_minutesController.hasClients && _minutesController.selectedItem >= 0) {
          _minutes = _minutesController.selectedItem;
        }
        if (_secondsController.hasClients && _secondsController.selectedItem >= 0) {
          _seconds = _secondsController.selectedItem;
        }
      });
    }
  }

  void _startTimer() {
    _totalSeconds = (_hours * 3600) + (_minutes * 60) + _seconds;
    if (_totalSeconds == 0) return;
    
    setState(() {
      _isRunning = true;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSeconds > 0) {
        setState(() {
          _totalSeconds--;
          _hours = _totalSeconds ~/ 3600;
          _minutes = (_totalSeconds % 3600) ~/ 60;
          _seconds = _totalSeconds % 60;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
        
        NotificationService.showNotification(
          id: 1,
          title: 'Timer Finished!',
          body: 'Your countdown timer has reached zero.',
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timer finished!')),
        );
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _hours = 0;
      _minutes = 5;
      _seconds = 0;
      _totalSeconds = 300;
    });
    
    if (_hoursController.hasClients) {
      _hoursController.jumpToItem(0);
    }
    if (_minutesController.hasClients) {
      _minutesController.jumpToItem(5);
    }
    if (_secondsController.hasClients) {
      _secondsController.jumpToItem(0);
    }
  }

  // Stopwatch methods
  void _startStopwatchTimer() {
    _stopwatchTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _timeDisplay = _formatTime(_stopwatch.elapsedMilliseconds);
      });
      
      // Notify every minute milestone
      final seconds = _stopwatch.elapsedMilliseconds ~/ 1000;
      if (seconds > 0 && seconds % 60 == 0 && _stopwatch.elapsedMilliseconds % 1000 < 100) {
        final minutes = seconds ~/ 60;
        NotificationService.showNotification(
          id: 2,
          title: 'Stopwatch Milestone',
          body: 'Running for $minutes minute${minutes > 1 ? 's' : ''}!',
        );
      }
    });
  }

  void _startStopwatch() {
    _stopwatch.start();
    _startStopwatchTimer();
  }

  void _stopStopwatch() {
    _stopwatch.stop();
    _stopwatchTimer?.cancel();
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    _stopwatchTimer?.cancel();
    setState(() {
      _timeDisplay = '00:00:00';
    });
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    
    return '$minutesStr:$secondsStr:$hundredsStr';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel();
    _stopwatchTimer?.cancel();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer & Stopwatch'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Timer', icon: Icon(Icons.timer)),
            Tab(text: 'Stopwatch', icon: Icon(Icons.timer_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTimerTab(),
          _buildStopwatchTab(),
        ],
      ),
    );
  }

  Widget _buildTimerTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${_hours.toString().padLeft(2, '0')}:${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontFamily: 'monospace',
              fontSize: 48,
            ),
          ),
          const SizedBox(height: 50),
          if (!_isRunning) ...[
            Container(
              height: 150,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildScrollPicker(
                      controller: _hoursController,
                      label: 'Hours',
                      maxValue: 23,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildScrollPicker(
                      controller: _minutesController,
                      label: 'Minutes',
                      maxValue: 59,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildScrollPicker(
                      controller: _secondsController,
                      label: 'Seconds',
                      maxValue: 59,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _isRunning ? _stopTimer : _startTimer,
                icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                label: Text(_isRunning ? 'Stop' : 'Start'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStopwatchTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _timeDisplay,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontFamily: 'monospace',
              fontSize: 48,
            ),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _stopwatch.isRunning ? _stopStopwatch : _startStopwatch,
                icon: Icon(_stopwatch.isRunning ? Icons.stop : Icons.play_arrow),
                label: Text(_stopwatch.isRunning ? 'Stop' : 'Start'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _resetStopwatch,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScrollPicker({
    required FixedExtentScrollController controller,
    required String label,
    required int maxValue,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 50,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: maxValue + 1,
              builder: (context, index) {
                final isSelected = controller.hasClients && 
                    controller.selectedItem == index;
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: isSelected ? 32 : 24,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}