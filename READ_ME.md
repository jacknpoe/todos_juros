# READ ME

This repository is about coding, in multiple dialects, the same solution in financial mathematics. To find the interest based on the increase, dates and weights of the installments. I use the Bisection Method of Numerical Calculus to solve it. The idea is that each version adheres to the culture of each dialect as much as possible. I use as few resources as possible. I avoid adding any libraries I can.

It's a "Rosetta Stone" of programming dialects.

With the exception of the "third parties" folder, all solutions were written by [jacknpoe](https://github.com/jacknpoe). BBC Basic used a simplified form of "translation," requiring a complete review of the code to run properly. QML had part of its JavaScript code translated by ChatGPT, but again, it had to be revised, with some parts being omitted.

A script executor for AngelScript was created by ChatGPT using the AngelScript libraries. It is a C++ source code (.cpp) that receives a script as a parameter and executes it. It is available along with the solution written in this scripting dialect, for anyone who wants to compile and test its execution (provided, of course, that the libraries are downloaded and placed in the appropriate folders).

Formula for calculating the increase from simple interest:

![Simple Interest](JurosSimples.jpg)

Formula for calculating the increase from compound interest:

![Compound Interest](JurosCompostos.jpg)

(pesoTotal = totalWeight; quantidade = quantity; pesos = weights; juros = interest; pagamentos = payments; periodo = period)

Only solutions that compiled (or were correctly interpreted), actually ran, and returned correct results are published. With the exception of Bend, which showed a difference of 0.02 in the interest calculation. The solution is kept for historical and educational record.

One of the goals is for compilers and interpreters to avoid displaying warnings when compiling or running the solutions. In integrated IDEs, warnings have also been avoided.

Two concepts that weighed heavily were the exponentiation of floating point numbers (direct or implemented, it is used in all dialects) and dynamic arrays (which were not possible, for example, in Chapel, Modula-2, MSX Turbo Pascal, Pascalzim, Portugol, VisuALG and XC=BASIC, and arrays can have one three or a thousand of elements).

Two dialects ​​are considered different when any part of the code has to be changed to be compiled or interpreted in both. This issue would become very complicated if a stricter criterion were chosen regarding how much one dialect needs to be different from another, which would be impractical. When two or more dialects ​​run exactly the same code (such as Chez Scheme, Guile and Scheme or ClojureScript and Squint), only one of the dialects ​​will be considered, and the others will be added to the end of the list only as equivalents, and will not be accounted. Technologies that require changes to code from other dialects ​​are also listed. When a dialect can be defined as an extension of another dialect, and new constructs can be used, they are included and posted as a different dialect. This applies to object-oriented programming and variables with more meaningful names. If two implementations can execute the same solution, but one of them is not legitimately represented, then two solutions will be included. Example: Starlark and Python — Starlark requires manual implementation of exponentials, while Python has these functions natively. Another example is RetroBASIC and retrobasic. Although the RetroBASIC interpreter runs the retrobasic version, there are differences in the accuracy of the results, the aesthetics of the solutions, the accentuation, and the definition of variable types. Publishing only the retrobasic solution as a common denominator would not correctly represent RetroBASIC.

Of course, for some dialects, some solutions are almost completely identical, but they were published separately because a single code would not run in more than one dialect. A classic example is the SML and Alice dialects. A single line (which is mandatory in SML and generates an error in Alice) prevents the same solution from running in both dialects. Another very clear example is the Forth dialects, which use arrays differently.

The solutions are divided between recursive and iterative methods, forming two very distinct algorithmic sets.

There are, in some solutions, safeguards for incorrect values ​​for a real application. These are zero and negative values. In some dialects ​​it is not verified, as it was understood that the target audience of these dialects ​​would not make this type of mistake.

Keep in mind that some solutions (such as those in BASIC for eight-bit microcomputers and shells), due to the very nature of their technologies, are extremely slow. Some have inefficient exponentiation, others depend on external processes for floating-point operations. With hundreds of payments, certain solutions can take minutes to produce results. It is recommended to start testing with a few installments and use the rule of three to estimate the time in larger cases, avoiding unfeasible executions.

In environments based on emulation of older microcomputers, it may be necessary to switch between the original emulation speed (1x), for interaction, and higher speeds (10x, 100x...) to make running the tests feasible.

Some implementations will not be maintained because they were done in trial versions of paid development environments such as Embarcadero Delphi and EiffelStudio. Less popular dialects will not be supported, even though they have free IDEs.

Some solutions, especially older ones in functional dialects, were not implemented in a truly scalable way (they generally have statically assigned arrays or lists). The Cakelisp, Gluon, Koka, Nickel, PicoLisp, Racket, Roc, and Typed Racket dialects are good examples of how functional solutions can be structured to support an arbitrary number of parcels while maintaining the same algorithmic model. In contrast, the number of scalable solutions in imperative dialects is significantly greater, including C, C++, Rust, C#, Fortran 90, Java, GForth, Lua, Go, Perl, and Python, among the most efficient and popular. In both lists, PicoLisp and Nickel were unable to run a benchmark with 300,000 parcels.

Some files are unreadable, as they are binary and must be opened or imported into the dialect environments, such as AppleSoft BASIC, Smalltalk, Snap! and twinBASIC. StarLogo Nova does not save to a file, so only the URL is available: https://www.slnova.org/jacknpoe/projects/941781/.

Some dialects will not yet have a solution because they lack support for necessary features, such as floating-point numbers (or 64-bit integers to emulate). Other dialects have other problems, such as being outdated and not running or compiling on current systems. Dialects that are, in fact, Turing tarpits, such as Agda, will be ignored.

A C version, with structural optimizations and computational transformations compared to the standard solutions, was published under the name [juros_otimizado.c](juros_otimizado.c). This version preserves the algorithmic basis of the problem, but alters the calculation method to reduce computational costs, including the upfront calculation of fixed parts of the financial equations, the use of global variables to reduce indirection, and other performance improvements. It is not intended for direct comparison with the other solutions, but can serve as a reference for those seeking greater efficiency or wishing to adapt these ideas to other languages. This version is not the most representative of the Rosetta Stone project. Its goal is not to serve as a mathematical, didactic, or philosophical model for other solutions, but to demonstrate how far it is possible to reduce computational cost while maintaining the same algorithmic basis. It functions as a proof of concept, a glimpse of possible structural optimizations, and a reminder that it is often possible to obtain the same result by doing less work. As the project's benchmarks seek to compare equivalent implementations, none of the other languages ​​or dialects adopt similar optimizations. Furthermore, for scenarios typically found in real-world applications (for example, a few hundred installments and moderate rates), such optimizations are rarely necessary.

Some dialects had their time measured for 300,000 installments and ranked: [benchmark.png](benchmark.png). There are two versions in C, the version for fair comparison, with the same algorithms as the other dialects, and the optimized version. In C++, an experiment was conducted [juros_rec.cpp](juros_rec.cpp) replacing loops with recursion, in a style similar to that of functional languages; this version was also measured.

The Bend dialect has two solutions. The first uses a map (structure {1:..., 2:...}) to simulate arrays, which is not scalable. The second uses functions to map payments and weights from the index, which is scalable. Both have been maintained for historical and didactic reasons. Numerical precision is limited (24-bit float), which affects the final result.

The most common output for tests is:

Peso total = 3.0 / Acréscimo = 6.059108997379403 / Juros = 2.999999999999992

WARNING: There is a possibility of division by zero in simple interest, for example, if the interest is 100% and one of the installments is -100 times the period. A check of this type would complicate the code, to avoid this very rare eventuality.

WARNING: Some solutions in this repository use their own implementations of exponential functions (`ln`, `exp`, and `pow`). These functions are not intended to replace generic implementations from standard mathematical libraries. They were designed and validated exclusively for the domains actually used in the solutions, especially fair interest rates and a reasonable number of installments. Using these functions outside of this context can result in a significant loss of numerical precision. The `powint` function, on the other hand, uses exponentiation with an integer exponent and does not have these limitations (besides the exponent not being real). Some dialects, such as B (BCause implementation) and PicoLisp, in addition to these functions, had fixed-point arithmetic (multiplication, division, conversions) implemented.

The list is organized alphabetically, by dialects names: https://jacknpoeexplicaprogramacao.wordpress.com/2024/03/02/10-resolucoes-de-equacao-transcendente/ or [SOLUCOES.md](SOLUCOES.md)

JavaScript and PHP versions can be tested from: https://jacknpoe.rf.gd/

The Scratch version is published at https://scratch.mit.edu/projects/1162953396/

The Snap! version is published at https://snap.berkeley.edu/project?username=jacknpoe&projectname=juros

The online WOKWI version of Arduino is published at https://wokwi.com/projects/447631899725952001

The online WOKWI version of Raspberry Pi is published at https://wokwi.com/projects/447794347319174145

The online WOKWI version of MicroPython is published at https://wokwi.com/projects/447878410647046145

The C++ dialect versions of the solution were written in English, including Arduino and Raspberry Pi.

The license is GNU [LICENSE](LICENSE).

The project also includes the spreadsheet [juros.xlsx](juros.xlsx). Besides directly implementing the `jurosParaAcrescimo` algorithm, it allows the use of the `Goal Seek` tool to obtain the result of the `acrescimoParaJuros` algorithm, without needing to implement a numerical method. See [SPREADSHEET.md](SPREADSHEET.md).

<br>

![ŕesoluções/resolutions](resolu%C3%A7%C3%B5es.jpg)
