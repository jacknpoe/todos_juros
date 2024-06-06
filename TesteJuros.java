/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 */

package jacknpoe.testejuros;

/**
 *
 * @author Ricardo
 */
public class TesteJuros {

    public static void main(String[] args) {
    	// cria um objeto juros da classe Juros e inicializa Quantidade, Composto e Periodo
    	Juros juros = new Juros(3, true, 30.0);

    	// inicializa o array Pesos[]
        juros.Pesos[0] = 1;
        juros.Pesos[1] = 1;
        juros.Pesos[2] = 1;
        
        // inicializa o array Pagamentos[]
        juros.Pagamentos[0] = 30.0;
        juros.Pagamentos[1] = 60.0;
        juros.Pagamentos[2] = 90.0;

        // guarda o retorno dos cálculos
        double pesoTotal = juros.getPesoTotal();
        double acrescimoCalculado = juros.jurosParaAcrescimo(3);        
        double jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50);
        
        // imprime os valores no console
        System.out.println("Peso total = " + Double.toString(pesoTotal));        
        System.out.println("Acrescimo = " + Double.toString(acrescimoCalculado));
        System.out.println("Juros = " + Double.toString(jurosCalculado));
    }
}
