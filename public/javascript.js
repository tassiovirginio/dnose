function carregarNomeProjeto(){
    const req3 = new XMLHttpRequest();
    req3.onload = (e) => {
        console.log("=> " + req3.response);
        document.getElementById("projectname").innerHTML = req3.response;

    };
    req3.open("GET", "/projectnameatual", true);
    req3.send();
}

function carregarNomesTestSmells(){
    const req4 = new XMLHttpRequest();
    var nomes = new Array();
    var valores = new Array();
    req4.onload = (e) => {
        var linhas = req4.response.split("\n");
        for (let i = 1; i < linhas.length; i++) {
            var nome = linhas[i].split(";")[0];
            var valor = linhas[i].split(";")[1];
            if(nome != ""){
                nomes.push(nome);
                var valorLog = Math.log(valor);
                valores.push(valorLog);
                console.log(nome);
            }
        }

        carregarChart(nomes, valores);
    };
    req4.open("GET", "/charts_data", true);
    req4.send();
    console.log(nomes);
    return nomes;
}

function carregarChart(nomes, valores){
    const ctx = document.getElementById('myChart');

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: nomes,
            datasets: [{
                label: '# of Test Smells (log)',
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

window.onload = (event) => {
    const processando = document.getElementById("processando");
    processando.innerHTML = "Processando: FALSE";

    carregarNomeProjeto();

    var nomes = carregarNomesTestSmells();

    carregarResultados();

    document.getElementById("loading").style.visibility = "hidden";

    carregarSelectProjects();

};

function carregarResultados(){
    const req2 = new XMLHttpRequest();
    req2.onload = (e) => {
        console.log("=> " + req2.response);
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

function carregarSelectProjects(){
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        console.log("=> " + req.response);

        var lista_projetos = JSON.parse(req.response);
        console.log(lista_projetos);

        var select_projects = document.getElementById("select_project");

        for (var i = 0; i < lista_projetos.length; i++) {
            var option = document.createElement("option");
            option.value = lista_projetos[i];
            option.text = lista_projetos[i];
            select_projects.appendChild(option);
        }
    };
    req.open("GET", "/projects", true);
    req.send();
}

function processar() {

    document.getElementById("resultado").style.visibility = "hidden";
    document.getElementById("resultado2").style.visibility = "hidden";
    document.getElementById("loading").style.visibility = "visible";

    const processando = document.getElementById("processando");
    processando.innerHTML = "Processando: TRUE";
    document.getElementById("processando").className = "tag is-danger";

    const path = document.getElementById("select_project");

    console.log(path.value);
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        processando.innerHTML = "Processando: FALSE";
        const resultado = document.getElementById("resultado");
        document.getElementById("resultado").style.visibility = "visible";
        document.getElementById("resultado2").style.visibility = "visible";
        document.getElementById("loading").style.visibility = "hidden";
        document.getElementById("processando").className = "tag is-primary is-light";

        carregarNomeProjeto();

        console.log("=> " + req.response);
    };
    req.open("GET", "/processar?path_project=" + path.value, true);
    req.send();

}