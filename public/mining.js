

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

function loadProjectToMining(){
    const path = document.getElementById("select_project").value;
    if(path != '0'){
        const req2 = new XMLHttpRequest();
        req2.onload = (e) => {
            document.getElementById("branchName").innerHTML = req2.response;
        };
        req2.open("GET", "/get_branch?path_project="+path, true);
        req2.send();

        const req3 = new XMLHttpRequest();
        req3.onload = (e) => {
            document.getElementById("qtdCommits").innerHTML = req3.response;
        };
        req3.open("GET", "/get_qtd_commits?path_project="+path, true);
        req3.send();
    }
}


window.onload = (event) => {
    console.log("Loading...");
    document.getElementById("loading").style.visibility = "hidden";
    loadSelectProjects();
};