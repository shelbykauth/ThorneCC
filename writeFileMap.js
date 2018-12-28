const fs = require('fs');
const path = require('path');

function writeMap() {
    var files = fs.readdirSync("./src/");
    var mapFiles = [];
    for (var i = 0; i < files.length; i++) {
        var fileName = files[i];
        var isDir = fs.statSync("./src/" + files[i]).isDirectory();
        if (isDir) {
            fs.readdirSync("./src/" + fileName).forEach(function(item) {
                files.push(fileName + "/" + item);
            });
        } else {
            mapFiles.push(fileName);
        }
    }
    var data = mapFiles.join("\n");
    fs.writeFileSync("src/ThorneCC_Filemap.txt", data);
}

console.log("Writing File Map");
writeMap();
console.log("File Map Written.");