import boto3
import json
import csv
from time import time
import sys
import ast

s3 = boto3.client('s3')
s3_out = boto3.resource("s3")

def lambda_handler(event, context):
    bucket_input = 'sismo-bucket-input'
    bucket_output = 'sismo-bucket-output'
    #input_s3_key = 'input_info.json'
    input_s3_key = event['Records'][0]['s3']['object']['key']
    output_s3_key = ''
    print(f"Input_s3_key: {input_s3_key}")
    
    try:
        data = s3.get_object(Bucket=bucket_input, Key=input_s3_key)
        raw_data = data['Body'].read()
        dict_data = json.loads(raw_data)
        
        output_s3_key = dict_data['Usuario'] + '_data.json'
        
        initial_pos = dict_data['Ubicacion']
        #initial_pos = tuple(map(int, initial_pos.split(',')))
        
        
        ############################ INICIO ALGORITMO DIJKSTRA############################
        
        class Nodo:
            # esta clase define los nodos de las graficas.
            # constructor
            def __init__(self, i):
                self.name = i  # nombre del nodo
                self.vecinos = []  # vecinos del nodo
                self.visitado = False  # Estado de visita
                self.padre = None  # El padre de ese nodo
                self.costo = float('inf')  # El costo que al principio es infinito
        
            def agregarVecino(self, v, c):  # v es el Id del vecino y c es el costo de la arista entre los vecinos
                if not v in self.vecinos:  # En dado caso que el vecino no este ya en la lista, se agrega.
                    self.vecinos.append([v, c])  # agregar nombre del nodo vecino y el costo
        
        
        class Grafica:
            # constructor
            def __init__(self):
                self.vertices = {}  # Declarar los vertices en un diccionario
        
            def agregarVertice(self, name):
                if not name in self.vertices:
                    self.vertices[name] = Nodo(name)  # Se agrega un Nodo a la grafica
                    print("Agregado a Dijkstra Beacon con ID {}".format(name))
        
            def agregarArista(self, a, b, c):
                if a in self.vertices and b in self.vertices:
                    self.vertices[a].agregarVecino(b, c)  # Se declara una union de nodos y su costo
                    self.vertices[b].agregarVecino(a, c)  # Se hace bidireccional para no tener problemas
                    print(
                        "La unión entre {} y {} se realizó de manera bidireccional sin errores con un costo de {}".format(a, b,
                                                                                                                          c))
                else:
                    print("Uno de los nodos ({}, {}) no ha sido declarado. Omitiendo arista.".format(a, b))
        
            def minimo(self, lista_noVisitados):
                if len(lista_noVisitados) > 0:
                    m = self.vertices[lista_noVisitados[0]].costo
                    v = lista_noVisitados[0]
                    for item in lista_noVisitados:
                        if m > self.vertices[item].costo:
                            m = self.vertices[item].costo
                            v = item
                    return v
        
            def camino(self, b):
                # Método que va guardando en la lista llamada 'camino' los nodos en el orden que sean visitados y actualizando dicha
                # lista con los vértices con el menor cost
                camino = []
                nodoActual = b
                while nodoActual != None:
                    camino.insert(0, nodoActual)
                    nodoActual = self.vertices[nodoActual].padre
                    """
                    try:
                        nodoActual = self.vertices[nodoActual].padre
                    except:
                        print("El beacon con ID:{} no está definido en la topología, por lo que no se puede elaborar la ruta al punto solicitado".format(nodoActual))
        
                        return False
                    """
                return [camino, self.vertices[b].costo]
        
            def Dijkstra(self, a):  # Desde aqui se correra el algoritmo
                if a in self.vertices:
                    self.vertices[a].costo = 0  # Le agregamos un costo de 0 al nodo inicial
                    nodoActual = a  # Definimos el nodo actual
                    noVisitados = []  # Se crea la lista de nodos no visitados para ir agarrandolos poco a poco
                    for v in self.vertices:
                        if v != a:
                            self.vertices[v].costo = float('inf')  # Resto de los nodos inica con costo infinito
                        self.vertices[v].padre = None  # Todos los nodos inician sin un padre
                        noVisitados.append(v)  # Agregamos todos los nodos a la lista de noVisitados
        
                    while len(noVisitados) > 0:
                        for vecino in self.vertices[nodoActual].vecinos:  # Recorremos a los vecinos del nodo Actual
                            if not self.vertices[vecino[0]].visitado:  # Aseguramos que no este visitado
                                if self.vertices[nodoActual].costo + vecino[1] < self.vertices[vecino[
                                    0]].costo:  # verificamos si el costo de llegar al nodo por esa via es menor al costo que ya tiene el nodo
                                    self.vertices[vecino[0]].costo = self.vertices[nodoActual].costo + vecino[
                                        1]  # si es menor, cambiamos el costo del nodo vecino
                                    self.vertices[
                                        vecino[0]].padre = nodoActual  # Asignamos como padre de ese vecino al nodo actual
                        self.vertices[nodoActual].visitado = True
                        noVisitados.remove(nodoActual)
                        nodoActual = self.minimo(noVisitados)
        
                else:
                    return False
                    
        ############################ INICIO ALGORITMO DIJKSTRA############################
        
        ############################ALGORITMO DE A ESTRELLA############################
        class Node():
            """Clase de los nodos que se utilizarán en el algoritmo"""

            def __init__(self, parent=None, position=None):
                self.parent = parent
                self.position = position

                self.g = 0
                self.h = 0
                self.f = 0

            def __eq__(self, other):
                return self.position == other.position


        def astar(maze, start, end):
            # Inicilización de nodos de inicio y de fin
            start_node = Node(None, start)
            start_node.g = start_node.h = start_node.f = 0
            end_node = Node(None, end)
            end_node.g = end_node.h = end_node.f = 0

            # Inicilización de lista abierta y lista cerrada (en donde se guardan los nodos)
            open_list = []
            closed_list = []

            # Añadir el nodo de inicio a la lista abierta
            open_list.append(start_node)

            # Repetir proceso hasta encontrar la meta
            while len(open_list) > 0:

                # Se analiza el nodo actual
                current_node = open_list[0]  # FIFO
                current_index = 0
                for index, item in enumerate(
                        open_list):  # Se discrimina entre el nodo que tenga una distancia Euclidiana más corta y se hace el siguiente nodo a analizar
                    if item.f < current_node.f:
                        current_node = item
                        current_index = index

                # Añadir el nodo actual a la lista cerrada (ya pasámos sobre él)
                open_list.pop(current_index)
                closed_list.append(current_node)

                # Se comprueba si se ha llegado a la meta
                if current_node == end_node:
                    path = []
                    current = current_node
                    while current is not None:
                        path.append(current.position)
                        current = current.parent
                    return path[::-1]  # Se regresa el camino recorrido

                # Generate los nodos hijo del nodo actual analizado
                children = []
                for new_position in [(0, -1), (0, 1), (-1, 0), (1, 0), (-1, -1), (-1, 1), (1, -1), (1, 1)]:  # Celdas adyacentes

                    # Extraer la posición del nodo
                    node_position = (current_node.position[0] + new_position[0], current_node.position[1] + new_position[1])

                    # Asegurarse que los nodos hijos estén dentro del límite establecido por el laberinto
                    if node_position[0] > (len(maze) - 1) or node_position[0] < 0 or node_position[1] > (
                            len(maze[len(maze) - 1]) - 1) or node_position[1] < 0:
                        continue

                    # Asegurarse que no se cuenten las celdas con obstáculos (walls)
                    if maze[node_position[0]][node_position[1]] == '1':
                        continue

                    # Creamos nuevo nodo
                    new_node = Node(current_node, node_position)

                    # Agregar al arreglo de nodos hijo
                    children.append(new_node)

                # Checar nodos hijo
                for child in children:

                    already_cl_flag = 0
                    already_ol_flag = 0

                    # Revisar que los hijos no se encuentren en la lista cerrada
                    for closed_child in closed_list:
                        if child == closed_child:
                            already_cl_flag = 1
                            break

                    # Caso en donde se repite un nodo hijo en la lista cerrada y se omite
                    if (already_cl_flag == 1):
                        continue

                    # Calcular los valores de f, g y h
                    child.g = current_node.g + 1
                    child.h = ((child.position[0] - end_node.position[0]) ** 2) + (
                            (child.position[1] - end_node.position[1]) ** 2)
                    child.f = child.g + child.h

                    # Revisar que los hijos no se encuentren en la lista abierta
                    for open_node in open_list:
                        if child == open_node and child.g > open_node.g:
                            already_ol_flag = 1
                            break

                    # Caso en donde se repite un nodo hijo en la lista abierta y se omite
                    if (already_ol_flag == 1):
                        continue

                    # Añadir los hijos a la lista abierta
                    open_list.append(child)

        ############################ALGORITMO DE A ESTRELLA############################
        
        
        ############################FUNCIONES NECESARIOS PARA PROGRAMA############################
        class Beacon:
            def __init__(self, name, id, coordinates, users=0, neighbors={}, active=False, type='convencional', equivalent=''):
                self.name = name
                self.id = id
                self.coordinates = coordinates
                self.users = users
                self.neighbors = neighbors
                self.active = active
                self.type = type
                self.equivalent = equivalent
        
        
        def getKey(dictionary, value):
            listItems = dictionary.items()
            for items in listItems:
                if items[1] == value:
                    return items[0]
                else:
                    pass
        
        
        def determineCheapestPathDijkstra(mapas, dictionary, caminos, pisosE):
            tempDict = {}
            pisosEmpleados = []
            for i in caminos:
                tempDict[i[1]] = i[0]  # Acomodados por peso: rutaDijkstra; tempDict = {20: ['A0', 'B0', 'C0', 'SAL0']}
        
            cheapestDijkstra = min(tempDict)
        
            tempDict2 = dict([(value, key) for key, value in dictionary.items()])  # Swap keys and values
        
            tempList = tempDict[cheapestDijkstra]
            for indx, item in enumerate(tempList):
                tempList[indx] = tempDict2[item]
        
            print("Ruta a seguir Dijkstra: ", tempList)  # tempList contiene la lista de beacons
            print("Puntos Dijkstra: ", len(tempList))
            
            #print("ESTOS SON LOS MAPAS: ", mapas)
            
            for i, piso in enumerate(mapas):
                if i == pisosE or i == 0:
                    pisosEmpleados.append(piso)
            
            return cheapestDijkstra, tempList, pisosEmpleados
        
        
        def determineAstarRoute(pisosEmpleados, mapas, beaconListRouteDijkstra, beacons, escaleras, salidas):
            inicio = None
            escalera = None
            escalera_en = None
            salida = None
            
            for i, j in enumerate(beaconListRouteDijkstra):
                if i == 0:
                    for beacon in beacons:
                        if beacon.name == j:
                            inicio = beacon.coordinates  # Guardar las coordenadas de inicio

                if j in escaleras:  # escaleras debe ser un diccionario que tenga {nombre : (coordenadas, equivalente)}
                    escalera = escaleras[j][0]  # Coordenadas de la escalera
                    escalera_en = escaleras[j][1]  # Coordenadas de la celda de unión
                elif j in salidas:  # escaleras debe ser un diccionario que tenga {nombre : coordenadas}
                    salida = salidas[j]  # Se guardan las coordenadas
                    

            if escalera != None:
                pathAstar1 = astar(mapas[pisosEmpleados[1]], tuple(inicio), tuple(escalera))
                pathAstar2 = astar(mapas[pisosEmpleados[0]], tuple(escalera_en), tuple(salida))
                return pathAstar1 + pathAstar2
            else:
                pathAstar1 = astar(mapas[pisosEmpleados[0]], tuple(inicio), tuple(salida))
                return pathAstar1
        
        def executeAlgorithm(g, beacons, escaleras, salidas, mapas, beaconName, beaconsDesactivados, dictBeaconName_ID, pisosE):
            for i in dictBeaconName_ID:
                dictBeaconName_ID[i] = dictBeaconName_ID[i][0]
        
            #print(dictBeaconName_ID)
            beaconID = dictBeaconName_ID[beaconName]
        
            caminos = []
            if beaconID in beaconsDesactivados or beaconID == None:
                print("El beacon de inicio está desactivado, por lo que no se puede proceder con el cálculo de la ruta.")
                sys.exit(1)
            else:
                g.Dijkstra(beaconID)
                for c in salidas:
                    caminos.append(g.camino(dictBeaconName_ID[c]))
        
                value = determineCheapestPathDijkstra(mapas, dictBeaconName_ID, caminos, pisosE)
                rutaAstar = determineAstarRoute(value[2], mapas, value[1], beacons, escaleras, salidas)
                print("Ruta a seguir Astar: ", rutaAstar)
                print("Puntos A*: ", len(rutaAstar))
                return value, rutaAstar
        ############################FUNCIONES NECESARIOS PARA PROGRAMA############################
        
        ############################INICIO DE ALGORITMO DE BUSQUEDA DE RUTA############################
        def main():
            # Declaración de nodos y uniones para Dijkstra
            g = Grafica()
            dictBeaconName_ID = {}
            beacons = []
            mapas = {}
            enlacesExistentes = []
            escaleras = {}
            salidas = {}
            beaconsDesactivados = {}
            pisoE = 0
        
            s3_data = boto3.resource('s3')
            data_obj = s3_data.Object('rutas-util', 'topology.json')
            json_file = data_obj.get()['Body'].read()
            data = json.loads(json_file)
            #print(f"Data 1: {data}")
            
            for i, beacon in enumerate(data.values()):
                if i == 0:
                    pisoE = int(beacon['Piso'])
                    
                beacon['ID'] = int(beacon['ID'])
                beacon['Coordenadas'] = beacon['Coordenadas'].strip('()').split(', ')
                beacon['Coordenadas'] = tuple([int(i) for i in beacon['Coordenadas']])      
                beacon['Vecinos'] = ast.literal_eval(beacon['Vecinos'])
                 
                if beacon['Equivalente'] != "":
                    beacon['Equivalente'] = beacon['Equivalente'].strip('()').split(', ')
                    beacon['Equivalente'] = tuple([int(i) for i in beacon['Equivalente']])
            
            #print(f"Data 2: {data}")
            
            #Leer el mapas.txt
            with open('mapa.txt') as json_file:
                maps = json.load(json_file)  # leemos los datos que nos interesan del archivo mapas JSON
            #Asignacion de los datos que contiene mapas.txt a la variable mapas
            for p in maps:
                for i in maps[p]:
                    mapas[p] = i['disposicion']  # En mapas[] estarán guardados los mapas de cada uno de los pisos
                    
            
            for key, val in data.items():  # Creamos la lista de beacons "beacons" y el diccionario "dictBeaconName_ID"
                #print(f"Key: {key}")
                #print(f"Val: {val}")
                new_Beacon = Beacon(key, val['ID'], val['Coordenadas'], val['Usuarios'], val['Vecinos'], val['Activado'],
                                    val['Tipo'],
                                    val['Equivalente'])  # Creamos y guardamos objectos tipo Beacon en la lista "beacons"
                beacons.append(new_Beacon)
                dictBeaconName_ID[new_Beacon.name] = [new_Beacon.id, new_Beacon.coordinates]
        
            for beacon in beacons:  #Se agregan los vértices con los que trabajará el mapa de Dijkstra siempre y cuando no estén desactivados
                if (beacon.active):
                    if beacon.type == 'escalera':
                        escaleras[beacon.name] = (beacon.coordinates, beacon.equivalent)
                    elif beacon.type == 'salida':
                        salidas[beacon.name] = beacon.coordinates
                    elif beacon.type == 'salidaPredeterminada':
                        salidas[beacon.name] = beacon.coordinates
                        salidaPredeterminada = True

                    g.agregarVertice(beacon.id)

                else:
                    beaconsDesactivados[beacon.id] = beacon.name

            for beacon in beacons:  # Se crean los enlaces con los que trabajará el mapa de Dijkstra
                for i in beacon.neighbors:
                    x_columnas = pow(abs(beacon.coordinates[1] - dictBeaconName_ID[i[0]][1][1]), 2)
                    y_filas = pow(abs(beacon.coordinates[0] - dictBeaconName_ID[i[0]][1][0]), 2)
                    suma = x_columnas + y_filas
                    distancia = pow(suma, 0.5)
                    peso = ((beacon.users + i[2]) / 2) + distancia # Se determina el peso con el promedio de usuarios que hay en los extremos de cada enlace y la distancia entre ambos beacons

                    if (str(beacon.id) + str(i[1]) in enlacesExistentes or str(i[1]) + str(beacon.id) in enlacesExistentes):
                        pass
                    else:
                        g.agregarArista(beacon.id, i[1], peso)  # Crear enlaces no repetidos (1-2 es igual que 2-1)

                    enlacesExistentes.append(str(beacon.id) + str(i[1]))
                    enlacesExistentes.append(str(i[1]) + str(beacon.id))

            if salidaPredeterminada:
                beaconName = initial_pos #Aquí es donde se tiene que poner el nombre en String del beacon en donde empieza el usuario
                pisoE = int(data[beaconName]['Piso'])
                print('Este es el piso de inicio', pisoE)

                if not beaconName in dictBeaconName_ID:
                    print(f"Beacon de partida ({beaconName}) no disponible o inexistente.")
                    sys.exit(1)
                else:
                    resultado = executeAlgorithm(g, beacons, escaleras, salidas, mapas, beaconName, beaconsDesactivados, dictBeaconName_ID, pisoE)
                    rutaFinalBeacons = resultado[0][1] #Esta es la ruta en Beacons que debe ser traducida a latitud, longitud
                    rutaFinalCeldas = resultado[1]
                    return rutaFinalBeacons, rutaFinalCeldas 

            else:
                print(
                    "Revise que todos los nodos tengan una ruta disponible a la salida designada como predeterminada y que esta última exista.")
                sys.exit(1)

        start_time = time()
        rutaFinalBeacons = main()
        elapsed_time = time() - start_time
        print("Tiempo de ejecución de la rutina: %.10f seconds." % elapsed_time)

        ############################FIN DE ALGORITMO DE BUSQUEDA DE RUTA############################

        ############################INICIO ALGORITMO DIJKSTRA############################

        dict_data['Ruta'] = rutaFinalBeacons[0]
        dict_data['Celdas'] = rutaFinalBeacons[1]

        json_data = json.dumps(dict_data)
        encoded_output = json_data.encode("utf-8")
        s3_out.Bucket(bucket_output).put_object(Key=output_s3_key, Body=encoded_output)

        return json_data

    except Exception as e:
        print(e)
        raise e
