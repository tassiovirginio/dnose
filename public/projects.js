window.onload = (event) => {
    console.log("Carregando...");
    document.getElementById("loading").style.visibility = "hidden";
    carregarListaProjetos();
};

function carregarListaProjetos(){
    const lista_projetos = document.getElementById("lista_projetos");
    lista_projetos.innerHTML = "";
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        const lista = JSON.parse(req.response);


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