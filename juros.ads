-- estrutura e funções do pacote
package juros is
   type vetor is array (Integer range <>) of Long_Float;
   type tjuros is record
      Quantidade : Integer := 0;
      Composto : Boolean := False;
      Periodo : Long_Float := 0.0;
      Pagamentos : vetor (1 .. 600);
      Pesos : vetor (1 .. 600);
   end record;
   function getPesototal(sjuros : tjuros) return Long_Float;
   function jurosParaAcrescimos(sjuros : tjuros; juros : Long_Float) return Long_FLoat;
   function acrescimoParaJuros(sjuros : tjuros; acrescimo : Long_Float; precisao : Integer; maxIteracoes : Integer; mJuros : Long_Float) return Long_FLoat;
end juros;
