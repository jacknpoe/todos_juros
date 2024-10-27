function valores_exemplo(){
	let quantidade = window.document.getElementById("quantidade")
	let tipo = window.document.getElementsByName("tipo")
	let periodo = window.document.getElementById("periodo")
	let pesos = window.document.getElementById("pesos")
	let pagamentos = window.document.getElementById("pagamentos")
	let calculo = window.document.getElementsByName("calculo")
	let percentual = window.document.getElementById("valor")

	quantidade.value = "3"
	tipo[1].checked = true
	periodo.value = "30"
	pesos.value = "1,1,1"
	pagamentos.value = "30,60,90"
	calculo[1].checked = true
	percentual.value = "6,059108997379403"
}