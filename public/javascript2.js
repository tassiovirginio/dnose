window.onload = (event) => {
    console.log("Carregando...");
    document.getElementById("loading").style.visibility = "hidden";
    carregarListaProjetos();
};

function carregarListaProjetos(){
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        const lista = JSON.parse(req.response);
        const lista_projetos = document.getElementById("lista_projetos");

        for (var i = 0; i < lista.length; i++) {
            const li = document.createElement("li");
            li.innerHTML = lista[i];
            lista_projetos.appendChild(li);
        }

        console.log(lista);
    };
    req.open("GET", "/projects", true);
    req.send();
}

function clonar(){
    document.getElementById("loading").style.visibility = "visible";
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        document.getElementById("loading").style.visibility = "hidden";
    };
    req.open("GET", "/clonar", true);
    req.send();
}