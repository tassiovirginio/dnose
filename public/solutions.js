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
        //"flutter;
        // "    ";
        // flutter_localizations;
        // /home/tassio/dnose_projects/flutter/packages/flutter_localizations/test/cupertino/translations_test.dart;
        // Magic Number;
        // 30;
        // 30"
        for (var i = 0; i < lista.length; i++) {
            var linha = lista[i].split(";");
            const tr = document.createElement("tr");

            const td1 = document.createElement("td");
            td1.innerHTML = linha[4];
            tr.appendChild(td1);

            const td2 = document.createElement("td");
            td2.innerHTML = linha[3];
            tr.appendChild(td2);

            const button = document.createElement("button");
            button.innerHTML = "solution";
            button.className = "button";
            button.onclick = (e) => {};
            const td3 = document.createElement("td");
            td3.appendChild(button);
            tr.appendChild(td3);

            listaFiles.appendChild(tr);
        }
    };
    req.open("GET", "/getlines100", true);
    req.send();
}


