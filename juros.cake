;; Cálculo do juros, sendo que precisa de arrays pra isso
;; Versão 0.1: 11/04/2025: criado a partir da versão em Emacs Lisp sem muito conhecimento de Cakelisp
;;        0.2: 16/02/2026: na verdade, só agora foi convertido, a sintaxe é muito distante dos outros Lisp
;;                         exemplos: c-imports, pow, at, return, declarações e tipos nos parâmetros e de retorno
;;                         a solução foi testada até 300.000 parcelas, mas com ulimit -s 65536, talvez precise dessa pilha

(c-import "<stdio.h>")
(c-import "<math.h>")

;; Variáveis
(var Quantidade int 3)
(var Composto int 1)
(var Periodo double 30.0)
(var Pagamentos (array 3 double))
(var Pesos (array 3 double))

;; função recursiva que inicializa Pagamentos
(defun _initPagamentos(indice int &return void)
  (if (< indice 0)
      (return)
      (set (at indice Pagamentos) (* 30.0 (+ indice 1)))
  )
  (_initPagamentos (- indice 1))
)

;; função que inicializa Pagamentos
(defun initPagamentos(&return void)
  (_initPagamentos (- Quantidade 1))
)

;; função recursiva que inicializa Pesos
(defun _initPesos(indice int &return void)
  (if (< indice 0)
      (return)
      (set (at indice Pesos) 1.0)
  )
  (_initPesos (- indice 1))
)

;; função que inicializa Pesos
(defun initPesos(&return void)
  (_initPesos (- Quantidade 1))
)

;; calcula a somatória de Pesos[]
(defun getPesoTotal(&return double)
  (return (_getPesoTotal(- Quantidade 1)))
)

;; função recursiva no lugar de um for com acumulador que realmente calcula a somatória de Pesos[]
(defun _getPesoTotal(valor int &return double)
  (if (= valor 0)
    (return (at 0 Pesos))
    (return (+ (at valor Pesos) (_getPesoTotal(- valor 1))))
  )
)

;; calcula a soma do amortecimento de todas as parcelas para juros compostos
(defun _jurosCompostos(valor int juros double &return double)
  (if (= valor 0)
    (return (/ (at 0 Pesos) (pow (+ 1.0 (/ juros 100.0)) (/ (at 0 Pagamentos) Periodo))))
    (return (+ (/ (at valor Pesos) (pow (+ 1.0 (/ juros 100.0)) (/ (at valor Pagamentos) Periodo))) (_jurosCompostos (- valor 1) juros)))
  )
)

;; calcula a soma do amortecimento de todas as parcelas para juros simples
(defun _jurosSimples(valor int juros double &return double)
  (if (= valor 0)
    (return (/ (at 0 Pesos) (+ 1.0 (* (/ juros 100.0) (/ (at 0 Pagamentos) Periodo)))))
    (return (+ (/ (at valor Pesos) (+ 1.0 (* (/ juros 100.0) (/ (at valor Pagamentos) Periodo)))) (_jurosSimples (- valor 1) juros)))
  )
)

;; calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(defun jurosParaAcrescimo(juros double &return double)
  (if (= Composto 1)
      (return (* (- (/ (getPesoTotal) (_jurosCompostos(- Quantidade 1) juros)) 1.0) 100.0))
      (return (* (- (/ (getPesoTotal) (_jurosSimples(- Quantidade 1) juros)) 1.0) 100.0))
  )
)

;; função recursiva no lugar de um for que realmente calcula os juros
(defun _acrescimoParaJuros(acrescimo double minDiferenca double iteracaoAtual int minJuros double maxJuros double &return double)
  (if (or (< (- maxJuros minJuros) minDiferenca) (= iteracaoAtual 0))
    (return (/ (+ minJuros maxJuros) 2.0))
    (if (< (jurosParaAcrescimo (/ (+ minJuros maxJuros) 2.0)) acrescimo)
      (return (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) (/ (+ minJuros maxJuros) 2.0) maxJuros))
      (return (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros (/ (+ minJuros maxJuros) 2.0)))
    )
  )
)

;; calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(defun acrescimoParaJuros(acrescimo double precisao int maxIteracoes int maxJuros double &return double)
  (return (_acrescimoParaJuros acrescimo (pow 0.1 precisao) maxIteracoes 0.0 maxJuros))
)

(defun main (&return int)
  (initPagamentos)
  (initPesos)

  (fprintf stdout "Peso total = %.15f\n" (getPesoTotal))
  (fprintf stdout "Acréscimo = %.15f\n" (jurosParaAcrescimo 3.0))
  (fprintf stdout "Juros = %.15f\n" (acrescimoParaJuros (jurosParaAcrescimo 3.0) 15 100 50.0))
  (return 0)
)
