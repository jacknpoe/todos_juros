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

    	// inicializa os arrays
        for(int indice = 0; indice < juros.getQuantidade(); indice++) {
            juros.Pagamentos[indice] = 30.0 * (indice + 1.0);
            juros.Pesos[indice] = 1.0;
        }

        // guarda o retorno dos cálculos
        double pesoTotal = juros.getPesoTotal();
        double acrescimoCalculado = juros.jurosParaAcrescimo(3);        
        double jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0);
        
        // imprime os valores no console
        System.out.println("Peso total = " + Double.toString(pesoTotal));        
        System.out.println("Acrescimo = " + Double.toString(acrescimoCalculado));
        System.out.println("Juros = " + Double.toString(jurosCalculado));
    }
}
