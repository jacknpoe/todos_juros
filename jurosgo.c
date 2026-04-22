// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 21/04/2026: criada a partir da versão 0.11 de C, sem conhecimento de GObject

#include <math.h>         // para usar pow()
// #include <stdio.h>     // para usar printf() e gets()
// #include <stdlib.h>    // para usar malloc() e free()
#include <glib-object.h>  // GObject
// #include <glib.h>         // gboolean TRUE FALSE

// define o tipo antes de qualquer uso no arquivo
#define JUROS_TYPE (juros_get_type())

// define macro de cast para o tipo Juros
#define JUROS(obj) (G_TYPE_CHECK_INSTANCE_CAST((obj), JUROS_TYPE, Juros))

// define macro de cast para instância e classe
#define JUROS_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST((klass), JUROS_TYPE, JurosClass))

// dados da instância (campos do objeto) + base GObject
typedef struct _Juros {
    GObject parent_instance;

    gint Quantidade;
    gboolean Composto;
    double Periodo;
    double *Pagamentos;
    double *Pesos;

} Juros;

// estrutura da classe (metadados; aqui vazia)
typedef struct _JurosClass {
    GObjectClass parent_class;
} JurosClass;

// declara funções antes do uso implícito pela macro
static void juros_init(Juros *self);
static void juros_class_init(JurosClass *klass);

// registra o tipo Juros no sistema GObject
G_DEFINE_TYPE(Juros, juros, G_TYPE_OBJECT)

// inicializa os campos de cada instância
static void juros_init(Juros *self) {
    self->Quantidade = 0;
    self->Composto = FALSE;
    self->Periodo = 0.0;
    self->Pagamentos = NULL;
    self->Pesos = NULL;
}

// libera memória alocada quando o objeto é destruído
static void juros_finalize(GObject *obj) {
    Juros *juros = JUROS(obj);

    g_clear_pointer(&juros->Pagamentos, g_free);
    g_clear_pointer(&juros->Pesos, g_free);

    G_OBJECT_CLASS(juros_parent_class)->finalize(obj);
}

// inicializa a classe (executa uma vez)
static void juros_class_init(JurosClass *klass) {
    GObjectClass *gobject_class = G_OBJECT_CLASS(klass);

    // conecta a liberação ao ciclo de vida do GObject
    gobject_class->finalize = juros_finalize;
}

// define a quantidade de parcelas
gboolean set_quantidade(Juros *juros, gint quantidade) {
    if(quantidade < 0) return FALSE;
	if(quantidade == juros->Quantidade) return TRUE;

    g_clear_pointer(&juros->Pagamentos, g_free);
    g_clear_pointer(&juros->Pesos, g_free);

    if(quantidade > 0) {
        juros->Pagamentos = g_new(double, quantidade);
        if(!juros->Pagamentos) { juros->Quantidade = 0; return FALSE; }
        juros->Pesos = g_new(double, quantidade);
        if(!juros->Pesos) { g_free(juros->Pagamentos); juros->Pagamentos = NULL; juros->Quantidade = 0; return FALSE; }
    }
	juros->Quantidade = quantidade; return TRUE;
}

// define os valores escalares da estrutura (automaticamente, também chama set_quantidade)
gboolean set_valores(Juros *juros, gint quantidade, gboolean composto, double periodo) {
    if(!set_quantidade(juros, quantidade)) return FALSE;
	juros->Composto = composto;
	juros->Periodo = periodo;
	return TRUE;
}

// calcula a somatória do array Pesos[]
double get_peso_total(Juros *juros) {
	double acumulador = 0.0;
	gint indice;
	for(indice = 0; indice < juros->Quantidade; indice++) acumulador += juros->Pesos[indice];
	return acumulador;
}

// calcula o acréscimo a partir dos juros e parcelas
double juros_para_acrescimo(Juros *juros, double valor) {
	double pesoTotal = get_peso_total(juros);
	if(valor <= 0.0 || juros->Quantidade < 1 || juros->Periodo <= 0.0 || pesoTotal <= 0.0) return 0.0;
	double acumulador = 0.0; 
	gint indice;
	
	for(indice = 0; indice < juros->Quantidade; indice++) {
		if(juros->Composto) acumulador += juros->Pesos[indice] / pow(1.0 + valor / 100.0, juros->Pagamentos[indice] / juros->Periodo);
		else acumulador += juros->Pesos[indice] / (1.0 + valor / 100.0 * juros->Pagamentos[indice] / juros->Periodo);
	}
	
	if( acumulador <= 0.0 ) return 0.0;
	return(pesoTotal / acumulador - 1.0) * 100.0;
}

// calcula os juros a partir do acréscimo e parcelas
double acrescimo_para_juros(Juros *juros, double valor, short precisao, short maxIteracoes, double maxJuros) {
	double minJuros = 0.0, medJuros = (minJuros + maxJuros) / 2.0, minDiferenca = pow(0.1, precisao);
	short indice;
	double pesoTotal = get_peso_total(juros);
	if(maxIteracoes < 1 || juros->Quantidade < 1 || precisao < 1 || valor <= 0.0 || juros->Periodo <= 0.0 || pesoTotal <= 0.0 || maxJuros <= 0.0) return 0.0;

	for(indice = 0; indice < maxIteracoes; indice++) {
		if((maxJuros - minJuros) < minDiferenca) return medJuros;
		if(juros_para_acrescimo(juros, medJuros) <= valor)
			minJuros = medJuros; else maxJuros = medJuros;
		medJuros = (minJuros + maxJuros) / 2.0;
	}
	
	return medJuros;
}

int main() {
    double pesoTotal = 0, acrescimoCalculado = 0, jurosCalculado = 0;
	gint indice;

    // cria uma instância de Juros usando o sistema GObject
    // usa macro do tipo em vez de chamar a função diretamente
    Juros *juros = g_object_new(JUROS_TYPE, NULL);

    // valida criação do objeto antes de usar
    if (!juros) {
        g_printerr("Erro ao criar objeto juros!\n");
        return -1;
    }

    // define os valores de juros
	if(!set_valores(juros, 3, TRUE, 30.0)) {
		g_printerr("Erro ao definir os valores do objeto juros!");
		return -1;
	}

	for(indice = 0; indice < juros->Quantidade; indice++) {
		juros->Pagamentos[indice] = (indice + 1) * juros->Periodo;
		juros->Pesos[indice] = 1;
	}

    // calcula, guarda e imprime os resultados
	pesoTotal = get_peso_total(juros);
	g_print("Peso total: %3.15f\n", pesoTotal);
	acrescimoCalculado = juros_para_acrescimo(juros, 3.0);
	g_print("Acréscimo calculado: %3.15f\n", acrescimoCalculado);
	jurosCalculado = acrescimo_para_juros(juros, acrescimoCalculado, 15, 65, 50.0);
	g_print("Juros calculado: %3.15f\n", jurosCalculado);

	// libera a memória e depois a instância GObject
    g_object_unref(juros);
	return 0;
}
