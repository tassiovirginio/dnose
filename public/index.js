async function loadProjectName() {
    try {
        const response = await fetch("/projectnameatual");
        if (!response.ok) {
            throw new Error(`Erro ao buscar dados: ${response.statusText}`);
        }

        const lista = await response.text(); // Supondo que a resposta seja texto.
        const projectElement = document.getElementById("projectname");
        const projectCountElement = document.getElementById("project_qts");

        projectElement.innerHTML = lista;
        projectCountElement.innerHTML = lista.split(",").filter(Boolean).length; // Filtrando itens vazios.
    } catch (error) {
        console.error("Erro ao carregar os nomes dos projetos:", error);
    }
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

function loadChart_noColor(id, names, values, msg) {
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

function loadChart(id, names, values, msg) {
    const ctx = document.getElementById(id);

    // Gerar cores automaticamente ou defina cores manualmente
    const colors = values.map((_, index) => `hsl(${(index * 360 / values.length)}, 70%, 50%)`);

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: names,
            datasets: [{
                label: msg,
                data: values,
                borderWidth: 1,
                backgroundColor: colors, // Define cores diferentes para cada coluna
                borderColor: colors // Opcional: usar mesma cor para a borda
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


async function loadResults() {
    const visible = (await fetch("/result1exists").then(res => res.text())) === "true" ? "visible" : "hidden";
    ["resultado", "resultado2", "resultado3", "resultado4"].forEach(id => document.getElementById(id).style.visibility = visible);

    if (select_project.length === 0) {
        document.getElementById("bt_process").disabled = true;
        document.getElementById("bt_process_all").disabled = true;
    }else{
        document.getElementById("bt_process").disabled = false;
        document.getElementById("bt_process_all").disabled = false;
    }

}


async function generatedb() {
    const response = await fetch("/gerardb");
    console.log(await response.text());
}


function loadSelectProjects() {
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        const lista_projetos = JSON.parse(req.response);
        const select_projects = document.getElementById("select_project");

        document.getElementById("lista_project_qtd").innerHTML = lista_projetos.length;

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
    document.getElementById("resultado4").style.visibility = "hidden";
    document.getElementById("resultado_db").style.visibility = "hidden";
    document.getElementById("loading").style.visibility = "visible";
    const path = document.getElementById("select_project");
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        const resultado = document.getElementById("resultado");
        document.getElementById("resultado").style.visibility = "visible";
        document.getElementById("resultado2").style.visibility = "visible";
        document.getElementById("resultado3").style.visibility = "visible";
        document.getElementById("resultado4").style.visibility = "visible";
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



function process_all() {
    console.log("Processar todos....");

    document.getElementById("resultado").style.visibility = "hidden";
    document.getElementById("resultado2").style.visibility = "hidden";
    document.getElementById("resultado3").style.visibility = "hidden";
    document.getElementById("resultado4").style.visibility = "hidden";
    document.getElementById("resultado_db").style.visibility = "hidden";
    document.getElementById("loading").style.visibility = "visible";

    const path = document.getElementById("select_project");

    const req = new XMLHttpRequest();

    req.onload = (e) => {
        const resultado = document.getElementById("resultado");
        document.getElementById("resultado").style.visibility = "visible";
        document.getElementById("resultado2").style.visibility = "visible";
        document.getElementById("resultado3").style.visibility = "visible";
        document.getElementById("resultado4").style.visibility = "visible";
        document.getElementById("resultado_db").style.visibility = "visible";
        document.getElementById("loading").style.visibility = "hidden";

        document.getElementById("projectname").innerHTML = "ALL";
        
        sleep(10000).then(r => {
            generatedb();
            loadStatistics();
        });
    };

    req.open("GET", "/processar_all", true);
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

    var contador = 0;

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
                if(j === 7) {
                    td.style.color = "blue";
                    if(i != 0){
                        contador = contador + parseInt(line[j], 10);
                    }
                }
                tr.appendChild(td);
            }
            linha1 = 1;
            table.appendChild(tr);
        }


        td = document.createElement("td");
        td.innerHTML = contador;
        td.style.color = "blue";

        td2 = document.createElement("td");
        td2.innerHTML = "TOTAL";

        let tr = document.createElement("tr");
        tr.appendChild(document.createElement("td"));
        tr.appendChild(document.createElement("td"));
        tr.appendChild(document.createElement("td"));
        tr.appendChild(document.createElement("td"));
        tr.appendChild(document.createElement("td"));
        tr.appendChild(document.createElement("td"));
        tr.appendChild(td2);
        tr.appendChild(td);
        tr.appendChild(document.createElement("td"));
        tr.appendChild(document.createElement("td"));
        table.appendChild(tr);

        document.getElementById("qtdbytestsmellbytype").appendChild(table);
    };
    req.open("GET", "/getstatistics", true);
    req.send();
}

const sleep = ms => new Promise(r => setTimeout(r, ms));

function loadButtonDownloadDb_() {
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

async function loadButtonDownloadDb() {
    const response = await fetch("/download.db.existe");
    document.getElementById("resultado_db").style.visibility = (await response.text()) === "true" ? "visible" : "hidden";
}


function reloadStatistic_() {
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

async function reloadStatistic() {
    const div = document.getElementById("qtdbytestsmellbytype");
    div.innerHTML = "Loading...";

    try {
        const response = await fetch("/gerardb");
        console.log(await response.text());

        await new Promise(resolve => setTimeout(resolve, 5000)); // Substitui o `sleep`
        console.log("Carregando estatísticas");

        div.innerHTML = "";
        loadStatistics();
    } catch (error) {
        console.error("Erro ao recarregar estatísticas:", error);
        div.innerHTML = "Erro ao carregar estatísticas.";
    }
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