# pragmas
use strict;
use warnings;
use Juros;

# os arrays para serem referenciados pelos atributos 
my @Pagamentos;
my @Pesos;

for(my $indice = 0; $indice < 3; $indice++) {
	@Pagamentos[$indice] = ($indice + 1) * 30.0;
	@Pesos[$indice] = 1.0;
}

# cria o objeto $juros com os valores (o número 1 quer dizer TRUE)
my $juros = Juros->new( 3, 1, 30.0, \@Pagamentos, \@Pesos);

# testes de cálculo
print "Peso Total = " . $juros->getPesoTotal() . "\n";
print "Acrescimo = " . $juros->jurosParaAcrescimo( 3.0) . "\n";
print "Juros = " . $juros->acrescimoParaJuros( $juros->jurosParaAcrescimo( 3.0), 15, 100, 50.0) . "\n";
