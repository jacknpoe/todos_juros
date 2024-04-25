-- Versão 0.2:    04/2024: trocada avaliação soZero por acumulador == 0

with Ada.Text_IO, Ada.Long_Float_Text_IO, Ada.Numerics.Generic_Elementary_Functions;
use  Ada.Text_IO, Ada.Long_Float_Text_IO;

package body juros is
   -- para exponenciação com pontos flutuantes
   package Value_Functions is new Ada.Numerics.Generic_Elementary_Functions(Long_Float);
   use Value_Functions;

   -- calcula a somatoria de Pesos[]
   function getPesototal(sjuros : tjuros) return Long_Float is
      acumulador : Long_Float := 0.0;
   begin
      for indice in 1 .. sjuros.Quantidade loop
         acumulador := acumulador + sjuros.Pesos(indice);
      end loop;
      return acumulador;
   end getPesototal;

   -- calcula o acrescimo a partir dos juros e dados comuns (como parcelas)
   function jurosParaAcrescimos(sjuros : tjuros; juros : Long_Float) return Long_FLoat is
      pesoTotal : Long_Float;
      acumulador : Long_Float := 0.0;
   begin
      if juros < 0.0 or sjuros.Quantidade <= 0 or sjuros.Periodo <= 0.0 then
         return 0.0;
      end if;
      pesoTotal := getPesototal(sjuros);
      if pesoTotal <= 0.0 then
         return 0.0;
      end if;

      for indice in 1 .. sjuros.Quantidade loop
         if sjuros.Composto then
            -- veja que foi convertida a divisao de Pagamentos por Periodo para Natural, entao, quando necessario, precisa usar os juros diarios
            -- foi corrigida a divisão para ponto flutuante em 12/04/2024
            acumulador := acumulador + sjuros.Pesos(indice) / (1.0 + juros / 100.0) ** (sjuros.Pagamentos(indice) / sjuros.Periodo);
         else
            acumulador := acumulador + sjuros.Pesos(indice) / (1.0 + juros / 100.0 * sjuros.Pagamentos(indice) / sjuros.Periodo);
         end if;
      end loop;

      if acumulador <= 0.0 then
         return 0.0;
      end if;
      return (pesoTotal / acumulador - 1.0) * 100.0;
   end jurosParaAcrescimos;

   -- calcula os juros a partir do acrescimo e dados comuns (como parcelas)
   function acrescimoParaJuros(sjuros : tjuros; acrescimo : Long_Float; precisao : Integer; maxIteracoes : Integer; mJuros : Long_Float) return Long_FLoat is
      pesoTotal : Long_Float;
      minJuros : Long_Float := 0.0;
      medJuros : Long_Float;
      maxJuros : Long_Float;
      minDiferenca : Long_Float;
   begin
      if maxIteracoes < 1 or sjuros.Quantidade <= 0 or precisao < 1 or sjuros.Periodo <= 0.0 or acrescimo <= 0.0 or mJuros <= 0.0 then
         return 0.0;
      end if;
      pesoTotal := getPesototal(sjuros);
      if pesoTotal <= 0.0 then
         return 0.0;
      end if;
      medJuros := mJuros / 2.0;
      maxJuros := mJuros;
      minDiferenca := 0.1 ** precisao;

      for indice in 1 .. maxIteracoes loop
         medJuros := (minJuros + maxJuros) / 2.0;
         if (maxJuros - minJuros) < minDiferenca then
            return medJuros;
         end if;
         if jurosParaAcrescimos(sjuros, medJuros) < acrescimo then
            minJuros := medJuros;
         else
            maxJuros := medJuros;
         end if;
      end loop;
      return medJuros;
   end acrescimoParaJuros;
end juros;
