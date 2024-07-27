// import 'dart:math';
//
// double Sred(List l) {
//   double sr = 0;
//   var leng = l.length;
//   for (int i = 0; i <= leng - 1; i++) {
//     sr += l[i];
//   }
//   return sr/leng ;
// }
//
// double Dispers(List l) {
//   double D = 0;
//   var sl = Sred(l);
//   for (int i = 0; i < l.length; i++) {
//     D += pow(l[i] - sl, 2);
//   }
//   return D ;
// }
//
// double Correl(List L1, List L2) {
//   var d1 = Dispers(L1);
//   var d2 = Dispers(L2);
//   var vsr1 = Sred(L1);
//   var vsr2 = Sred(L2);
//   double covar = 0;
//   double Res = 0;
//   for (int i = 0; i < L1.length; i++) {
//     covar += (L1[i] - vsr1) * (L2[i] - vsr2);
//   }
//   Res = covar /sqrt (d1 * d2);
//   return Res;
// }
//
// void main() {
//   List<double> x = [6.0, 2.0, 3.0, 2.0];
//   List<double> y = [5.0, 2.0, 3.0, 1.0];
//
//   double K = Correl(x, y);
//
//   print('Correlação de Pearson = $K');
// }