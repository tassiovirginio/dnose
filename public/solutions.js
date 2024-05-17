window.onload = (event) => {
    console.log("Carregando...");
    document.getElementById("loading").style.visibility = "hidden";
    hljs.highlightAll();
    carrregarSelect();
    carrregarLista();
};


function carrregarSelect() {
    var select = document.getElementById("testSmells");
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        const lista = JSON.parse(req.response);
        for (var i = 0; i < lista.length; i++) {
            const option = document.createElement("option");
            option.value = lista[i];
            option.text = lista[i];
            select.appendChild(option);
        }
    };
    req.open("GET", "/testsmellsnames", true);
    req.send();//getlines100
}

function carrregarLista() {
    var listaFiles = document.getElementById("listaFiles");
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        const lista = JSON.parse(req.response);
        //0 - "flutter;
        //1 -  "    ";
        //2 -  flutter_localizations;
        //3 -  /home/tassio/dnose_projects/flutter/packages/flutter_localizations/test/cupertino/translations_test.dart;
        //4 - Magic Number;
        //5 - 30;
        //6 - 30"
        for (var i = 0; i < lista.length; i++) {
            var linha = lista[i].split(";");

            if (linha[1].trim() === "") continue;

            var path = linha[3];
            var testDescripcion = linha[1];
            var testSmellName = linha[4];
            console.log(linha);
            console.log(linha[1]);

            const tr = document.createElement("tr");

            const td1 = document.createElement("td");
            td1.innerHTML = linha[4];
            tr.appendChild(td1);

            const td2 = document.createElement("td");
            td2.innerHTML = linha[3];
            tr.appendChild(td2);

            const button = document.createElement("button");
            button.innerHTML = "solution";
            button.className = "button is-info is-light";
            button.onclick = () => {
                const solutionDiv = document.getElementById("solution");
                solutionDiv.innerHTML = "";
                var code = document.getElementById("code");
                code.innerHTML = "";
                carregarFile(path, testDescripcion, testSmellName)
            };
            const td3 = document.createElement("td");
            td3.appendChild(button);
            tr.appendChild(td3);

            listaFiles.appendChild(tr);
        }
    };
    req.open("GET", "/getlines100", true);
    req.send();
}

function carregarFile(path, testDescripcion, testSmellName) {
    console.log("path: " + path + " - " + testDescripcion);
    var code = document.getElementById("code");
    const req = new XMLHttpRequest();
    req.onload = async (e) => {
        console.log(req.response);
        var code_full = req.response;
        code.innerHTML = code_full;
        var prompt = "O código abaixo tem um Test Smell (" + testSmellName + ") gostaria que me desse soluções para a resolução do test smells. Código: " + code_full;
        await carregarSolution(prompt);
    };
    req.open("GET", "/getfiletext?path=" + path + "&test='" + testDescripcion + "'", true);
    req.send();
}

async function carregarSolution(prompt) {
    console.log(prompt);

    const solutionDiv = document.getElementById("solution");
    solutionDiv.innerHTML = "Analyzing...";
    const req = new XMLHttpRequest();
    req.open("POST", "/solution", true);
    req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

    prompt = prompt.replaceAll(" ","_");
    console.log(prompt);

    req.onreadystatechange = () => {
        if (req.readyState === XMLHttpRequest.DONE && req.status === 200) {
            solutionDiv.innerHTML = req.response;
            console.log(req.response);
        }
    };
    req.send(prompt);

}


