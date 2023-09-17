<!DOCTYPE html>
<html lang="pt-BR">
	<head>
		<title>Teste de Classe \jacknpoe\CalculaJuros (de juros a acréscimo e de acréscimo a juros)</title>
 		<link rel="stylesheet" href="php_testejuros.css"/>
		<link rel="icon" type="image/png" href="php_testejuros.png"/>
		<meta name="viewport" content="width=device-width, initial-scale=1">
	</head>
	<body>
		<?php
			header( "Content-Type: text/html; charset=ISO-8859-1", true);

			$resultado = '0';
			$quantidade = '0';
			$tipo = "simples";
			$periodo = '30';
			$pesos = '';
			$pagamentos = '';
			$calculo = 'jurosparaacrescimo';
			$valor = '0';

			if( isset( $_POST[ 'calcular']))
			{
				$quantidade = $_POST['quantidade'];
				$tipo =  $_POST['tipo'];
				$periodo = $_POST['periodo'];
				$pesos = trim( $_POST[ 'pesos']);
				$pagamentos = trim( $_POST[ 'pagamentos']);
				$calculo = $_POST['calculo'];
				$valor = $_POST['valor'];

				require_once( 'CalculaJuros.php');
				$calculajuros = new \jacknpoe\CalculaJuros( (int)$quantidade, ( $tipo === "composto"), (int)$periodo);
				$calculajuros->setPesos( ",", $pesos);
				$calculajuros->setPagamentos( ",", $pagamentos);
				if( $calculo === "jurosparaacrescimo")
				{
					$resultado = $calculajuros->JurosParaAcrescimo( floatval( str_replace( ',', '.', $valor)));
				}
				else
				{
					$resultado = $calculajuros->AcrescimoParaJuros( floatval( str_replace( ',', '.', $valor)), 16, 100, 50, false);
				}

			}
		?>
		<h1>Juros para Acréscimo / Acréscimo para Juros<br></h1>

		<form action="php_testejuros.php" method="POST" style="border: 0px">
			<p>Quantidade: <input type="number" name="quantidade" value="<?php echo htmlspecialchars( $quantidade, ENT_QUOTES | ENT_SUBSTITUTE | ENT_HTML401, "ISO-8859-1"); ?>" style="width: 50px" autofocus></p>
			<p>Tipo: <input type="radio" name="tipo" value="simples" <?php if( $tipo === "simples") echo "checked"; ?>>simples
				     <input type="radio" name="tipo" value="composto" <?php if( $tipo === "composto") echo "checked"; ?>>composto</p>
			<p>Período: <input type="number" name="periodo" value="<?php echo htmlspecialchars( $periodo, ENT_QUOTES | ENT_SUBSTITUTE | ENT_HTML401, "ISO-8859-1"); ?>" style="width: 50px"> dias (período sobre o qual o juros incide, normalmente 30 dias)</p>
			<p>Pesos: <input type="text" name="pesos" value="<?php echo htmlspecialchars( $pesos, ENT_QUOTES | ENT_SUBSTITUTE | ENT_HTML401, "ISO-8859-1"); ?>" style="width: 200px"> (pesos separados por vírgula, para parcelas iguais deixe vazio ou 1,1,1,1...)</p> 
			<p>Pagamentos: <input type="text" name="pagamentos" value="<?php echo htmlspecialchars( $pagamentos, ENT_QUOTES | ENT_SUBSTITUTE | ENT_HTML401, "ISO-8859-1"); ?>" style="width: 200px"> (prazos de pagamento separados por vírgula, para 30,60,90,120... deixar vazio)</p> 
			<p>Cálculo: <input type="radio" name="calculo" value="jurosparaacrescimo"<?php if( $calculo === "jurosparaacrescimo") echo "checked"; ?>>juros para acréscimo
				        <input type="radio" name="calculo" value="acrescimoparajuros"<?php if( $calculo === "acrescimoparajuros") echo "checked"; ?>>acréscimo para juros</p>
			<p>Percentual: <input type="text" name="valor" value="<?php echo htmlspecialchars( $valor, ENT_QUOTES | ENT_SUBSTITUTE | ENT_HTML401, "ISO-8859-1"); ?>" style="width: 100px">%</p>
			<p><input type="submit" name="calcular" value="Calcular"></p>
		</form>

		<br><p>Resultado: <?php echo number_format( $resultado, 14, ",", ".") ; ?>%</p><br><br>
		<p><a href="https://github.com/jacknpoe/php_testejuros">Repositório no GitHub</a></p><br><br>
		<form action="index.html" method="POST" style="border: 0px">
			<p><input type="submit" name="voltar" value="Voltar"></p>
		</form>
	</body>
</html>