(** Cálculo dos juros, sendo que precisa de arrays para isso *)
(** Versão 0.1: 30/05/2024: versão feita sem muito conhecimento de OCaml *)

(** valores para simplificar as chamadas *)
let quantidade : int = 3
let composto = true
let periodo = 30.0
let pagamentos = [| 30.0; 60.0; 90.0 |]
let pesos = [| 1.0; 1.0; 1.0|]

(** função recursiva que calcula a somatória de Pesos[] *)
let rec rGetPesoTotal indice = if indice = 0 then pesos.(0) else pesos.(indice) +. rGetPesoTotal(indice-1);;

(** calcula a somatória de Pesos[] *)
let getPesoTotal = rGetPesoTotal(quantidade-1);;

(** função recursiva que calcula o amortecimento das parcelas em juros compostos *)
let rec rJurosCompostos indice juros =
  if indice = 0 then pesos.(0) /. (1.0 +. juros /. 100.0) ** (pagamentos.(0) /. periodo)
  else pesos.(indice) /. (1.0 +. juros /. 100.0) ** (pagamentos.(indice) /. periodo) +. rJurosCompostos (indice-1) juros ;;

(** função recursiva que calcula o amortecimento das parcelas em juros simples *)
let rec rJurosSimples indice juros =
  if indice = 0 then pesos.(0) /. (1.0 +. juros /. 100.0 *. pagamentos.(0) /. periodo)
  else pesos.(indice) /. (1.0 +. juros /. 100.0 *. pagamentos.(indice) /. periodo) +. rJurosSimples (indice-1) juros ;;

(** calcula o acréscimo a partir dos juros e das parcelas *)
let jurosParaAcrescimo juros =
  if composto then (getPesoTotal /. (rJurosCompostos (quantidade-1) juros) -. 1.0) *. 100.0 
  else (getPesoTotal /. (rJurosSimples (quantidade-1) juros) -. 1.0) *. 100.0  ;;

(** função recursiva no lugar de um for que realmente calcula o acréscimo *)
let rec rAcrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros =
  if iteracaoAtual = 0 || (maxJuros -. minJuros) < minDiferenca then medJuros else
    if jurosParaAcrescimo medJuros < acrescimo then rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual-1) medJuros maxJuros ((medJuros +. maxJuros) /. 2.0)
    else rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual-1) minJuros medJuros ((minJuros +. medJuros) /. 2.0);;

(** calcula os juros a partir do acréscimo e das parcelas *)
let acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros =
  rAcrescimoParaJuros acrescimo (0.1 ** (float precisao)) maxIteracoes 0.0 maxJuros (maxJuros /. 2.0);;

(** faz os cálculos para testes *)
let pesoTotal = getPesoTotal;;
let acrescimoCalculado = jurosParaAcrescimo 3.0;;
let jurosCalculado = acrescimoParaJuros acrescimoCalculado 15 100 50.0;;

(** imprime os resultados *)
Printf.printf "Peso total = %.15f\n" pesoTotal;
Printf.printf "Acréscimo = %.15f\n" acrescimoCalculado;
Printf.printf "Juros = %.15f\n" jurosCalculado;
