# Calcula o acréscimo a partir dos juros e os juros a partir do acréscimo
# Versões: 0.1: 17/11/2025: fazendo a partir da versão em Python para MicroPython
# on-line: https://wokwi.com/projects/447878410647046145

# módulos
from machine import I2C, Pin    # I2C é o mostrador de cristal líquido
from time import sleep
from pico_i2c_lcd import I2cLcd
import Juros

# cria o lcd (não sei o que cada linha faz, estava assim no exemplo que eu peguei)
i2c = I2C(0, sda=Pin(0), scl=Pin(1), freq=400000)
I2C_ADDR = i2c.scan()[0]
lcd = I2cLcd(i2c, I2C_ADDR, 2, 16)

# cria o objeto juros da classe Juros do arquivo importado Juros.py
juros = Juros.Juros(3, True, 30.0)
juros.setpagamentos(",", "")
juros.setpesos(",", "")

# calcula os resultados
pesototal = juros.getpesototal()
acrescimocalculado = juros.jurosparaacrescimo(3.0)
juroscalculado = juros.acrescimoparajuros(acrescimocalculado, 18)

# fica mostrando os resultados em looping infinito
while True:
    lcd.move_to(0, 0)
    lcd.putstr("Peso total:")
    lcd.move_to(0, 1)
    lcd.putstr(str(pesototal))
    sleep(3)        # mostra por três segundos
    lcd.clear()
    lcd.move_to(0, 0)
    lcd.putstr("Acrescimo:")
    lcd.move_to(0, 1)
    lcd.putstr(str(acrescimocalculado))
    sleep(3)        # mostra por três segundos
    lcd.clear()
    lcd.move_to(0, 0)
    lcd.putstr("Juros:")
    lcd.move_to(0, 1)
    lcd.putstr(str(juroscalculado))
    sleep(3)        # mostra por três segundos
    lcd.clear()