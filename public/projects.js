function loadProjectList(){
    const req = new XMLHttpRequest();
    const lista_projetos2 = document.getElementById("lista_projetos2");
    lista_projetos2.innerHTML = "";
    req.onload = (e) => {
        const lista = JSON.parse(req.response);
        const html = document.createElement("table");
        html.className = "table is-fullwidth";

        for (let i = 0; i < lista.length; i++) {
            const path = lista[i];
            const tr = document.createElement("tr");
            const td = document.createElement("td");
            tr.appendChild(td);
            const td2 = document.createElement("td");
            tr.appendChild(td2);
            let button = document.createElement("button");
            button.innerHTML = "del";
            button.onclick = () => {
                var result = confirm("Want to delete?");
                if (result) {
                    del(path);
                }
            };
            button.className = "button is-danger is-small";
            td2.appendChild(button);
            html.appendChild(tr);
            td.innerHTML = path;
        }
        lista_projetos2.appendChild(html);
    };
    req.open("GET", "/list_projects", true);
    req.send();
}

function clone(){
    const url = document.getElementById("url").value;
    document.getElementById("loading").style.visibility = "visible";
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        loadProjectList();
        document.getElementById("loading").style.visibility = "hidden";
    };
    req.open("GET", "/clonar?url=" + url, true);
    req.send();
}

function del(path){
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        loadProjectList();
    };
    req.open("GET", "/delete?path=" + path, true);
    req.send();
}

window.onload = (event) => {
    console.log("Loading...");
    document.getElementById("loading").style.visibility = "hidden";
    loadProjectList();
};