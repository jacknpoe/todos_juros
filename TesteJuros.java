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
        Juros juros = new Juros(3, true, 30.0);

        juros.Pesos[0] = 1;
        juros.Pesos[1] = 1;
        juros.Pesos[2] = 1;
        
        juros.Pagamentos[0] = 30.0;
        juros.Pagamentos[1] = 60.0;
        juros.Pagamentos[2] = 90.0;

        double acrescimoCalculado = juros.jurosParaAcrescimo(3);        
        double jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50);        
        System.out.println(Double.toString(acrescimoCalculado));
        System.out.println(Double.toString(jurosCalculado));
    }
}
