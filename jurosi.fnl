; Cálculo dos juros, sendo que precisa de parcelas pra isso
; Versão 0.1: 01/02/2026: versão feita sem muito conhecimento de Fennel, com 80% da matemática retirada de newLISP
;        0.2: 12/10/2026: versão iterativa

; variáveis globais para simplificar as chamadas de métodos
(set _G.Quantidade 3)
(set _G.Composto true)
(set _G.Periodo 30.0)
(set _G.Pagamentos {})
(set _G.Pesos {})

; calcula a somatória de Pesos[]
(fn getPesoTotal []
  (var acumulador 0.0)
  (for [indice 1 _G.Quantidade]
    (set acumulador (+ acumulador (. _G.Pesos indice)))
  )
  acumulador
)

; calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(fn jurosParaAcrescimo [juros]
  (var pesoTotal (getPesoTotal))
  (if (or (< _G.Quantidade 1) (<= _G.Periodo 0.0) (<= pesoTotal 0.0) (<= juros 0.0))
    0.0
    (do
      (var acumulador 0.0)
      (for [indice 1 _G.Quantidade]
        (if _G.Composto
          (set acumulador (+ acumulador (/ (. _G.Pesos indice) (^ (+ 1.0 (/ juros 100.0)) (/ (. _G.Pagamentos indice) _G.Periodo)))))
          (set acumulador (+ acumulador (/ (. _G.Pesos indice) (+ 1.0 (* (/ juros 100.0) (/ (. _G.Pagamentos indice) _G.Periodo))))))
        )
      )
      (* (- (/ pesoTotal acumulador) 1.0) 100.0)
    )
  )
)

; calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(fn acrescimoParaJuros [acrescimo precisao maxIteracoes maximoJuros]
  (var pesoTotal (getPesoTotal))
  (if (or (< _G.Quantidade 1) (<= _G.Periodo 0.0) (<= pesoTotal 0.0) (<= acrescimo 0.0) (< precisao 1) (< maxIteracoes 1) (<= maximoJuros 0.0))
    0.0
    (do
      (var minJuros 0.0)
      (var medJuros (/ maximoJuros 2.0))
      (var maxJuros maximoJuros)
      (var minDiferenca (^ 0.1 precisao))
      (var indice 0)
      (while (and (< indice maxIteracoes) (> (- maxJuros minJuros) minDiferenca))
        (do
          (if (< (jurosParaAcrescimo medJuros) acrescimo)
            (set minJuros medJuros)
            (set maxJuros medJuros)
          )
          (set medJuros (/ (+ minJuros maxJuros) 2.0))
          (set indice (+ indice 1))
        )
      )
      medJuros
    )
  )
)

; preenche dinamicamente as listas (arrays, tabelas...)
(for [indice 1 _G.Quantidade]
  (table.insert _G.Pagamentos (* _G.Periodo indice))
  (table.insert _G.Pesos 1.0)
)

; calcula e guarda os resultados das funções
(local pesoTotal (getPesoTotal))
(local acrescimoCalculado (jurosParaAcrescimo 3.0))
(local jurosCalculado (acrescimoParaJuros acrescimoCalculado 15 65 50.0))

; imprime os resultados
(print (string.format "Peso total = %.15f" pesoTotal))
(print (string.format "Acréscimo = %.15f" acrescimoCalculado))
(print (string.format "Juros = %.15f" jurosCalculado))
