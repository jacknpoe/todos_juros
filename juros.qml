// Calculo do juros, sendo que precisa de arrays pra isso
// Versao 0.1: 27/01/2026: feito sem muito conhecimento de QML com a ajuda do ChatGPT
// export QML_XHR_ALLOW_FILE_READ=1 // execute no terminal ANTES de qmlscene juros.qml

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "Cálculo de Juros com JS"

    property var juros: null

    Component.onCompleted: {
        // Carrega o arquivo jurosQML.js
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "jurosQML.js", false)
        xhr.send()
        eval(xhr.responseText)

        // cria a instancia da classe Juros e define os atributos
        var juros = new Juros(3, true, 30.0)
        juros.setPagamentos()
        juros.setPesos()

        // realiza e guarda os cálculos
        var pesoTotal = juros.getPesoTotal()
        var acrescimoCalculado = juros.jurosParaAcrescimo(3.0)
        var jurosCalculado = juros.acrescimoParaJuros(acrescimoCalculado)

        // atualiza os textos na interface
        pesoText.text = "Peso total = " + pesoTotal.toFixed(15)
        acrescimoText.text = "Acrescimo = " + acrescimoCalculado.toFixed(15)
        jurosText.text = "Juros = " + jurosCalculado.toFixed(15)
    }

    Column {
        anchors.centerIn: parent
        spacing: 10

        Text { id: pesoText; text: "" }
        Text { id: acrescimoText; text: "" }
        Text { id: jurosText; text: "" }
    }
}
