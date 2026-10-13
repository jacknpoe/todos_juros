; Cálculo dos juros, sendo que precisa de parcelas pra isso
; Versão 0.1: 01/02/2026: versão feita sem muito conhecimento de Fennel, com 80% da matemática retirada de newLISP
;        0.2: 13/02/2026: alteradas _getPesoTotal, _jurosCompostos e _jurosSimples para permitir Tail Call Optimization (TCO), o for foi trocado por recursão

; variáveis globais para simplificar as chamadas de métodos
(set _G.Quantidade 300000)
(set _G.Composto true)
(set _G.Periodo 30.0)
(set _G.Pagamentos {})
(set _G.Pesos {})

; função recursiva que insere elementos nos arrays
(fn _insereArrays [indice]
  (if (> indice _G.Quantidade)
    0.0
    (do
      (table.insert _G.Pagamentos (* _G.Periodo indice))
      (table.insert _G.Pesos 1.0)
      (_insereArrays (+ indice 1))
    )
  )
)

; função açúcar que insere elementos nos arrays
(fn insereArrays []
  (_insereArrays 1)
)

; função recursiva que calcula a somatória de Pesos[]
(fn _getPesoTotal [indice acumulador]
  (if (= indice 0)
    acumulador
    (_getPesoTotal (- indice 1) (+ (. _G.Pesos indice) acumulador))
  )
)

; função açúcar que calcula a somatória de Pesos[]
(fn getPesoTotal []
  (_getPesoTotal _G.Quantidade 0.0)
)

; função recursiva que calcula a soma do amortecimento de todas as parcelas para juros compostos
(fn _jurosCompostos [indice juros acumulador]
  (if (= indice 0)
    acumulador
    (_jurosCompostos (- indice 1) juros (+ (/ (. _G.Pesos indice) (^ (+ 1.0 (/ juros 100.0)) (/ (. _G.Pagamentos indice) _G.Periodo))) acumulador))
  )
)

; função recursiva que calcula a soma do amortecimento de todas as parcelas para juros simples
(fn _jurosSimples [indice juros acumulador]
  (if (= indice 0)
    acumulador
    (_jurosSimples (- indice 1) juros) (+ (/ (. _G.Pesos indice) (+ 1.0 (* (/ juros 100.0) (/ (. _G.Pagamentos indice) _G.Periodo)))) acumulador)
  )
)

; função que calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
(fn jurosParaAcrescimo [juros]
  (if _G.Composto
      (* (- (/ (getPesoTotal) (_jurosCompostos _G.Quantidade juros 0.0)) 1.0) 100.0)
      (* (- (/ (getPesoTotal) (_jurosSimples _G.Quantidade juros 0.0)) 1.0) 100.0)
  )
)

; função recursiva que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(fn _acrescimoParaJuros [acrescimo minDiferenca iteracaoAtual minJuros maxJuros]
  (if (or (< (- maxJuros minJuros) minDiferenca) (= iteracaoAtual 0))
    (/ (+ minJuros maxJuros) 2.0)
    (if (< (jurosParaAcrescimo (/ (+ minJuros maxJuros) 2.0)) acrescimo)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) (/ (+ minJuros maxJuros) 2.0) maxJuros)
      (_acrescimoParaJuros acrescimo minDiferenca (- iteracaoAtual 1) minJuros (/ (+ minJuros maxJuros) 2.0))
    )
  )
)

; fumção açúcar que calcula os juros a partir do acréscimo e dados comuns (como parcelas)
(fn acrescimoParaJuros [acrescimo precisao maxIteracoes maxJuros]
  (_acrescimoParaJuros acrescimo (^ 0.1 precisao) maxIteracoes 0 maxJuros)
)

; chama a função que insere elementos nos arrays
(insereArrays)

; calcula e guarda os resultados das funções
(local pesoTotal (getPesoTotal))
(local acrescimoCalculado (jurosParaAcrescimo 3.0))
(local jurosCalculado (acrescimoParaJuros acrescimoCalculado 15 65 50.0))

; imprime os resultados
(print (string.format "Peso total = %.15f" pesoTotal))
(print (string.format "Acréscimo = %.15f" acrescimoCalculado))
(print (string.format "Juros = %.15f" jurosCalculado))
