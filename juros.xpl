inc	C:\CXPL\EXPLCodes.xpl;	\ declaracoes intrinsecas

\ Calculo dos juros, sendo que precisa de parcelas pra isso
\  Versao 0.1: 19/02/2025: versao feita sem muito conhecimento de XPL0

\ numero de parcelas
def Quantidade = 3;

\ variaveis globais para simplificar as chamadas
int Composto;
real Periodo, Pagamentos(Quantidade), Pesos(Quantidade);

int Indice;
real PesoTotal, AcrescimoCalculado, JurosCalculado;

\\ calcula a somatoria de Pesos()
function real GetPesoTotal;
	real Acumulador;
	int Indice;
begin
	Acumulador := 0.;
	for Indice := 0, Quantidade - 1 do Acumulador := Acumulador + Pesos(Indice);
	return Acumulador;
end;

\ calcula o acrescimo a partir dos juros e parcelas
function real JurosParaAcrescimo(Juros);
	real Juros, PesoTotal, Acumulador;
	int Indice;
begin
	PesoTotal := GetPesoTotal;
	if Juros <= 0. ! Quantidade < 1 ! Periodo <= 0. ! PesoTotal <= 0. then return 0.;

	Acumulador := 0.;
	for Indice := 0, Quantidade - 1 do
		if Composto = 1 then 
			Acumulador := Acumulador + Pesos(Indice) / Pow(1. + Juros / 100., Pagamentos(Indice) / Periodo)
		else Acumulador := Acumulador + Pesos(Indice) / (1. + Juros / 100. * Pagamentos(Indice) / Periodo);

	if Acumulador <= 0. then return 0.;
	return (PesoTotal / Acumulador - 1.) * 100.;
end;

\ calcula os juros a partir do acrescimo e parcelas
function  real AcrescimoParaJuros(Acrescimo, Precisao, MaxIteracoes, MaxJuros);
	real Acrescimo;
	int Precisao, MaxIteracoes;
	real MaxJuros;
	real PesoTotal, MinJuros, MinDiferenca, MedJuros;
	int Iteracao;
begin
	if Acrescimo <= 0. ! Quantidade < 1 ! Periodo <= 0. ! PesoTotal <= 0. ! Precisao < 1 ! MaxIteracoes < 1 ! MaxJuros < 0. then return 0.;

	MinJuros := 0.;
	MinDiferenca := Pow(0.1, Float(Precisao));

	for Iteracao := 1, MaxIteracoes do
	begin
		MedJuros := (MinJuros + MaxJuros) / 2.;
		if (MaxJuros - MinJuros) < MinDiferenca then return MedJuros;
		if (JurosParaAcrescimo(MedJuros) < Acrescimo) then MinJuros := MedJuros else MaxJuros := MedJuros;
	end;

	return MedJuros;
end;

begin
	\ define os valores das variaveis globais
	Composto := 1;  \ 1 = true, outros = false
	Periodo := 30.;

	for Indice := 0, Quantidade - 1 do
	begin
		Pagamentos(Indice) := 30. * (Float(Indice) + 1.);
		Pesos(Indice) := 1.;
	end;

	\ calcula e guarda os resultados das funcoes
	PesoTotal := GetPesoTotal;
	AcrescimoCalculado := JurosParaAcrescimo(3.);
	JurosCalculado := AcrescimoParaJuros(AcrescimoCalculado, 15, 100, 50.);

	\ imprime os resultados
	Format(2, 15);
	Text(0, "Peso total = ");
	RlOut(0, PesoTotal);
	CrLf(0);
	Text(0, "Acrescimo = ");
	RlOut(0, AcrescimoCalculado);
	CrLf(0);
	Text(0, "Juros = ");
	RlOut(0, JurosCalculado);
	CrLf(0);
end;