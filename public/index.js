function loadProjectName() {
    const req3 = new XMLHttpRequest();
    req3.onload = (e) => {
        document.getElementById("projectname").innerHTML = req3.response;
    };
    req3.open("GET", "/projectnameatual", true);
    req3.send();
}

function loadTestSmellsNames() {
    const req4 = new XMLHttpRequest();
    const names_ = [];
    const values = [];
    const values2 = [];
    req4.onload = (e) => {
        const lines = req4.response.split("\n");
        for (let i = 1; i < lines.length; i++) {
            const nome = lines[i].split(";")[0];
            const value = lines[i].split(";")[1];
            if (nome !== "") {
                names_.push(nome);
                const valueLog = Math.log(value);
                values.push(value);
                values2.push(valueLog);
            }
        }
        loadChart('myChart', names_, values, '# of Test Smells');
        loadChart('myChart2', names_, values2, '# of Test Smells (log))');
    };
    req4.open("GET", "/charts_data", true);
    req4.send();
    return names_;
}

function loadChart(id, names, values, msg) {
    const ctx = document.getElementById(id);

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: names,
            datasets: [{
                label: msg,
                data: values,
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

function loadResults() {
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

function generatedb() {
    const req2 = new XMLHttpRequest();
    req2.onload = (e) => {
        console.log(req2.response);
    };
    req2.open("GET", "/gerardb", true);
    req2.send();
}

function loadSelectProjects() {
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        const lista_projetos = JSON.parse(req.response);
        const select_projects = document.getElementById("select_project");

        for (let i = 0; i < lista_projetos.length; i++) {
            const option = document.createElement("option");
            option.value = lista_projetos[i];
            option.text = lista_projetos[i];
            select_projects.appendChild(option);
        }
    };
    req.open("GET", "/list_projects", true);
    req.send();
}

function process() {
    document.getElementById("resultado").style.visibility = "hidden";
    document.getElementById("resultado2").style.visibility = "hidden";
    document.getElementById("resultado3").style.visibility = "hidden";
    document.getElementById("resultado_db").style.visibility = "hidden";
    document.getElementById("loading").style.visibility = "visible";
    const path = document.getElementById("select_project");
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        const resultado = document.getElementById("resultado");
        document.getElementById("resultado").style.visibility = "visible";
        document.getElementById("resultado2").style.visibility = "visible";
        document.getElementById("resultado3").style.visibility = "visible";
        document.getElementById("resultado_db").style.visibility = "visible";
        document.getElementById("loading").style.visibility = "hidden";
        loadProjectName();
        sleep(5000).then(r => {
            generatedb();
            loadStatistics();
        });
    };


    var lista = getSelectValues(path);

    var listaString = "";

    lista.forEach((p) => listaString = listaString + ";" +p);

    console.log(listaString);

    req.open("GET", "/processar?path_project=" + listaString, true);
    req.send();
}

function getSelectValues(select) {
    var result = [];
    var options = select && select.options;
    var opt;

    for (var i=0, iLen=options.length; i<iLen; i++) {
        opt = options[i];

        if (opt.selected) {
            result.push(opt.value || opt.text);
        }
    }
    return result;
}

function loadStatistics() {
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        var table = document.createElement("table");
        table.className = "table is-fullwidth";
        let linhas = req.response.split("\n");
        let linha1 = 0;

        for (let i = 0; i < linhas.length; i++) {
            let line = linhas[i].split(";");
            let tr = document.createElement("tr");
            for (let j = 0; j < line.length; j++) {
                let td;
                if (linha1 === 0) {
                    td = document.createElement("th");
                } else {
                    td = document.createElement("td");
                }
                td.innerHTML = line[j];
                if(j === 7) td.style.color = "blue";
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

function loadButtonDownloadDb() {
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

function reloadStatistic() {
    var div = document.getElementById("qtdbytestsmellbytype");
    div.innerHTML = "Loading...";
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        console.log(req.response);
        sleep(5000).then(r => {
            console.log("Carregando estatísticas");
            div.innerHTML = "";
            loadStatistics();
        });
    };
    req.open("GET", "/gerardb", true);
    req.send();
}

window.onload = (event) => {
    document.getElementById("loading").style.visibility = "hidden";
    loadProjectName();
    loadTestSmellsNames();
    loadResults();
    loadSelectProjects();
    loadStatistics();
    loadButtonDownloadDb();
};