<?php

// Cálculo dos juros, sendo que precisa de parcelas pra isso
// Versão 0.1: 13/02/2026: versao feita sem muito conhecimento de Twig

require_once __DIR__ . '/vendor/autoload.php';
require_once('CalculaJuros.php');

use Twig\Environment;
use Twig\Loader\FilesystemLoader;

$loader = new FilesystemLoader(__DIR__);
$twig = new Environment($loader);

$calculajuros = new \jacknpoe\CalculaJuros( 3, true, 30.0);
$calculajuros->setPesos( ",", "");
$calculajuros->setPagamentos( ",", "");

$pesoTotal = $calculajuros->getPesoTotal();
$acrescimoCalculado = $calculajuros->JurosParaAcrescimo(3.0);
$jurosCalculado = $calculajuros->AcrescimoParaJuros($acrescimoCalculado, 15, 65, 50.0, false);

echo $twig->render('juros.html.twig', [
    'pesoTotal'          => $pesoTotal,
    'acrescimoCalculado' => $acrescimoCalculado,
    'jurosCalculado'     => $jurosCalculado
]);
