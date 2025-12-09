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
        loadChart2('myChart2', names_, values2, '# of Test Smells (log))');
    };
    req4.open("GET", "/charts_data", true);
    req4.send();
}

function listAuthorStartEnd() {
    const req4 = new XMLHttpRequest();
    req4.onload = (e) => {
        const lines = req4.response.split("\n");
        const div_listAuthorStartEnd = document.getElementById('listAuthorStartEnd');

        const div_table = document.createElement('table');
        div_table.style = "width: 100%; border-collapse: collapse;";

        // Cabeçalho da tabela em inglês
        const thead = document.createElement("thead");
        const headerRow = document.createElement("tr");
        const headers = ["Project", "Author", "Start Date", "End Date", "Number of Days"];
        headers.forEach(text => {
            const th = document.createElement("th");
            th.textContent = text;
            th.style = "text-align: center; padding: 4px; border-bottom: 1px solid #ccc;";
            headerRow.appendChild(th);
        });
        thead.appendChild(headerRow);
        div_table.appendChild(thead);

        // Corpo da tabela
        const tbody = document.createElement("tbody");

        lines.forEach(linha => {
            linha = linha.split(";");
            const project = linha[0];
            const autor = linha[1];
            const data1 = linha[2];
            const data2 = linha[3];
            const dias = linha[4];
            const tr = document.createElement("tr");

            const td1 = document.createElement("td"); td1.textContent = project; td1.style = "text-align: center;";
            const td2 = document.createElement("td"); td2.textContent = autor; td2.style = "text-align: center;";
            const td3 = document.createElement("td"); td3.textContent = data1; td3.style = "text-align: center;";
            const td4 = document.createElement("td"); td4.textContent = data2; td4.style = "text-align: center;";
            const td5 = document.createElement("td"); td5.textContent = dias; td5.style = "text-align: center;";

            tr.appendChild(td1);
            tr.appendChild(td2);
            tr.appendChild(td3);
            tr.appendChild(td4);
            tr.appendChild(td5);
            tbody.appendChild(tr);
        });

        div_table.appendChild(tbody);
        div_listAuthorStartEnd.appendChild(div_table);
    };
    req4.open("GET", "/list_author_start_end", true);
    req4.send();
}



function listAuthorQtdCommit() {
    const req4 = new XMLHttpRequest();
    req4.onload = (e) => {
        const lines = req4.response.split("\n");
        const div_listAuthorQtdCommit = document.getElementById('listAuthorQtdCommit');

        const div_table = document.createElement('table');
        div_table.style = "width: 100%; border-collapse: collapse;";

        // Cabeçalho da tabela em inglês
        const thead = document.createElement("thead");
        const headerRow = document.createElement("tr");
        const headers = ["Project", "Author", "Number of Commits"];
        headers.forEach(text => {
            const th = document.createElement("th");
            th.textContent = text;
            th.style = "text-align: center; padding: 4px; border-bottom: 1px solid #ccc;";
            headerRow.appendChild(th);
        });
        thead.appendChild(headerRow);
        div_table.appendChild(thead);

        // Corpo da tabela
        const tbody = document.createElement("tbody");

        lines.forEach(linha => {
            linha = linha.split(";");
            const project = linha[0];
            const autor = linha[1];
            const qtd = linha[2];
            const tr = document.createElement("tr");

            const td1 = document.createElement("td"); td1.textContent = project; td1.style = "text-align: center;";
            const td2 = document.createElement("td"); td2.textContent = autor; td2.style = "text-align: center;";
            const td3 = document.createElement("td"); td3.textContent = qtd; td3.style = "text-align: center;";

            tr.appendChild(td1);
            tr.appendChild(td2);
            tr.appendChild(td3);
            tbody.appendChild(tr);
        });

        div_table.appendChild(tbody);
        div_listAuthorQtdCommit.appendChild(div_table);
    };
    req4.open("GET", "/list_author_qtd_commit", true);
    req4.send();
}


function loadTestSmellsNamesAuthors() {
    const req5_ = new XMLHttpRequest();
    const names__ = [];
    const values__ = [];
    req5_.onload = (e) => {
        const lines = req5_.response.split("\n");
        for (let i = 0; i < lines.length; i++) {
            const nome1 = lines[i].split(";")[0];
            const value1 = lines[i].split(";")[1];
            if (nome1 !== "") {
                names__.push(nome1);
                values__.push(value1);
            }
        }
        loadChart3('myChart3', names__, values__, '# of Test Smells');
    };
    req5_.open("GET", "/charts_data_author", false);
    req5_.send();
}

function chartTestSmellsSentiments() {
    const req5_ = new XMLHttpRequest();
    const names__ = [];
    const values__ = [];
    req5_.onload = (e) => {
        const lines = req5_.response.split("\n");
        for (let i = 0; i < lines.length; i++) {
            const nome1 = lines[i].split(";")[0];
            const value1 = lines[i].split(";")[1];
            if (nome1 !== "") {
                names__.push(nome1);
                values__.push(value1);
            }
        }
        loadChart5('myChart5', names__, values__, '# of Test Smells x Sentiments (Sum score)');
    };
    req5_.open("GET", "/charts_data_testsmells_sentiments", false);
    req5_.send();
}

function loadTestSmellsNamesAuthorsSentiments() {
    const req5_ = new XMLHttpRequest();
    const names__ = [];
    const values__ = [];
    req5_.onload = (e) => {
        const lines = req5_.response.split("\n");
        for (let i = 0; i < lines.length; i++) {
            const nome1 = lines[i].split(";")[0];
            const value1 = lines[i].split(";")[1];
            if (nome1 !== "") {
                names__.push(nome1);
                values__.push(value1);
            }
        }
        loadChart4('myChart4', names__, values__, '# of Test Smells');
    };
    req5_.open("GET", "/charts_data_author_sentiment", false);
    req5_.send();
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

var myChart;

function loadChart(id, names, values, msg) {
    const ctx = document.getElementById(id);

    // Gerar cores automaticamente ou defina cores manualmente
    const colors = values.map((_, index) => `hsl(${(index * 360 / values.length)}, 70%, 50%)`);

    if (myChart) {
        myChart.destroy();
    }

    myChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: names,
            datasets: [{
                label: msg,
                data: values,
                borderWidth: 1,
                // backgroundColor: colors, // Define cores diferentes para cada coluna
                // borderColor: colors // Opcional: usar mesma cor para a borda
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

var myChart2;

function loadChart2(id, names, values, msg) {
    const ctx = document.getElementById(id);

    // Gerar cores automaticamente ou defina cores manualmente
    const colors = values.map((_, index) => `hsl(${(index * 360 / values.length)}, 70%, 50%)`);

    if (myChart2) {
        myChart2.destroy();
    }

    myChart2 = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: names,
            datasets: [{
                label: msg,
                data: values,
                borderWidth: 1,
                // backgroundColor: colors, // Define cores diferentes para cada coluna
                // borderColor: colors // Opcional: usar mesma cor para a borda
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

var myChart3;

function loadChart3(id, names, values, msg) {
    const ctx = document.getElementById(id);

    // Gerar cores automaticamente ou defina cores manualmente
    const colors = values.map((_, index) => `hsl(${(index * 360 / values.length)}, 70%, 50%)`);

    if (myChart3) {
        myChart3.destroy();
    }

    myChart3 = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: names,
            datasets: [{
                label: msg,
                data: values,
                borderWidth: 1,
                // backgroundColor: colors, // Define cores diferentes para cada coluna
                // borderColor: colors // Opcional: usar mesma cor para a borda
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

var myChart4;

function loadChart4(id, names, values, msg) {
    const ctx = document.getElementById(id);
    const chartHeight = ctx.height;

    // Degradê vermelho vertical
    // const gradient = ctx.getContext('2d').createLinearGradient(0, chartHeight, 0, 0);
    // gradient.addColorStop(0, 'rgba(255, 100, 100, 0.7)');
    // gradient.addColorStop(1, 'rgba(200, 0, 0, 1)');

    if (myChart4) {
        myChart4.destroy();
    }

    myChart4 = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: names,
            datasets: [{
                label: msg,
                data: values,
                borderWidth: 1,
                // backgroundColor: gradient,
                // borderColor: 'rgba(150, 0, 0, 1)'
            }]
        },
        options: {
            plugins: {
                datalabels: {
                    anchor: 'end',
                    align: 'start',
                    color: '#000',
                    font: {
                        weight: 'bold'
                    },
                    // formatter: value => Math.abs(value) // mostra sem sinal
                    // formatter: value => value // mostra sem sinal
                },
                tooltip: {
                    callbacks: {
                        label: context => `${context.label}: ${context.raw}`
                    }
                }
            },
            scales: {
                y: {
                    reverse: true,
                    title: {
                        display: true,
                        text: 'Negative score (the higher the score, the worse)'
                    },
                    ticks: {
                        // callback: value => Math.abs(value)
                        // callback: value => value
                    }
                }
            }
        },
        // plugins: [ChartDataLabels] // Ativando o plugin
    });
}

var myChart5;
function loadChart5(id, names, values, msg) {
    const ctx = document.getElementById(id);

    // const chartHeight = ctx.height;
    // const colors = ctx.getContext('2d').createLinearGradient(0, chartHeight, 0, 0);
    // colors.addColorStop(0, 'rgba(255, 100, 100, 0.7)'); // base mais clara
    // colors.addColorStop(1, 'rgba(200, 0, 0, 1)');

    if (myChart5) {
        myChart5.destroy();
    }

    myChart5 = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: names,
            datasets: [{
                label: msg,
                data: values,
                borderWidth: 1,
                // backgroundColor: colors, // Define cores diferentes para cada coluna
                // borderColor: colors // Opcional: usar mesma cor para a borda
            }]
        },
        options: {
            scales: {
                y: {
                    // beginAtZero: true
                    reverse: true,
                }
            }
        }
    });
}

async function loadResults() {
    const visible = (await fetch("/result1exists").then(res => res.text())) === "true" ? "visible" : "hidden";
    ["resultado", "resultado2", "resultado3", "resultado4"].forEach(id => document.getElementById(id).style.visibility = visible);
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

function getSelectedSmells() {
    const smells = [];
    const checkboxes = document.querySelectorAll('input[type="checkbox"]');
    checkboxes.forEach(checkbox => {
        if (checkbox.checked) {
            smells.push(checkbox.id);
        }
    });
    return smells.join(';');
}

function selectAllSmells() {
    const checkboxes = document.querySelectorAll('input[type="checkbox"]');
    checkboxes.forEach(checkbox => {
        checkbox.checked = true;
    });
}

function deselectAllSmells() {
    const checkboxes = document.querySelectorAll('input[type="checkbox"]');
    checkboxes.forEach(checkbox => {
        checkbox.checked = false;
    });
}


function process() {
    hideResultButtons();
    showLoading();

    const path = document.getElementById("select_project");

    var lista = getSelectValues(path);
    var listaString = "";
    lista.forEach((p) => listaString = listaString + ";" + p);

    const selectedSmells = getSelectedSmells();

    const req = new XMLHttpRequest();
    req.onload = async () => {
        showResultButtons();
        await loadProjectName();
        await loadStatistics();
        await loadTestSmellsNames();
        loadTestSmellsNamesAuthors();
        loadTestSmellsNamesAuthorsSentiments();
        chartTestSmellsSentiments();
        loadQtdFilesTests();
        listAuthorStartEnd();
        listAuthorQtdCommit();
        hideLoading();
    };

    req.open("GET", "/processar?path_project=" + listaString + "&smells=" + selectedSmells, true);
    req.send();
}



function process_all() {
    hideResultButtons();
    showLoading();

    const req = new XMLHttpRequest();

    req.onload = async () => {
        showResultButtons();
        

        document.getElementById("projectname").innerHTML = "ALL";

        await loadStatistics();
        await loadTestSmellsNames();
        loadTestSmellsNamesAuthors();
        loadTestSmellsNamesAuthorsSentiments();
        chartTestSmellsSentiments();
        loadQtdFilesTests();
        listAuthorStartEnd();
        listAuthorQtdCommit();
        hideLoading();
    };

    req.open("GET", "/processar_all", true);
    req.send();
}

function getSelectValues(select) {
    var result = [];
    var options = select && select.options;
    var opt;

    for (var i = 0, iLen = options.length; i < iLen; i++) {
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
        table.className = "table is-fullwidth is-striped is-hoverable";
        table.style.width = "100%";

        // CENTRALIZAR TUDO
        table.style.textAlign = "center";
        table.style.verticalAlign = "middle";

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
        
                let value = line[j];
        
                // Decide se deve formatar para 2 casas decimais ou deixar inteiro
                if (!isNaN(value) && value !== "") {
                    if ([1, 2, 3, 4, 8].includes(j)) {
                        // Mean, Std Dev, Median, Square Mean, Center → 2 casas decimais
                        value = parseFloat(value).toFixed(2);
                    } else {
                        // Max, Min, Sum, Squares Sum → inteiro absoluto
                        value = parseInt(value, 10);
                    }
                }
        
                td.innerHTML = value;
        
                if (j === 7 && i != 0) { // coluna Sum
                    td.style.color = "blue";
                    contador += parseInt(line[j], 10);
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

        const div = document.getElementById("qtdbytestsmellbytype");
        div.innerHTML = "";
        div.appendChild(table);
    };
    req.open("GET", "/getstatistics", true);
    req.send();
}

function loadQtdFilesTests() {
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        console.log(req.response);
        document.getElementById("qtd_test_files").innerHTML = req.response;
    };
    req.open("GET", "/qtd_test_files", true);
    req.send();
}

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


async function reloadStatistic() {
    const div = document.getElementById("qtdbytestsmellbytype");
    div.innerHTML = "Loading...";
    try {
        div.innerHTML = "";
        await loadStatistics();
    } catch (error) {
        console.error("Erro ao recarregar estatísticas:", error);
        div.innerHTML = "Erro ao carregar estatísticas.";
    }
}


window.onload = (event) => {
    document.getElementById("loading").style.visibility = "hidden";
    loadProjectName();
    loadResults();
    loadSelectProjects();
    loadStatistics();
    loadButtonDownloadDb();
    loadTestSmellsNames();
    loadTestSmellsNamesAuthors();
    loadTestSmellsNamesAuthorsSentiments();
    chartTestSmellsSentiments();
    loadQtdFilesTests();
    listAuthorStartEnd();
    listAuthorQtdCommit();
};


function showLoading() {
    document.getElementById("loading").style.visibility = "visible";

}

function hideLoading() {
    document.getElementById("loading").style.visibility = "hidden";

}
function hideResultButtons() {
    document.getElementById("resultado").style.visibility = "hidden";
    document.getElementById("resultado2").style.visibility = "hidden";
    document.getElementById("resultado3").style.visibility = "hidden";
    document.getElementById("resultado4").style.visibility = "hidden";
    document.getElementById("resultado_db").style.visibility = "hidden";
}
function showResultButtons() {
    document.getElementById("resultado").style.visibility = "visible";
    document.getElementById("resultado2").style.visibility = "visible";
    document.getElementById("resultado3").style.visibility = "visible";
    document.getElementById("resultado4").style.visibility = "visible";
    document.getElementById("resultado_db").style.visibility = "visible";
}
