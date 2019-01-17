
let numArgs = process.argv.length;
let className = process.argv[2];
let line = 0;
let argument = Array();
let text = 'class ' + className + '{\n\t'
let argNum = 3;
for(let i = 3; i < numArgs -1; i++){
    argument.push(Array())
    argument[line].push(process.argv[argNum])
    i++;
    argNum++;
    argument[line].push(process.argv[argNum])
    argNum++;
    i++;
    argument[line].push(process.argv[argNum])
    argNum++;
    line++
}
for(let i = 0; i < argument.length; i++){
    for(let j = 0; j < argument[i].length; j++){
        if(j === 1)
            text += argument[i][j] + ': '
            else if(j === 0)
                text += argument[i][j] + ' '
                else
                    text += argument[i][j]
                    }
    text += '\n\t'
}
text += '\n\tinit('
for(let i = 0; i < argument.length; i++){
    for(let j = 1; j < argument[i].length; j++){
        if(j === 1)
            text += argument[i][j] + ': '
            else
                text += argument[i][j]
                }
    if(i < argument.length-1)
        text += ', '
        }
text += ') {\n\t\t'
for(let i = 0; i < argument.length; i++){
    for(let j = 1; j < argument[i].length-1; j++){
        if(i < argument.length -1)
            text += 'self.' + argument[i][j] + ' = ' + argument[i][j]+ '\n\t\t'
            else
                text += 'self.' + argument[i][j] + ' = ' + argument[i][j]+ '\n'
                }
}
text += '\t}\n}'

console.log(text)
//init.js
//Displaying init.js.
