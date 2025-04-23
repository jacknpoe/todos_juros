// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 23/04/2025: versão feita sem muito conhecimento de SnapDevelop

using System;

namespace JurosSD
{
    public class JurosSD
    {
        private int _quantidade;
        public bool Composto;
        public double Periodo;
        public double[] Pagamentos;
        public double[] Pesos;

        public int Quantidade
        {
            get { return _quantidade; }
            set
            {
                int quantidade = (value > 0) ? value : 0;
                _quantidade = quantidade;
                Pagamentos = new double[quantidade];
                Pesos = new double[quantidade];
            }
        }

        public JurosSD(int quantidade = 0, bool composto = false, double periodo = 30.0)
        {
            _quantidade = (quantidade > 0) ? quantidade : 0;
            Pagamentos = new double[_quantidade];
            Pesos = new double[_quantidade];
            Composto = composto;
            Periodo = periodo;
        }

        public double GetPesoTotal()
        {
            double acumulador = 0;
            for (int indice = 0; indice < Quantidade; indice++) acumulador += Pesos[indice];
            return acumulador;
        }

        public double JurosParaAcrescimo(double juros)
        {
            if (juros == 0 || Quantidade == 0 || Periodo <= 0.0) return 0;
            double pesoTotal = GetPesoTotal();
            if (pesoTotal == 0) return 0;
            double acumulador = 0;

            for (int indice = 0; indice < Quantidade; indice++)
            {
                if (Composto)
                {
                    acumulador += Pesos[indice] / Math.Pow(1 + juros / 100, Pagamentos[indice] / Periodo);
                }
                else
                {
                    acumulador += Pesos[indice] / (1 + juros / 100 * Pagamentos[indice] / Periodo);
                }
            }

            if (acumulador <= 0) return 0;
            return (pesoTotal / acumulador - 1) * 100;
        }

        public double AcrescimoParaJuros(double acrescimo, int precisao = 15, int maxInteracoes = 100, double maxJuros = 50)
        {
            if (maxInteracoes < 1 || Quantidade == 0 || precisao < 1 || Periodo <= 0.0 || acrescimo <= 0 || maxJuros <= 0) return 0;
            double minJuros = 0, medJuros = (minJuros + maxJuros) / 2, minDiferenca = Math.Pow(0.1, precisao), pesoTotal = GetPesoTotal();
            if (pesoTotal == 0) return 0;

            for (int indice = 0; indice < maxInteracoes; indice++)
            {
                if ((maxJuros - minJuros) < minDiferenca) break;
                if (JurosParaAcrescimo(medJuros) <= acrescimo)
                {
                    minJuros = medJuros;
                }
                else
                {
                    maxJuros = medJuros;
                }
                medJuros = (minJuros + maxJuros) / 2;
            }

            return medJuros;
        }
    }
}