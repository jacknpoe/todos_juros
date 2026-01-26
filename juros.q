/ Calculo do juros, sendo que precisa de arrays pra isso
/ Versao 0.1: 26/01/2026: talvez inspirado em linguagens como "J", sem saber muito sobre "Q"

\P 16  / precisão de 16 digitos

/ variáveis globais
quantidade: 3;
composto: 1;  / 1 TRUE para juros composto, 0 FALSE para simples
periodo: 30.0;
pagamentos: ();
pesos: ();

/ insere elementos nos arrays dinamicamente
indice: 0
while [ indice < quantidade;
   pagamentos ,: (indice + 1.0) * periodo;
   pesos ,: 1.0;
   indice +: 1 ]

/ função de impressão (não retorna nada visível)
print:{ -1 x; }

/ calcula a soma total do array pesos[]
getPesoTotal:{
  acumulador: 0.0;
  indice: 0;
  while [ indice < quantidade;
     acumulador +: pesos indice;
     indice +: 1 ];
  acumulador }

/ calcula o acréscimo a partir dos juros e parcelas
jurosParaAcrescimo:{ [ juros ]
   pesoTotal: getPesoTotal[];
   if[ (quantidade < 1) or (periodo <= 0.0) or (pesoTotal <= 0.0) or (juros <= 0.0); : 0.0 ];
   acumulador: 0.0;
   indice: 0;
   while [ indice < quantidade;
      if[ composto; acumulador: acumulador + (pesos indice) % ((1.0 + juros % 100.0) xexp ((pagamentos indice) % periodo)) ];
      if[ not composto; acumulador: acumulador + (pesos indice) % (1.0 + (((juros % 100.0) * (pagamentos indice)) % periodo)) ];
      indice +: 1 ];
   if[ acumulador <= 0.0; : 0.0 ];
   ((pesoTotal % acumulador) - 1.0) * 100.0 }

/ calcula os juros a partir do acréscimo e parcelas
acrescimoParaJuros:{ [ acrescimo ; precisao ; maxIteracoes ; maxJuros ]
   pesoTotal: getPesoTotal[];
   if[ (quantidade < 1) or (periodo <= 0.0) or (pesoTotal <= 0.0) or (acrescimo <= 0.0) or (precisao <= 0.0) or (maxIteracoes <= 0) or (maxJuros <= 0.0); : 0.0 ];
   minJuros: 0.0;
   medJuros: maxJuros % 2.0;
   minDiferenca: 0.1 xexp precisao;
   iteracao: 0;
   while [ iteracao < maxIteracoes;
      if[ (maxJuros - minJuros) < minDiferenca; : medJuros ];
      calculadoAcrescimo: jurosParaAcrescimo[medJuros];
      if[ calculadoAcrescimo < acrescimo; minJuros: medJuros ];
      if[ calculadoAcrescimo > acrescimo; maxJuros: medJuros ];
      medJuros: (minJuros + maxJuros) % 2.0;
      iteracao +: 1 ];
   medJuros }

/ calcula e guarda os valores de retorno das fumções
pesoTotal: getPesoTotal[];
acrescimocalculado: jurosParaAcrescimo[3.0];
jurosCalculado: acrescimoParaJuros[acrescimocalculado; 15; 65; 50.0];

/ imprime o resultado
print ("Peso total = ", string pesoTotal);
print ("Acrescimo = ", string acrescimocalculado);
print ("Juros = ", string jurosCalculado);

\\