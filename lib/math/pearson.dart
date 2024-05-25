import 'dart:math';

import 'package:scidart/numdart.dart';
import 'package:statistics/statistics.dart';
import 'package:scidart/scidart.dart';

extension NumberParsing on String {
  int parseInt2() {
    return int.parse(this);
  }
// ···
}



// Função para calcular a covariância
double calcularCovariancia(List<num> x, List<num> y, double mediaX, double mediaY) {
  double soma = 0.0;
  for (int i = 0; i < x.length; i++) {
    soma += (x[i] - mediaX) * (y[i] - mediaY);
  }
  return soma / (x.length - 1);
}

// Função para calcular a correlação de Pearson
num calcularCorrelacaoPearson(List<num> x, List<num> y) {
  if (x.length != y.length) {
    throw Exception('As listas devem ter o mesmo tamanho');
  }

  var x_statistics = x.statistics;
  var x_media = x_statistics.mean;
  var x_desvioPadrao = x_statistics.standardDeviation;
  var x_mediana = x_statistics.median;
  var x_squareMean = x_statistics.squaresMean;
  var x_sum = x_statistics.sumBigInt;
  var x_max = x_statistics.max;
  var x_min = x_statistics.min;
  var x_center = x_statistics.center;
  var x_squaresSum = x_statistics.squaresSum;

  print("x_media-> $x_media");
  print("x_desvioPadrao-> $x_desvioPadrao");
  print("x_desvioPadrao-> $x_desvioPadrao");

  print("x_mediana-> $x_mediana");
  print("x_squareMean-> $x_squareMean");
  print("x_sum-> $x_sum");
  print("x_max-> $x_max");
  print("x_min-> $x_min");
  print("x_center-> $x_center");
  print("x_squaresSum-> $x_squaresSum");

  var y_statistics = y.statistics;
  var y_media = y_statistics.mean;
  var y_desvioPadrao = y_statistics.standardDeviation;
  var y_mediana = y_statistics.median;
  var y_squareMean = y_statistics.squaresMean;
  var y_sum = y_statistics.sumBigInt;
  var y_max = y_statistics.max;
  var y_min = y_statistics.min;
  var y_center = y_statistics.center;
  var y_squaresSum = y_statistics.squaresSum;

  print("==============================================");
  print("y_media-> $y_media");
  print("y_desvioPadrao-> $y_desvioPadrao");
  print("y_mediana-> $y_mediana");
  print("y_squareMean-> $y_squareMean");
  print("y_sum-> $y_sum");
  print("y_max-> $y_max");
  print("y_min-> $y_min");
  print("y_center-> $y_center");
  print("y_squaresSum-> $y_squaresSum");

  print("==============================================");

  double covariancia = calcularCovariancia(x, y, x_media, y_media);
  print("Covariancia: $covariancia");
  double correlacaoPearson = (covariancia / (x_desvioPadrao * y_desvioPadrao));
  print(correlacaoPearson);

  return correlacaoPearson;
}

void main() {
  List<double> x = [6.0, 2.0, 3.0, 1.0];
  List<double> y = [6.0, 2.0, 3.0, 1.0];

 var array_x = Array([6.0, 2.0, 3.0, 1.0]);
 var array_y = Array([6.0, 2.0, 3.0, 1.0]);

  num correlacao = calcularCorrelacaoPearson(x, y);
  print('A correlação de Pearson é: $correlacao');


  var coor = correlate(array_x, array_y);
  print("coor: $coor");
}
