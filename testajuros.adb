-- Calculo do juros, sendo que precisa de arrays pra isso
-- Versão 0.1: 09/04/2024: versao feita sem muito conhecimento de Ada e exponenciacao inteira
--        0.2: 12/04/2024: versao feita sem muito conhecimento de Ada e exponenciacao ponto flutuante
--        0.3:    04/2024: trocada avaliações soZero por acumulador == 0
--        0.4: 25/04/2024: arrays dinâmicos
--        0.5: 22/01/2026: para caracteres do Linux, padronizados Puts e retirados withs e uses desnecessários

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
   Put("Peso total ="); Put(juros.getPesototal(sjuros)); Put_Line("");
   Put("Acréscimo ="); Put(juros.jurosParaAcrescimos(sjuros, 3.0)); Put_Line("");
   Put("Juros ="); Put( juros.acrescimoParaJuros(sjuros, juros.jurosParaAcrescimos(sjuros, 3.0), 15, 100, 50.0)); Put_Line("");
end testajuros;
