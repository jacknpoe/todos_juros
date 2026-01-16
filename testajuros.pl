# pragmas
use strict;
use warnings;
use Juros;

# mude esses valores para suas parcelas
my $Quantidade = 3;
my $Composto = 1; # verdadeiro
my $Periodo = 30.0;

# cria o objeto $juros com os valores (o número 1 quer dizer TRUE)
my $juros = Juros->new( $Quantidade, $Composto, $Periodo);

# preenche os arrays das parcelas, mude aqui para seu parcelamento
for(my $indice = 0; $indice < $juros->{Quantidade}; $indice++) {
	$juros->setParcela( $indice, ($indice + 1) * 30.0, 1.0);
}

# testes de cálculo
print "Peso Total = " . $juros->getPesoTotal() . "\n";
print "Acrescimo = " . $juros->jurosParaAcrescimo( 3.0) . "\n";
print "Juros = " . $juros->acrescimoParaJuros( $juros->jurosParaAcrescimo( 3.0), 15, 100, 50.0) . "\n";
