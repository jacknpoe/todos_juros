/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 27/02/2024: publicação inicial, sem comentários nem legendas
//        0.2: 20/03/2004: pagamentos e períodos de int para double
//        0.3: 04/04/2004: trocado de avaliar soZero para se acumulador <= 0.0
//        0.4: 06/06/2024: com comentários e legendas
//        0.5: 15/07/2024: todos os valores double com .0 no final e retirados comentários com soZero
//        0.6: 01/03/2025: agora, inicializa os arrays com um laço for

package jacknpoe.testejuros;

import java.lang.Math;	// para Math.pow() 

/**
 *
 * @author Ricardo
 */
// classe com os atributos para simplificação das chamadas
public class Juros {
    private int Quantidade;
    public boolean Composto;
    public double Periodo;
    public double Pagamentos[];
    public double Pesos[];
   
    // construtor, que inicializa Quantidade, Composto e Periodo
    public Juros(int quantidade, boolean composto, double periodo) {
        this.Quantidade = quantidade;
        this.Composto = composto;
        this.Periodo = periodo;
        this.Pagamentos = new double[quantidade];
        this.Pesos = new double[quantidade];
    }

    // get de Quantidade
    public int getQuantidade() { return Quantidade; }

    // set de Quantidade (altera os tamanhos dos arrays Pagamentos[] e Pesos[]
    public void setQuantidade(int valor) {
        this.Quantidade = valor;
        this.Pagamentos = new double[valor];
        this.Pesos = new double[valor];
    }
    
    // calcula a somatória de Pesos[]
    public double getPesoTotal() {
        double acumulador = 0.0;
        for(int indice = 0; indice < this.Quantidade; indice++) acumulador += this.Pesos[indice];
        return acumulador;
    }
    
    // calcula o acréscimo a partir dos juros e das parcelas
    public double jurosParaAcrescimo(double juros){
        if(juros <= 0.0 || this.Quantidade <= 0 || this.Periodo <= 0.0) return 0.0;
        double pesoTotal = this.getPesoTotal();
        if(pesoTotal <= 0.0) return 0.0;
        double acumulador = 0.0;
        
        for(int indice = 0; indice < this.Quantidade; indice++) {
            if(this.Composto) {
                acumulador += this.Pesos[indice] / Math.pow(1.0 + juros / 100.0, this.Pagamentos[indice] / this.Periodo);
            } else {
                acumulador += this.Pesos[indice] / (1.0 + juros / 100.0 * this.Pagamentos[indice] / this.Periodo);
            }
        }
        
        if (acumulador <= 0.0) return 0.0;
        return (pesoTotal / acumulador - 1.0) * 100.0;
    }

    // calcula os juros a partir do acréscimo e das parcelas
    public double acrescimoParaJuros(double acrescimo, int precisao, int maxIteracoes, double maxJuros) {
        if(maxIteracoes < 1 || this.Quantidade <= 0 || precisao < 1 || this.Periodo <= 0.0 || acrescimo <= 0.0 || maxJuros <= 0.0) return 0;
        double minJuros = 0.0, medJuros = 0.0, minDiferenca = Math.pow(0.1, precisao), pesoTotal = this.getPesoTotal();
        if(pesoTotal <= 0.0) return 0.0;
       
        for(int indice = 0; indice < maxIteracoes; indice++) {
            medJuros = (minJuros + maxJuros) / 2.0;
            if((maxJuros - minJuros) < minDiferenca) break;
            if(this.jurosParaAcrescimo(medJuros) <= acrescimo) {
                minJuros = medJuros;
            } else {
                maxJuros = medJuros;
            }
        }
        
        return medJuros;
    }
}
