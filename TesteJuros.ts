import { Juros } from "./Juros";

const juros = new Juros(3, true, 30);

juros.setPesos("1.0,1.0,1.0");
juros.setPagamentos("30,60,90");

const acrescimoCalculado: number = juros.jurosParaAcrescimo(3.0);
const jurosCalculado: number = juros.acrescimoParaJuros(acrescimoCalculado);

console.log(acrescimoCalculado);
console.log(jurosCalculado);
