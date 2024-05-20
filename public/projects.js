window.onload = (event) => {
    console.log("Carregando...");
    document.getElementById("loading").style.visibility = "hidden";
    carregarListaProjetos();
};

function carregarListaProjetos(){

    const req = new XMLHttpRequest();

    const lista_projetos2 = document.getElementById("lista_projetos2");
    lista_projetos2.innerHTML = "";

    req.onload = (e) => {
        const lista = JSON.parse(req.response);
        const html = document.createElement("table");
        html.className = "table is-fullwidth";

        for (let i = 0; i < lista.length; i++) {
            const tr = document.createElement("tr");
            const td = document.createElement("td");
            tr.appendChild(td);
            const td2 = document.createElement("td");
            tr.appendChild(td2);
            var button = document.createElement("button");
            button.innerHTML = "deletar";
            button.onclick = () => console.log("deletar" + lista[i]);
            button.className = "button is-danger is-small";
            td2.appendChild(button);
            html.appendChild(tr);
            td.innerHTML = lista[i];
        }

        lista_projetos2.appendChild(html);
    };
    req.open("GET", "/list_projects", true);
    req.send();
}

function clonar(){
    const url = document.getElementById("url").value;

    document.getElementById("loading").style.visibility = "visible";
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        carregarListaProjetos();
        document.getElementById("loading").style.visibility = "hidden";
    };
    req.open("GET", "/clonar?url=" + url, true);
    req.send();
}