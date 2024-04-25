/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 * Versão 0.2:    04/2024: trocada avaliação soZero por acumulador == 0
 */

package jacknpoe.testejuros;

import java.lang.Math;

/**
 *
 * @author Ricardo
 */
public class Juros {
    private int Quantidade;
    public boolean Composto;
    public double Periodo;
    public double Pagamentos[];
    public double Pesos[];
    
    public Juros(int quantidade, boolean composto, double periodo) {
        this.Quantidade = quantidade;
        this.Composto = composto;
        this.Periodo = periodo;
        this.Pagamentos = new double[quantidade];
        this.Pesos = new double[quantidade];
    }

    public int getQuantidade() { return Quantidade; }

    public void setQuantidade(int valor) {
        this.Quantidade = valor;
        this.Pagamentos = new double[valor];
        this.Pesos = new double[valor];
    }
    
    public double getPesoTotal() {
        double acumulador = 0.0;
        for(int indice = 0; indice < this.Quantidade; indice++) acumulador += this.Pesos[indice];
        return acumulador;
    }
    
    public double jurosParaAcrescimo(double juros){
        if(juros <= 0 || this.Quantidade <= 0 || this.Periodo <= 0.0) return 0.0;
        double pesoTotal = this.getPesoTotal();
        if(pesoTotal <= 0.0) return 0.0;
        double acumulador = 0.0;
        // boolean soZero = true;
        
        for(int indice = 0; indice < this.Quantidade; indice++) {
            // if(this.Pagamentos[indice] > 0.0 && this.Pesos[indice] > 0.0) soZero = false;
            if(this.Composto) {
                acumulador += this.Pesos[indice] / Math.pow(1 + juros / 100, this.Pagamentos[indice] / this.Periodo);
            } else {
                acumulador += this.Pesos[indice] / (1 + juros / 100 * this.Pagamentos[indice] / this.Periodo);
            }
        }
        
        // if(soZero) return 0.0;
        if (acumulador <= 0.0) return 0.0;
        return (pesoTotal / acumulador - 1) * 100;
    }

    public double acrescimoParaJuros(double acrescimo, int precisao, int maxIteracoes, double maxJuros) {
        if(maxIteracoes < 1 || this.Quantidade <= 0 || precisao < 1 || this.Periodo <= 0.0 || acrescimo <= 0 || maxJuros <= 0) return 0;
        double minJuros = 0.0, medJuros = 0.0, minDiferenca = Math.pow(0.1, precisao), pesoTotal = this.getPesoTotal();
        if(pesoTotal <= 0.0) return 0.0;
       
        for(int indice = 0; indice < maxIteracoes; indice++) {
            medJuros = (minJuros + maxJuros) / 2;
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
