// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 30/04/2025: versão feita sem muito conhecimento de Monkey C

import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// classe Juros com atributos que simplificam as chamadas aos métodos
class Juros {
    var Quantidade;
    var Composto;
    var Periodo;
    var Pagamentos;
    var Pesos;

    // construtor que inicializa escalares e aloca arrays
    function initialize(quantidade, composto, periodo) {
        self.Quantidade = quantidade;
        self.Composto = composto;
        self.Periodo = periodo;
        self.Pagamentos = new[quantidade];
        self.Pesos = new[quantidade];
    }

    // calcula a somatória de Pesos[]
    function getPesoTotal() {
        var acumulador = 0.0;
        for(var indice = 0; indice < self.Quantidade; indice++) {
            acumulador += self.Pesos[indice];
        }
        return acumulador;
    }

    // calcula o acréscimo a partir dos juros e parcelas
    function jurosParaAcrescimo(juros) {
        var pesoTotal = self.getPesoTotal();
        if(self.Quantidade < 1 || self.Periodo <= 0.0 || pesoTotal <= 0.0 || juros <= 0.0) { return 0.0; }

        var acumulador = 0.0;
        for(var indice = 0; indice < self.Quantidade; indice++) {
            if(self.Composto) {
                acumulador += self.Pesos[indice] / Math.pow(1.0 + juros / 100.0, self.Pagamentos[indice] / self.Periodo);
            } else {
                acumulador += self.Pesos[indice] / (1.0 + juros / 100.0 * self.Pagamentos[indice] / self.Periodo);
            }
        }
        if(acumulador <= 0.0) { return 0.0; }
        return (pesoTotal / acumulador - 1.0) * 100.0;
    }

    // calcula os juros a partir do acréscimo e parcelas
    function acrescimoParaJuros(acrescimo, precisao, maxIteracoes, maxJuros) {
        var pesoTotal = self.getPesoTotal();
        if(self.Quantidade < 1 || self.Periodo <= 0.0 || pesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes < 1 || maxJuros <= 0.0) { return 0.0; }

        var minJuros = 0.0;
        var medJuros = maxJuros / 2.0;
        var minDiferenca = Math.pow(0.1, precisao);
        for(var indice = 0; indice < maxIteracoes; indice++) {
            if(maxJuros - minJuros < minDiferenca) { return 0.0; }
            if(self.jurosParaAcrescimo(medJuros) < acrescimo) { minJuros = medJuros; } else { maxJuros = medJuros; }
            medJuros = (minJuros + maxJuros) / 2.0;
        }
        return medJuros;
    }
}

class jurosApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        // cria um objeto juros da classe Juros e inicializa os atributos, os arrays dinamicamente
        var juros = new Juros(3, true, 30.0);

        for(var indice = 0; indice < juros.Quantidade; indice++) {
            juros.Pagamentos[indice] = (indice + 1.0) * juros.Periodo;
            juros.Pesos[indice] =  1.0;
        }

        // chama e guarda os resultados dos métodos
        var pesoTotal = juros.getPesoTotal();
        var acrescimoCalculado = juros.jurosParaAcrescimo(3.0);
        var jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);

        // imprime os resultados
        System.print("Peso total = "); System.println(pesoTotal);
        System.print("Acréscimo = "); System.println(acrescimoCalculado);
        System.print("Juros = "); System.println(jurosCalculado);
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new jurosView(), new jurosDelegate() ];
    }
}

function getApp() as jurosApp {
    return Application.getApp() as jurosApp;
}