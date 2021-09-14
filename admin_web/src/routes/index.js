const { Router } = require('express');
const router = Router();
const admin = require('firebase-admin');
const bodyParser = require("body-parser");
var serviceAccount = require("../serviceAccountKey.json");
const app = require('../app');
var parseForm = bodyParser.urlencoded({ extended: false });
const filesystem = require('fs');
const AWS = require('aws-sdk');
const path = require('path');
const e = require('express');
var floor = 0;
var coordmaping = {};
var alertwarner = 0;
var usuariosRecibidos = [];

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

const ID = '';
const SECRET = '';

const s3 = new AWS.S3({
    accessKeyId: ID,
    secretAccessKey: SECRET
});

const fs = admin.firestore();

router.get('/login', (req, res) => {
    res.render('login');
});

router.get('/admin', (req, res) => {
    const sessionCookie = req.cookies.session || "";

    admin
        .auth()
        .verifySessionCookie(sessionCookie, true /** checkRevoked */)
        .then(() => {
            res.render('admin', { csrfToken: req.csrfToken(), contadorPiso: floor , alerta: alertwarner});
            alertwarner = 0;
        })
        .catch((error) => {
            res.redirect("/login");
        });

});

router.post('/mandar-jsonDijkstra', parseForm, function (req, res) {
    console.time('Loop de Enviado Dijkstra');
    var JSONDijkstraFinal = JSON.parse(req.body.JSONContainer);
    console.log("Este es el JSON dentro de la ruta /mandar-jsonDijkstra" + JSONDijkstraFinal);
    send_to_AWS_Topology(JSONDijkstraFinal);
    res.redirect("/admin");
});

router.post('/mandar-jsonUsers', parseForm, function (req, res) {
    console.time("Loop de Enviado Usuarios");
    var JSONUsersFinal = JSON.parse(req.body.UsersContainer);
    console.log("Este es el tipo del JSON dentro de la ruta /mandar-jsonUsers " + typeof (req.body.UsersContainer));
    console.log("Este es el tipo de variable JSONUsersFinal: ", typeof (JSONUsersFinal));

    buildCoordMaping(fs).then((diccionario) => {
        coordmaping = diccionario;
    });

    for (var attributename in JSONUsersFinal){
        usuariosRecibidos.push(JSONUsersFinal[attributename].Usuario); //Para recuperar los usuarios con @dominio
        console.log("ESTE ES usuariosRecibidos", usuariosRecibidos);
    }
   

    for (var attributename in JSONUsersFinal) {
        JSONUsersFinal[attributename].Usuario = JSONUsersFinal[attributename].Usuario.split("@")[0];
        //console.log("OUTPUT", JSONUsersFinal[attributename].Usuario);
        send_to_AWS(JSONUsersFinal[attributename]);
        console.log("Upload finished");
        
        const timeout = setTimeout(receive_from_AWS, 6000, JSONUsersFinal[attributename].Usuario);
    }
    console.timeEnd("Loop de Enviado Usuarios");

    res.redirect("/admin");
});

router.post("/sessionLogin", (req, res) => {
    const idToken = req.body.idToken.toString();

    const expiresIn = 60 * 60 * 24 * 5 * 1000;

    admin
        .auth()
        .createSessionCookie(idToken, { expiresIn })
        .then(
            (sessionCookie) => {
                const options = { maxAge: expiresIn, httpOnly: true };
                res.cookie("session", sessionCookie, options);
                res.end(JSON.stringify({ status: "success" }));
            },
            (error) => {
                res.status(401).send("UNAUTHORIZED REQUEST!");
            }
        );
});

router.get("/sessionLogout", (req, res) => {
    res.clearCookie("session");
    res.redirect("/login");
});

router.post('/new-beacon', parseForm, function (req, res) {
    const sessionCookie = req.cookies.session || "";

    admin
        .auth()
        .verifySessionCookie(sessionCookie, true /** checkRevoked */)
        .then(() => {

            var nameb = req.body.nNombre;
            var idb = req.body.nID;
            var coordb = req.body.nCoordenadas;
            var neighborsb = req.body.nVecinos;
            var typeb = req.body.nTipo;
            var equivb = req.body.nEquivalente;
            var latitudb = req.body.nLatitud;
            var longitudb = req.body.nLongitud
            floor = req.body.piso;

            console.log("El valor de floor es: ", floor);

            verificarNombre(fs, nameb).then((usuarios) => {
                var separacionVecinos = neighborsb.split("/");
                constructorVecinos(fs, separacionVecinos).then((arr) => {
                    vecinosTemp = arr.toString();
                    vecinosTemp = vecinosTemp.replace(/#/g, "'");
                    vecinosTemp = "[" + vecinosTemp + "]";
                    console.log("ESTE ES VECINOS TEMP: ", vecinosTemp);

                    verificarID(fs, usuarios, nameb, idb, coordb, vecinosTemp, typeb, equivb, latitudb, longitudb, floor).then((nuevadata) => {
                        setDocument(fs, nuevadata, nameb).then(() => {
                            console.log("A punto de renderear de nuevo al admin");
                            alertwarner = 3;
                            res.redirect('/admin');
                        });
                    }).catch(function () {
                        console.log('Something failed in ID verification');
                        alertwarner = 2;
                        res.redirect('/admin');
                    });

                })/*.catch(() => {})*/;
            }).catch(function () {
                console.log('Something failed in Name verification');
                alertwarner = 1;
                res.redirect('/admin');
            });
        });
})

router.get('/refresh-beacon-state/:user', (req, res) => {
    var userRecibido = req.params.user;
    console.log("El usuario recibido fue:", userRecibido);
    updateActiveField1(fs, userRecibido).then(() => {
        res.redirect('/admin');
    })/*.catch(() => {
        console.log("Ha habido un problema al actualizar el estado Activo del documento");
        res.redirect('/admin');
    })*/;
});

router.get('/delete-user/:user', (req, res) => {
    var userRecibido = req.params.user;
    console.log("El usuario recibido fue: ", userRecibido);
    
    deleteDocument(fs, userRecibido).then(() => {
        res.redirect('/admin');
    }).catch(() => {
        console.log("Ha habido un problema al borrar el documento");
        res.redirect('/admin');
    });
})

//#################################FUNCIONES DE FIRESTORE#################################//
async function verificarID(fs, usuarios, name, id, coord, neigh, type, equiv, latitud, longitud, floor) {
    var flag = 1;
    const snapshot = await fs.collection('Beacons Virtuales').get();
    snapshot.forEach((doc) => {
        if (doc.data()['ID'] == id) {
            flag = -1;
        }
    });

    if (flag == 1) {
        const newData = {
            Nombre: name,
            ID: id,
            Coordenadas: coord,
            Usuarios: usuarios,
            Vecinos: neigh,
            Activado: true,
            Tipo: type,
            Equivalente: equiv,
            Latitud: latitud,
            Longitud: longitud,
            Piso: floor
        };
        return newData;
    } else {
        PromiseRejectionEvent();
    }
}

async function constructorVecinos(fs, arr){
    const snapshot = await fs.collection('Beacons Virtuales').get();
    var finalArr = [];

    arr.forEach((element) => {
        snapshot.forEach((doc) => {
            if(element == doc.data().Nombre){
                finalArr.push("(" + "#" + element + "#" + ", " + doc.data().ID.toString() + ", " + doc.data().Usuarios.toString() + ")");
            }
        });
    });
    
    return finalArr;
}

async function verificarNombre(fs, name) {
    var resultado = -1;
    const snapshot = await fs.collection('Conteo de Alumnos por Salón').get();

    snapshot.forEach((doc) => {
        var nombreActual = doc.data()['Edificio'] + " " + doc.data()['Salón'];
        var usuariosActual = doc.data()['Total'];
        if (nombreActual == name) {
            resultado = usuariosActual;
        }
    });

    if (resultado != -1) { //Éxito: El beacon virtual declarado por el usuario sí existe en la topología física
        return resultado;
    } else {
        PromiseRejectionEvent();
    }

}

async function setDocument(fs, newData, name) {
    const newpush = await fs.collection('Beacons Virtuales').doc(name.toString()).set(newData);
    console.log('Set: ', newpush);
    return 1;
}

async function updateActiveField1(fs, user){
    const newpull = await fs.collection('Beacons Virtuales').doc(user).get();
    const newupdate = await fs.collection('Beacons Virtuales').doc(user);
    var tempbool = Boolean;
    console.log("New pull", newpull.data().Activado);

    if (newpull.data().Activado === true){
        tempbool = false;
        updateActiveField2(fs, tempbool, newupdate);
    }else{
        tempbool = true;
        updateActiveField2(fs, tempbool, newupdate);
    }
}

async function updateActiveField2(fs, booli, update){
    const res = await update.update({Activado: booli});
    console.log('Update: ', res);
}

async function buildCoordMaping(fs) {
    var dictTemp = {};
    const snapshot = await fs.collection('Beacons Virtuales').get();
    
    snapshot.forEach((doc) => {
        var nombreActual = doc.data()['Nombre'];
        var latitudActual = doc.data()['Latitud'];
        var longitudActual = doc.data()['Longitud'];
        dictTemp[nombreActual] = {
            latitud: latitudActual,
            longitud: longitudActual
        };
    });

    return dictTemp;
}

async function deleteDocument(fs, name) {
    const res = await fs.collection('Beacons Virtuales').doc(name).delete();
    console.log('Delete: ', res);
}

//#################################FUNCIONES DE AWS#################################//
function send_to_AWS(user_data) {

    const BUCKET_NAME = 'sismo-bucket-input';

    const uploadFile = (user_data, key) => {
        const params = {
            Bucket: BUCKET_NAME,
            Key: key,
            Body: user_data
        };

        // Uploading files to the bucket
        s3.upload(params, function (err, data) {
            if (err) {
                console.log(err);
                throw err;
            }
            console.log(`File uploaded successfully!`, data);
        });
    };

    data_path = path.join(__dirname, '..', 'users_files/user_' + user_data.Usuario + '.json')
    const user_data_json = JSON.stringify(user_data);
    try {
        filesystem.writeFileSync(data_path, user_data_json)
    } catch (err) {
        console.log(err);
    }

    try {
        var data_s3 = filesystem.readFileSync(data_path, 'utf8')
        console.log('DATA S3', data_s3);
    } catch (err) {
        console.error(err)
    }
    uploadFile(data_s3, user_data.Usuario + '.json');
    return data_s3
}

function receive_from_AWS(usuario) {
    console.log("ESTE ES EL USUARIO ", usuario);
    const BUCKET_NAME = 'sismo-bucket-output';
    const params = {
        Bucket: BUCKET_NAME,
        Key: usuario + '_data.json'
    }
    s3.getObject(params, function (err, data) {
        if (err) {
            console.log(err);
        } else {
            var user_data = data.Body.toString()
            user_data = JSON.parse(user_data)
            //console.log("Este es user data recibido: ", user_data);
            user_data = format_route(user_data);
            setRoutes(fs, user_data);
        }
    })
}

async function setRoutes(fs, user_data) {
    const rutVis = await fs.collection('Ruta de Salida').doc(user_data.Usuario).get();
    //console.log("Este es el campo Ruta Visible: ", rutVis.data()['Ruta Visible'], " de ", user_data.Usuario);
    try{
        user_data['Ruta Visible'] = rutVis.data()['Ruta Visible'];
    }catch(e){
        user_data['Ruta Visible'] = 'Activado';
    }

    await fs.collection('Ruta de Salida').doc(user_data.Usuario).delete();
    const newpush = await fs.collection('Ruta de Salida').doc(user_data.Usuario).set(user_data);
    //const newpush = await fs.collection('Ruta de Salida').doc(user_data.Usuario).update(user_data);
    console.log('Set: ', newpush);
}

function send_to_AWS_Topology(user_data) {

    const BUCKET_NAME = 'rutas-util';

    const uploadFile = (user_data, key) => {
        const params = {
            Bucket: BUCKET_NAME,
            Key: key,
            Body: user_data
        };

        // Uploading files to the bucket
        s3.upload(params, function (err, data) {
            if (err) {
                console.log(err);
                throw err;
            }
            console.log(`File uploaded successfully!`, data);
        });
    };

    data_path = path.join(__dirname, '..', 'users_files/topology.json')
    const user_data_json = JSON.stringify(user_data);
    try {
        filesystem.writeFileSync(data_path, user_data_json)
    } catch (err) {
        console.log(err);
    }

    try {
        var data_s3 = filesystem.readFileSync(data_path, 'utf8')
        console.log('DATA S3 Topology', data_s3);
    } catch (err) {
        console.error(err)
    }
    uploadFile(data_s3, 'topology.json');
    console.timeEnd('Loop de Enviado Dijkstra');
    return data_s3
}

function format_route(user_data){
    var tempDic = {};
    user_data.Ruta.forEach((element, idx) => {
        tempDic[`Instrucción ${idx}`] = element;
        tempDic[`Latitud ${idx}`] = coordmaping[element].latitud;
        tempDic[`Longitud ${idx}`] = coordmaping[element].longitud;
    })

    usuariosRecibidos.forEach((usuario) => {
        if(user_data.Usuario == usuario.split('@')[0]){
            tempDic['Usuario'] = usuario;
        }
    });

    user_data.Celdas.forEach((item, idx) => {
        if (idx == 0){
            tempDic['Celdas'] = "(" + item.toString() + ")"
        }

        tempDic['Celdas'] = tempDic.Celdas + " " + "(" + item.toString() + ")"
    })
    
    console.log(" TempDict: ", tempDic);
    //Borrar Ruta, Ubicación y Usuario
    return tempDic;
}

module.exports = router;