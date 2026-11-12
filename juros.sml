(* Cálculo do juros, sendo que precisa de arrays pra isso
   Versão 0.1: 31/05/2024: completo, mas sem saber muito sobre Moscow ML
          0.2: 12/11/2026: RETIRADOS DE juros_alice.ml:
                           melhorias nos comentários (incluindo retornos de acentuação); saída do REPL no final; retirados casos especiais
                           validações de variáveis, parâmetros e cálculos; arrays escaláveis dinamicamente preenchidos
                           funções recursivas alteradadas para permitir Tail Call Optimization (TCO) *)

load "Math"; load "Real"; load "OS";

(* variáveis básicas para simplificar as chamadas *)
val quantidade = 3;
val composto = true;
val periodo = 30.0;
val pagamentos = Array.array(quantidade, 0.0);
val pesos = Array.array(quantidade, 0.0);

(* função recursiva que preenche os elementos do array pagamentos *)
fun rPreenchePagamentos indice =
    if indice < 0 then (
    ) else (
        Array.update(pagamentos, indice, Real.fromInt(indice + 1) * periodo);
        rPreenchePagamentos (indice - 1)
    )

(* função açúcar que preenche os elementos do array pagamentos *)
fun preenchePagamentos () = rPreenchePagamentos (quantidade - 1);

(* função recursiva que preenche os elementos do array pesos *)
fun rPreenchePesos indice =
    if indice < 0 then (
    ) else (
        Array.update(pesos, indice, 1.0);
        rPreenchePesos (indice - 1)
    )

(* função açúcar que preenche os elementos do array pesos *)
fun preenchePesos () = rPreenchePesos (quantidade - 1);

(* função recursiva que calcula a somatória de Pesos *)
fun rGetPesoTotal indice acumulador = 
    if indice < 0 then acumulador
    else rGetPesoTotal (indice - 1) (acumulador + Array.sub(pesos, indice));
    
(* função açúcar que calcula a somatória de Pesos *)
fun getPesoTotal () = rGetPesoTotal (quantidade - 1) 0.0;

(* função recursiva que calcula a soma do amortecimento de todas as parcelas para juros compostos *)
fun rJurosCompostos indice juros acumulador =
    if indice < 0 then acumulador
    else rJurosCompostos (indice - 1) juros (acumulador + Array.sub(pesos, indice) * Math.pow(1.0 + juros / 100.0, ~(Array.sub(pagamentos, indice)) / periodo));

(* função recursiva que calcula a soma do amortecimento de todas as parcelas para juros simples *)
fun rJurosSimples indice juros acumulador =
    if indice < 0 then acumulador
    else rJurosSimples (indice - 1) juros (acumulador + Array.sub(pesos, indice) / (1.0 + juros / 100.0 * Array.sub(pagamentos, indice) / periodo));

(* função que calcula o acrescimo a partir dos juros e dados comuns (como parcelas) *)
fun jurosParaAcrescimo juros =
    let
        val pesoTotal = getPesoTotal();
    in
        if (quantidade < 1) orelse (periodo <= 0.0) orelse (pesoTotal <= 0.0) orelse (juros <= 0.0) then 0.0
        else let val acumulador =
            if composto then rJurosCompostos (quantidade - 1) juros 0.0
            else rJurosSimples (quantidade - 1) juros 0.0
        in
            if acumulador <= 0.0 then 0.0
            else (pesoTotal / acumulador - 1.0) * 100.0
        end
    end;

(* função recursiva que calcula os juros a partir do acrescimo e dados comuns (como parcelas) *)
fun rAcrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros =
    if (iteracaoAtual = 0) orelse ((maxJuros - minJuros) <= minDiferenca) then medJuros
    else if (jurosParaAcrescimo medJuros) < acrescimo
         then rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) medJuros maxJuros ((medJuros + maxJuros) / 2.0)
         else rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) minJuros medJuros ((minJuros + medJuros) / 2.0);

(* função açúcar que calcula os juros a partir do acrescimo e dados comuns (como parcelas) *)
fun acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros =
    let
        val pesoTotal = getPesoTotal();
    in
        if (quantidade < 1) orelse (periodo <= 0.0) orelse (pesoTotal <= 0.0) orelse (acrescimo <= 0.0) orelse (precisao < 1) orelse (maxIteracoes < 1) orelse (maxJuros <= 0.0) then 0.0
        else rAcrescimoParaJuros acrescimo (Math.pow(0.1, Real.fromInt(precisao))) maxIteracoes 0.0 maxJuros (maxJuros / 2.0)
    end;        

(* preenche os elementos dos arrays pagamentos e pesos *)
preenchePagamentos();
preenchePesos();

(* calcula e guarda os resultados das funções *)
val pesoTotal = getPesoTotal();
val acrescimoCalculado = jurosParaAcrescimo 3.0;
val jurosCalculado = acrescimoParaJuros acrescimoCalculado 15 65 50.0;

(* imprime os resultados *)
print ("Peso total = " ^ Real.toString(pesoTotal) ^ "\n");
print ("Acréscimo = " ^ Real.toString(acrescimoCalculado) ^ "\n");
print ("Juros = " ^ Real.toString(jurosCalculado) ^ "\n");

val _ = OS.Process.exit OS.Process.success;
