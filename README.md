# todos_juros

PORTUGUÊS
=========
Este repositório é sobre codificar, em várias linguagens, a mesma solução em matemática financeira. Achar os juros a partir do acréscimo, das datas e pesos das parcelas. Eu uso o Método da Bisseção do Cálculo Numérico para resolvê-la. A ideia é que cada versão se fixe ao máximo à cultura de cada linguagem. Eu uso o mínimo de recursos possível. Eu evito adicionar qualquer biblioteca que eu puder.

Fórmula para calcular o acréscimo a partir dos juros simples:

![Juros Simples](https://github.com/jacknpoe/todos_juros/blob/main/JurosSimples.png)

Fórmula para calcular o acréscimo a partir dos juros compostos:

![Juros Compostos](https://github.com/jacknpoe/todos_juros/blob/main/JurosCompostos.png)

Dois conceitos que pesaram muito foram a exponenciação de números ponto flutuante (implementada em todas as linguagens) e os arrays dinâmicos (que não foram possíveis em Chapel, Modula-2, Pascalzim, Portugol, SuperPascal, VisuALG e XC=BASIC, onde os arrays têm mil elementos, ou três nos casos de Modula-2 e XC=BASIC).

Duas linguagens são consideradas diferentes quando qualquer parte do código tem que ser alterada para ser compilado ou interpretado em ambas. Essa questão ficaria muito complicada, se fosse escolhido um critério mais rígido sobre o quanto uma linguagem precisa ser diferente de outra, o que seria impraticável.

As soluções estão divididas entre as recursivas (Alice, Bend, Clean, Clojure, Common Lisp, DataWeave, Elixir, Elm, Erlang, Haskell, Idris, Lean, Miranda, Ocaml, Prolog, Racket, ReasonML, ReScript, Scheme, SML e Yeti) e iterativas (todas as outras linguagens, incluindo F#).

Existem, em algumas soluções, salvaguardas para valores incorretos para uma aplicação real. São valores zerados e negativos. Em algumas linguagens não é verificado, pois entendeu-se que o público-alvo dessas linguagens não cometeria esse tipo de equívoco.

Algumas implementações não serão mantidas, porque foram feitas em versões de avaliação de ambientes de desenvolvimento pagos, como o Embarcadero Delphi e o EiffelStudio. Após dia 29 de maio de 2024, as linguagens menos utilizadas não terão mais suporte, mesmo tendo IDEs gratuitas.

Alguns arquivos estão ilegíveis, pois são binários e devem ser abertos ou importados nos ambientes das linguagens, como GW-BASIC, Smalltalk, Snap! e twinBASIC.

Linguagens que não terão a solução, por não terem suporte a recursos necessários: Solidify (não tem números de ponto flutuante), Scratch, CHIP-8, Frege e Gosu (não têm exponenciação), Self, Rexx e Bash (não têm exponenciação de números de ponto flutuante). Outras linguagen têm outros problemas, como estarem desatualizadas e não rodam ou compilam nos sistemas atuais. Linguagens que são, na verdade, piadas mal contadas, como Agda, são ignoradas.

A saída mais comum para os testes é:

Peso total = 3.0 / Acréscimo = 6.059108997379403 / Juros = 2.999999999999992

A lista está organizada em ordem alfabética, pelos nomes das linguagens, em: https://jacknpoeexplicaprogramacao.wordpress.com/2024/03/02/10-resolucoes-de-equacao-transcendente/ ou https://github.com/jacknpoe/todos_juros/blob/main/todos_juros.txt

As versões em JavaScript e PHP podem ser testadas a partir de: https://jacknpoe.rf.gd/

A licença é GNU (https://www.gnu.org/licenses/gpl-3.0.html).

ENGLISH
=======
This repository is about coding, in multiple languages, the same solution in financial mathematics. To find the interest based on the increase, dates and weights of the installments. I use the Bisection Method of Numerical Calculus to solve it. The idea is that each version adheres to the culture of each language as much as possible. I use as few resources as possible. I avoid adding any libraries I can.

Formula for calculating the increase from simple interest:

![Simple Interest](https://github.com/jacknpoe/todos_juros/blob/main/JurosSimples.png)

Formula for calculating the increase from compound interest:

![Compound Interest](https://github.com/jacknpoe/todos_juros/blob/main/JurosCompostos.png)

(pesoTotal = totalWeight; quantidade = quantity; pesos = weights; juros = interest; pagamentos = payments; periodo = period)

Two concepts that weighed heavily were the exponentiation of floating point numbers (implemented in all languages) and dynamic arrays (which were not possible in Chapel, Modula-2, Pascalzim, Portugol, SuperPascal, VisuALG and XC=BASIC, where arrays have a thousand elements, or three in tne Modula-2 and XC=BASIC cases).

Two languages ​​are considered different when any part of the code has to be changed to be compiled or interpreted in both. This issue would become very complicated if a stricter criterion were chosen regarding how much one language needs to be different from another, which would be impractical.

The solutions are divided between recursive (Alice, Bend, Clean, Clojure, Common Lisp, DataWeave, Elixir, Elm, Erlang, Haskell, Idris, Lean, Miranda, Ocaml, Prolog, Racket, ReasonML, ReScript, Scheme, SML and Yeti) and iterative (all other languages, including F#).

There are, in some solutions, safeguards for incorrect values ​​for a real application. These are zero and negative values. In some languages ​​it is not verified, as it was understood that the target audience of these languages ​​would not make this type of mistake.

Some implementations will not be maintained because they were done in trial versions of paid development environments such as Embarcadero Delphi and EiffelStudio. After May 29, 2024, less used languages ​​will no longer be supported, even though they have free IDEs.

Some files are unreadable, as they are binary and must be opened or imported into the language environments, such as GW-BASIC, Smalltalk, Snap! and twinBASIC.

Languages ​​that will not have the solution, as they do not support the necessary resources: Solidify (does not have floating point numbers), Scratch, CHIP-8, Frege and Gosu (does not have exponentiation), Self, Rexx and Bash (does not have exponentiation of floating point numbers). Other languages ​​have other problems, such as being outdated and not running or compiling on current systems. Languages that are actually poorly told jokes, like Agda, are ignored.

The most common output for tests is:

Peso total = 3.0 / Acréscimo = 6.059108997379403 / Juros = 2.999999999999992

The list is organized alphabetically, by languages names: https://jacknpoeexplicaprogramacao.wordpress.com/2024/03/02/10-resolucoes-de-equacao-transcendente/ or https://github.com/jacknpoe/todos_juros/blob/main/todos_juros.txt

JavaScript and PHP versions can be tested from: https://jacknpoe.rf.gd/

The license is GNU (https://www.gnu.org/licenses/gpl-3.0.html).

![52](https://github.com/jacknpoe/todos_juros/blob/main/resolu%C3%A7%C3%B5es.jpg)
