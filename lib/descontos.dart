double calcularDesconto(
    double valorInicial, double desconto, bool ehPorcentagem) {
  if (desconto <= 0)
    throw new ArgumentError("O desconto deve ser maior que zero!");

  if (valorInicial <= 0)
    throw new ArgumentError("O valor inicial deve ser maior que zero!");

  if (ehPorcentagem) {
    return valorInicial - (valorInicial * desconto / 100);
  }

  return valorInicial - desconto;
}
