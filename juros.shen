\\ Cálculo dos juros, sendo que precisa de parcelas pra isso
\\ Versão 0.1: 09/06/2026: feita sem muito conhecimento de Shen
\\        0.2: 26/08/2026: tentativa de alterar funções recursivas para permitir Tail Call Optimization
\\        0.3: 09/10/2026: versão mista, que usa TCO onde poderiam acontecer problemas de segurança (nomeadamente rJurosCompostos e rJurosSimples)
\\                         TCO não se traduziu em melhor performance (quase o contrário) mas, de acordo com a documentação, é seguro para a pilha
\\                         conds foram trocados por ifs, por performance (embora influencie pouco) e semântica; tc - desativa verificação de tipos
\\ CONDIÇÕES: não informe números negativos fora da realidade, a solução será correta dentro do domínio do problema

\\ ############### FUNÇÕES FORA DO DOMÍNIO DO PROBLEMA, IMPLEMENTAM EXPONENCIAÇÕES ###############

\\ função recursiva que calcula o logaritmo natural usando uma série de Taylor
(define rLog Indice Ip Termo Soma ->
    (if (= (+ Soma Termo) Soma) 
        (* 2.0 Soma)
        (rLog (+ Indice 1) Ip (* Termo Ip Ip) (+ Soma (/ Termo (- (* 2.0 Indice) 1.0))))
    )
)

\\ função açúcar que calcula o logaritmo natural; converge corretamente para os valores do domínio do problema
(define log Valor -> (rLog 1 (/ (- Valor 1.0) (+ Valor 1.0)) (/ (- Valor 1.0) (+ Valor 1.0)) 0.0))

\\ função recursiva que calcula o exponencial natural usando uma série  de Taylor
(define rExp Indice Valor Termo Soma ->
    (if (= (+ Soma Termo) Soma) 
        Soma
        (rExp (+ Indice 1) Valor (/ (* Termo Valor) (+ Indice 1)) (+ Soma Termo))
    )
)

\\ função açúcar que calcula o exponencial natural; converge mais rapidamente quanto menor o Valor
(define exp Valor -> (rExp 1 Valor Valor 1.0))

\\ calcula base elevado a expoente usando as funções log e exp
(define pow Base Expoente -> (exp (* (log Base) Expoente)))

\\ função recursiva que calcula base elevado a expoente inteiro (para 0.1 ^ 15)
(define rPowint Base Expoente Acumulador ->
    (if (<= Expoente 0) 
        Acumulador
        (rPowint Base (- Expoente 1) (* Base Acumulador))
    )
)

\\ função açúcar que calcula base elevado a expoente inteiro (para 0.1 ^ 15)
(define powint Base Expoente -> (rPowint Base Expoente 1.0))

\\ ############### FUNÇÕES E DECLARAÇÕES DENTRO DO DOMÍNIO DO PROBLEMA (MATEMÁTICA FINANCEIRA) ###############

\\ função recursiva que monta a lista Pagamentos
(define rCriaPagamentos
  0 -> []
  Indice -> (cons (* Indice (value *Periodo*)) (rCriaPagamentos (- Indice 1)))
)

\\ função açúcar que monta a lista Pagamentos
(define criaPagamentos -> (rCriaPagamentos (value *Quantidade*)))

\\ função recursiva que monta a lista Pesos
(define rCriaPesos
  0 -> []
  Indice -> (cons 1.0 (rCriaPesos (- Indice 1)))
)

\\ função açúcar que monta a lista Pesos
(define criaPesos -> (rCriaPesos (value *Quantidade*)))

\\ função recursiva que calcula a somatória da lista Pesos
(define rGetPesoTotal
    [] Acumulador -> Acumulador
    [HPes|TPes] Acumulador -> (rGetPesoTotal TPes (+ HPes Acumulador))
)

\\ função açúcar que calcula a somatória da lista Pesos
(define getPesoTotal -> (rGetPesoTotal (value *Pesos*) 0.0))

\\ função recursiva que calcula a somatória das amortizações dos Juros Compostos
(define rJurosCompostos
    _ [] [] Acumulador -> Acumulador
    Juros [HPag|TPag] [HPes|TPes] Acumulador -> (rJurosCompostos Juros TPag TPes (+ (/ HPes (pow (+ 1.0 (/ Juros 100.0)) (/ HPag (value *Periodo*)))) Acumulador))
)

\\ função recursiva que calcula a somatória das amortizações dos Juros Simples
(define rJurosSimples
    _ [] [] Acumulador -> Acumulador
    Juros [HPag|TPag] [HPes|TPes] Acumulador -> (rJurosSimples Juros TPag TPes (+ (/ HPes (+ 1.0 (* (/ Juros 100.0) (/ HPag (value *Periodo*))))) Acumulador))
)

\\ função que calcula o acréscimo a partir dos juros e parcelas (com uma pitada de açúcar)
(define jurosParaAcrescimo Juros ->
    (if (value *Composto*) 
        (* (- (/ (getPesoTotal) (rJurosCompostos Juros (value *Pagamentos*) (value *Pesos*) 0.0)) 1.0) 100.0)
        (* (- (/ (getPesoTotal) (rJurosSimples Juros (value *Pagamentos*) (value *Pesos*) 0.0)) 1.0) 100.0)
    )
)

\\ função recursiva que calcula os juros a partir do acréscimo e parcelas
(define rAcrescimoParaJuros Acrescimo MinDiferenca Iteracao MinJuros MaxJuros MedJuros ->
    (if (or (= Iteracao 0) (< (- MaxJuros MinJuros) MinDiferenca)) 
        MedJuros
        (if (< (jurosParaAcrescimo MedJuros) Acrescimo) 
            (rAcrescimoParaJuros Acrescimo MinDiferenca (- Iteracao 1) MedJuros MaxJuros (/ (+ MedJuros MaxJuros) 2.0))
            (rAcrescimoParaJuros Acrescimo MinDiferenca (- Iteracao 1) MinJuros MedJuros (/ (+ MinJuros MedJuros) 2.0)))
    )
)

\\ função açúcar que calcula os juros a partir do acréscimo e parcelas
(define acrescimoParaJuros Acrescimo Precisao MaxIteracoes MaxJuros ->
    (rAcrescimoParaJuros Acrescimo (powint 0.1 Precisao) MaxIteracoes 0.0 MaxJuros (/ MaxJuros 2.0))
)

\\ função main de testes
(define main ->
    (do
        \\ variáveis globais escalares para simplificar as chamadas às funções
        (set *Quantidade* 3000)
        (set *Composto* true)
        (set *Periodo* 30.0)

        \\ listas globais para simplificar as chamadas às funções
        \\ (output "antes de listas~%")
        (set *Pagamentos* (criaPagamentos))
        \\ (output "depois de pagamentos~%")
        (set *Pesos* (criaPesos))
        \\ (output "depois de pesos~%")

        \\ calcula e guarda os retornos das funções
        (let PesoTotal (getPesoTotal)
             AcrescimoCalculado (jurosParaAcrescimo 3.0)
             JurosCalculado (acrescimoParaJuros AcrescimoCalculado 15 65 50.0)

            \\ imprime os resultados
            (do
                (output "Peso total = ~A~%" PesoTotal)
                (output "Acrescimo = ~A~%" AcrescimoCalculado)
                (output "Juros = ~A~%" JurosCalculado)
                true            
            )
        )
    )
)

\\ use essa função quando quiser medir o tempo de execução
(define mede -> 
    (do (tc -)
    (time (main))))
