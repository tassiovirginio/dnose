// import 'dart:math';

// Função para calcular os ranks de uma lista
List<double> calcularRanks(List<double> lista) {
  // Cria uma lista de pares (valor, índice original)
  List<MapEntry<double, int>> pares = lista.asMap().entries.cast<MapEntry<double, int>>().toList();
  // Ordena os pares pelo valor
  pares.sort((a, b) => a.key.compareTo(b.key));

  // Cria uma lista para armazenar os ranks
  List<double> ranks = List<double>.filled(lista.length, 0.0);

  for (int i = 0; i < pares.length; i++) {
    // Trata empates atribuindo a média dos ranks
    int start = i;
    while (i < pares.length - 1 && pares[i].key == pares[i + 1].key) {
      i++;
    }
    double avgRank = (start + i + 2) / 2.0;
    for (int j = start; j <= i; j++) {
      ranks[pares[j].value] = avgRank;
    }
  }

  return ranks;
}

// Função para calcular a correlação de Spearman
double calcularCorrelacaoSpearman(List<double> x, List<double> y) {
  if (x.length != y.length) {
    throw Exception('As listas devem ter o mesmo tamanho');
  }

  List<double> ranksX = calcularRanks(x);
  List<double> ranksY = calcularRanks(y);

  double somaDiffQuadrado = 0.0;
  for (int i = 0; i < x.length; i++) {
    double diff = ranksX[i] - ranksY[i];
    somaDiffQuadrado += diff * diff;
  }

  int n = x.length;
  double coefSpearman = 1 - (6 * somaDiffQuadrado) / (n * (n * n - 1));

  return coefSpearman;
}

void main() {
  List<double> x = [1.0, 2.0, 3.0, 4.0, 5.0];
  List<double> y = [2.0, 3.0, 4.0, 5.0, 6.0];

  double correlacao = calcularCorrelacaoSpearman(x, y);
  print('A correlação de Spearman é: $correlacao');
}