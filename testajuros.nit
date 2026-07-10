# Cálculo dos juros, sendo que precisa de parcelas pra isso
# Versão 0.1: 10/07/2026: versão feita sem muito conhecimento de Nit

module testajuros

# importa juros.nit
import juros

# variáveis globais para enviar para o construtor
var quantidade : Int = 3
var composto : Bool = true
var periodo : Float = 30.0

# cria um objeto juros da classe Juros e inicializa seus atributoscom as variáveis globais
var juros : Juros = new Juros(quantidade, composto, periodo)

# insere elementos nos arrays pagamentos[] e pesos[]
for indice in [1..quantidade] do
    juros.pagamentos.add(indice.to_f * periodo)
    juros.pesos.add(1.0)
end

# calcula e guarda os resultados dos métodos
var pesoTotal : Float = juros.getPesoTotal
var acrescimoCalculado : Float = juros.jurosParaAcrescimo(3.0)
var jurosCalculado : Float = juros.acrescimoParaJuros(acrescimoCalculado, 15, 65, 50.0)

# imprime os resultados
print "Peso total = {pesoTotal.to_precision(15)}"
print "Acréscimo = {acrescimoCalculado.to_precision(15)}"
print "Juros = {jurosCalculado.to_precision(15)}"
