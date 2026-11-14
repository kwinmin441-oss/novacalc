import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.instance.initialize();
  runApp(const NovaCalcApp());
}

class NovaCalcApp extends StatefulWidget {
  const NovaCalcApp({super.key});

  @override
  State<NovaCalcApp> createState() => _NovaCalcAppState();
}

class _NovaCalcAppState extends State<NovaCalcApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    const neon = Color(0xFF00D9FF);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NovaCalc',
      themeMode: _themeMode,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: neon,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF080D18),
        cardColor: const Color(0xFF121C2D),
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: neon),
      ),
      home: NovaHomePage(
        isDark: _themeMode == ThemeMode.dark,
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}

class NovaHomePage extends StatefulWidget {
  const NovaHomePage({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  final bool isDark;
  final VoidCallback onThemeChanged;

  @override
  State<NovaHomePage> createState() => _NovaHomePageState();
}

class _NovaHomePageState extends State<NovaHomePage> {
  static const neon = Color(0xFF00D9FF);
  static const purple = Color(0xFF9B72FF);

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  String _expression = '';
  String _result = '0';
  int _selectedTab = 0;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final saved = await _prefs.getStringList('calculation_history') ?? [];
    if (mounted) setState(() => _history = saved);
  }

  Future<void> _saveHistory() async {
    await _prefs.setStringList('calculation_history', _history);
  }

  void _press(String value) {
    setState(() {
      switch (value) {
        case 'AC':
          _expression = '';
          _result = '0';
          break;
        case 'DEL':
          if (_expression.isNotEmpty) {
            _expression = _expression.substring(0, _expression.length - 1);
          }
          break;
        case '=':
          _calculate();
          break;
        default:
          if (_expression.length < 80) _expression += value;
      }
    });
  }

  void _calculate() {
    if (_expression.trim().isEmpty) return;
    try {
      final normalized = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('−', '-')
          .replaceAll('π', 'pi')
          .replaceAll('%', '/100');

      final parsed = GrammarParser().parse(normalized);
     
final value = parsed.evaluate(EvaluationType.REAL, ContextModel()) as num;


      if (!value.isFinite) {
        _result = 'Undefined';
        return;
      }

      final formatted = value == value.roundToDouble()
          ? value.toInt().toString()
          : value.toStringAsPrecision(10).replaceFirst(RegExp(r'0+$'), '');

      _result = formatted;
      _history.insert(0, '$_expression = $_result');
      if (_history.length > 100) {
        _history = _history.take(100).toList();
      }
      _saveHistory();
    } catch (_) {
      _result = 'Invalid expression';
    }
  }

  void _selectHistory(String item) {
    final parts = item.split(' = ');
    if (parts.length < 2) return;
    setState(() {
      _expression = parts.first;
      _result = parts.last;
      _selectedTab = 0;
    });
  }

  Future<void> _clearHistory() async {
    setState(() => _history = []);
    await _prefs.remove('calculation_history');
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _calculatorPage(),
      _toolsPage(),
      _historyPage(),
      _settingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.blur_on, color: neon, size: 28),
            SizedBox(width: 9),
            Text('NovaCalc', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Text(
              'PRO',
              style: TextStyle(
                fontSize: 10,
                color: neon,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: widget.onThemeChanged,
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: pages[_selectedTab]),
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: NovaBannerAd(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) =>
            setState(() => _selectedTab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Tools',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _calculatorPage() {
    const buttons = [
      ['AC', 'DEL', '(', ')'],
      ['7', '8', '9', '÷'],
      ['4', '5', '6', '×'],
      ['1', '2', '3', '−'],
      ['0', '.', '%', '+'],
      ['sin(', 'cos(', 'tan(', '='],
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
      
Expanded(
  flex: 3,
  child: LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxHeight < 160;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(compact ? 8 : 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF14253C),
              Color(0xFF10152A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: neon.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'SMART CALCULATOR',
              style: TextStyle(
                color: neon,
                fontSize: compact ? 9 : 11,
                letterSpacing: compact ? 1 : 2,
              ),
            ),
            SizedBox(height: compact ? 4 : 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                _expression.isEmpty ? '0' : _expression,
                style: TextStyle(
                  fontSize: compact ? 18 : 28,
                  color: Colors.white70,
                ),
              ),
            ),
            SizedBox(height: compact ? 4 : 14),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _result,
                style: TextStyle(
                  fontSize: compact ? 28 : 42,
                  fontWeight: FontWeight.bold,
                  color: neon,
                ),
              ),
            ),
          ],
        ),
      );
    },
  ),
),

          const SizedBox(height: 16),
          Expanded(
            flex: 5,
            child: Column(
              children: buttons
                  .map(
                    (row) => Expanded(
                      child: Row(
                        children: row
                            .map(
                              (value) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: _keyButton(value),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _keyButton(String value) {
    final isEqual = value == '=';
    final isAction =
        ['AC', 'DEL', '÷', '×', '−', '+', '%'].contains(value);

    return Material(
      color: isEqual
          ? neon
          : isAction
              ? purple.withValues(alpha: 0.18)
              : const Color(0xFF142034),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _press(value),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              fontSize: value.length > 3 ? 15 : 22,
              fontWeight: FontWeight.w600,
              color: isEqual
                  ? const Color(0xFF07111E)
                  : isAction
                      ? neon
                      : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolsPage() {
    const tools = [
      ('Percentage Calculator', Icons.percent),
      ('Discount Calculator', Icons.discount_outlined),
      ('Loan & EMI Calculator', Icons.account_balance_outlined),
      ('Tip & Split Bill', Icons.receipt_long),
      ('Unit Converter', Icons.swap_horiz),
      ('Currency Converter', Icons.currency_exchange),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Smart Tools',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Explore useful calculation tools.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ...tools.map(
          (tool) => Card(
            child: ListTile(
              leading: Icon(tool.$2, color: neon),
              title: Text(tool.$1),
              trailing: const Icon(Icons.arrow_forward_ios, size: 15),
              onTap: () => _showToolMessage(tool.$1),
            ),
          ),
        ),
      ],
    );
  }

  void _showToolMessage(String name) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: const Text(
          'This tool is planned for a future NovaCalc update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _historyPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'History',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: _history.isEmpty ? null : _clearHistory,
                child: const Text('Clear all'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _history.isEmpty
                ? const Center(
                    child: Text(
                      'No calculations yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.history, color: neon),
                        title: Text(_history[index]),
                        onTap: () => _selectHistory(_history[index]),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _settingsPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Use the futuristic dark appearance'),
          value: widget.isDark,
          onChanged: (_) => widget.onThemeChanged(),
        ),
        const ListTile(
          leading: Icon(Icons.language),
          title: Text('App Language'),
          subtitle: Text('English'),
        ),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('About NovaCalc'),
          subtitle: Text('Version 1.0.0'),
        ),
        const ListTile(
          leading: Icon(Icons.privacy_tip_outlined),
          title: Text('Privacy'),
          subtitle: Text('Privacy policy required before release'),
        ),
      ],
    );
  }
}
