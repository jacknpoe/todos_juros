# SOLVING TRANSCENDENT EQUATIONS

There are **equations** that cannot be solved using **elementary algebraic methods**. These are called transcendental equations. You need to apply a concept from **Numerical Analysis** called the **Bisection Method** to solve them. This **method** is used to find the **roots** of **functions**. Here, we will solve one of these **equations**, which is the **calculation** of the **interest rate** from the **increase percentage** of a set of **weighted installments**. The only difference is that we will look for the **value** at which a **function** reaches the desired **increase**, instead of the **roots** of the **function**.

Our **project** will be in **Python**, for simplicity, but the other solutions in this **repository** follow the same structure and logic. We begin by placing some basic values, which rarely change, ​​in `Juros.py` and which we will store as attributes in our `Juros` class:

```python
class Juros:
    """this class calculates interest rate and requires arrays to do so"""
    Quantidade = 0
    Composto = False
    Periodo = 30.0
    Pagamentos = []
    Pesos = []
```

We have **three** simple attributes: the total **number** (`Quantidade`) of payments, whether the **interest** is **compound** (`Composto`), and the number of **periods** (`Periodo`) over which the **interest** is **calculated** (for example, every `30.0` **days**; note that the **period** does not need to be in **days**, it can be in **weeks**, **months**, or even **years**, it is only required that the **payment terms** use the same **unit of time**). And **two** *array* attributes: the number of **payment times** (`Pagamentos`) for each **payment** (for example, `0.0`, `30.0`, `60.0`, and `90.0` **days**), and the **weights** (`Pesos`) of each **payment** (for example, if the **down payment** were **double** the others, it would be `2.0`, `1.0`, `1.0`, `1.0`).

Our **constructor** will allow the definition of these **three** simple attributes:

```python
    def __init__(self, quantidade=0, composto=False, periodo=30.0):
        """the constructor initializes the scalar attributes."""
        self.Quantidade = quantidade
        self.Composto = composto
        self.Periodo = periodo
```

The `Pagamentos` array will have a **method** to insert elements from a string:

```python
    def setpagamentos(self, delimitador=",", pagamentos=""):
        """defines payment dates from a string separated by the delimiter"""
        self.Pagamentos.clear()
        if pagamentos == "":
            for i in range(self.Quantidade):
                self.Pagamentos.append((i + 1) * self.Periodo)
        else:
            temporaria = pagamentos.split(delimitador)
            for i in range(self.Quantidade):
                self.Pagamentos.append(float(temporaria[i]))
```

It receives a **delimiter** and a **string of numbers** separated by the **delimiter** (Example: `“,”`, `“0,30,60,90”`). By default, if the string is empty, the values ​​in the array will be included with the values ​​of `Periodo` (period) multiplied by the **installment** number (considering the first as `1`). For example, with `Periodo` (period) = `30.0`, for `30.0`, `60.0`, `90.0`... up to the `Quantidade` (number) of **installments**.

The `Pesos` (weights) array will have a similar **method**:

```python
    def setpesos(self, delimitador=",", pesos=""):
        """define the weights from a string separated by the delimiter"""
        self.Pesos.clear()
        if pesos == "":
            for i in range(self.Quantidade):
                self.Pesos.append(1.0)
        else:
            temporaria = pesos.split(delimitador)
            for i in range(self.Quantidade):
                self.Pesos.append(float(temporaria[i]))
```

The difference in this **method** is that if the string is empty, all **weights** will be included with the value `1.0`, meaning that all **installments** have the same value.

Now, let's see how the **calculations** are done.

**Simple Interest**:

![Juros Simples](JurosSimples.jpg)

**Compound interest**:

![Juros Compostos](JurosCompostos.jpg)

(`pesoTotal` = totalWeight; `quantidade` = quantity; `pesos` = weights; `juros` = interest rate; `pagamentos` = payments; `periodo` = period)

One **method** we need to define before our **calculations** is the **sum** of the **weights** of the **installments** (`getpesototal`):

```python
    def getpesototal(self):
        """returns the total sum of all weights"""
        acumulador = 0.0
        for i in range(self.Quantidade):
            acumulador += self.Pesos[i]
        return acumulador
```

The **Bisection Method** needs to have a **method** to call, and **evaluate** whether the result is **above** or **below** the **target increase**. In our **solution**, it **calculates** the **increase** based on the **interest rate** and the **attributes** of the **object**. The **method** is `jurosparaacrescimo` (increase from interest rate):

```python
    def jurosparaacrescimo(self, juros=0.0):
        """calculates the increase based on the interest rate"""
        pesototal = self.getpesototal()

        if juros <= 0.0 or self.Quantidade < 1 or self.Periodo <= 0.0 or pesototal <= 0.0:
            return 0.0

        acumulador = 0.0

        for i in range(self.Quantidade):
            if self.Composto:
                try:
                    acumulador += self.Pesos[i] / ((1.0 + juros / 100.0) ** (self.Pagamentos[i] / self.Periodo))
                except OverflowError:
                    pass
            else:
                acumulador += self.Pesos[i] / (1.0 + juros / 100.0 * self.Pagamentos[i] / self.Periodo)

        if acumulador <= 0.0:
            return 0.0

        return (pesototal / acumulador - 1.0) * 100.0
```

This method receives the **interest rate**, expressed as a percentage.

We **calculate** the **total weight**, storing it in `pesototal` (total weight). This variable will be used to produce the **final result**.

We **evaluate** if at least one value among `juros` (interest rate), `Quantity` (number of installments), `Periodo` (period), or `pesototal` (total weight) is **zero** or **negative**, which causes the method to return **zero**. This evaluation eliminates much of the method's misuse. In practice, only in cases like **simple interest** exactly equal to `1.0`, and an element in `Pagamentos` (payments) being **negative one hundred** times `Periodo` (period), will it cause a **division by zero**. But arrays are not being evaluated in this **version**, for **didactic** purposes.

We **initialize** the `acumulador` (accumulator) which will sum the **weighted values** ​​of the **installments** (which is the **contribution** each **installment** makes to paying the **total value**, deducting **interest**).

We **iterate** through the **number** of installments. We **increment** the `acumulador` (accumulator) to obtain the sum of the **weighted values ​​of the installments**, using the **calculation** of **compound interest** or **simple interest**, according to `Composto` (compound).

We return **zero** if the `acumulador` (accumulator) is **zero** or **negative** (because it could generate a **division by zero** or absurd results).

The value of the **increase** is **calculated** by dividing the `pesototal` (total weight) by the **sum of the weighted values** ​​multiplied by the **interest rate** `acumulador` (accumulator), subtracting `1.0` and multiplying by `100.0`. For example, if the division value is `1.03`, the result will be a `3%` **increase**.

We can now **write** the **method** that is the objective of this **repository**, `acrescimoparajuros` (interest rate from increase):

```python
    def acrescimoparajuros(self, acrescimo=0.0, precisao=15, maximointeracoes=65, maximojuros=50.0):
        """calculates the interest rate based on the increase"""
        pesototal = self.getpesototal()

        if ( maximointeracoes < 1 or self.Quantidade < 1 or precisao < 1 or self.Periodo <= 0.0
             or acrescimo <= 0.0 or pesototal <= 0.0 or maximojuros <= 0.0 ):
            return 0.0

        minimojuros = 0.0
        mediojuros = maximojuros / 2.0

        minimadiferenca = 0.1 ** precisao

        for i in range(maximointeracoes):
            if (maximojuros - minimojuros) < minimadiferenca:
                return mediojuros
            if self.jurosparaacrescimo(mediojuros) <= acrescimo:  # bisseção
                minimojuros = mediojuros
            else:
                maximojuros = mediojuros
            mediojuros = (minimojuros + maximojuros) / 2.0

        return mediojuros
```

The **parameters** of this **method** are a bit more complicated. We receive the `acrescimo` (increase) value, we can choose how many decimal places we want for `precisao` (precision), the maximum number of **iterations** the method will apply, `maximoiteracoes` (maximum number of iterations), and the **maximum interest rate** the method will use at the beginning, `maximojuros` (maximum interest rate). Only `acrescimo` (increase) is absolutely necessary, as the **default values** ​​of the other **parameters** are sufficient to perform the **calculation** in most situations.

First, we **calculate** the `pesototal` (total weight). Here it is not used for **calculations**, only for **validation**.

Then we **test** if some values ​​are equal to **zero** or **negative** (`maximoiteracoes` (maximum number of iterations), `Quantidade` (number of installments), `precisao` (precision), `Periodo` (period), `acrescimo` (increase), `pesototal`(total weight), and `maximojuros` (maximum interest rate)), if so, we return **zero**.

We **initialize** the **minimum interest rate** as **zero**, `minimojuros`, and the **midpoint interest rate** as half of `maximojuros` (maximum interest rate), `mediojuros`.

In `minimadiferenca` (minimum difference), we store the value of the **precision** we want, in `precisao` of **decimal places**, so we can evaluate when the **algorithm** can stop (for example, `0.0001` when we define `precisao` as `4`).

In the **loop**, we first **check** if the current values ​​in `maximojuros` (maximum interest rate) and `minimojuros` (minimum interest rate) differ **less** than `minimadiferenca` (minimum difference), at which point we return the **average** found in `mediojuros` (midpoint interest rate), since we have already found the result with the desired **precision**.

The **key idea** of the **algorithm** we are **implementing** is in the next `if`. We call the `jurosparaacrescimo` (increase from interest rate) method to calculate whether, with the current value of `mediojuros` (midpoint interest rate), the result of the **method** is greater or **less** than the **parameter** `acrescimo` (increase). If it is **less** or **equal**, we change `minimojuros` (minimum interest rate) to `mediojuros` (midpoint interest rate). If it is **greater**, we change `maximojuros` (maximum interest rate) to `mediojuros` (midpoint interest rate).

The **most important thing** in the **algorithm** is that it has these two values, `minimojuros` (minimum interest rate) and `maximojuros` (maximum interest rate), whose **difference** is **halved** in each **iteration**. Eventually, the **difference** may become **less** than the precision we want. Note that `minimojuros` (minimum interest rate) will always be **less** than or **equal** to, and `maximojuros` (maximum interest rate) will always be **greater** than or **equal** to, the value we are looking for.

The last thing done in the **loop** is to update `mediojuros` (midpoint interest rate) to be the **average** between `minimojuros` (minimum interest rate) and `maximojuros` (maximum interest rate).

If the number of **iterations** reaches `maximoiteracoes` (maximum number of iterations), the value of `mediojuros` (average interest rate) will be returned, even if the **precision** we calculated in `minimadiferenca` (minimum difference) is not reached. This is very important when, for example, due to **implementation** issues with **floating-point numbers**, it's not possible to find a difference between `minimojuros` (minimum interest rate) and `maximojuros` (maximum interest rate) that is **smaller** than `minimadiferenca` (minimum difference).

To **test** our **class**, we created a `main.py` file:

```python
import Juros

# creates an Interest object of the Interest class, initializes scalars, and sets arrays
juros = Juros.Juros(3, True, 30.0)
juros.setpagamentos()
juros.setpesos()

# calculates and stores the results of the methods
pesototal = juros.getpesototal()
acrescimocalculado = juros.jurosparaacrescimo(3.0)
juroscalculado = juros.acrescimoparajuros(acrescimocalculado)

# print the results
print("Peso total = " + str(pesototal))
print("Acréscimo = " + str(acrescimocalculado))
print("Juros = " + str(juroscalculado))
```

We import `Juros`. We create an object with `3` installments, **compound** interest, and periods of `30.0` days. We call `juros.setpagamentos` (set payments) and `juros.setpesos` (set weights) without **parameters**, so that `juros.pagamentos` (payments) is equal to [`30.0`, `60.0`, `90.0`] and `juros.pesos` (weights) is equal to [`1.0`, `1.0`, `1.0`].

We **calculate** the **total weight**. We **calculate** the **increase** from `3%` **interest rate**. And we perform the **inverse calculation**, using `acrescimocalculado` (calculated increase) in the `acrescimo` (increase) parameter, without altering the default values ​​of `pesos.acrescimoparajuros` (interest rate from increase) (`15` for `precisao` (precision), `65` for `maximoiteracoes` (maximum iterations), and `50.0` for `maximojuros` (maximum interest rate)).

Then we print the three **results**.

The **result** should look something like this:

```console
Peso total = 3.0
Acréscimo = 6.059108997379403
Juros = 3.0000000000000133
```

The source code for the complete solution:

[Juros.py](Juros.py)<br>
[main.py](main.py)
