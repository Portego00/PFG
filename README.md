<p align = "center"><img src="https://user-images.githubusercontent.com/98835194/175779869-c014ef47-b136-4534-8fcc-c959f9852769.png" width = "250"/>
<h1 align = "center"> Proyecto de Fin de Grado </h1>
En este repositorio se encuentran los códigos utilizados para este proyecto de fin de grado. A continuación, se mostrarán los requisitos necesarios para la correcta ejecución del mismo, los pasos seguidos para su correcto funcionamiento y las aplicaciones utilizadas.
<h2> Aplicaciones utilizadas </h2>
Las aplicaciones que se han utilizado para este proyecto son dos. Por un lado, tenemos Arduino, el cual se utiliza para controlar el microprocesador de la placa de Arduino Uno que se encuentra en el LantierBoard. Por otro lado, usamos processing tanto para el seguimiento del proyecto como para mostrar una aplicación final simplificada.
<p align = "center"><img src="https://user-images.githubusercontent.com/98835194/175780393-c1f8e6fa-673e-4128-9eb9-d6513ce32c86.png" height = "200"><img src="https://user-images.githubusercontent.com/98835194/175780483-2bd4efb3-c793-4ad5-a48c-fd8069cb0321.png" height = "200"/>
<h2> Requisitos </h2>
En este apartado se muestran los requisitos para la correcta ejecución de los programas. En concreto, se mostrarán las librerias utilizadas en cada uno de los códigos.
<ul> <li type="disc">En el caso de Arduino, se utilizará la librería SPI para la comunicación con el sintetizador digital directo. Esta librería suele venir instalada predeterminadamente con el programa, así que en principio no debería haber problema.</li> </ul>
<pre>
//LIBRARIES
#include "SPI.h"
</pre>
<ul> <li type="disc">En el caso de Processing, se utilizarán las siguientes librerías tanto para procesar la información recibida en serie como para sacar la hora para los archivos .txt</li> </ul>
<pre>
//LIBRARIES
import processing.serial.*;
import java.util.Date;
</pre>
<h2> Pasos para ejecución </h2>
<p>1. Lo primero será conectar la placa LantierBoard al ordenador, y encender el switch de la parte posterior de la caja. </p>
<p>2. Seguidamente habrá que abrir el código de arduino y ejecutarlo. Esto tan solo hay que hacerlo una vez, ya que luego se almacena en el propio micoroprocesador.</p>
<p>3. Finalmente, para ejecutar el código del seguimiento del proyecto o de la aplicación final y acceder a la interfaz gráfica, el proceso será el mismo. Tan solo será necesario abrir uno de los cuatro archivos de processing, y ejecutarlo, asegurandose que primero se hayan cumplido los dos primeros pasos, ya que sino no funcionará incuso si se hacen los pasos después. En este caso habra que cerrar el programa de Processing y volver a ejecutarlo tras cumplir estos pasos.</p>
<p>A continuación se muestra un video de ejemplo con el proceso de ejecución, y el resultado que se debería obtener si se ha hecho correctamente.</p>


<video source src="https://user-images.githubusercontent.com/98835194/175782156-a7945e83-2ab8-4b2b-9278-e3624a11dd5c.mp4" autoplay>
