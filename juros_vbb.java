// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 15/07/2024: não está sendo possível testar

import virtualbreadboard.vbbmicro.target.ChatVBB4UNO;
import virtualbreadboard.arduino.LiquidCrystal;
import java.lang.Math;  // para Math.pow() 

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

    // set de Quantidade (altera os tamanhos dos arrays Pagamentos[] e Pesos[])
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
        if(maxIteracoes < 1 || this.Quantidade <= 0 || precisao < 1 || this.Periodo <= 0.0 || acrescimo <= 0.0 || maxJuros <= 0.0) return 0.0;
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

public class MyArduino extends ChatVBB4UNO {
    private LiquidCrystal _lcd;

    @Before
    public void configureTest(){
    }
    
    @Test
    public void testThis(){
        assertTrue(false);
    }

    @Test
    public void testThat(){
        assertTrue(false);
    }

    @Override
    public void setup()
    {
        _lcd = new LiquidCrystal();
        _lcd.begin(16, 2);
    }

    @Override
    public void loop()
    {
        // cria um objeto juros da classe Juros e inicializa Quantidade, Composto e Periodo
        Juros juros = new Juros(3, true, 30.0);

        // inicializa o array Pesos[]
        juros.Pesos[0] = 1.0;
        juros.Pesos[1] = 1.0;
        juros.Pesos[2] = 1.0;
        
        // inicializa o array Pagamentos[]
        juros.Pagamentos[0] = 30.0;
        juros.Pagamentos[1] = 60.0;
        juros.Pagamentos[2] = 90.0;

        // guarda o retorno dos cálculos
        double pesoTotal = juros.getPesoTotal();
        double acrescimoCalculado = juros.jurosParaAcrescimo(3);        
        double jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);
        
        // imprime os valores no console
        _lcd.setCursor(0, 0);
        _lcd.print("Peso total:");
        _lcd.setCursor(0, 1);
        _lcd.print(pesoTotal);
        delayMicroseconds(3000);

        _lcd.setCursor(0, 0);
        _lcd.print("Acrescimo:");
        _lcd.setCursor(0, 1);
        _lcd.print(acrescimoCalculado);
        delayMicroseconds(3000);

        _lcd.setCursor(0, 0);
        _lcd.print("Juros:");
        _lcd.setCursor(0, 1);
        _lcd.print(jurosCalculado);
        delayMicroseconds(3000);
    }
}