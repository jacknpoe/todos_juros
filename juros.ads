with Ada.Containers.Vectors; -- 0.4

-- estrutura e funções do pacote
package juros is
   package vetor_dinamico is new Ada.Containers.Vectors (Index_Type => Natural, Element_Type => Long_Float); -- 0.4

   type tjuros is record
      Quantidade : Integer := 0;
      Composto : Boolean := False;
      Periodo : Long_Float := 0.0;
      Pagamentos : vetor_dinamico.Vector; -- 0.4
      Pesos : vetor_dinamico.Vector; -- 0.4
   end record;
   function getPesototal(sjuros : tjuros) return Long_Float;
   function jurosParaAcrescimos(sjuros : tjuros; juros : Long_Float) return Long_FLoat;
   function acrescimoParaJuros(sjuros : tjuros; acrescimo : Long_Float; precisao : Integer; maxIteracoes : Integer; mJuros : Long_Float) return Long_FLoat;
end juros;
