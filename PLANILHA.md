# Planilha

![Planilha](https://github.com/jacknpoe/todos_juros/blob/main/planilha.jpg)

PORTUGUÊS
=========

A planilha [juros.xlsx](https://github.com/jacknpoe/todos_juros/blob/main/juros.xlsx) (Cálculo de Acréscimos) implementa o algoritmo `jurosParaAcrescimo` utilizado neste projeto. Seu objetivo é servir como referência para validação das implementações nos diversos dialetos de programação e também como ferramenta para experimentação com diferentes períodos, pagamentos, pesos e taxas de juros. Usando a ferramenta `Goal Seek` (`Atingir Meta`) também se pode implementar o algoritmo `acrescimoParaJuros`.

O cálculo dos acréscimos a partir dos juros é direto. Os valores das células `Quantidade`, `Período` e `Juros` podem ser alterados livremente como nos testes inclusos nas soluções. Na tabela de `Parcelas`, os valores da colula `Peso` serão preenchidos com os valores 1.0 ou 0.0, de acordo com a célula `Quantidade`. Os valores da coluna `Pagamento` serão preenchidos com o valor na célula `Período`, multiplicado pelos valores na coluna `Número`. Ambas as colunas `Peso` e `Pagamento` podem ser editadas diretamente nas células, sobrescrevendo esses cálculos padrão.

O cálculo dos juros a partir do acréscimo deve ser feito usando a ferramenta `Goal Seek` (`Atingir Meta`). A `célula de fórmula` deve ser ou a célula de `Acréscimo` dos `Juros Simples` (célula $D$19) ou a célula de `Acréscimo` dos `Juros Compostos` ($E$19). No `valor de destino`, coloque o valor do `Acréscimo` pretendido, mas em % (ou seja, para 10% escreva 0,1). Em `Célula variável` coloque a célula `Juros` ($D$3).
