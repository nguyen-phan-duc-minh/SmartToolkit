import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Converter'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.compare_arrows),
              text: 'Unit Converter',
            ),
            Tab(
              icon: Icon(Icons.cake),
              text: 'Birthday',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UnitConverterTab(),
          BirthdayCalculatorTab(),
        ],
      ),
    );
  }
}

// Custom TextInputFormatter for thousands separator
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all commas
    String newText = newValue.text.replaceAll(',', '');

    // Check if it's a valid number
    if (double.tryParse(newText) == null && newText != '.') {
      return oldValue;
    }

    // Split by decimal point
    List<String> parts = newText.split('.');
    
    // Format the integer part
    String formatted = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    // Add decimal part if exists
    if (parts.length > 1) {
      formatted += '.${parts[1]}';
    } else if (newText.endsWith('.')) {
      formatted += '.';
    }

    // Calculate new cursor position
    int selectionIndex = newValue.selection.end;
    int oldCommaCount = oldValue.text.substring(0, oldValue.selection.end).split(',').length - 1;
    int newCommaCount = formatted.substring(0, selectionIndex).split(',').length - 1;
    selectionIndex += (newCommaCount - oldCommaCount);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex.clamp(0, formatted.length)),
    );
  }
}

// Unit Converter Tab
class UnitConverterTab extends StatefulWidget {
  const UnitConverterTab({super.key});

  @override
  State<UnitConverterTab> createState() => _UnitConverterTabState();
}

class _UnitConverterTabState extends State<UnitConverterTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final TextEditingController _inputController = TextEditingController();
  String _selectedCategory = 'Length';
  String _fromUnit = 'Meter';
  String _toUnit = 'Kilometer';
  double _result = 0.0;

  final Map<String, Map<String, double>> _conversions = {
    'Length': {
      'Meter': 1.0,
      'Kilometer': 0.001,
      'Centimeter': 100.0,
      'Millimeter': 1000.0,
      'Inch': 39.3701,
      'Foot': 3.28084,
      'Yard': 1.09361,
    },
    'Weight': {
      'Kilogram': 1.0,
      'Gram': 1000.0,
      'Pound': 2.20462,
      'Ounce': 35.274,
      'Ton': 0.001,
    },
    'Temperature': {
      'Celsius': 1.0,
      'Fahrenheit': 1.0,
      'Kelvin': 1.0,
    },
    'Currency': {
      'USD': 1.0,
      'EUR': 0.92,
      'GBP': 0.79,
      'JPY': 149.50,
      'CNY': 7.24,
      'VND': 25350.0,
      'KRW': 1310.0,
      'THB': 35.20,
      'SGD': 1.34,
      'AUD': 1.52,
    },
  };

  double _convertTemperature(double value, String from, String to) {
    if (from == to) return value;
    
    // Convert to Celsius first
    double celsius;
    if (from == 'Celsius') {
      celsius = value;
    } else if (from == 'Fahrenheit') {
      celsius = (value - 32) * 5 / 9;
    } else { // Kelvin
      celsius = value - 273.15;
    }
    
    // Convert from Celsius to target
    if (to == 'Celsius') {
      return celsius;
    } else if (to == 'Fahrenheit') {
      return celsius * 9 / 5 + 32;
    } else { // Kelvin
      return celsius + 273.15;
    }
  }

  void _convert() {
    String inputText = _inputController.text.replaceAll(',', '');
    double inputValue = double.tryParse(inputText) ?? 0.0;
    
    if (_selectedCategory == 'Temperature') {
      _result = _convertTemperature(inputValue, _fromUnit, _toUnit);
    } else {
      double inBaseUnit = inputValue / _conversions[_selectedCategory]![_fromUnit]!;
      _result = inBaseUnit * _conversions[_selectedCategory]![_toUnit]!;
    }
    setState(() {});
  }

  String _getResultDisplay() {
    final formatter = NumberFormat('#,##0.00');
    if (_selectedCategory == 'Currency') {
      return formatter.format(_result);
    }
    return _result.toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _conversions.keys.map((category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                      _fromUnit = _conversions[_selectedCategory]!.keys.first;
                      _toUnit = _conversions[_selectedCategory]!.keys.elementAt(1);
                    });
                    _convert();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _inputController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                        _ThousandsSeparatorInputFormatter(),
                      ],
                      decoration: InputDecoration(labelText: 'Enter value in $_fromUnit'),
                      onChanged: (value) => _convert(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _fromUnit,
                      decoration: const InputDecoration(labelText: 'From'),
                      items: _conversions[_selectedCategory]!.keys.map((unit) {
                        return DropdownMenuItem(value: unit, child: Text(unit));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _fromUnit = value!);
                        _convert();
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _toUnit,
                      decoration: const InputDecoration(labelText: 'To'),
                      items: _conversions[_selectedCategory]!.keys.map((unit) {
                        return DropdownMenuItem(value: unit, child: Text(unit));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _toUnit = value!);
                        _convert();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Result',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getResultDisplay(),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _toUnit,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}

// Birthday Calculator Tab
class BirthdayCalculatorTab extends StatefulWidget {
  const BirthdayCalculatorTab({super.key});

  @override
  State<BirthdayCalculatorTab> createState() => _BirthdayCalculatorTabState();
}

class _BirthdayCalculatorTabState extends State<BirthdayCalculatorTab> with AutomaticKeepAliveClientMixin {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _calculatedData;

  @override
  bool get wantKeepAlive => true;

  void _calculateAge() {
    final now = DateTime.now();
    final age = now.year - _selectedDate.year;
    final hasHadBirthdayThisYear = now.month > _selectedDate.month ||
        (now.month == _selectedDate.month && now.day >= _selectedDate.day);

    final actualAge = hasHadBirthdayThisYear ? age : age - 1;
    
    // Calculate next birthday
    DateTime nextBirthday = DateTime(_selectedDate.year + actualAge + 1, _selectedDate.month, _selectedDate.day);
    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(nextBirthday.year + 1, _selectedDate.month, _selectedDate.day);
    }
    
    final daysUntilBirthday = nextBirthday.difference(now).inDays;
    final totalDays = now.difference(_selectedDate).inDays;
    final totalWeeks = (totalDays / 7).floor();
    final totalMonths = actualAge * 12 + (now.month - _selectedDate.month);

    setState(() {
      _calculatedData = {
        'age': actualAge,
        'months': totalMonths,
        'weeks': totalWeeks,
        'days': totalDays,
        'nextBirthday': nextBirthday,
        'daysUntilBirthday': daysUntilBirthday,
        'dayOfWeek': _getDayOfWeek(_selectedDate.weekday),
        'zodiacSign': _getZodiacSign(_selectedDate.month, _selectedDate.day),
      };
    });
  }

  String _getDayOfWeek(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  String _getZodiacSign(int month, int day) {
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '♈ Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '♉ Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return '♊ Gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return '♋ Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '♌ Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '♍ Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return '♎ Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return '♏ Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return '♐ Sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return '♑ Capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '♒ Aquarius';
    return '♓ Pisces';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _calculateAge();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Card(
            child: InkWell(
              onTap: _selectDate,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.cake, size: 28, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Your Birthday',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
          ),
          
          if (_calculatedData != null) ...[
            const SizedBox(height: 6),
            
            // Age Card
            SizedBox(
              width: double.infinity,
              child: Card(
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        'You are',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_calculatedData!['age']} Years Old',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Details Grid
            SizedBox(
              height: 280,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.4,
              children: [
                _buildInfoCard(
                  'Months',
                  '${_calculatedData!['months']}',
                  Icons.calendar_month,
                  colorScheme,
                ),
                _buildInfoCard(
                  'Weeks',
                  '${_calculatedData!['weeks']}',
                  Icons.view_week,
                  colorScheme,
                ),
                _buildInfoCard(
                  'Days',
                  '${_calculatedData!['days']}',
                  Icons.today,
                  colorScheme,
                ),
                _buildInfoCard(
                  'Until Next',
                  '${_calculatedData!['daysUntilBirthday']} days',
                  Icons.celebration,
                  colorScheme,
                ),
              ],
            ),
            ),
            
            const SizedBox(height: 8),
            
            // Additional Info
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    _buildInfoRow('Born on', _calculatedData!['dayOfWeek'], Icons.calendar_today),
                    const Divider(height: 12),
                    _buildInfoRow('Zodiac Sign', _calculatedData!['zodiacSign'], Icons.stars),
                    const Divider(height: 12),
                    _buildInfoRow(
                      'Next Birthday',
                      '${(_calculatedData!['nextBirthday'] as DateTime).day}/${(_calculatedData!['nextBirthday'] as DateTime).month}/${(_calculatedData!['nextBirthday'] as DateTime).year}',
                      Icons.cake,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}