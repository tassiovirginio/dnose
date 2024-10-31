

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


function websocketTest(){
     // Cria um novo WebSocket
     const socket = new WebSocket('ws://localhost:8080/websocket');

     const socket2 = new WebSocket('ws://localhost:8080/timenow');

     // Manipula o evento de abertura da conexão
     socket.onopen = function(event) {
         console.log('Conexão estabelecida!');
         socket.send('Oi, servidor!'); // Envia mensagem ao servidor
     };

     socket2.onopen = function(event) {
        console.log('Conexão estabelecida 2!');
        socket.send('Oi, servidor!'); // Envia mensagem ao servidor
    };

     // Manipula o recebimento de mensagens do servidor
     socket.onmessage = function(event) {
         const messagesDiv = document.getElementById('messages');
         messagesDiv.innerHTML += `<div>Mensagem do servidor: ${event.data}</div>`;
         messagesDiv.scrollTop = messagesDiv.scrollHeight; // Rola para baixo
     };

     socket2.onmessage = function(event) {
        const messagesDiv = document.getElementById('messages');
        messagesDiv.innerHTML += `<div>Mensagem do servidor: ${event.data}</div>`;
        messagesDiv.scrollTop = messagesDiv.scrollHeight; // Rola para baixo
    };

     // Manipula o fechamento da conexão
     socket.onclose = function(event) {
         console.log('Conexão fechada!');
     };

     socket2.onclose = function(event) {
        console.log('Conexão fechada!');
    };

     // Envia uma mensagem ao clicar no botão
     document.getElementById('sendButton').onclick = function() {
         const input = document.getElementById('messageInput');
         const message = input.value;
         if (message) {
             socket.send(message);
             socket2.send(message);
             input.value = ''; // Limpa o campo de entrada
         }
     };
}


window.onload = (event) => {
    console.log("Loading...");
    document.getElementById("loading").style.visibility = "hidden";
    loadSelectProjects();
    websocketTest();
};