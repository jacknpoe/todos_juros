-- with Ada.Containers; use Ada.Containers;
-- with Ada.Containers.Vectors;
with Ada.Containers.Vectors; -- 0.4

-- estrutura e funções do pacote
package juros is
   type vetor is array (Integer range <>) of Long_Float;
   package vetor_dinamico is new Ada.Containers.Vectors (Index_Type => Natural, Element_Type => Long_Float);

   -- type vetor is new Real_Vector(1..0);
   -- package vetor is new Ada.Containers.Vectors(Index_Type => Natural, Element_Type => Long_Float);
   -- use vetor;
   type tjuros is record
      Quantidade : Integer := 0;
      Composto : Boolean := False;
      Periodo : Long_Float := 0.0;
      -- Pagamentos : vetor (1 .. 1000);
      -- Pesos : vetor (1 .. 1000);
      Pagamentos : vetor_dinamico.Vector; -- 0.4
      Pesos : vetor_dinamico.Vector; -- 0.4
   end record;
   function getPesototal(sjuros : tjuros) return Long_Float;
   function jurosParaAcrescimos(sjuros : tjuros; juros : Long_Float) return Long_FLoat;
   function acrescimoParaJuros(sjuros : tjuros; acrescimo : Long_Float; precisao : Integer; maxIteracoes : Integer; mJuros : Long_Float) return Long_FLoat;
end juros;
