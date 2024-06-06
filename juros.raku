class Juros {
	# atributos para simplificar as chamadas (como o new() de testajuros indicará os atributos, não precisa de construtor)
	has Int  $.Quantidade = 0;
	has Bool $.Composto = False;
	has Num  $.Periodo = 0e0;
	has Num  @.Pagamentos = ();
	has Num  @.Pesos = ();

	# calcula a somatória de Pesos[]
	method getPesoTotal {
		my $acumulador = 0.0;
		loop (my $indice = 0; $indice < $!Quantidade; $indice++) {
			$acumulador += @!Pesos[$indice];
		}
		return $acumulador;
	}

	# calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
	method jurosParaAcrescimo ($juros) {
		if ($juros <= 0e0 || $!Quantidade < 1 || $!Periodo <= 0e0) { return 0e0; }
		my $pesoTotal = self.getPesoTotal();
		if ($pesoTotal <= 0e0) { return 0e0; }
		my $acumulador = 0e0;

		loop (my $indice = 0; $indice < $!Quantidade; $indice++) {
			if ($!Composto) {
				$acumulador += @!Pesos[$indice] / (1.0 + $juros / 100.0) ** (@!Pagamentos[$indice] / $!Periodo);
			} else {
				$acumulador += @!Pesos[$indice] / (1.0 + $juros / 100.0 * @!Pagamentos[$indice] / $!Periodo);
			}
		}

		if ($acumulador <= 0.0) { return 0.0; }

		return ($pesoTotal / $acumulador - 1.0) * 100.0;
	}

	# calcula os juros a partir do acréscimo e dados comuns (como parcelas)
	method acrescimoParaJuros ($acrescimo, $precisao, $maxIteracoes, $maximoJuros) {
		if ($maxIteracoes < 1 || $!Quantidade <= 0 || $precisao < 1 || $!Periodo <= 0e0 || $acrescimo <= 0e0 || $maximoJuros <= 0e0) { return  0e0; }
		my $pesoTotal = self.getPesoTotal();
		if ($pesoTotal <= 0e0) { return 0e0; }
		my $minJuros = 0e0;
		my $medJuros = $maximoJuros / 2e0;
		my $maxJuros = $maximoJuros;
		my $minDiferenca = .1e0 ** $precisao;

		loop (my $indice = 0; $indice < $maxIteracoes; $indice++) {
			$medJuros = ($minJuros + $maxJuros) / 2e0;
			if (($maxJuros - $minJuros) < $minDiferenca) { return $medJuros; }
			if (self.jurosParaAcrescimo($medJuros) < $acrescimo) {
				$minJuros = $medJuros;
			} else {
				$maxJuros = $medJuros;
			}
		}

		return $medJuros;
	}
} 

# os arrays para serem referenciados pelos atributos 
my @Pagamentos;
my @Pesos;

loop (my $indice = 0; $indice < 3; $indice++) {
	@Pagamentos[$indice] = ($indice + 1e0) * 30e0;
	@Pesos[$indice] = 1e0;
}

# cria o objeto $juros com os valores
my $juros = Juros.new(Quantidade => 3, Composto => True, Periodo => 30e0, Pagamentos => @Pagamentos, Pesos => @Pesos);

# testes de cálculos
my $pesoTotal = $juros.getPesoTotal();
my $acrescimoCalculado = $juros.jurosParaAcrescimo(3e0);
my $jurosCalculado = $juros.acrescimoParaJuros($acrescimoCalculado, 15, 100, 50e0);

# imprime os resultados
say "Peso Total = $pesoTotal";
say "Acrescimo = $acrescimoCalculado";
say "Juros = $jurosCalculado";
