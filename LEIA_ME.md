# LEIA ME

Este repositório é sobre codificar, em vários dialetos, a mesma solução em matemática financeira. Achar os juros a partir do acréscimo, das datas e pesos das parcelas. Eu uso o Método da Bisseção do Cálculo Numérico para resolvê-la. A ideia é que cada versão se fixe ao máximo à cultura de cada dialeto. Eu uso o mínimo de recursos possível. Eu evito adicionar qualquer biblioteca que eu puder.

É uma "Pedra de Roseta" sobre dialetos de programação.

Tirando a pasta "terceiros", todas as soluções foram escritas por [jacknpoe](https://github.com/jacknpoe). Em BBC Basic foi utilizada uma forma simplificada de "tradução", sendo que o código precisou ser completamente revisado para poder rodar apropriadamente. QML teve parte do código traduzida de JavaScript pelo ChatGPT mas, de novo, ela teve que ser revisada, com partes que foram ignoradas.

Um executor de scripts para AngelScript foi criado pelo ChatGPT a partir das bibliotecas do AngelScript. Trata-se de um código-fonte em C++ (.cpp) que recebe um script como parâmetro e o executa. Ele está disponível junto à solução escrita nesse dialeto de script, para quem quiser compilar e testar a execução (desde que, é claro, as bibliotecas sejam baixadas e colocadas nas pastas adequadas).

Fórmula para calcular o acréscimo a partir dos juros simples:

![Juros Simples](JurosSimples.jpg)

Fórmula para calcular o acréscimo a partir dos juros compostos:

![Juros Compostos](JurosCompostos.jpg)

Apenas soluções que compilaram (ou foram corretamente interpretadas), que realmente rodaram, e retornaram resultados corretos, são publicadas. Com exceção de Bend, que apresentou diferença de 0,02 no cálculo dos juros. A solução é mantida para registro histórico e didático.

Uma das metas é que os compiladores e interpretadores não exibam avisos ao compilar ou rodar as soluções. Em IDEs integradas, os avisos também foram evitados. 

Dois conceitos que pesaram muito foram a exponenciação de números ponto flutuante (direta ou implementada, é usada em todos os dialetos) e os arrays dinâmicos (que não foram possíveis, por exemplo, em Chapel, Modula-2, MSX Turbo Pascal, Pascalzim, Portugol, VisuALG e XC=BASIC e, nesses casos, os arrays podem ter três ou mil elementos).

Dois dialetos são considerados diferentes quando qualquer parte do código tem que ser alterada para ser compilado ou interpretado em ambos. Essa questão ficaria muito complicada, se fosse escolhido um critério mais rígido sobre o quanto um dialeto precisa ser diferente de outro, o que seria impraticável. Quando dois ou mais dialetos rodam exatamente o mesmo código (como Chez Scheme, Guile e Scheme ou ClojureScript e Squint), apenas um dos dialetos será considerado, e os outros serão adicionados ao final da lista apenas como equivalentes, e não serão contabilizados. Tecnologias que exigem alteração no código de outros dialetos também estão listadas. Quando um dialeto puder ser definido como uma extensão de outro dialeto, e construções novas puderem ser usadas, ele é incluído e postado como dialeto diferente. Isso vale para orientação a objetos e variáveis com nomes mais significativos. Se duas implementações puderem executar uma mesma solução, mas para isso uma delas não for legitimamente representada, duas soluções serão incluídas. Exemplo: Starlark e Python — Starlark requer implementação manual de exponenciais, enquanto Python possui essas funções nativamente. Outro exemplo é RetroBASIC e retrobasic. Embora o interpretador RetroBASIC rode a versão em retrobasic, há diferenças na precisão dos resultados, na estética das soluções, na acentuação e na definição dos tipos de variáveis. Publicar somente a solução em retrobasic como denominador comum não representaria corretamente RetroBASIC.

Claro que, para alguns dialetos, algumas soluções são quase completamente idênticas, mas foram publicadas distintamente porque um só código não rodaria em mais de um dialeto. Um exemplo clássico são os dialetos SML e Alice. Uma única linha (que é obrigatória em SML e gera um erro em Alice) impede que uma mesma solução rode em ambos os dialetos. Outro exemplo bem evidente são os dialetos de Forth, que usam arrays distintamente.

As soluções estão divididas entre as recursivas e iterativas, formando dois conjuntos algorítmicos bem distintos.

Existem, em algumas soluções, salvaguardas para valores incorretos para uma aplicação real. São valores zerados e negativos. Em alguns dialetos não é verificado, pois entendeu-se que o público-alvo desses dialetos não cometeria esse tipo de equívoco.

Tenham em mente que algumas das soluções (como as em BASIC para microcomputadores de oito bits e shells), pelas próprias naturezas de suas tecnologias, são extremamente lentas. Algumas têm exponenciação ineficiente, outras dependem de processos externos para operações de ponto flutuante. Com centenas de pagamentos, certas soluções podem levar minutos para produzir resultados. Recomenda-se iniciar os testes com poucas parcelas e utilizar regra de três para estimar o tempo em casos maiores, evitando execuções inviáveis.

Em ambientes baseados em emulação de microcomputadores antigos, pode ser necessário alternar entre a velocidade original de emulação (1x), para interação, e velocidades mais altas (10x, 100x...) para tornar a execução dos testes viável.

Algumas implementações não serão mantidas, porque foram feitas em versões de avaliação de ambientes de desenvolvimento pagos, como o Embarcadero Delphi e o EiffelStudio. Os dialetos menos populares não terão suporte, mesmo tendo IDEs gratuitas.

Algumas soluções, principalmente as mais antigas em dialetos funcionais, não foram implementadas de forma realmente escalável (em geral têm arrays ou listas atribuídos estaticamente). Os dialetos Cakelisp, Gluon, Koka, Nickel, PicoLisp, Racket, Roc e Typed Racket são bons exemplos de como soluções funcionais podem ser estruturadas para suportar um número arbitrário de parcelas, mantendo o mesmo modelo algorítmico. Em contraste, a quantidade de soluções escaláveis em dialetos imperativos é significativamente maior, incluindo C, C++, Rust, C#, Fortran 90, Java, GForth, Lua, Go, Perl e Python, entre os mais eficientes e populares. Em ambas as listas, em PicoLisp e Nickel não foi possível executar um benchmark com 300.000 parcelas.

Alguns arquivos estão ilegíveis, pois são binários e devem ser abertos ou importados nos ambientes dos dialetos, como AppleSoft BASIC, Smalltalk, Snap! e twinBASIC. StarLogo Nova não salva em arquivo, então somente a URL está disponibilizada: https://www.slnova.org/jacknpoe/projects/941781/.

Alguns dialetos não terão a solução ainda, por não terem suporte a recursos necessários, como números de ponto flutuante (ou inteiros de 64 bits para emular). Outros dialetos têm outros problemas, como estarem desatualizadas e não rodarem ou compilarem nos sistemas atuais. Dialetos que são, na verdade, Turing tarpits, como Agda, serão ignorados.

Uma versão em C, com otimizações estruturais e transformações computacionais em relação ao padrão das demais soluções, foi publicada com o nome de [juros_otimizado.c](juros_otimizado.c). Essa versão preserva a base algorítmica do problema, mas altera a forma de cálculo para reduzir custos computacionais, incluindo o cálculo antecipado de partes fixas das equações financeiras, uso de variáveis globais para diminuir indireção e outras melhorias de desempenho. Ela não é destinada à comparação direta com as demais soluções, mas pode servir como referência para quem busca maior eficiência ou deseja adaptar essas ideias para outras linguagens. Esta versão não é a mais representativa do projeto Pedra de Roseta. Seu objetivo não é servir como modelo matemático, didático ou filosófico para as demais soluções, mas demonstrar até onde é possível reduzir o custo computacional mantendo a mesma base algorítmica. Ela funciona como uma prova de conceito, um vislumbre de otimizações estruturais possíveis e um lembrete de que muitas vezes é possível obter o mesmo resultado realizando menos trabalho. Como os benchmarks do projeto procuram comparar implementações equivalentes, nenhuma das demais linguagens ou dialetos adota otimizações semelhantes. Além disso, para os cenários normalmente encontrados em aplicações reais (por exemplo, algumas centenas de parcelas e taxas moderadas), tais otimizações raramente são necessárias.

Alguns dialetos tiveram o tempo medido para 300.000 parcelas, e classificados: [benchmark.png](benchmark.png). Existem duas versões em C, a versão para comparação justa, com os mesmos algoritmos dos demais dialetos, e a versão otimizada. Já em C++ foi realizado um experimento [juros_rec.cpp]juros_rec.cpp) substituindo laços por recursão, em estilo próximo ao das linguagens funcionais; essa versão também foi medida.

O dialeto Bend tem duas soluções. A primeira usa um mapa (estrutura {1:..., 2:...}) para simular arrays, o que não é escalável. A segunda usa funções para mapear pagamentos e pesos a partir do índice, sendo escalável. Ambas foram mantidas por motivos históricos e didáticos. A precisão numérica é limitada (float de 24 bits), o que afeta o resultado final.

A saída mais comum para os testes é:

Peso total = 3.0 / Acréscimo = 6.059108997379403 / Juros = 2.999999999999992

ATENÇÃO: existe uma possibilidade de divisão por zero, nos juros simples, por exemplo, se os juros forem 100% e uma das parcelas for -100 vezes o período. Uma verificação desse tipo complicaria o código, para evitar essa eventualidade tão rara.

ATENÇÃO: Algumas soluções deste repositório utilizam implementações próprias de funções exponenciais (`ln`, `exp` e `pow`). Essas funções não têm como objetivo substituir implementações genéricas das bibliotecas matemáticas padrão. Elas foram projetadas e validadas exclusivamente para os domínios efetivamente usados nas soluções, em especial valores de juros honestos e um número sensato de parcelas. O uso dessas funções fora desse contexto pode resultar em perda significativa de precisão numérica. A função `powint`, por sua vez, utiliza exponenciação com expoente inteiro e não apresenta essas limitações (além do expoente não ser real). Alguns dialetos, como B (BCause implementation) e PicoLisp, além dessas funções, tiverram aritmética (multiplicação, divisão, conversões) de pontos fixos implementada.

As versões em JavaScript e PHP podem ser testadas a partir de: https://jacknpoe.rf.gd/

A versão em Scratch está publicada em https://scratch.mit.edu/projects/1162953396/

A versão em Snap! está publicada em https://snap.berkeley.edu/project?username=jacknpoe&projectname=juros

A versão on-line em WOKWI de Arduino está publicada em https://wokwi.com/projects/447631899725952001

A versão on-line em WOKWI de Raspberry Pi está publicada em https://wokwi.com/projects/447794347319174145

A versão on-line em WOKWI de MicroPython está publicada em https://wokwi.com/projects/447878410647046145

O projeto também inclui a planilha [juros.xlsx](juros.xlsx). Além de implementar diretamente o algoritmo `jurosParaAcrescimo`, ela permite utilizar a ferramenta `Goal Seek` (`Atingir Meta`) para obter o resultado do algoritmo `acrescimoParaJuros`, sem necessidade de implementar um método numérico. Consulte [PLANILHA.md](PLANILHA.md).

A licença é GNU [LICENSE](LICENSE).
