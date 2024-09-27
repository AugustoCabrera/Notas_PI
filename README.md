# Notas Proyecto Integrador



## 01-PI-Papp-Turina   🚀

El modelo propuesto para el desarrollo del trabajo es el **modelo iterativo**. En cada iteración se presentará:

1. Planteo de los **objetivos** que se esperan alcanzar al finalizar la iteración.
2. Propuesta de un nuevo **modelo de redes de Petri** y/o modificaciones al anterior para cubrir los objetivos propuestos.
3. **Explicación detallada** del funcionamiento del modelo propuesto.
4. **Validación** del modelo.
5. **Implementación** del modelo.
6. **Análisis final** en base a los objetivos planteados al inicio de la iteración y los resultados obtenidos.
7. **Pasos a seguir** en la próxima iteración.

---


### Primera iteración: Modelo Inicial 📋

_En base a los 5 estados que se puede encontrar un hilo se obtiene:_


<p align="center">
  <a href="https://example.com/">
    <img src="img/image1.png" alt="bloques">
  </a>
  </p>

**T0**:  Momento de creación de un proceso o cuando el mismo realiza un fork. Esta tarea no corresponde al scheduler, por lo que inicialmente un hilo en el scheduler se encuentra inicializado en el estado `CAN RUN`. Esta transición nunca se dispara, solo se la incorpora al modelo de modo representativo.

**T1**: El hilo se pone en una cola local de una determinada CPU o en la cola global dependiendo de la disponibilidad. Esta cola organiza los hilos de acuerdo a sus prioridades de ejecución.

**T2**: El hilo pasa de la cola ejecutando las instrucciones del programa que tiene asignadas. En este instante el procesador se encuentra ocupado por dicho hilo.

**T3**: El scheduler interrumpe el hilo y lo vuelve a colocar en una cola. El planificador toma otro hilo de la cola (el de mayor prioridad) y realiza un cambio de contexto.

**T4**: Algún evento, semáforo o espera bloquea al hilo. Se agrega en una `sleepq` o `turnstile`, en la cual el hilo queda a la espera de un evento que le quitará el bloqueo.

**T5**: Se desbloquea el hilo y puede volver a encolarse nuevamente. El evento que lo desbloquea se genera fuera del scheduler. El hilo queda a la espera para poder cambiar de estado cuando corresponda.

### ¿En qué parte se define la estructura de los hilos?

`\sys\sys\proc.h`  → Se puede observar

_NOTA: Algunos valores presentan incongruencias, ya que corresponden a la versión final de la RDP. Por motivos de continuidad, se muestra que se han modificado, pero no se debe dar importancia al valor final. En la última versión se aclarará este punto._

<p align="center">
  <a href="https://example.com/">
    <img src="img/image2.png" alt="bloques">
  </a>
  </p>

  Agregar a la estructura `thread` los siguientes campos:

- `mark`: vector que tiene el marcado inicial, con tamaño `PLACES SIZE`.
- `sensitized_buffer`: vector que representa las transiciones sensibilizadas de su red asociada, con tamaño `TRANSITIONS SIZE`.


<p align="center">
  <a href="https://example.com/">
    <img src="img/image3.png" alt="bloques">
  </a>
  </p>


  `\sys\kern\sched_petri.c`  → Se creo que incluye a sched_petri.h para
representar la red de Petri propuesta y su funcionamiento. Se declaración
la matriz de incidencia (PLACES SIZE * TRANSITIONS SIZE) y el vector
de marcado inicial (PLACES SIZE), y a su vez se implementaron las
funciones declaradas anteriormente:

<p align="center">
  <a href="https://example.com/">
    <img src="img/image4.png" alt="bloques">
  </a>
  </p>



### ¿Donde se inicializa y asigna memoria a la estructura thread dentro del código fuente?

`\sys\kern\kern_thread.c`  → Llamamos ahora a `init_petri_net` para inicializar y asignar memoria

<p align="center">
  <a href="https://example.com/">
    <img src="img/image5.png" alt="bloques">
  </a>
  </p>

### Conclusion: Primera Interacción

Con un modelo ya desarrollado para los hilos, el próximo paso consiste en
proponer un modelo inicial para representar los estados y eventos de los recursos del sistema.

---


### Segunda iteración: Recursos del sistema 📋

En esta iteración se buscara proponer un modelo inicial de red de Petri para representar el reparto de las CPU para cada uno de los hilos.

<p align="center">
  <a href="https://example.com/">
    <img src="img/image6.png" alt="bloques">
  </a>
  </p>


---


### Tercera iteración: Sistema de turnos  para 4 CPU. 📋

Se pensó la red como el ciclo de un token que circula por
tantas plazas como CPU disponga el sistema. Esto nos da la posibilidad de ir
tomando decisiones respecto a cada CPU y de poder movernos de una CPU a
la siguiente en forma cíclica, pasando por todas las CPU antes de volver a la
misma. Esto permite que la asignación de hilos dentro de cada CPU sea justa
y equitativa.

<p align="center">
  <a href="https://example.com/">
    <img src="img/image7.png" alt="bloques">
  </a>
  </p>


### ¿Cómo represento los CPU en la RdP?

`\sys\sys\sched_petri.h` se describen ahi 

<p align="center">
  <a href="https://example.com/">
    <img src="img/image8.png" alt="bloques">
  </a>
  </p>


### ¿Cómo represento los recursos GLOBALES en la RdP?

`sys\kern\petri_global_net.c` → representar la red de Petri de recursos propuesta y su funcionamiento.
Se declaro la matriz de incidencia base y la matriz de inhibición base, y a
su vez se implementaron las funciones declaradas anteriormente

<p align="center">
  <a href="https://example.com/">
    <img src="img/image9.png" alt="bloques">
  </a>
  </p>


### ¿Qué más se ha añadido en la Tercera intersección?

En la función sched_setup del archivo sched_4bsd.c identificar donde
se inicializa el scheduler para inicializar su red de recursos. Llamar a init_resource_net en sched_setup para inicializar y asignar
espacio de memoria para la red de recursos.

<p align="center">
  <a href="https://example.com/">
    <img src="img/image10.png" alt="bloques">
  </a>
  </p>



