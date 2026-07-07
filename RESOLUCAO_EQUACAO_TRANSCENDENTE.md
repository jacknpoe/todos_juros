# Resolução de Equação Transcendente

Existem equações que não podem ser resolvidas com métodos elementares. São as chamadas [equações transcendentes](https://pt.wikipedia.org/wiki/Equa%C3%A7%C3%A3o_transcendente). Você precisa aplicar um conceito de `Cálculo Numérico` chamado `Método da Bisseção` para resolvê-las. Esse método é utilizado para procurar os zeros das funções. Aqui, iremos resolver uma dessas equações, que é o cálculo do percentual de juros a partir do percentual de acréscimo de um conjunto de parcelas ponderadas.

Nosso projeto será em `Python`, por simplicidade, mas as outras soluções neste repositório seguem as mesmas estrutura e lógica. Começamos colocando, em `Juros.py`, alguns valores básicos, que mudam pouco, e que iremos guardar como atributos em nossa classe `Juros`:

![atributos](juros_python_atributos.png)

Temos **três** atributos simples, a quantidade total de pagamentos (`Quantidade`), se os juros são **compostos** (`Composto`), e a quantidade de dias sobre os quais os juros incidem (por exemplo, a cada **30** dias) (`Periodo`). E **dois** atributos arrays: a quantidade de dias de prazo de cada pagamento (por exemplo, **0**, **30**, **60** e **90** dias) (`Pagamentos`), e os pesos de cada pagamento (por exemplo, se a parcela a vista fosse o dobro das demais, ficaria **2.0**, **1.0**, **1.0**, **1.0**) (`Pesos`).

Nosso construtor irá permitir a definição dos **três** atributos simples:

![construtor](juros_python_construtor.png)

O array `Pagamentos` terá um método para incluir elementos a partir de uma *string*:

![setpagamentos](juros_python_setpagamentos.png)

Ele recebe um delimitador e uma *string* de números separados pelo delimitador (Exemplo: **“,”**, **“0,30,60,90”**). Por padrão, se a *string* for vazia, os valores no array serão incluídos com os valores de `Periodo` vezes o número da parcela (considerando a primeira como **1**). Por exemplo, com `Periodo` = **30.0**, para **30.0**, **60.0**, **90.00**...  até a `Quantidade` de parcelas.

O array `Pesos` terá um método parecido:

![setpesos](juros_python_setpesos.png)

A diferença nesse método é que, se a *string* for vazia, todos os pesos serão incluídos com o valor para **1.0**, significando que todas as parcelas têm o mesmo valor.

Vejamos como são feitos os cálculos.

**Juros simples**:

![Juros Simples](JurosSimples.jpg)

**Juros copostos**:

![Juros Compostos](JurosCompostos.jpg)

Um método que precisamos definir antes de nossos cálculos é a soma dos pesos das parcelas (`pesoTotal`):

![getpesototal](juros_python_getpesototal.png)

O **Método da Bisseção** precisa ter uma função para chamar. Na nossa solução, ela calcula os juros a partir do acréscimo e dos atributos do objeto. A função é `jurosparacrescimo`:

![jurosparaacrescimo](juros_python_jurosparaacrescimo.png)

Esse método recebe o percentual de juros.

Calculamos o peso total, guardando em `pesototal`. A variável será usada para produzir o resultado final.

Avaliamos se ao menos um valor entre `juros`, `Quantidade`, `Periodo` ou `pesototal` é zero ou negativo, o que faz o método retornar **zero**. Essa avaliação elimina boa parte do uso errado do método. Na prática, apenas se um elemento em `Pagamentos` for em negativo vezes `Periodo` causará uma divisão por zero. Mas os arrays não estão sendo avaliados nessa versão, por fins didáticos.

Inicializamos o `acumulador` que somará o peso ponderado das parcelas (que é a contribuição que cada parcela tem em pagar o valor total, deduzindo-se os juros).

Iteramos a quantidade de parcelas. Incrementamos `acumulador`, o peso ponderado das parcelas, usando o cálculo dos **juros compostos** ou o cálculo dos **juros simples**, de acordo com `Composto` .

Retornamos zero se `acumulador` for zero ou negativo (porque poderia gerar uma divisão por zero ou resultados absurdos.

O valor do acréscimo é calculado dividindo `pesototal` pelo peso ponderado pelos juros `acumulador`, diminuindo **um** e multiplicando por **cem**. Por exemplo, se o valor da divisão for **1,03**, o resultado será **3%**.

Podemos escrever, agora, o método que é o objetivo desse repositório, `acrescimoparajuros`:

![acrescimoparajuros](juros_python_acrescimoparajuros.png)

Os parâmetros desse método já são um pouco mais complicados. Recebemos o `acrescimo`, podemos escolher quantas casas depois da vírgula teremos de `precisao`, o máximo de iterações que o método irá aplicar, `maximoiteracoes`, e o máximo de juros que o método irá usar no começo, `maximojuros` . Apenas `acrescimo` é absolutamente necessário, pois os valores padrão dos outros parâmetros já bastam para fazer o cálculo, na maioria das situações.

Primeiro, calculamos o `pesototal`. Aqui ela não é usada para cálculos, apenas para validação.

Então testamos se alguns valores estão são iguais ou menores a **zero** (`maximoiteracoes`, `Quantidade`, `precisao`, `Periodo`, `acrescimo`, `pesototal` e `maximojuros`), se sim, retornamos **zero**.

Nós iniciamos o minimo de juros como **zero**, `minimojuros` e média de juros como metade de `maximojuros`, `mediojuros`.

Em `minimadiferenca`, guardamos o valor da precisão que queremos, em `precisao` de casas decimais, para podermos avaliar quando o algoritmo pode parar (por exemplo, **0.0001** quando definimos `precisao` como **4**).

Na iteração, pŕimeiro verificamos se os valores atuais em `maximojuros` e `minimojuros` diferirem menos do que `minimadiferenca`, quando nós retornamos a média que se encontra em `mediojuros`, pois já encontramos o resultado com a precisão que queremos.

A **mágica** do algoritmo que estamos implementando estão no próximo `if`. Nós chamamos o método `jurosparaacrescimo` para calcularmos se, com o valor de `mediojuros` atual, o resultado do método fica maior ou menor do que o parâmetro `acrescimo`. Se for menor ou igual, nós alteramos `minimojuros` para `mediojuros`. Se for maior, nós alteramos `maximojuros` para `mediojuros`.

A coisa mais importante, no algoritmo, é que ele tem esses dois valores, `minimojuros` e `maximojuros` que, a cada iteração, têm a sua diferença cortada pela metade. Eventualmente, a diferença pode ficar menor do que a precisão que queremos. Veja que `minimojuros` será sempre menor ou igual e `maximojuros` será sempre maior ou igual ao valor que estamos procurando.

A última coisa feita no laço é atualizar `mediojuros` para ser a média entre `minimojuros` e `maximojuros`.

Se o número de iterações alcançar `maximoiteracoes`, o valor de `mediojuros` será retornado, mesmo que não se alcance a precisão que calculamos em `minimadiferenca`. Isso é muito importante quando, por exemplo, por uma questão de implementação dos números de ponto flutuante, não for possível encontrar uma diferença entre `minimojuros` e `maximojuros` menor do que `minimadiferenca`.

Para mais detalhes, pesquise por **Método da Bisseção**.

Para testar a nossa classe, criamos um main.py:

![main](juros_python_main.png)

Nós importamos `Juros`. Criamos um objeto com **três** parcelas, juros **compostos** e com períodos de **trinta** dias. Chamamos `juros.setpagamentos` e `juros.setpesos` sem parâmetros, para que `juros.pagamentos` seja igual a [**30.0**, **60.0**, **90.0**] e `juros.pesos` seja igual a [**1.0**, **1.0**, **1.0**].

Calculamos o peso total. Calculamos o acréscimo a partir de **3%** de juros. E fazemos o cálculo inverso, usando `acrescimocalculadl` no parâmetro `acrescimo`, sem alterar os valores padrão de `juros.acrescimoparajuros` (**15** para `precisao`, **65** para `maximoiteracoes` e **50.0** para `maximojuros`).

Depois imprimos os três resultados.

O resultado deve ser algo parecido com isso:

``` console
Peso total = 3.0
Acréscimo = 6.059108997379403
Juros = 3.0000000000000133
```
