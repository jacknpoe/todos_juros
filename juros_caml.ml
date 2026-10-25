(** Cálculo dos juros, sendo que precisa de vetores para isso *)
(** Versão 0.1: 25/03/2025: versão feita sem muito conhecimento de Caml *)
(**        0.2: 25/10/2026: convertida para a versão de camlc para Debian (print_newline, quebras de linha, encoding UTF-8), vetores agora são escaláveis *)
(**                         funções recursivas foram alteradas para permitir Tail Call Optimization (TCO) *)

(** valores para simplificar as chamadas *)
let quantidade = 3 ;;
let composto = true ;;
let periodo = 30.0 ;;
let pagamentos = make_vect quantidade 0.0 ;;
let pesos = make_vect quantidade 0.0 ;;

(** função recursiva que gera a lista pagamentos *)
let rec rDefinePagamentos indice =
    if indice < 0
        then ()
        else (
            pagamentos.(indice) <- ((float_of_int (indice + 1)) *. periodo) ; 
            rDefinePagamentos (indice - 1)
        ) ;;

(** função açúcar que gera a lista pagamentos *)
let definePagamentos = rDefinePagamentos (quantidade - 1) ;;

(** função recursiva que gera a lista pesos *)
let rec rDefinePesos indice =
    if indice < 0
        then ()
        else (
            pesos.(indice) <- 1.0 ; 
            rDefinePesos (indice - 1)
        ) ;;

(** função açúcar que gera a lista pagamentos *)
let definePesos = rDefinePesos (quantidade - 1) ;;

(** função recursiva que calcula a somatória de pesos *)
let rec rGetPesoTotal indice acumulador =
    if indice < 0
        then acumulador
        else rGetPesoTotal (indice - 1) (pesos.(indice) +. acumulador) ;;

(** função açúcar que calcula a somatória de pesos *)
let getPesoTotal = rGetPesoTotal (quantidade - 1) 0.0 ;;

(** função recursiva que calcula o amortecimento das parcelas em juros compostos *)
let rec rJurosCompostos indice juros acumulador =
  if indice < 0
    then acumulador
    else rJurosCompostos (indice - 1) juros (pesos.(indice) /. (1.0 +. juros /. 100.0) ** (pagamentos.(indice) /. periodo) +. acumulador) ;;

(** função recursiva que calcula o amortecimento das parcelas em juros simples *)
let rec rJurosSimples indice juros acumulador =
  if indice < 0
    then acumulador
    else rJurosSimples (indice - 1) juros (pesos.(indice) /. (1.0 +. juros /. 100.0 *. pagamentos.(indice) /. periodo) +. acumulador) ;;

(** função que calcula o acréscimo a partir dos juros e das parcelas *)
let jurosParaAcrescimo juros =
  if composto
    then (getPesoTotal /. (rJurosCompostos (quantidade - 1) juros 0.0) -. 1.0) *. 100.0 
    else (getPesoTotal /. (rJurosSimples (quantidade - 1) juros 0.0) -. 1.0) *. 100.0 ;;

(** função recursiva que calcula os juros a partir do acréscimo e das parcelas *)
let rec rAcrescimoParaJuros acrescimo minDiferenca iteracaoAtual minJuros maxJuros medJuros =
  if iteracaoAtual = 0 || (maxJuros -. minJuros) < minDiferenca then medJuros else
    if jurosParaAcrescimo medJuros < acrescimo 
        then rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) medJuros maxJuros ((medJuros +. maxJuros) /. 2.0)
        else rAcrescimoParaJuros acrescimo minDiferenca (iteracaoAtual - 1) minJuros medJuros ((minJuros +. medJuros) /. 2.0) ;;

(** função açúcar que calcula os juros a partir do acréscimo e das parcelas *)
let acrescimoParaJuros acrescimo precisao maxIteracoes maxJuros =
  rAcrescimoParaJuros acrescimo (0.1 ** (float_of_int precisao)) maxIteracoes 0.0 maxJuros (maxJuros /. 2.0) ;;

(** define os valores dos vetores *)
definePagamentos ;;
definePesos ;;

(** faz os cálculos para testes *)
let pesoTotal = getPesoTotal ;;
let acrescimoCalculado = jurosParaAcrescimo 3.0 ;;
let jurosCalculado = acrescimoParaJuros acrescimoCalculado 15 65 50.0 ;;

(** imprime os resultados *)
print_string "Peso total = " ; print_float pesoTotal; print_newline () ;;
print_string "Acréscimo = " ; print_float acrescimoCalculado; print_newline () ;;
print_string "Juros = " ; print_float jurosCalculado; print_newline () ;;
