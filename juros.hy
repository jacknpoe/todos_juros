#!/usr/bin/env hy
; Cálculo dos juros, sendo que precisa de parcelas pra isso
; Versão 0.1: 15/03/2025: versão feita sem muito conhecimento de Hy

; define variáveis que, na verdade, são constantes (Composto 1 é TRUE)
(setv Quantidade 3 Composto 1 Periodo 30.0 Pagamentos [30.0 60.0 90.0] Pesos [1.0 1.0 1.0])

; calcula a somatória de Pesos[]
(defn getPesoTotal [Quantidade Pesos]
    (setv acumulador 0.0 indice 0)
    (while (< indice Quantidade)
        (setv acumulador (+ acumulador (get Pesos indice)))
        (setv indice (+ indice 1))
    )
    acumulador
)

; calcula o acréscimo a partir dos juros e parcelas
(defn jurosParaAcrescimo [Quantidade Composto Periodo Pagamentos Pesos juros]
    (setv pesoTotal (getPesoTotal Quantidade Pesos) acumulador 0.0 indice 0)
    (while (< indice Quantidade)
        (if (= Composto 1)
            (do
                (setv acumulador (+ acumulador (/ (get Pesos indice) (** (+ 1.0 (/ juros 100.0)) (/ (get Pagamentos indice) Periodo)))))
            )
            (do
                (setv acumulador (+ acumulador (/ (get Pesos indice) (+ 1.0 (* (/ juros 100.0) (/ (get Pagamentos indice) Periodo))))))
            )
        )
        (setv indice (+ indice 1))
    )
    (* (- (/ pesoTotal acumulador) 1.0) 100.0)
)

; calcula os juros a partid do acréscimo e parcelas
(defn acrescimoParaJuros [Quantidade Composto Periodo Pagamentos Pesos acrescimo precisao maxIteracoes maxJuros]
    (setv minJuros 0.0 medJuros (/ maxJuros 2.0) minDiferenca (** 0.1 precisao) indice 0)
    (while (< indice maxIteracoes)
        (setv medJuros (/ (+ minJuros maxJuros) 2.0))
        (if (< (- maxJuros minJuros) minDiferenca)
            (setv indice maxIteracoes)
            (if (< (jurosParaAcrescimo Quantidade Composto Periodo Pagamentos Pesos medJuros) acrescimo)
                (setv minJuros medJuros)
                (setv maxJuros medJuros)
            )
        )
    )
    medJuros
)

; calcula e guarda os resultados das funções
(setv pesoTotal (getPesoTotal Quantidade Pesos))
(setv acrescimoCalculado (jurosParaAcrescimo Quantidade Composto Periodo Pagamentos Pesos 3.0))
(setv jurosCalculado(acrescimoParaJuros Quantidade Composto Periodo Pagamentos Pesos acrescimoCalculado 15 100 50.0))

; imprime os resultados
(print "Peso total =" pesoTotal)
(print "Acréscimo =" acrescimoCalculado)
(print "Juros =" jurosCalculado)