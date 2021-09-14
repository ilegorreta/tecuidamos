const express = require('express');
const cookieParser = require("cookie-parser");
const csrf = require("csurf");
const bodyParser = require("body-parser");
const morgan = require('morgan'); //Middleware (En medio de las peticiones del servidor)
const exphbs = require('express-handlebars');
const path = require('path');
const favicon = require('serve-favicon');


const csrfMiddleware = csrf({ cookie: true });


const app = express(); //Ejecutar módulo express y guardarlo en app


//Settings
app.set('port', process.env.PORT || 3000); //Si en mi SO existe un puerto para esta apliación, tómalo
app.set('views', path.join(__dirname, 'views')); //__dirname te dice en automático la ruta de la carpeta que contiene el archivo que actualmente se está ejecutando (app.js)
//Motor de plantillas (express handlebars)
app.engine('.hbs', exphbs({
    defaultLayout: 'main', //va a haber un archivo con código en común (reutilizar estructura de código HTML)
    extname: '.hbs' //Dar extensión a los archivos
}));
app.set('view engine', '.hbs');

//Middlewares
app.use(morgan('dev')); //Modo de desarrollo
app.use(express.urlencoded({extended: false})); //urlencoded es para habilitar la recepción de formularios (extended:false, solo recibir datos en formato json)
app.use(express.static("static"));
app.use(bodyParser.json());
app.use(cookieParser());
app.use(csrfMiddleware);

app.all("*", (req, res, next) => {
    res.cookie("XSRF-TOKEN", req.csrfToken());
    next();
  });

//Routes
app.use(require('./routes/index'));

//Static Files
app.use(express.static(path.join(__dirname, 'public')));
app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));

module.exports = app;

