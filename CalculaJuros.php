<?php
	//***********************************************************************************************
	// AUTOR: Ricardo Erick Rebêlo
	// Objetivo: calcular os juros a partir das parcelas e as parcelas a partir dos juros (acréscimo)
	// Versão Original (Pastebin https://pastebin.com/7QrcCmsX): 07/11/2013 - Ricardo Erick Rebêlo
	// Alterações:
	// 0.1   15/04/2023 - Começo da primeira conversão
	// 0.2   18/04/2023 - Classe inteiramente convertida
	// 1.0   20/04/2023 - Versão implantada compatível com a página de testes

	namespace jacknpoe;

	//***********************************************************************************************
	// Classe CalculaJuros

	class CalculaJuros
	{
		public $Quantidade = 0;
		public $Composto = false;
		public $Periodo = 30;
		public $Pagamentos = array();
		public $Pesos = array();

		function __construct( $quantidade = 0, $composto = false, $periodo = 30)		// vamos ver se tem como sobrecarregar!
		{
			$this->Quantidade = $quantidade;
			$this->Composto = $composto;
			$this->Periodo = $periodo;
		}

		function setPagamentos( $delimitador = ",", $pagamentos = "")
		{
			$indice = 0;
			if( $pagamentos === "")
			{
				for( $indice = 1; $indice <= $this->Quantidade; $indice++)
				{
					$this->Pagamentos[ $indice] = $indice * $this->Periodo;
				}
			}
			else
			{
				$temporaria = explode( $delimitador, $pagamentos);
				for( $indice = 1; $indice <= $this->Quantidade; $indice++)
				{
					$this->Pagamentos[ $indice] = intval( $temporaria[ $indice - 1]);
				}
			}
		}

		function setPesos( $delimitador = ",", $pesos = "")
		{
			$indice = 0;
			if( $pesos === "")
			{
				for( $indice = 1; $indice <= $this->Quantidade; $indice++)
				{
					$this->Pesos[ $indice] = 1;
				}
			}
			else
			{
				$temporaria = explode( $delimitador, $pesos);
				for( $indice = 1; $indice <= $this->Quantidade; $indice++)
				{
					$this->Pesos[ $indice] = intval( $temporaria[ $indice - 1]);
				}
			}
		}

		function getPesoTotal()
		{
			$acumulador = 0;
			$indice = 0;

			for( $indice = 1; $indice <= $this->Quantidade; $indice++)
			{
				$acumulador += $this->Pesos[ $indice];
			}
			return $acumulador;
		}

		function JurosParaAcrescimo( $juros)
		{
			if( $juros <= 0 or $this->Quantidade <= 0 or $this->Periodo <= 0) return 0;
			$total = $this->getPesoTotal();
			$acumulador = 0;
			// $soZero = true;
			$indice = 0;

			for( $indice = 1; $indice <= $this->Quantidade; $indice++)
			{
				// if( $this->Pagamentos[ $indice] > 0 and $this->Pesos[ $indice] > 0 ) $soZero = false;

				if( $this->Composto )
				{	// COMPOSTO
					$acumulador += $this->Pesos[ $indice] / pow( 1 + $juros / 100, $this->Pagamentos[ $indice] / $this->Periodo);
				}
				else
				{	// SIMPLES
					$acumulador += $this->Pesos[ $indice] / ( 1 + $juros / 100 * $this->Pagamentos[ $indice] / $this->Periodo);
				}
			}

			// if( $soZero ) return 0;
			if( $acumulador <= 0) return 0;
			return ( $total / $acumulador - 1) * 100;
		}

		function AcrescimoParaJuros( $acrescimo, $precisao = 12, $maximoInteracoes = 100, $maximoJuros = 50, $acrescimoComoValorOriginal = false)
		{
			if( $maximoInteracoes < 1 or $this->Quantidade <= 0 or $precisao < 1 or $this->Periodo <= 0 or $acrescimo <= 0) return 0;
			$minimoJuros = 0;
			$medioJuros = 0;
			$minimaDiferenca = 0;
			$indice = 0;
			$total = $this->getPesoTotal();
			if( $total == 0) return 0;

			if( $acrescimoComoValorOriginal )		// nesse caso, os pesos totais dão o valor cobrado e o acrescimo é o original
			{
				$acrescimo = 100 * ( $total / $acrescimo - 1);
				if( $acrescimo <= 0) return 0;
			}

			$minimaDiferenca = pow( 0.1, $precisao);

			for( $indice = 1; $indice <= $maximoInteracoes; $indice++)
			{
				$medioJuros = ( $minimoJuros + $maximoJuros) / 2;
				if( ( $maximoJuros - $minimoJuros ) < $minimaDiferenca ) break;
				if( $this->JurosParaAcrescimo( $medioJuros ) <= $acrescimo )
				{
					$minimoJuros = $medioJuros;
				}
				else
				{
					$maximoJuros = $medioJuros;
				}
			}

			return $medioJuros;
		}
	}
?>