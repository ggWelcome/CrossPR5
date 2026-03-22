import 'dart:async'; // Для роботи з асинхронними таймерами
import 'dart:math';  // Для генерації випадкових чисел
import 'package:flutter/material.dart'; // Основна бібліотека Flutter для UI
import 'package:fl_chart/fl_chart.dart'; // Бібліотека для побудови графіків

void main() {
  runApp(SmartGridApp()); // Запуск головного застосунку
}

// Головний клас застосунку
class SmartGridApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Grid', // Назва застосунку
      theme: ThemeData(primarySwatch: Colors.blue), // Тема оформлення
      home: DeviceInputPage(), // Стартова сторінка
    );
  }
}

// Клас Device моделює пристрій у системі
class Device {
  String name;
  double power;
  double hours;
  String energyType;

  // Конструктор
  Device(this.name, this.power, this.hours, this.energyType);

  // Метод для розрахунку добового споживання
  double getConsumption() {
    return power * hours;
  }
}

// Сторінка введення параметрів пристроїв
class DeviceInputPage extends StatefulWidget {
  @override
  _DeviceInputPageState createState() => _DeviceInputPageState();
}

class _DeviceInputPageState extends State<DeviceInputPage> {
  // Контролери для введення даних
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _powerController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();

  // Тип енергії за замовчуванням
  String _selectedEnergyType = "electric";

  // Список пристроїв
  List<Device> devices = [];

  // Метод для додавання пристрою
  void _addDevice() {
    String name = _nameController.text;
    double power = double.tryParse(_powerController.text) ?? 0;
    double hours = double.tryParse(_hoursController.text) ?? 0;

    Device device = Device(name, power, hours, _selectedEnergyType);

    setState(() {
      devices.add(device);
      _nameController.clear();
      _powerController.clear();
      _hoursController.clear();
    });
  }

  // Перехід на екран результатів
  void _goToResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(devices: devices),
      ),
    );
  }

  // Перехід на екран моніторингу
  void _goToMonitoring() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonitoringPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Smart Grid - Введення пристроїв")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Поля для введення параметрів
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Назва пристрою"),
            ),
            TextField(
              controller: _powerController,
              decoration: InputDecoration(labelText: "Потужність (Вт)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _hoursController,
              decoration: InputDecoration(labelText: "Час роботи (год)"),
              keyboardType: TextInputType.number,
            ),
            // Вибір типу енергії
            DropdownButton<String>(
              value: _selectedEnergyType,
              items: [
                DropdownMenuItem(value: "electric", child: Text("Електрична")),
                DropdownMenuItem(value: "thermal", child: Text("Теплова")),
                DropdownMenuItem(value: "solar", child: Text("Сонячна")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedEnergyType = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _addDevice, child: Text("Додати пристрій")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _goToResults, child: Text("Перейти до результатів")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _goToMonitoring, child: Text("Моніторинг сенсорів")),
            SizedBox(height: 20),
            // Список доданих пристроїв
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final d = devices[index];
                  return ListTile(
                    title: Text("${d.name} (${d.energyType})"),
                    subtitle: Text("Потужність: ${d.power} Вт, Час: ${d.hours} год, Споживання: ${d.getConsumption()} Вт·год"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Сторінка результатів
class ResultsPage extends StatelessWidget {
  final List<Device> devices;

  ResultsPage({required this.devices});

  @override
  Widget build(BuildContext context) {
    double electricConsumption = 0;
    double thermalConsumption = 0;
    double solarConsumption = 0;

    // Підрахунок споживання по типах енергії
    for (var d in devices) {
      double consumption = d.getConsumption();
      if (d.energyType == "electric") {
        electricConsumption += consumption;
      } else if (d.energyType == "thermal") {
        thermalConsumption += consumption;
      } else if (d.energyType == "solar") {
        solarConsumption += consumption;
      }
    }

    double totalConsumption = electricConsumption + thermalConsumption + solarConsumption;

    return Scaffold(
      appBar: AppBar(title: Text("Smart Grid - Результати")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final d = devices[index];
                  return ListTile(
                    title: Text("${d.name} (${d.energyType})"),
                    subtitle: Text("Потужність: ${d.power} Вт, Час: ${d.hours} год, Споживання: ${d.getConsumption()} Вт·год"),
                  );
                },
              ),
            ),
            Text(
              "Електрична енергія: $electricConsumption Вт·год\n"
              "Теплова енергія: $thermalConsumption Вт·год\n"
              "Сонячна енергія: $solarConsumption Вт·год\n"
              "Загальне споживання: $totalConsumption Вт·год",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// Сторінка моніторингу сенсорів
class MonitoringPage extends StatefulWidget {
  @override
  _MonitoringPageState createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  // Списки даних для кожного типу енергії (точки для графіка)
  List<FlSpot> solarData = [];
  List<FlSpot> electricData = [];
  List<FlSpot> thermalData = [];

  int time = 0; // Лічильник часу (ось X для графіка)
  Timer? timer; // Таймер для асинхронної генерації даних
  Random random = Random(); // Генератор випадкових чисел (імітація сенсорів)

  @override
  void initState() {
    super.initState();
    // Запускаємо таймер, який кожні 2 секунди додає нові дані
    timer = Timer.periodic(Duration(seconds: 2), (t) {
      setState(() {
        time++; // збільшуємо час на 1 крок
        // Генеруємо випадкові значення для кожного типу енергії
        solarData.add(FlSpot(time.toDouble(), random.nextDouble() * 100));
        electricData.add(FlSpot(time.toDouble(), random.nextDouble() * 200));
        thermalData.add(FlSpot(time.toDouble(), random.nextDouble() * 150));
      });
    });
  }

  @override
  void dispose() {
    // Зупиняємо таймер при закритті сторінки, щоб не витрачати ресурси
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Верхня панель із заголовком
      appBar: AppBar(title: Text("Smart Grid - Моніторинг")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(show: true), // Відображення підписів осей
            lineBarsData: [
              // Лінія для сонячної енергії
              LineChartBarData(
                spots: solarData, // точки для графіка
                isCurved: true,   // плавна лінія
                color: Colors.orange, // колір лінії
                dotData: FlDotData(show: false), // приховати точки
              ),
              // Лінія для електричної енергії
              LineChartBarData(
                spots: electricData,
                isCurved: true,
                color: Colors.blue,
                dotData: FlDotData(show: false),
              ),
              // Лінія для теплової енергії
              LineChartBarData(
                spots: thermalData,
                isCurved: true,
                color: Colors.red,
                dotData: FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
