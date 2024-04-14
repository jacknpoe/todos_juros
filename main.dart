// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 14/04/2024: versão feita sem muito conhecimento de Flutter

import 'package:flutter/material.dart';
import "dart:math";

// classe para agrupar os valores comuns
class Juros {
  int quantidade;
  bool composto;
  double periodo;
  List<double> pagamentos;
  List<double> pesos;

  // construtor
  Juros(this.quantidade, this.composto, this.periodo, this.pagamentos, this.pesos);

  // calcula a somatória de Pesos[]
  double getPesoTotal() {
    double acumulador = 0.0;
    for(int indice = 0; indice < quantidade; indice++) {
      acumulador += pesos[indice];
    }
    return acumulador;
  }

  // calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
  double jurosParaAcrescimo(double juros) {
    double pesoTotal;
    double acumulador = 0.0;
    if(juros <= 0.0 || quantidade <= 0 || periodo <= 0.0) { return 0.0; }
    pesoTotal = getPesoTotal();
    if(pesoTotal <= 0.0) { return 0.0; }

    for(int indice = 0; indice < quantidade; indice++) {
      if(composto) {
        acumulador += pesos[indice] / pow(1.0 + juros / 100.0, pagamentos[indice] / periodo);
      } else {
        acumulador += pesos[indice] / (1.0 + juros / 100.0 * pagamentos[indice] / periodo);
      }
    }

    if(acumulador <= 0.0) { return 0.0; }
    return (pesoTotal / acumulador - 1.0) * 100.0;
  }
  
  // calcula os juros a partir do acréscimo e dados comuns (como parcelas)
  double acrescimoParaJuros(double acrescimo, {int precisao = 15, int maxIteracoes = 100, double maxJuros = 50.0}) {
    double pesoTotal;
    double minJuros = 0.0;
    double medJuros = maxJuros / 2.0;
    double minDiferenca = pow(0.1, precisao).toDouble();
    if(maxIteracoes < 1 || quantidade <= 0 || precisao < 1 || periodo <= 0.0 || acrescimo <= 0.0 || maxJuros <= 0.0) { return 0.0; }
    pesoTotal = getPesoTotal();
    if(pesoTotal <= 0.0) { return 0.0; }

    for(int indice = 0; indice < maxIteracoes; indice++) {
      medJuros = (minJuros + maxJuros) / 2.0;
      if((maxJuros - minJuros) <minDiferenca) { return medJuros; }
      if(jurosParaAcrescimo(medJuros) < acrescimo) {
        minJuros = medJuros;
      } else {
        maxJuros = medJuros;
      }
    }

    return medJuros;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calcula Juros',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Teste de Cálculo de Juros'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _texto = "";

  void _botaoMostrar() {
    setState(() {
      // define os valores de juros
      int quantidade = 3;
      double pesoTotalCalculado, acrescimoCalculado, jurosCalculado;
      Juros juros = Juros(quantidade, true, 30.0, [], []);
      for (int indice = 0; indice < quantidade; indice++) {
        juros.pagamentos.add((indice + 1) * 30.0);
        juros.pesos.add(1.0);
      }

      // testa os métodos
      pesoTotalCalculado = juros.getPesoTotal();
      acrescimoCalculado = juros.jurosParaAcrescimo(3.0);
      jurosCalculado = juros.acrescimoParaJuros(juros.jurosParaAcrescimo(3.0), precisao: 18, maxIteracoes: 200, maxJuros: 100.0);
      _texto = 'Peso total = $pesoTotalCalculado, acréscimo = $acrescimoCalculado, juros = $jurosCalculado.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Os resultados são:',
            ),
            Text(
              _texto,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _botaoMostrar,
        tooltip: 'Mostra os resultados',
        child: const Icon(Icons.play_arrow),
      ), 
    );
  }
}
