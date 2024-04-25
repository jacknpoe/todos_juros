-- Calculo do juros, sendo que precisa de arrays pra isso
-- Versao 0.1: 09/04/2024: versao feita sem muito conhecimento de Ada e exponenciacao inteira
-- Versao 0.2: 12/04/2024: versao feita sem muito conhecimento de Ada e exponenciacao ponto flutuante
-- Versão 0.3:    04/2024: trocada avaliação soZero por acumulador == 0
-- Versão 0.4: 25/04/2024: arrays dinâmicos

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
      sJuros.Pagamentos.Append(30.0 * long_float(indice)); -- 0.4
      sJuros.Pesos.Append(1.0); -- 0.4
   end loop;

   -- faz os testes
   Put("O peso total é ="); Put(juros.getPesototal(sjuros)); Put_Line("");
   Put("O acréscimo é ="); Put(juros.jurosParaAcrescimos(sjuros, 3.0)); Put_Line("");
   Put("Os juros são ="); Put( juros.acrescimoParaJuros(sjuros, juros.jurosParaAcrescimos(sjuros, 3.0), 15, 100, 50.0)); Put_Line("");
end testajuros;
