import 'dart:math';

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

  double mediaX = calcularMedia(x);
  double mediaY = calcularMedia(y);
  double desvioPadraoX = calcularDesvioPadrao(x, mediaX);
  double desvioPadraoY = calcularDesvioPadrao(y, mediaY);
  double covariancia = calcularCovariancia(x, y, mediaX, mediaY);

  return covariancia / (desvioPadraoX * desvioPadraoY);
}

void main() {
  List<double> x = [1.0, 2.0, 3.0, 4.0, 5.0];
  List<double> y = [2.0, 4.0, 6.0, 8.0, 10.0];

  double correlacao = calcularCorrelacaoPearson(x, y);
  print('A correlação de Pearson é: $correlacao');
}