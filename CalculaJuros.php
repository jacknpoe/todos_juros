<?php
	declare(strict_types=1);

	//***********************************************************************************************
	// AUTOR: Ricardo Erick Rebêlo
	// Objetivo: calcular os juros a partir das parcelas e as parcelas a partir dos juros (acréscimo)
	// Versão Original (Pastebin https://pastebin.com/7QrcCmsX): 07/11/2013 - Ricardo Erick Rebêlo
	// Alterações:
	// 0.1   15/04/2023 - Começo da primeira conversão
	// 0.2   18/04/2023 - Classe inteiramente convertida
	// 1.0   20/04/2023 - Versão implantada compatível com a página de testes
	// 1.1   26/10/2024 - adicionado botão "Valores Exemplo"
	// 1.2   12/02/2026 - arrays e periodo como float
	// 1.3   12/02/2026 - tipagem de parâmetros e atributos, números floats, atualização e melhorias

	namespace jacknpoe;

	//***********************************************************************************************
	// Classe CalculaJuros

	class CalculaJuros
	{
		public int $Quantidade = 0;
		public bool $Composto = false;
		public float $Periodo = 30.0;
		public array $Pagamentos = array();
		public array $Pesos = array();

		function __construct(int $quantidade = 0, bool $composto = false, float $periodo = 30.0)		// vamos ver se tem como sobrecarregar!
		{
			$this->Quantidade = $quantidade;
			$this->Composto = $composto;
			$this->Periodo = $periodo;
		}

		function setPagamentos(string $delimitador = ",", $pagamentos = "")
		{
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
					$this->Pagamentos[ $indice] = floatval( $temporaria[ $indice - 1]);
				}
			}
		}

		function setPesos(string $delimitador = ",", $pesos = "")
		{
			if( $pesos === "")
			{
				for( $indice = 1; $indice <= $this->Quantidade; $indice++)
				{
					$this->Pesos[ $indice] = 1.0;
				}
			}
			else
			{
				$temporaria = explode( $delimitador, $pesos);
				for( $indice = 1; $indice <= $this->Quantidade; $indice++)
				{
					$this->Pesos[ $indice] = floatval( $temporaria[ $indice - 1]);
				}
			}
		}

		function getPesoTotal()
		{
			$acumulador = 0.0;

			for( $indice = 1; $indice <= $this->Quantidade; $indice++)
			{
				$acumulador += $this->Pesos[ $indice];
			}
			return $acumulador;
		}

		function JurosParaAcrescimo(float $juros)
		{
			$total = $this->getPesoTotal();
			if( $juros <= 0.0 or $this->Quantidade < 1 or $this->Periodo <= 0.0 or $total <= 0.0) return 0.0;
			$acumulador = 0.0;

			for( $indice = 1; $indice <= $this->Quantidade; $indice++)
			{

				if( $this->Composto )
				{	// COMPOSTO
					$acumulador += $this->Pesos[ $indice] / pow(1.0 + $juros / 100.0, $this->Pagamentos[ $indice] / $this->Periodo);
				}
				else
				{	// SIMPLES
					$acumulador += $this->Pesos[ $indice] / (1.0 + $juros / 100.0 * $this->Pagamentos[ $indice] / $this->Periodo);
				}
			}

			if( $acumulador <= 0) return 0.0;
			return ( $total / $acumulador - 1.0) * 100.0;
		}

		function AcrescimoParaJuros(float $acrescimo, int $precisao = 15, int $maximoInteracoes = 65, float $maximoJuros = 50.0, bool $acrescimoComoValorOriginal = false)
		{
			$total = $this->getPesoTotal();
			if( $maximoInteracoes < 1 or $this->Quantidade < 1 or $precisao < 1 or $this->Periodo <= 0.0 or $acrescimo <= 0.0 or $total <= 0.0 or $maximoJuros <= 0.0) return 0.0;
			$minimoJuros = 0.0;
			$medioJuros = ( $minimoJuros + $maximoJuros) / 2.0;
			$minimaDiferenca = pow( 0.1, $precisao);

			if( $acrescimoComoValorOriginal )		// nesse caso, os pesos totais dão o valor cobrado e o acrescimo é o original
			{
				$acrescimo = 100.0 * ( $total / $acrescimo - 1.0);
				if( $acrescimo <= 0.0) return 0.0;
			}

			for( $indice = 1; $indice <= $maximoInteracoes; $indice++)
			{
				if( ( $maximoJuros - $minimoJuros ) < $minimaDiferenca ) break;
				if( $this->JurosParaAcrescimo( $medioJuros ) <= $acrescimo )
				{
					$minimoJuros = $medioJuros;
				}
				else
				{
					$maximoJuros = $medioJuros;
				}
				$medioJuros = ( $minimoJuros + $maximoJuros) / 2.0;
			}

			return $medioJuros;
		}
	}
?>