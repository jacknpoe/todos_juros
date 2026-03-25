# ; Cálculo do juros, sendo que precisa de arrays pra isso
# ; Versão 0.1: 24/03/2026: versao feita sem muito conhecimento de Picolisp
# ;             25/03/2026: (maxJuros - minJuros) <= minDiferenca (em vez de < ) e (if (not (car pesos) 0 em lugar de sobre cdr
# ; AVISOS: algumas verificações foram retiradas, então os calculos são indefinidos para valores incorretos

# ; a primeira parte não é domínio do problema, mas a matemática mais básica, de ponto fixo, para a parte financeira

# ; variáveis globais para facilitar escrita e leitura (mude apenas DIGITOS e todas as outras irão mudar em sequência)
(setq DIGITOS 8)
(setq ESCALA (** 10 DIGITOS))
(setq TOTLN (* 2 DIGITOS))
(setq TOTEXP (* 3 DIGITOS))
(setq UM ESCALA)
(setq MEIO (/ UM 2))
(setq INFINITO (* ESCALA ESCALA))

# ; torna um integer em fixed-point com DIGITOS de digitos (usando ESCALA que ja esta computada)
(de itof (x)
  (* x ESCALA)
)

# ; operacao / de dois fixed-points
(de divfp (a b)
  (if (= b 0)
    INFINITO  # divisao por zero retorna valor fora do dominio do problema (ou nao trate aqui, se preferir)
    (if (< (* a b) 0)
      (/ (- (* a ESCALA) (/ b 2)) b)
      (/ (+ (* a ESCALA) (/ b 2)) b)
    )
  )  
)

# ; operacao * de dois fixed-points
(de mulfp (a b)
  (if (< (* a b) 0)
    (/ (- (* a b) MEIO) ESCALA)
    (/ (+ (* a b) MEIO) ESCALA)
  )
)

# ; função recursiva que calcula o logaritmo natural usando a série de Taylor
(de _lnfp (indice ip termo soma)
  (if (> indice TOTLN)
    (* 2 soma)
    (_lnfp (+ indice 1) ip (mulfp termo (mulfp ip ip)) (+ soma (/ termo (- (* 2 indice) 1))))
  )
)

# ; logaritmo natural em fixed-point usando serie via (x-1)/(x+1); preciso e estavel no dominio do problema de matematica financeira;
# ; apresenta melhor convergencia para valores proximos de 1; a precisao depende de TOTLN e da escala fixa adotada
(de lnfp(valor)
  (_lnfp 1 (divfp (- valor UM) (+ valor UM)) (divfp (- valor UM) (+ valor UM)) 0)
)

# ; função recursiva que calcula o exponencial natural usando a série de Taylor
(de _expfp (indice valor termo soma)
  (if (> indice TOTEXP)
    soma
    (_expfp (+ indice 1) valor (/ (mulfp termo valor) (+ indice 1)) (+ soma termo))
  )
)

# ; exponencial em fixed-point usando serie de Taylor; precisa e estavel no dominio do problema (expoentes pequenos,
# ; tipicamente derivados de lnfp em matematica financeira); a precisao depende de TOTEXP e da escala fixa adotada */
(de expfp (valor)
  (_expfp 1 valor valor UM)
)

# ; calcula base elevado a expoente usando a função expnat e lognat
(de powfp (base expoente)
  (expfp (mulfp expoente (lnfp base)))
)

# ; calcula a mínima diferença com digitos de precisao
(de pretomin (precisao)
  (** 10 (- DIGITOS precisao))
)

# ; a partir daqui é domínio do problema

# ; variáveis globais para simplificar as chamadas às funções
(setq Quantidade 3)
(setq Composto 1)
(setq Periodo (itof 30))
(setq Pagamentos NIL)
(setq Pesos NIL)

# ; função recursiva que inicializa Pagamentos
(de _initPagamentos (indice)
  (if (= indice 0)
    NIL
    (push 'Pagamentos (* indice Periodo))
    (_initPagamentos (- indice 1))
  )
)

# ; função que inicializa Pagamentos
(de initPagamentos ()
  (_initPagamentos Quantidade)
)

# ; função recursiva que inicializa Pesos
(de _initPesos (indice)
  (if (= indice 0)
    NIL
    (push 'Pesos UM)
    (_initPesos (- indice 1))
  )
)

# ; função que inicializa Pesos
(de initPesos ()
  (_initPesos Quantidade)
)

# ; função recursiva no lugar de um for com acumulador que realmente calcula a somatória de Pesos[]
(de _getPesoTotal (pesos)
  (if (not (car pesos))
    0
    (+ (_getPesoTotal (cdr pesos)) (car pesos))
  )
)

# ; calcula a somatória de Pesos[]
(de getPesoTotal ()
  (_getPesoTotal Pesos)
)

# ; calcula a soma do amortecimento de todas as parcelas para juros compostos
(de _jurosCompostos (juros pagamentos pesos)
  (if (not (car pesos))
    0
    (+ (divfp (car pesos) (powfp (+ UM (/ juros 100)) (divfp (car pagamentos) Periodo))) (_jurosCompostos juros (cdr pagamentos) (cdr pesos)))
  )
)

# ; calcula a soma do amortecimento de todas as parcelas para juros simples
(de _jurosSimples (juros pagamentos pesos)
  (if (not (car pesos))
    0
    (+ (divfp (car pesos) (+ UM (mulfp (/ juros 100) (divfp (car pagamentos) Periodo)))) (_jurosSimples juros (cdr pagamentos) (cdr pesos)))
  )
)

# ; calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(de jurosParaAcrescimo (juros)
  (if (> Composto 0)
    (* (- (divfp (getPesoTotal) (_jurosCompostos juros Pagamentos Pesos)) UM) 100)
    (* (- (divfp (getPesoTotal) (_jurosSimples juros Pagamentos Pesos)) UM) 100)
  )
)

# ; função recursiva no lugar de um for que realmente calcula os juros
(de _acrescimoParaJuros (acrescimo minDiferenca iteracaoAtual minJuros maxJuros)
  (if (<= (- maxJuros minJuros) minDiferenca)
    (/ (+ minJuros maxJuros) 2)
    (if (> iteracaoAtual 0)
      (if (< (jurosParaAcrescimo (/ (+ minJuros maxJuros) 2)) acrescimo)
        (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) (/ (+ minJuros maxJuros) 2) maxJuros)
        (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros (/ (+ minJuros maxJuros) 2))
      )
      (/ (+ minJuros maxJuros) 2)
    )
  )
)

# ; calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(de acrescimoParaJuros (acrescimo precisao maxIteracoes maxJuros)
  (_acrescimoParaJuros acrescimo (pretomin precisao) maxIteracoes 0 maxJuros)
)

# ; inicializa as listas
(initPagamentos)
(initPesos)

# ; calcula e guarda os resultados das funções
(setq pesoTotal (getPesoTotal))
(setq acrescimoCalculado (jurosParaAcrescimo (itof 3)))
(setq jurosCalculado (acrescimoParaJuros acrescimoCalculado DIGITOS (* DIGITOS 4) (itof 50)))

# ; imprime os resultados
(prinl "Peso total = " (format pesoTotal DIGITOS))
(prinl "Acréscimo = " (format acrescimoCalculado DIGITOS))
(prinl "Juros = " (format jurosCalculado DIGITOS))
(bye)
