import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Gráfico de barras agrupadas. Recibe:
///  • data: `Map<nombre_comportamiento, [valorEjecutivo, valorGerente, valorMiembro]>`
///    Ejemplo: { "Trabajo en equipo": [4.0, 3.5, 4.2], "Comunicación": [3.8, 4.1, 3.9], … }
///  • title: String (título encima del gráfico)
///  • minY: double (mínimo del eje Y, típicamente 0)
///  • maxY: double (máximo del eje Y, p. ej. 5)
class GroupedBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data; // Asegúrate que esto es List<Map<String, dynamic>>
  final String title;
  final double minY;
  final double maxY;
  final bool isDetail;

  const GroupedBarChart({
    super.key,
    required this.data,
    required this.title,
    this.minY = 0,
    this.maxY = 5,
    this.isDetail = false,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No hay datos disponibles para mostrar.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    final labels = data.map((e) => e['nombre_comportamiento'] as String).toList(); // Lista de nombres de comportamientos

    Widget chartWidget = BarChart(
      BarChartData(
        minY: minY,
        maxY: maxY,
        barGroups: List.generate(labels.length, (i) {
          final valores = data[i].values.skip(1).toList().cast<double>();
          return BarChartGroupData(
            x: i,
            barsSpace: isDetail ? 8 : 4,
            barRods: [
              // Barra de Ejecutivo (azul)
              BarChartRodData(
                toY: valores[0],
                color: Colors.blue,
                width: isDetail ? 16 : 8,
              ),
              // Barra de Gerente (rojo)
              BarChartRodData(
                toY: valores[1],
                color: Colors.red,
                width: isDetail ? 16 : 8,
              ),
              // Barra de Miembro (verde)
              BarChartRodData(
                toY: valores[2],
                color: Colors.green,
                width: isDetail ? 16 : 8,
              ),
            ],
          );
        }),
        groupsSpace: isDetail ? 32 : 20,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: isDetail,
              reservedSize: isDetail ? 50 : 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Transform.rotate(
                    angle: -pi / 4, // rotar 45° para que quepan nombres largos
                    child: Text(
                      labels[index],
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: isDetail,
              interval: 1,
              reservedSize: isDetail ? 40 : 28,
              getTitlesWidget: (value, meta) {
                // Mostramos e.g. 0,1,2,3,4,5
                if (value % 1 == 0 && value >= minY && value <= maxY) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: isDetail,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withAlpha(77), // 0.3 opacity
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Colors.black, width: 2),
            left: BorderSide(color: Colors.black, width: 2),
            right: BorderSide(color: Colors.transparent),
            top: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
    );

    if (title.isNotEmpty) { // Mostrar título solo si no está vacío
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(child: chartWidget),
        ],
      );
    } else {
      return chartWidget; // Retornar solo el gráfico si el título está vacío
    }
  }
}