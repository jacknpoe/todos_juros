import { CalculaJuros } from "./CalculaJuros.js";

const btnValoresExemplo = window.document.getElementById("btnValoresExemplo");
const btnCalcular = window.document.getElementById("btnCalcular");

function valores_exemplo(){
	let quantidade = window.document.getElementById("quantidade");
	let tipo = window.document.getElementsByName("tipo");
	let periodo = window.document.getElementById("periodo");
	let pesos = window.document.getElementById("pesos");
	let pagamentos = window.document.getElementById("pagamentos");
	let calculo = window.document.getElementsByName("calculo");
	let percentual = window.document.getElementById("valor");

	quantidade.value = "3";
	tipo[1].checked = true;
	periodo.value = "30";
	pesos.value = "1,1,1";
	pagamentos.value = "30,60,90";
	calculo[1].checked = true;
	percentual.value = "6,059108997379403";
}

function calcular(){
	let quantidade = Number(window.document.getElementById("quantidade").value);
	let tipo = window.document.getElementsByName("tipo");
	tipo = ! tipo[0].checked;
	let periodo = Number(window.document.getElementById("periodo").value);
	let pesos = window.document.getElementById("pesos").value;
	let pagamentos = window.document.getElementById("pagamentos").value;
	let calculo = window.document.getElementsByName("calculo");
	calculo = calculo[0].checked;
	let percentual = Number(window.document.getElementById("valor").value.replace(",", "."));
	let resultado = window.document.getElementById("resultado");

	let juros = new CalculaJuros(quantidade, tipo, periodo);
	if(! juros.setPesos(",", pesos)){
		window.alert(`Você deve informar ${quantidade} pesos numéricos ou vazio!`);
		window.document.getElementById("pesos").focus();
		return;
	}
	if(! juros.setPagamentos(",", pagamentos)){
		window.alert(`Você deve informar ${quantidade} pagamentos numéricos ou vazio!`);
		window.document.getElementById("pagamentos").focus();
		return;
	}

	let res_numb = "";
	if(calculo){
		res_numb = "" + juros.jurosParaAcrescimo(percentual);
	} else{
		res_numb = "" + juros.acrescimoParaJuros(percentual, 18);
	}
	res_numb = res_numb.replace(".", ",");
	resultado.innerText = "Resultado: " + res_numb + "%";
}

btnValoresExemplo.addEventListener("click", (evt) => {
    valores_exemplo();
})

btnCalcular.addEventListener("click", (evt) => {
    calcular();
})
