function loadSelect() {
    let select = document.getElementById("testSmells");
    const req = new XMLHttpRequest();

    const option = document.createElement("option");
    option.value = "all";
    option.text = "all";
    select.appendChild(option);

    req.onload = (e) => {
        const lista = JSON.parse(req.response);
        for (let i = 0; i < lista.length; i++) {
            const option = document.createElement("option");
            option.value = lista[i];
            option.text = lista[i];
            select.appendChild(option);
        }
    };
    req.open("GET", "/testsmellsnames", true);
    req.send();//getlines100
}

function loadList() {
    let listaFiles = document.getElementById("listaFiles");
    const req = new XMLHttpRequest();
    req.onload = (e) => {
        const lista = JSON.parse(req.response);

        for (let i = 0; i < lista.length; i++) {
            let linha = lista[i].split(";");

            if (linha[1].trim() === "") continue;

            const path = linha[3];
            const testDescripcion = linha[1];
            const testSmellName = linha[4];

            const tr = document.createElement("tr");

            const td1 = document.createElement("td");
            td1.innerHTML = linha[4];
            tr.appendChild(td1);

            const td2 = document.createElement("td");
            td2.innerHTML = linha[3];
            tr.appendChild(td2);

            const button = document.createElement("button");
            button.innerHTML = "solution";
            button.className = "button is-info is-light";
            button.onclick = () => {
                const solutionDiv = document.getElementById("solution");
                solutionDiv.innerHTML = "";
                let code = document.getElementById("code");
                code.innerHTML = "";
                console.log(path + " - " + testDescripcion + " - " + testSmellName);
                loadFile(path, testDescripcion, testSmellName)
            };
            const td3 = document.createElement("td");
            td3.appendChild(button);
            tr.appendChild(td3);

            listaFiles.appendChild(tr);
        }
    };
    req.open("GET", "/getlines100", true);
    req.send();
}

function loadFile(path, testDescripcion, testSmellName) {
    console.log("path: " + path + " - " + testDescripcion);
    let code = document.getElementById("code");
    const req = new XMLHttpRequest();
    req.onload = async (e) => {
        console.log(req.response);
        var code_full = req.response;
        code.innerHTML = code_full;
        prompt = prompt.replaceAll("$testSmellName", testSmellName);
        prompt = prompt.replaceAll("$code_full", code_full);
        console.log(prompt);
        await uploadSolutions(prompt);
        await uploadSolutions2(prompt);
        await uploadSolutions3(prompt);
    };
    req.open("GET", "/getfiletext?path=" + path + "&test='" + testDescripcion + "'", true);
    req.send();
}

async function uploadSolutions(prompt) {
    console.log(prompt);
    const solutionDiv = document.getElementById("solution");
    solutionDiv.innerHTML = "Analyzing...";
    const req = new XMLHttpRequest();
    req.open("POST", "/solution", true);
    req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    prompt = prompt.replaceAll(" ", "_");
    req.onreadystatechange = () => {
        if (req.readyState === XMLHttpRequest.DONE && req.status === 200) {
            solutionDiv.innerHTML = marked.parse(req.response);
        }
    };
    req.send(prompt);
}

async function uploadSolutions2(prompt) {
    console.log(prompt);
    const solutionDiv = document.getElementById("solution2");
    solutionDiv.innerHTML = "Analyzing...";
    const req = new XMLHttpRequest();
    req.open("POST", "/solution2", true);
    req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    prompt = prompt.replaceAll(" ", "_");
    req.onreadystatechange = () => {
        if (req.readyState === XMLHttpRequest.DONE && req.status === 200) {
            solutionDiv.innerHTML = req.response;
        }
    };
    req.send(prompt);
}

async function uploadSolutions3(prompt) {
    console.log(prompt);
    const solutionDiv = document.getElementById("solution3");
    solutionDiv.innerHTML = "Analyzing...";
    const req = new XMLHttpRequest();
    req.open("POST", "/solution3", true);
    req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    prompt = prompt.replaceAll(" ", "_");
    req.onreadystatechange = () => {
        if (req.readyState === XMLHttpRequest.DONE && req.status === 200) {
            solutionDiv.innerHTML = marked.parse(req.response);
        }
    };
    req.send(prompt);
}

function loadStructureSolution() {
    document.getElementById("lkGemini").className = "is-active";
    document.getElementById("lkchatGPT").className = "";
    document.getElementById("lkOllama").className = "";
    document.getElementById("solution").style.display = 'block';
    document.getElementById("solution2").style.display = 'none';
    document.getElementById("solution3").style.display = 'none';
    document.getElementById("btCopy1").style.display = 'block';
    document.getElementById("btCopy2").style.display = 'none';
    document.getElementById("btCopy3").style.display = 'none';
}

function tabs(atual) {
    if (atual == "0") {
        document.getElementById("lkGemini").className = "is-active";
        document.getElementById("lkchatGPT").className = "";
        document.getElementById("lkOllama").className = "";
        document.getElementById("solution").style.display = 'block';
        document.getElementById("solution2").style.display = 'none';
        document.getElementById("solution3").style.display = 'none';
        document.getElementById("btCopy1").style.display = 'block';
        document.getElementById("btCopy2").style.display = 'none';
        document.getElementById("btCopy3").style.display = 'none';
    } else if (atual == "1"){
        document.getElementById("lkGemini").className = "";
        document.getElementById("lkchatGPT").className = "is-active";
        document.getElementById("lkOllama").className = "";
        document.getElementById("solution").style.display = 'none';
        document.getElementById("solution2").style.display = 'block';
        document.getElementById("solution3").style.display = 'none';
        document.getElementById("btCopy1").style.display = 'none';
        document.getElementById("btCopy2").style.display = 'block';
        document.getElementById("btCopy3").style.display = 'none';
    } else if (atual == "2"){
        document.getElementById("lkGemini").className = "";
        document.getElementById("lkchatGPT").className = "";
        document.getElementById("lkOllama").className = "is-active";
        document.getElementById("solution").style.display = 'none';
        document.getElementById("solution2").style.display = 'none';
        document.getElementById("solution3").style.display = 'block';
        document.getElementById("btCopy1").style.display = 'none';
        document.getElementById("btCopy2").style.display = 'none';
        document.getElementById("btCopy3").style.display = 'block';
    }
}

copy1 = () =>
    navigator.clipboard.writeText(document.getElementById("solution").innerHTML)
        .then(r => console.log("copied"));

copy2 = () => navigator.clipboard.writeText(document.getElementById("solution2").innerHTML)
    .then(r => console.log("copied"));

copy3 = () => navigator.clipboard.writeText(document.getElementById("solution3").innerHTML)
    .then(r => console.log("copied"));

var prompt = "";

function loadPrompt(){
    var promptLocal = window.localStorage.getItem("prompt");

    if(promptLocal == null){
        prompt = "The code below has a Test Smell ( $testSmellName ) I would like you to give me solutions for resolving the test smells. Code: $code_full";
        window.localStorage.setItem("prompt", prompt);
    }else{
        prompt = promptLocal;
    }
}

window.onload = (event) => {
    console.log("loading...");
    document.getElementById("loading").style.visibility = "hidden";
    loadPrompt();
    hljs.highlightAll();
    loadSelect();
    loadList();
    loadStructureSolution();
};


