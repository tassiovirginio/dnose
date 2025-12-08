function loadProjectList(){
    const req = new XMLHttpRequest();
    const lista_projetos2 = document.getElementById("lista_projetos2");
    lista_projetos2.innerHTML = "";
    req.onload = (e) => {
        const lista = JSON.parse(req.response);
        
        // Criar tabela estilizada
        const table = document.createElement("table");
        table.className = "w-full border-collapse text-sm text-left text-slate-700";

        // Cabeçalho (opcional)
        const thead = document.createElement("thead");
        thead.innerHTML = `
            <tr class="bg-slate-100">
                <th class="px-4 py-2 text-left">Project Path</th>
                <th class="px-4 py-2 text-left">Actions</th>
            </tr>
        `;
        table.appendChild(thead);

        const tbody = document.createElement("tbody");

        for (let i = 0; i < lista.length; i++) {
            const path = lista[i];
            const tr = document.createElement("tr");
            tr.className = "border-b border-slate-200 hover:bg-slate-50 transition-colors";

            // Coluna do path
            const tdPath = document.createElement("td");
            tdPath.className = "px-4 py-2";
            tdPath.textContent = path;
            tr.appendChild(tdPath);

            // Coluna do botão
            const tdButton = document.createElement("td");
            tdButton.className = "px-4 py-2 flex justify-start"; // botão à esquerda

            const button = document.createElement("button");
            button.innerHTML = `<i class="fa-solid fa-trash mr-1"></i> Delete`;
            button.onclick = () => {
                if (confirm("Want to delete?")) {
                    del(path);
                }
            };
            button.className = `
                inline-flex items-center px-3 py-1.5
                bg-red-600 text-white text-xs font-medium
                rounded-md shadow-sm
                hover:bg-red-700
                transition-all duration-200
            `;
            tdButton.appendChild(button);

            tr.appendChild(tdButton);
            tbody.appendChild(tr);
        }

        table.appendChild(tbody);
        lista_projetos2.appendChild(table);
    };
    req.open("GET", "/list_projects", true);
    req.send();
}

function clone(){
    const url = document.getElementById("url").value;

    if(url == null || url == ""){
        alert("URL is empty");
        return;
    }

    showLoading();

    const req = new XMLHttpRequest();
    req.onload = (e) => {
        loadProjectList();
        hideLoading();
    };
    req.open("GET", "/clonar?url=" + url, true);
    req.send();
}

function clone_lote(){
    var urls = document.getElementById("urls").value;

    console.log(urls);

    if(urls == null || urls == ""){
        alert("URLS is empty");
        return;
    }

    urls = urls.replace(/\n/g, '|');

    console.log(urls);

    showLoading();
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        loadProjectList();
        hideLoading();
    };
    req.open("GET", "/clonar_lote?urls=" + urls, true);
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

function selectTab(tab) {
    const singleTab = document.getElementById('single-tab');
    const batchTab = document.getElementById('batch-tab');
    const btnSingle = document.getElementById('btn-single');
    const btnBatch = document.getElementById('btn-batch');

    if (tab === 'single') {
        singleTab.classList.remove('hidden');
        batchTab.classList.add('hidden');

        btnSingle.classList.add('bg-primary-50', 'text-primary-600', 'border-b-2', 'border-primary-500');
        btnSingle.classList.remove('bg-white', 'text-slate-500', 'border-transparent');

        btnBatch.classList.remove('bg-primary-50', 'text-primary-600', 'border-b-2', 'border-primary-500');
        btnBatch.classList.add('bg-white', 'text-slate-500', 'border-transparent');
    } else {
        singleTab.classList.add('hidden');
        batchTab.classList.remove('hidden');

        btnBatch.classList.add('bg-primary-50', 'text-primary-600', 'border-b-2', 'border-primary-500');
        btnBatch.classList.remove('bg-white', 'text-slate-500', 'border-transparent');

        btnSingle.classList.remove('bg-primary-50', 'text-primary-600', 'border-b-2', 'border-primary-500');
        btnSingle.classList.add('bg-white', 'text-slate-500', 'border-transparent');
    }
}


function showLoading() {
    document.getElementById("loading").style.visibility = "visible";

}

function hideLoading() {
    document.getElementById("loading").style.visibility = "hidden";

}