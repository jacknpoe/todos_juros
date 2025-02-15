import Juros
from jinja2 import Template

juros = Juros.Juros(3, True, 30.0)
juros.setpagamentos(",", "30.0,60.0,90.0")
juros.setpesos(",", "1.0,1.0,1.0")

with open("main.html.jinja") as f:
    tmpl = Template(f.read())

print(tmpl.render(
    pesoTotal = juros.getpesototal(),
    acrescimoCalculado = juros.jurosparaacrescimo(3.0),
    jurosCalculado = juros.acrescimoparajuros(juros.jurosparaacrescimo(3.0), 18)
))