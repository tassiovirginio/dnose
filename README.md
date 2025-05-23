# DNose
## Dart Test Smells Detector

- https://dnose-ts.github.io/

## Demo

- https://dnose.onrender.com/


### List of Detected Test Smells

- [x] **Assertion Roulette**
- [x] **Conditional Test Logic**
- [x] **Duplicate Assert**
- [x] **Empty Test**
- [x] **Exception Handling**
- [x] **Ignored Test**
- [x] **Magic Number**
- [x] **Print Statement**
- [x] **Resource Optimism**
- [x] **Sensitive Equality**
- [x] **Sleepy Test**
- [x] **Test Without Description**
- [x] **Unknown Test**
- [x] **Verbose Test**


### Pré-requisito

- Ubuntu -> sudo apt-get -y install sqlite3 libsqlite3-dev git dart
- Arch -> pacman -S git sqlite3 libsqlite3 dart


### Docker

- docker build -t dnose .
- docker run -it --rm -p 8080:8080 --name dnose dnose


## Running Locally (Linux and Windows)
- dart run bin/dnose.dart


## Compile and Execute - Linux (running in Linux)
- dart run build_runner clean && dart run build_runner build --delete-conflicting-outputs
- dart compile exe bin/dnose.dart -o dnose.exe
- ./dnose.exe


## Compile and Execute - Windows (running in Windows)
- dart run build_runner clean && dart run build_runner build --delete-conflicting-outputs
- dart compile exe bin/dnose.dart --target-os=windows --target-arch=x64 -o dnose_win.exe
  - or dart compile exe bin/dnose.dart --target-os=windows -o dnose_win.exe
- dnose_win.exe