function carregarNomeProjeto() {
    const req3 = new XMLHttpRequest();
    req3.onload = (e) => {
        document.getElementById("projectname").innerHTML = req3.response;
    };
    req3.open("GET", "/projectnameatual", true);
    req3.send();
}

function carregarNomesTestSmells() {
    const req4 = new XMLHttpRequest();
    const nomes = new Array();
    const valores = new Array();
    const valores2 = new Array();
    req4.onload = (e) => {
        const linhas = req4.response.split("\n");
        for (var i = 1; i < linhas.length; i++) {
            const nome = linhas[i].split(";")[0];
            const valor = linhas[i].split(";")[1];
            if (nome !== "") {
                nomes.push(nome);
                const valorLog = Math.log(valor);
                valores.push(valor);
                valores2.push(valorLog);
            }
        }
        carregarChart('myChart', nomes, valores, '# of Test Smells');
        carregarChart('myChart2', nomes, valores2, '# of Test Smells (log))');
    };
    req4.open("GET", "/charts_data", true);
    req4.send();
    return nomes;
}

function carregarChart(id, nomes, valores, msg) {
    const ctx = document.getElementById(id);

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: nomes,
            datasets: [{
                label: msg,
                data: valores,
                borderWidth: 1
            }]
        },
        options: {
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
}

function carregarResultados() {
    const req2 = new XMLHttpRequest();
    req2.onload = (e) => {
        if (req2.response === "true") {
            document.getElementById("resultado").style.visibility = "visible";
            document.getElementById("resultado2").style.visibility = "visible";
        } else {
            document.getElementById("resultado").style.visibility = "hidden";
            document.getElementById("resultado2").style.visibility = "hidden";
        }
    };
    req2.open("GET", "/result1exists", true);
    req2.send();
}

function gerardb() {
    const req2 = new XMLHttpRequest();
    req2.onload = (e) => {
        console.log(req2.response);
    };
    req2.open("GET", "/gerardb", true);
    req2.send();
}

function carregarSelectProjects() {
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        const lista_projetos = JSON.parse(req.response);
        const select_projects = document.getElementById("select_project");

        for (var i = 0; i < lista_projetos.length; i++) {
            const option = document.createElement("option");
            option.value = lista_projetos[i];
            option.text = lista_projetos[i];
            select_projects.appendChild(option);
        }
    };
    req.open("GET", "/list_projects", true);
    req.send();
}

function processar() {

    document.getElementById("resultado").style.visibility = "hidden";
    document.getElementById("resultado2").style.visibility = "hidden";
    document.getElementById("loading").style.visibility = "visible";

    const path = document.getElementById("select_project");

    const req = new XMLHttpRequest();

    req.onload = (e) => {
        const resultado = document.getElementById("resultado");
        document.getElementById("resultado").style.visibility = "visible";
        document.getElementById("resultado2").style.visibility = "visible";
        document.getElementById("loading").style.visibility = "hidden";

        carregarNomeProjeto();
        sleep(5000).then(r => {
            gerardb();
            carregarStatitics();
        });

    };
    req.open("GET", "/processar?path_project=" + path.value, true);
    req.send();

}

function carregarStatitics() {
    const req = new XMLHttpRequest();
    req.onload = (e) => {

        var table = document.createElement("table");

        table.className = "table is-fullwidth";

        var linhas = req.response.split("\n");

        var linha1 = 0;

        for (var i = 0; i < linhas.length; i++) {
            var linha = linhas[i].split(";");
            var tr = document.createElement("tr");
            for (var j = 0; j < linha.length; j++) {
                if(linha1 == 0){
                    var td = document.createElement("th");
                }else{
                    var td = document.createElement("td");
                }
                td.innerHTML = linha[j];
                tr.appendChild(td);
            }
            linha1 = 1;
            table.appendChild(tr);
        }

        document.getElementById("qtdbytestsmellbytype").appendChild(table);
    };
    req.open("GET", "/getstatistics", true);
    req.send();
}

const sleep = ms => new Promise(r => setTimeout(r, ms));

function carregarBotaoDownloadDb() {
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        if (req.response == "true") {
            document.getElementById("resultado_db").style.visibility = "visible";
        } else {
            document.getElementById("resultado_db").style.visibility = "hidden";
        }

    };
    req.open("GET", "/download.db.existe", true);
    req.send();

}

window.onload = (event) => {
    document.getElementById("loading").style.visibility = "hidden";
    carregarNomeProjeto();
    carregarNomesTestSmells();
    carregarResultados();
    carregarSelectProjects();
    carregarStatitics();
    carregarBotaoDownloadDb();
};