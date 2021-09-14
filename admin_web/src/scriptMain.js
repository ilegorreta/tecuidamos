async function getFireStore(fs, name) {
  var jsonaguardar = {};
  var snapshot = await fs.collection('Beacons Virtuales').get();
  snapshot.forEach((doc) => {
      if (name === doc.data()['Nombre']) {
          //AQuí va logica para crear la tarjeta
          var ndiv = document.createElement("div"); /* creamos nuevo div*/
          var ediv = document.getElementById("espaNode"); /* variable que nos dice donde esta el div de nodo*/
          ediv.appendChild(ndiv); /* el div creado va encerrado por el div de nodo*/
          ndiv.id = document.getElementById("idd").value;

          var nh = document.createElement("h5");
          var hname = document.createTextNode("Beacon: #" + doc.data()['ID'] + "Planta Baja");
          nh.appendChild(hname);
          ndiv.appendChild(nh);

          //Cuestionable
          var deletebuton = document.createElement("button");
          var msgbutton = document.createTextNode("DELETE");
          deletebuton.appendChild(msgbutton);
          document.body.appendChild(deletebuton);

          var namep = document.createElement("p"); /* creamos nuevo parrafo de name*/
          var namev = doc.data()['Nombre'];
          namep.innerHTML = " Nombre: " + namev;
          ndiv.appendChild(namep).style.display = "inline"; /*el parrafo nuevo con valor de n casilla esta en el div que creamos*/

          var nid = document.createElement("p"); /* creamos nuevo parrafo de id*/
          var idv = doc.data()['ID'];
          nid.innerHTML = " ID: " + idv;
          ndiv.appendChild(nid).style.display = "inline"; /*el parrafo nuevo con valor de n casilla esta en el div que creamos*/

          var ncord = document.createElement("p"); /* creamos nuevo parrafo de cordenadas*/
          var cordv = doc.data()['Coordenadas'];
          ncord.innerHTML = " Coordenada: " + cordv;
          ndiv.appendChild(ncord).style.display = "inline"; /*el parrafo nuevo con valor de n casilla esta en el div que creamos*/

          var nusu = document.createElement("p"); /* creamos nuevo parrafo de vecinos*/
          var vusu = doc.data()['Usuarios'];
          nusu.innerHTML = " Vecinos: " + vusu;
          ndiv.appendChild(nusu).style.display = "inline"; /*el parrafo nuevo con valor de n casilla esta en el div que creamos*/

          var nvec = document.createElement("p"); /* creamos nuevo parrafo de vecinos*/
          var vecv = doc.data()['Vecinos'];
          nvec.innerHTML = " Vecinos: " + vecv;
          ndiv.appendChild(nvec).style.display = "inline"; /*el parrafo nuevo con valor de n casilla esta en el div que creamos*/

          var nact = document.createElement("p"); /* creamos nuevo parrafo de tipo*/
          var actv = doc.data()['Activado'];
          nact.innerHTML = " Activado: " + actv;
          ndiv.appendChild(nact).style.display = "inline"; /*el parrafo nuevo con valor de n casilla esta en el div que creamos*/

          var ntip = document.createElement("p"); /* creamos nuevo parrafo de tipo*/
          var tipov = doc.data()['Tipo'];
          ntip.innerHTML = " Tipo: " + tipov;
          ndiv.appendChild(ntip).style.display = "inline"; /*el parrafo nuevo con valor de n casilla esta en el div que creamos*/

          var nequ = document.createElement("p"); /* creamos nuevo parrafo de equivalente*/
          var equiv = doc.data()['Equivalente'];
          nequ.innerHTML = " Equivalente: " + equiv;
          ndiv.appendChild(nequ).style.display = "inline"; /*el parrafo nuevo con valor de n casilla esta en el div que creamos*/

          ndiv.appendChild(deletebuton);

          deletebuton.id = "buttonDeletePB" + i0;
          deletebuton.setAttribute('onclick', 'deletefun(this.id)');
      }
  });
}
var nombre = document.getElementById("nombree").value;
getFireStore(firestore, nombre);