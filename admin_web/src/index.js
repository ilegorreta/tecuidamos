const app = require('./app')

app.listen(app.get('port')); //app.get('port') es para obtener la configuración port que se configura en app.js
console.log('Server on port ', app.get('port'));