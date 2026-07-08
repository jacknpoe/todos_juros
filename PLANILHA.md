# PLANILHA

<br>

![Planilha](planilha.png)

<br>

A planilha [juros.xlsx](juros.xlsx) (**Cálculo de Acréscimos**) implementa o algoritmo `jurosParaAcrescimo` utilizado neste projeto. Seu objetivo é servir como referência para validação das implementações nos diversos dialetos de programação e também como ferramenta para experimentação com diferentes **períodos**, **pagamentos**, **pesos** e **taxas de juros**. Usando a ferramenta `Goal Seek` (`Atingir Meta`) também é possível obter o resultado do algoritmo `acrescimoParaJuros`. A planilha está limitada a até `12` `Parcelas`, embora com alterações possa ser escalada mantendo a mesma lógica.

O cálculo dos acréscimos a partir dos juros (`jurosParaAcrescimo`) é direto. Os valores das células `Quantidade`, `Período` e `Juros` podem ser alterados livremente como nos casos de teste incluídos nas soluções. Na tabela de `Parcelas`, os valores da coluna `Peso` serão preenchidos com os valores `1.0` ou `0.0`, de acordo com a célula `Quantidade`. Pode-se ver como isso funciona na imagem acima. Quando a `Quantidade` é `3`, apenas os três primeiros pesos são `1.0`, os restantes ficam com o valor `0.0`, o que, efetivamente, os exclui dos cálculos. Os valores da coluna `Pagamento` serão preenchidos com o valor na célula `Período`, multiplicado pelos valores na coluna `Número`. As colunas `Número`, `Peso` e `Pagamento` podem ser editadas diretamente nas células, sobrescrevendo valores e fórmulas padrão.

O cálculo dos juros a partir do acréscimo (`acrescimoParaJuros`) deve ser feito usando a ferramenta `Goal Seek` (`Atingir Meta`). A `Célula de fórmula` deve ser ou a célula de `Acréscimo` dos `Juros Simples` (célula $D$19) ou a célula de `Acréscimo` dos `Juros Compostos` ($E$19). No `Valor de destino`, coloque o valor do `Acréscimo` pretendido, mas em percentual (inclua `%`, como em `10%`). Em `Célula variável` coloque a célula `Juros` ($D$3).
