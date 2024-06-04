


window.onload = (event) => {
    console.log("loading...");

    var taPrompt = document.getElementById("taPrompt");
    var prompt = window.localStorage.getItem("prompt");

    if(prompt == null){
        console.log("Vazio");
        var prompt = "The code below has a Test Smell ( $testSmellName ) I would like you to give me solutions for resolving the test smells. Code: $code_full";
        window.localStorage.setItem("prompt", prompt);
        taPrompt.value = prompt;
    }else{
        console.log("tem algo");
        console.log(prompt);
        taPrompt.value = prompt;
    }

};

function save(){
    var taPrompt = document.getElementById("taPrompt");
    var valorPromtp = taPrompt.value;
    window.localStorage.setItem("prompt", valorPromtp);
}

