// Cálculo do juros, sendo que precisa de arrays pra isso
// Versão 0.1: 27/03/2024: versão feita a partir de pesquisas no Google no jdoodle.com e POW com expoente inteiro

#import <Foundation/Foundation.h>
#include <math.h> 

// classe
@interface Juros: NSObject {
    int Quantidade;
    BOOL Composto;
    double Periodo;
    NSMutableArray* Pagamentos; // = [NSMutableArray array];
    NSMutableArray* Pesos; // = [NSMutableArray array];
}
- (void) aloca;
- (int) Quantidade;
- (BOOL) Composto;
- (double) Periodo;
- (double) Pagamento: (int) i;
- (double) Pesos: (int) i;
- (void) setQuantidade: (int) q;
- (void) setComposto: (BOOL) c;
- (void) setPeriodo: (double) p;
- (void) putPagamento: (double) p;
- (void) putPeso: (double) p;
- (double) potencia: (double) valor expoente: (double) e;
- (double) getPesoTotal;
- (double) jurosParaAcrescimo: (double) juros;
- (double) acrescimoParaJuros: (double) acrescimo precisao: (double) p maxIteracoes: (int) i maxJuros: (double) m;
- (void) desaloca;
@end

@implementation Juros
- (void) aloca {
    Pagamentos  = [[NSMutableArray alloc] init];
    Pesos = [[NSMutableArray alloc] init];
}
- (int) Quantidade {
    return Quantidade;
}
- (BOOL) Composto {
    return Composto;
}
- (double) Periodo {
    return Periodo;
}
- (double) Pagamento: (int) i {
    return [[Pagamentos objectAtIndex: i] doubleValue];
}
- (double) Pesos: (int) i {
    return [[Pesos objectAtIndex: i] doubleValue];
}
- (void) setQuantidade: (int) q {
    Quantidade = q;
}
- (void) setComposto: (BOOL) c {
    Composto = c;
}
- (void) setPeriodo: (double) p {
    Periodo = p;
}
- (void) putPagamento: (double) p {
    [Pagamentos addObject: [NSNumber numberWithDouble: p]];
}
- (void) putPeso: (double) p {
    [Pesos addObject: [NSNumber numberWithDouble: p]];
}
// calcula a exponenciação do valor por e
// o problema é que ela só funciona co expoentes inteiros
// deve ser colocada uma exponenciação mais genérica
- (double) potencia: (double) valor expoente: (double) e {
    int expoente = (int) e;
    double acumulador = 1.0;
    int indice;
    for (indice = 0; indice < expoente; indice++) {
        acumulador *= valor;
    }
    return acumulador;
//    return pow(valor, e);
//    return (double) pow([NSNumber numberWithDouble: valor], [NSNumber numberWithDouble: e]);
}
// calcula a somatória de pesos
- (double) getPesoTotal {
    double acumulador = 0;
    int indice;
    for (indice = 0; indice < Quantidade; indice++) {
        acumulador += [[Pesos objectAtIndex: indice] doubleValue];
    }
    return acumulador;
}
// calcula os juros a partir do acréscimo e dados comuns (como parcelas)
- (double) jurosParaAcrescimo: (double) juros {
    if (juros <= 0.0 || Quantidade <= 0 || Periodo <= 0.0) return 0.0;
    double pesoTotal = [self getPesoTotal];
    if (pesoTotal <= 0.0) return 0.0;
    double acumulador = 0.0;
    // BOOL soZero = YES;
    int indice;

    for (indice = 0; indice < Quantidade; indice++) {
        // if([[Pagamentos objectAtIndex: indice] doubleValue] > 0.0 && [[Pesos objectAtIndex: indice] doubleValue] > 0.0) soZero = NO;
        if (Composto) {
            // ATENÇÃO: a potência só funciona com expoentes inteiros, porque a linguagem não tem POW!
            acumulador += [[Pesos objectAtIndex: indice] doubleValue] / [self potencia: (1 + juros / 100) expoente: ([[Pagamentos objectAtIndex: indice] doubleValue] / Periodo)];
        } else {
            acumulador += [[Pesos objectAtIndex: indice] doubleValue] / (1 + juros / 100 * [[Pagamentos objectAtIndex: indice] doubleValue] / Periodo);
        }
    }
    // if (soZero) return 0.0;
    if (acumulador <= 0.0) return 0.0;
    return (pesoTotal / acumulador - 1) * 100;
}
// calcula o acréscimo a partir dos juros e dados comuns (como parcelas)
- (double) acrescimoParaJuros: (double) acrescimo precisao: (double) p maxIteracoes: (int) mi maxJuros: (double) mj {
    if (mi < 1 || Quantidade < 1 || p < 1 || Periodo <= 0.0 || acrescimo <- 0.0 || mj <= 0.0 ) return 0.0;
    double pesoTotal = [self getPesoTotal];
    if (pesoTotal <= 0.0) return 0.0;
    double minJuros = 0.0;
    double medJuros = mj / 2.0;
    double maxJuros = mj;
    double minDiferenca = [self potencia: 0.1 expoente: p];
    int indice;
    
    for (indice = 0; indice < mi; indice++) {
        medJuros = (minJuros + maxJuros) / 2.0;
        if ((maxJuros - minJuros) < minDiferenca) return medJuros;
        if ([self jurosParaAcrescimo: medJuros] < acrescimo) {
            minJuros = medJuros;
        } else {
            maxJuros = medJuros;
        }
    }
    
    return medJuros;
}
- (void) desaloca {
    [Pagamentos release];
    [Pesos release];
}
@end

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // cria juros e seta as propriedades
    Juros * juros = [[Juros alloc] init];
    [juros aloca];
    [juros setQuantidade: 3];
    [juros setComposto: YES];
    [juros setPeriodo: 30.0];
    [juros putPagamento: 30.0];
    [juros putPagamento: 60.0];
    [juros putPagamento: 90.0];
    [juros putPeso: 1.0];
    [juros putPeso: 1.0];
    [juros putPeso: 1.0];

    // testes
    double pesoTotal = [juros getPesoTotal];
    double acrescimo = [juros jurosParaAcrescimo: 3.0];
    double juroscalc = [juros acrescimoParaJuros: acrescimo precisao: 15.0 maxIteracoes: 100 maxJuros: 50.0];

    NSLog(@"Peso Total = %f", pesoTotal);
    NSLog(@"Acréscimo = %f", acrescimo);
    NSLog(@"Juros = %f", juroscalc);
    // NSLog(@"Pow = %f", pow(1.03, 0.5));
    // NSLog(@"Pow = %f", pow(acrescimo, [juros Pagamento: 1] / [juros Periodo]));

    [juros desaloca];
    [juros release];
    [pool drain];
    return 0;
}