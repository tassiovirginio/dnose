# DNose
## Dart Test Smells Detector

- https://dnose-ts.github.io/

## Demo

- https://dnose.onrender.com/

### List Test Smells Detected

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
- [x] **Unknow Test**
- [x] **Verbose Test**


### Pré-requisito

- Ubuntu -> sudo apt-get -y install sqlite3 libsqlite3-dev git dart
- Arch -> pacman -S git sqlite3 libsqlite3 dart


### Docker

- docker build -t dnose .
- docker run -it --rm -p 8080:8080 --name dnose dnose
