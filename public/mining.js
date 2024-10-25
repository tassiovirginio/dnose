

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
    console.log('carregando projeto');
    const path = document.getElementById("select_project").value;

    if(path != '0'){
        console.log(path);

    }
    
}

window.onload = (event) => {
    console.log("Loading...");
    document.getElementById("loading").style.visibility = "hidden";
    loadSelectProjects();
};