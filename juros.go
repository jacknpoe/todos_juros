// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 27/02/2024: versão feita sem muito conhecimento de Go
//        0.2: 09/05/2024: saídas melhoradas com descrição e mais peso total
//        0.3: 13/07/2025: flexibilizadas as variáveis e os arrays, e comentários

package main

// importação para math.Pow e fmt.Print/Println
import (
	"fmt"
	"math"
)

// estrutura passada para simplificar as chamadas
type Juros struct {
	Quantidade int
	Composto   bool
	Periodo    float64
	Pagamentos []float64
	Pesos      []float64
}

// calcula a somatória de Pesos()
func (this Juros) getPesoTotal() float64 {
	var acumulador float64 = 0.0
	for _, valor := range this.Pesos {
		acumulador += valor
	}
	return acumulador
}

// calcula o acréscimo a partir dos juros e parcelas
func (this Juros) jurosParaAcrescimo(juros float64) float64 {
	if juros <= 0.0 || this.Quantidade <= 0 || this.Periodo <= 0.0 {
		return 0.0
	}
	pesoTotal := this.getPesoTotal()
	if pesoTotal <= 0.0 {
		return 0.0
	}

	var acumulador float64 = 0.0

	for indice := 0; indice < this.Quantidade; indice++ {
		if this.Composto {
			acumulador += this.Pesos[indice] / math.Pow(1.0+juros/100.0, this.Pagamentos[indice]/this.Periodo)
		} else {
			acumulador += this.Pesos[indice] / (1.0 + juros/100.0*this.Pagamentos[indice]/this.Periodo)
		}
	}

	if acumulador <= 0.0 {
		return 0.0
	}
	return (pesoTotal/acumulador - 1.0) * 100.0
}

// calcula os juros a partir do acréscimo e parcelas
func (this Juros) acrescimoParaJuros(acrescimo float64, precisao int, maxIteracoes int, maxJuros float64) float64 {
	if maxIteracoes < 1 || this.Quantidade < 1 || precisao < 1 || this.Periodo <= 0.0 || acrescimo <= 0.0 || maxJuros <= 0.0 {
		return 0.0
	}
	var minJuros, medJuros, minDiferenca, pesoTotal float64 = 0.0, 0.0, math.Pow(0.1, float64(precisao)), this.getPesoTotal()
	if pesoTotal <= 0.0 {
		return 0.0
	}

	for indice := 0; indice < maxIteracoes; indice++ {
		medJuros = (minJuros + maxJuros) / 2.0
		if (maxJuros - minJuros) < minDiferenca {
			break
		}
		if this.jurosParaAcrescimo(medJuros) <= acrescimo {
			minJuros = medJuros
		} else {
			maxJuros = medJuros
		}
	}

	return medJuros
}

func main() {
	// altere aqui os valores iniciais para outros casos
	quantidade := 300
	composto := true
	periodo := 30.0

	// os arrays são dinamicamente inicializados (mude as fórmulas se necessário)
	var pagamentos = []float64{}
	var pesos = []float64{}
	for indice := 0; indice < quantidade; indice++ {
		pagamentos = append(pagamentos, (float64(indice)+1.0)*periodo)
		pesos = append(pesos, 1.0)
	}

	// estrutura juros do tipo Juros
	juros := Juros{quantidade, composto, periodo, pagamentos, pesos}

	// calcula e guarda os resultados das funções
	pesoTotal := juros.getPesoTotal()
	acrescimoCalculado := juros.jurosParaAcrescimo(3)
	jurosCalculado := juros.acrescimoParaJuros(acrescimoCalculado, 15, 100, 50.0)

	// imprime os resultados
	fmt.Print("Peso Total = ")
	fmt.Println(pesoTotal)
	fmt.Print("Acréscimo = ")
	fmt.Println(acrescimoCalculado)
	fmt.Print("Juros = ")
	fmt.Println(jurosCalculado)
}
