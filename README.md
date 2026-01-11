# DNose
## Dart Test Smells Detector

- https://dnose-ts.github.io/

## Demo

- https://dnose.onrender.com/


## Download Executables (Linux and Windows*) - *Alfa

- [Last Realease](https://github.com/tassiovirginio/dnose/releases/latest)


### List of Detected Test Smells

- [x] **Assertion Roulette**
- [x] **Conditional Test Logic**
- [x] **Dependent Test**
- [x] **Default Test**
- [x] **Duplicate Assert**
- [x] **Eager Test**
- [x] **Empty Test**
- [x] **Exception Handling**
- [x] **Expected Resolution Omission**
- [x] **Ignored Test**
- [x] **Lazy Test**
- [x] **Magic Number**
- [x] **Mystery Guest**
- [x] **Print Statement**
- [x] **Redundant Assertion**
- [x] **Resource Optimism**
- [x] **Residual State**
- [x] **Sensitive Equality**
- [x] **Sleepy Test**
- [x] **Test Without Description**
- [x] **Unknown Test**
- [x] **Verbose Test**
- [x] **Widget Setup**


### Prerequisites

- Ubuntu -> sudo apt-get -y install sqlite3 libsqlite3-dev git dart
- Arch -> pacman -S git sqlite3 libsqlite3 dart
- Windows -> dart sdk, git, SQLite 3 - All bin in your PATH
- Install Mise -> https://mise.jdx.dev/


### Run with MISE
- edit the "mise.toml"
  - API_KEY_GEMINI="YOUR_API_KEY_GEMINI"
  - API_KEY_CHATGPT="YOUR_API_KEY_OPENAI"
  - OLLAMA_MODEL="deepcoder:1.5b"

- mise run
  - analyze       
  - build  - 1º run for generate html/dart       
  - compile       
  - format        
  - run - 2º start the DNose           
  - run_compiled  
  - test

### For running the LLMs
- create file .env
- input in the file this codes:
```
API_KEY_GEMINI="YOUR_API_KEY_GEMINI"
API_KEY_CHATGPT="YOUR_API_KEY_OPENAI"
OLLAMA_MODEL="deepcoder:1.5b"
```

### Running in Docker

- docker build -t dnose .
- docker run -it --rm -p 8080:8080 --name dnose dnose

## Running Locally (Linux and Windows)
- dart run bin/dnose.dart


## Compile and Execute - Linux (running in Linux)
- dart run build_runner clean && dart run build_runner build --delete-conflicting-outputs
- dart compile exe bin/dnose.dart -o dnose.run
- ./dnose.run


## Compile and Execute - Windows (running in Windows)
- dart run build_runner clean && dart run build_runner build --delete-conflicting-outputs
or
- dart run build_runner clean && dart run build_runner watch
- dart compile exe bin/dnose.dart --target-os=windows --target-arch=x64 -o dnose_win.exe
  - or dart compile exe bin/dnose.dart --target-os=windows -o dnose_win.exe
- dnose_win.exe
