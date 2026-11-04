/** Cálculo dos juros, sendo que precisa de arrays para isso */
/** Versão 0.1: 13/08/2024: versão feita sem muito conhecimento de Reason */
/**        0.2: 04/11/2026: melhorias em comentários, retirado o tipo int de quantidade, valida variáveis, parâmetros e cálculos */
/**                         retirados casos especiais, funções recursivas alteradas para permitir Tail Call Optimization (TCO) */

/** valores para simplificar as chamadas */
let quantidade = 3;
let composto = true;
let periodo = 30.0;
let pagamentos = Array.make(quantidade, 0.0);
let pesos = Array.make(quantidade, 0.0);

/** função recursiva que gera a lista pagamentos */
let rec rDefinePagamentos = indice =>
  if (indice < 0) {
    ()
  } else {
    pagamentos[indice] = ((float(indice + 1)) *. periodo) ; 
    rDefinePagamentos (indice - 1)
  };

/** função açúcar que gera a lista pagamentos */
let definePagamentos = rDefinePagamentos (quantidade - 1) ;

/** função recursiva que gera a lista pesos */
let rec rDefinePesos = indice =>
  if (indice < 0) {
    ()
  } else {
    pesos[indice] = 1.0 ; 
    rDefinePesos (indice - 1)
  };

/** função açúcar que gera a lista pesos */
let definePesos = rDefinePesos (quantidade - 1) ;

/** função recursiva que calcula a somatória de Pesos[] */
let rec rGetPesoTotal = (indice, acumulador) =>
  if (indice < 0) {
    acumulador;
  } else {
    rGetPesoTotal (indice - 1) (pesos[indice] +. acumulador);
  };

/** função açúcar que calcula a somatória de Pesos[] */
let getPesoTotal = rGetPesoTotal (quantidade - 1, 0.0);

/** função recursiva que calcula o amortecimento das parcelas em juros compostos */
let rec rJurosCompostos = (indice, juros, acumulador) =>
  if (indice < 0) {
    acumulador;
  } else {
    rJurosCompostos(indice - 1, juros, pesos[indice] /. (1.0 +. juros /. 100.0) ** (pagamentos[indice] /. periodo) +. acumulador);
  };

/** função recursiva que calcula o amortecimento das parcelas em juros simples */
let rec rJurosSimples = (indice, juros, acumulador) =>
  if (indice < 0) {
    acumulador;
  } else {
    rJurosSimples(indice - 1, juros, pesos[indice] /. (1.0 +. juros /. 100.0 *. pagamentos[indice] /. periodo) +. acumulador);
  };

/** função que calcula o acréscimo a partir dos juros e das parcelas */
let jurosParaAcrescimo = juros => {
  let pesoTotal = getPesoTotal;
  if (quantidade < 1 || periodo <= 0.0 || pesoTotal <= 0.0 || juros <= 0.0) {    
    0.0;
  } else {
    let acumulador = if (composto) {
      rJurosCompostos(quantidade - 1, juros, 0.0);
    } else {
      rJurosSimples(quantidade - 1, juros, 0.0);
    };
    if (acumulador <= 0.0) {
      0.0
    } else {
      (pesoTotal /. acumulador -. 1.0) *. 100.0;
    }
  };
};

/** função recursiva que calcula os juros a partir do acréscimo e das parcelas */
let rec rAcrescimoParaJuros = (acrescimo, minDiferenca, iteracaoAtual, minJuros, maxJuros, medJuros) =>
  if (iteracaoAtual == 0 || maxJuros -. minJuros < minDiferenca) {
    medJuros;
  } else if (jurosParaAcrescimo(medJuros) < acrescimo) {
    rAcrescimoParaJuros( acrescimo, minDiferenca, iteracaoAtual - 1, medJuros, maxJuros, (medJuros +. maxJuros) /. 2.0) ;
  } else {
    rAcrescimoParaJuros( acrescimo, minDiferenca, iteracaoAtual - 1, minJuros, medJuros, (minJuros +. medJuros) /. 2.0) ;
  };

/** função açúcar que calcula os juros a partir do acréscimo e das parcelas */
let acrescimoParaJuros = (acrescimo, precisao, maxIteracoes, maxJuros) => {
  let pesoTotal = getPesoTotal;
  if (quantidade < 1 || periodo <= 0.0 || pesoTotal <= 0.0 || acrescimo <= 0.0 || precisao < 1 || maxIteracoes <= 1 || maxJuros <= 0.0) {    
    0.0;
  } else {
    rAcrescimoParaJuros( acrescimo, 0.1 ** float(precisao), maxIteracoes, 0.0, maxJuros, maxJuros /. 2.0 );
  };
};

/** define os valores dos vetores */
definePagamentos;
definePesos;

/** faz os cálculos para testes */
let pesoTotal = getPesoTotal;
let acrescimoCalculado = jurosParaAcrescimo(3.0);
let jurosCalculado = acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0);

/** imprime os resultados */
{
  Printf.printf("Peso total = %.15f\n", pesoTotal);
  Printf.printf("Acréscimo = %.15f\n", acrescimoCalculado);
  Printf.printf("Juros = %.15f\n", jurosCalculado);
};
