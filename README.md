# todos_juros

PORTUGUÊS
=========
Este repositório é sobre codificar, em vários dialetos, a mesma solução em matemática financeira. Achar os juros a partir do acréscimo, das datas e pesos das parcelas. Eu uso o Método da Bisseção do Cálculo Numérico para resolvê-la. A ideia é que cada versão se fixe ao máximo à cultura de cada dialeto. Eu uso o mínimo de recursos possível. Eu evito adicionar qualquer biblioteca que eu puder.

O foco é resolver o problema de Matemática Financeira usando Cálculo Numérico. Então, alguns dialetos que exigiriam um conhecimento maior de matemática, como exponenciação de números de ponto flutuante, estão sendo preteridos até o momento.

É uma "Pedra de Roseta" sobre dialetos de programação.

Tirando a pasta "terceiros", todas as soluções foram escritas por https://github.com/jacknpoe, sendo que apenas em BBC Basic foi utilizada uma forma simplificada de "tradução", sendo que o código precisou ser completamente revisado para poder rodar apropriadamente.

Fórmula para calcular o acréscimo a partir dos juros simples:

![Juros Simples](https://github.com/jacknpoe/todos_juros/blob/main/JurosSimples.jpg)

Fórmula para calcular o acréscimo a partir dos juros compostos:

![Juros Compostos](https://github.com/jacknpoe/todos_juros/blob/main/JurosCompostos.jpg)

Apenas soluções que compilaram (ou foram corretamente interpretadas), que realmente rodaram, e retornaram resultados corretos, são publicadas.

Uma das metas é que os compiladores e interpretadores não exibam avisos ao compilar ou rodar as soluções. Em IDEs integradas, os avisos também foram evitados. 

Dois conceitos que pesaram muito foram a exponenciação de números ponto flutuante (implementada em todos os dialetos) e os arrays dinâmicos (que não foram possíveis, por exemplo, em Chapel, Modula-2, MSX Turbo Pascal, Pascalzim, Portugol, VisuALG e XC=BASIC e, nesses casos, os arrays podem ter três ou mil elementos).

Dois dialetos são consideradas diferentes quando qualquer parte do código tem que ser alterada para ser compilado ou interpretado em ambos. Essa questão ficaria muito complicada, se fosse escolhido um critério mais rígido sobre o quanto um dialeto precisa ser diferente de outro, o que seria impraticável. Quando dois ou mais dialetos rodam exatamente o mesmo código (como Chez Scheme, Guile e Scheme ou ClojureScript e Squint), apenas um dos dialetos será considerado, e os outros serão adicionados ao final da lista apenas como equivalentes, e não serão contabilizados. Tecnologias que exigem alteração no código de outros dialetos também estão listadas. Quando um dialeto puder ser definido como uma extensão de outro dialeto, e construções novas puderem ser usadas, ele é incluído e postado como dialeto diferente.

Claro que, para alguns dialetos, algumas soluções são quase completamente idênticas, mas foram publicadas distintamente porque um só código não rodaria em mais de um dialeto. Um exemplo clássico são os dialetos SML e SML/NJ. Uma única linha (que é obrigatória em SML e gera um erro em SML/NJ) impede que uma mesma solução rode em ambos os dialetos. Outro exemplo bem evidente são os dialetos de Forth, que usam arrays distintamente.

As soluções estão divididas entre as recursivas (Alice, Arc, AutoLISP, Bend, Bigloo, Caml, Clean, Clojure, Common Lisp, DataWeave, DrScheme, Elixir, Elm, Emacs Lisp, Erlang, EusLisp, Flix, Gleam, GOOPS, Haskell, Hope, Idris, ILOS, ISLISP, Kawa, Lean, Miranda, NewLISP, Oak, OCaml, Orc, Otus Lisp, Prolog, PureScript, Racket, ReasonML, ReScript, Scheme, SML, 3, Source, Squint, Steel, Visual LISP, XSB e Yeti) e iterativas (todos os outros dialetos, incluindo F#).

Existem, em algumas soluções, salvaguardas para valores incorretos para uma aplicação real. São valores zerados e negativos. Em alguns dialetos não é verificado, pois entendeu-se que o público-alvo desses dialetos não cometeria esse tipo de equívoco.

Tenham em mente que algumas das soluções (como as em BASIC para microcomputadores de oito bits e Bash/Dash), pelas próprias naturezas de suas tecnologias, são extremamente lentas. Algumas são lentas na função de exponenciação, outras dependem de outros processos para a matemática de ponto flutuante. Com centenas de pagamentos, algumas soluções podem demorar minutos para darem resultados. Os testes devem ser realizados, inicialmente, com menos parcelas. Faça a regra de três para determinar se vale a pena fazer testes com números extraordinários de parcelas.

Algumas implementações não serão mantidas, porque foram feitas em versões de avaliação de ambientes de desenvolvimento pagos, como o Embarcadero Delphi e o EiffelStudio. Os dialetos menos populares não terão suporte, mesmo tendo IDEs gratuitas.

Alguns arquivos estão ilegíveis, pois são binários e devem ser abertos ou importados nos ambientes dos dialetos, como AppleSoft BASIC, Smalltalk, Snap! e twinBASIC. StarLogo Nova não salva em arquivo, então somente a URL está disponibilizada: https://www.slnova.org/jacknpoe/projects/941781/.

Exemplos de dialetos que não terão a solução ainda, por não terem suporte a recursos necessários: Solidify (não tem números de ponto flutuante), CHIP-8, Frege e Gosu (não têm exponenciação), Self e (não têm exponenciação de números de ponto flutuante). Outros dialetos têm outros problemas, como estarem desatualizadas e não rodarem ou compilarem nos sistemas atuais. Dialetos que são, na verdade, Turing tarpits, como Agda, serão ignorados.

A saída mais comum para os testes é:

Peso total = 3.0 / Acréscimo = 6.059108997379403 / Juros = 2.999999999999992

ATENÇÃO: existe uma possibilidade de divisão por zero, nos juros simples, por exemplo, se os juros forem 100% e uma das parcelas for -100 vezes o período. Uma verificação desse tipo complicaria o código, para evitar essa eventualidade tão rara.

A lista está organizada em ordem alfabética, pelos nomes dos dialetos, em: https://jacknpoeexplicaprogramacao.wordpress.com/2024/03/02/10-resolucoes-de-equacao-transcendente/ ou https://github.com/jacknpoe/todos_juros/blob/main/todos_juros.txt

As versões em JavaScript e PHP podem ser testadas a partir de: https://jacknpoe.rf.gd/

A versão em Scratch está publicada em https://scratch.mit.edu/projects/1162953396/

A versão em Snap! está publicada em https://snap.berkeley.edu/project?username=jacknpoe&projectname=juros

A versão on-line em WOKWI de Arduino está publicada em https://wokwi.com/projects/447631899725952001

A versão on-line em WOKWI de Raspberry Pi está publicada em https://wokwi.com/projects/447794347319174145

A versão on-line em WOKWI de MicroPython está publicada em https://wokwi.com/projects/447878410647046145

A licença é GNU (https://github.com/jacknpoe/todos_juros/blob/main/LICENSE).

ENGLISH
=======
This repository is about coding, in multiple dialects, the same solution in financial mathematics. To find the interest based on the increase, dates and weights of the installments. I use the Bisection Method of Numerical Calculus to solve it. The idea is that each version adheres to the culture of each dialect as much as possible. I use as few resources as possible. I avoid adding any libraries I can.

The focus is to solve the Financial Mathematics problem using Numerical Calculus. Therefore, some dialects ​​that would require greater knowledge of mathematics, such as exponentiation of floating point numbers, are being deprecated for now.

It's a "Rosetta Stone" of programming dialects.

Aside from the "terceiros" folder, all solutions were written by https://github.com/jacknpoe, with only BBC Basic using a simplified "translation" method, requiring a complete code revision to run properly.

Formula for calculating the increase from simple interest:

![Simple Interest](https://github.com/jacknpoe/todos_juros/blob/main/JurosSimples.jpg)

Formula for calculating the increase from compound interest:

![Compound Interest](https://github.com/jacknpoe/todos_juros/blob/main/JurosCompostos.jpg)

(pesoTotal = totalWeight; quantidade = quantity; pesos = weights; juros = interest; pagamentos = payments; periodo = period)

Only solutions that compiled (or were correctly interpreted), actually ran, and returned correct results are published.

One of the goals is for compilers and interpreters to avoid displaying warnings when compiling or running the solutions. In integrated IDEs, warnings have also been avoided.

Two concepts that weighed heavily were the exponentiation of floating point numbers (implemented in all dialects) and dynamic arrays (which were not possible, for example, in Chapel, Modula-2, MSX Turbo Pascal, Pascalzim, Portugol, VisuALG and XC=BASIC, and arrays can have one three or a thousand of elements).

Two dialects ​​are considered different when any part of the code has to be changed to be compiled or interpreted in both. This issue would become very complicated if a stricter criterion were chosen regarding how much one dialect needs to be different from another, which would be impractical. When two or more dialects ​​run exactly the same code (such as Chez Scheme, Guile and Scheme or ClojureScript and Squint), only one of the dialects ​​will be considered, and the others will be added to the end of the list only as equivalents, and will not be accounted. Technologies that require changes to code from other dialects ​​are also listed. When a dialect can be defined as an extension of another dialect, and new constructs can be used, they are included and posted as a different dialect.

Of course, for some dialects, some solutions are almost completely identical, but they were published separately because a single code would not run in more than one dialect. A classic example is the SML and SML/NJ dialects. A single line (which is mandatory in SML and generates an error in SML/NJ) prevents the same solution from running in both dialects. Another very clear example is the Forth dialects, which use arrays differently.

The solutions are divided between recursive (Alice, Arc, AutoLISP, Bend, Bigloo, Caml, Clean, Clojure, Common Lisp, DataWeave, DrScheme, Elixir, Elm, Emacs Lisp, Erlang, EusLisp, Flix, Gleam, GOOPS, Haskell, Hope, Idris, ILOS, ISLISP, Kawa, Lean, Miranda, NewLISP, Oak, OCaml, Orc, Otus Lisp, Prolog, PureScript, Racket, ReasonML, ReScript, Scheme, SML, SML/NJ, Source, Squint, Steel, Visual LISP, XSB and Yeti) and iterative (all other dialects, including F#).

There are, in some solutions, safeguards for incorrect values ​​for a real application. These are zero and negative values. In some dialects ​​it is not verified, as it was understood that the target audience of these dialects ​​would not make this type of mistake.

Keep in mind that some solutions (such as those in BASIC for eight-bit microcomputers and Bash/Dash), by the very nature of their technologies, are extremely slow. Some are slow in the exponentiation function, others rely on other processes for floating-point mathematics. With hundreds of payments, some solutions can take minutes to yield results. Tests should initially be performed on fewer installments. Use the rule of three to determine whether it's worth testing with an extraordinary number of installments.

Some implementations will not be maintained because they were done in trial versions of paid development environments such as Embarcadero Delphi and EiffelStudio. Less popular dialects will not be supported, even though they have free IDEs.

Some files are unreadable, as they are binary and must be opened or imported into the dialect environments, such as AppleSoft BASIC, Smalltalk, Snap! and twinBASIC. StarLogo Nova does not save to a file, so only the URL is available: https://www.slnova.org/jacknpoe/projects/941781/.

Examples of dialects that will not have the solution yet, as they do not support the necessary resources: Solidify (does not have floating point numbers), CHIP-8, Frege and Gosu (does not have exponentiation), Self and Rexx (does not have exponentiation of floating point numbers). Other dialects ​​have other problems, such as being outdated and not running or compiling on current systems. Dialectss that are actually Turing tarpits, like Agda, are ignored.

The most common output for tests is:

Peso total = 3.0 / Acréscimo = 6.059108997379403 / Juros = 2.999999999999992

WARNING: There is a possibility of division by zero in simple interest, for example, if the interest is 100% and one of the installments is -100 times the period. A check of this type would complicate the code, to avoid this very rare eventuality.

The list is organized alphabetically, by dialects names: https://jacknpoeexplicaprogramacao.wordpress.com/2024/03/02/10-resolucoes-de-equacao-transcendente/ or https://github.com/jacknpoe/todos_juros/blob/main/todos_juros.txt

JavaScript and PHP versions can be tested from: https://jacknpoe.rf.gd/

The Scratch version is published at https://scratch.mit.edu/projects/1162953396/

The Snap! version is published at https://snap.berkeley.edu/project?username=jacknpoe&projectname=juros

The online WOKWI version of Arduino is published at https://wokwi.com/projects/447631899725952001

The online WOKWI version of Raspberry Pi is published at https://wokwi.com/projects/447794347319174145

The online WOKWI version of MicroPython is published at https://wokwi.com/projects/447878410647046145

The C++ dialect versions of the solution were written in English, including Arduino and Raspberry Pi.

The license is GNU (https://github.com/jacknpoe/todos_juros/blob/main/LICENSE).

![52](https://github.com/jacknpoe/todos_juros/blob/main/resolu%C3%A7%C3%B5es.jpg)
