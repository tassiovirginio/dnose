import 'dart:math';
import 'package:statistics/statistics.dart';


// Função para calcular a média
double calcularMedia(List<double> lista) {
  double soma = lista.reduce((a, b) => a + b);
  return soma / lista.length;
}

// Função para calcular o desvio padrão
double calcularDesvioPadrao(List<double> lista, double media) {
  num somaDesviosAoQuadrado = lista.map((x) => pow(x - media, 2)).reduce((a, b) => a + b);
  return sqrt(somaDesviosAoQuadrado / (lista.length - 1));
}

// Função para calcular a covariância
double calcularCovariancia(List<double> x, List<double> y, double mediaX, double mediaY) {
  double soma = 0.0;
  for (int i = 0; i < x.length; i++) {
    soma += (x[i] - mediaX) * (y[i] - mediaY);
  }
  return soma / (x.length - 1);
}

// Função para calcular a correlação de Pearson
double calcularCorrelacaoPearson(List<double> x, List<double> y) {
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

  double xy_covariancia = calcularCovariancia(x, y, x_media, y_media);
  var resultado_with_lib = xy_covariancia / (x_desvioPadrao * y_desvioPadrao);
  print(resultado_with_lib);


  double mediaX = calcularMedia(x);
  double mediaY = calcularMedia(y);

  print("mediax1-> $mediaX");
  print("mediax2-> $x_media");
  print("mediay1-> $mediaY");
  print("mediay2-> $y_media");

  double desvioPadraoX = calcularDesvioPadrao(x, mediaX);
  double desvioPadraoY = calcularDesvioPadrao(y, mediaY);

  print("dvpx1-> $x_desvioPadrao");
  print("dvpx2-> $desvioPadraoX");
  print("dvpy1-> $y_desvioPadrao");
  print("dvpy2-> $desvioPadraoY");

  double covariancia = calcularCovariancia(x, y, mediaX, mediaY);
  var resultado_normal = covariancia / (desvioPadraoX * desvioPadraoY);
  print(resultado_normal);

  return resultado_normal;
}

void main() {
  List<double> x = [1.0, 2.0, 3.0, 4.0, 5.0];
  List<double> y = [1.0, 2.0, 3.0, 4.0, 5.0];

  double correlacao = calcularCorrelacaoPearson(x, y);
  print('A correlação de Pearson é: $correlacao');
}
