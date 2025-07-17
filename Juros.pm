# Cálculo do juros, sendo que precisa de arrays pra isso
# Versão 0.1: 25/02/2024: versão feita sem muito conhecimento de Perl

# pragmas
use strict;
use warnings;

# Pacote com os valores comuns
package Juros;

# construtor
sub new {
	my ( $class ) = shift;
	my $self = {
		Quantidade => shift,
		Composto => shift,
		Periodo => shift,
		Pagamentos => shift,
		Pesos => shift
	};
	bless $self, $class;
	return $self;
}

# calcula a somatória de Pesos[]
sub getPesoTotal {
	my $self = shift;
	my $acumulador = 0;
	for(my $indice = 0; $indice < $self->{Quantidade}; $indice++) {
		$acumulador += $self->{Pesos}[$indice];
	}
	return $acumulador;
}

# calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
sub jurosParaAcrescimo {
	my $self = shift;
	my ($juros) = @_;

	if($juros <= 0.0 || $self->{Quantidade} <= 0 || $self->{Periodo} <= 0.0) { return 0.0; }
	my $pesoTotal = $self->getPesoTotal();
	if($pesoTotal <= 0.0) { return 0.0; }
	my $acumulador = 0.0;

	for(my $indice = 0; $indice < $self->{Quantidade}; $indice++) {
		if($self->{Composto}) {
			$acumulador += $self->{Pesos}[$indice] / (1.0 + $juros / 100.0) ** ($self->{Pagamentos}[$indice] / $self->{Periodo});
		} else {
			$acumulador += $self->{Pesos}[$indice] / (1.0 + $juros / 100.0 * $self->{Pagamentos}[$indice] / $self->{Periodo});
		}
	}

	if($acumulador <= 0.0) { return 0.0; }

	return ($pesoTotal / $acumulador - 1.0) * 100.0;
}

# calcula os juros a partir do acréscimo e dados comuns (como parcelas)
sub acrescimoParaJuros {
	my $self = shift;
	my ($acrescimo, $precisao, $maxIteracoes, $maxJuros) = @_;

	if($maxIteracoes < 1 || $self->{Quantidade} <= 0 || $precisao < 1 || $self->{Periodo} <= 0.0 || $acrescimo <= 0.0 || $maxJuros <= 0.0) { return  0.0; }
	my $pesoTotal = $self->getPesoTotal();
	if($pesoTotal <= 0.0) { return 0.0; }
	my $minJuros = 0.0;
	my $medJuros = $maxJuros / 2.0;
	my $minDiferenca = 0.1 ** $precisao;

	for(my $indice = 0; $indice < $maxIteracoes; $indice++) {
		$medJuros = ($minJuros + $maxJuros) / 2.0;
		if(($maxJuros - $minJuros) < $minDiferenca) { return $medJuros; }
		if($self->jurosParaAcrescimo($medJuros) < $acrescimo) {
			$minJuros = $medJuros;
		} else {
			$maxJuros = $medJuros;
		}
	}

	return $medJuros;
}

1;
