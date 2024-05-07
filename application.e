note
	description: "Classe raiz da aplicação de testes"
	author: "Ricardo Erick Rebêlo"
	date: "$Date$"
	revision: "$Revision$"

class APPLICATION

inherit ANY -- ARGUMENTS_32

create {ANY} make

feature {}
	make
	local
		juros: JUROS
		pesototal, acrescimocalculado, juroscalculado: REAL_64
	do  -- cria objeto com os valores iniciais
		juros := create {JUROS}.make(3, True, 30.0, <<30.0, 60.0, 90.0>>, <<1.0, 1.0, 1.0>>)

		-- testa as funções
		pesototal := juros.getpesototal
		acrescimocalculado := juros.jurosparaacrescimo(3.0)
		juroscalculado := juros.acrescimoparajuros(acrescimocalculado, 15, 100, 50.0)
		print("%NPeso total = ")
		print(pesototal.out)
		print("%NAcrescimo = ")
		print(acrescimocalculado.out)
		print("%NJuros = ")
		print(juroscalculado.out)
		print("%N")
	end
end
