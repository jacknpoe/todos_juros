-- Calculo do juros, sendo que precisa de arrays pra isso
-- Versao 0.1: 09/04/2024: versao feita sem muito conhecimento de Ada e exponenciacao inteira

with Ada.Text_IO, Ada.Long_Float_Text_IO;
use  Ada.Text_IO, Ada.Long_Float_Text_IO;
with juros;

procedure testajuros is
   sjuros : juros.tjuros;
   quantidade : integer := 3;
begin
   -- define os valores para sJuros
   sjuros.Quantidade := quantidade;
   sjuros.Composto := true;
   sjuros.Periodo := 30.0;
   for indice in 1 .. quantidade loop
      sjuros.Pagamentos(indice) := 30.0 * long_float(indice);
      sjuros.Pesos(indice) := 1.0;
   end loop;

   -- faz os testes
   Put("O peso total é ="); Put(juros.getPesototal(sjuros)); Put_Line("");
   Put("O acréscimo é ="); Put(juros.jurosParaAcrescimos(sjuros, 3.0)); Put_Line("");
   Put("Os juros são ="); Put( juros.acrescimoParaJuros(sjuros, juros.jurosParaAcrescimos(sjuros, 3.0), 15, 100, 50.0)); Put_Line("");
end testajuros;
