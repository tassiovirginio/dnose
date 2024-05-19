function carregarNomeProjeto(){
    const req3 = new XMLHttpRequest();
    req3.onload = (e) => {
        document.getElementById("projectname").innerHTML = req3.response;
    };
    req3.open("GET", "/projectnameatual", true);
    req3.send();
}

function carregarNomesTestSmells(){
    const req4 = new XMLHttpRequest();
    const nomes = new Array();
    const valores = new Array();
    const valores2 = new Array();
    req4.onload = (e) => {
        const linhas = req4.response.split("\n");
        for (var i = 1; i < linhas.length; i++) {
            const nome = linhas[i].split(";")[0];
            const valor = linhas[i].split(";")[1];
            if(nome !== ""){
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

function carregarChart(id, nomes, valores, msg){
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

function carregarResultados(){
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

function gerardb(){
    const req2 = new XMLHttpRequest();
    req2.onload = (e) => {
        console.log(req2.response);
    };
    req2.open("GET", "/gerardb", true);
    req2.send();
}

function carregarSelectProjects(){
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
            carregarQtdTestSmells();
        });

    };
    req.open("GET", "/processar?path_project=" + path.value, true);
    req.send();

}

function carregarQtdTestSmells() {
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        // var lista = req.response.replaceAll("[","").replaceAll("]","").split(",");
        // console.log(lista[0]);
        // var saida = "";
        // console.log(lista);

        var saida = "";
        var lista = JSON.parse(req.response);

        for (let i = 0; i < lista.length; i++) {
            var linha = lista[i].replaceAll("{testsmell:","").replaceAll("}","").split(",");
            var path = linha[0];
            var qtd = linha[1];
            saida += path + " - " + qtd + "<br>";
        }

        document.getElementById("qtdbytestsmellbytype").innerHTML = saida;
    };
    req.open("GET", "/qtdbytestsmellbytype", true);
    req.send();
}

const sleep = ms => new Promise(r => setTimeout(r, ms));


window.onload = (event) => {
    document.getElementById("loading").style.visibility = "hidden";
    carregarNomeProjeto();
    carregarNomesTestSmells();
    carregarResultados();
    carregarSelectProjects();
    // carregarQtdTestSmells();
};