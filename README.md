# Notas Proyecto Integrador



# 01-PI-Papp-Turina   🚀

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
    <img src="img/image1.png" alt="bloques">
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
    <img src="img/image2.png" alt="bloques">

  </p>

  Agregar a la estructura `thread` los siguientes campos:

- `mark`: vector que tiene el marcado inicial, con tamaño `PLACES SIZE`.
- `sensitized_buffer`: vector que representa las transiciones sensibilizadas de su red asociada, con tamaño `TRANSITIONS SIZE`.


<p align="center">
    <img src="img/image3.png" alt="bloques">

  </p>


  `\sys\kern\sched_petri.c`  → Se creo que incluye a sched_petri.h para
representar la red de Petri propuesta y su funcionamiento. Se declaración
la matriz de incidencia (PLACES SIZE * TRANSITIONS SIZE) y el vector
de marcado inicial (PLACES SIZE), y a su vez se implementaron las
funciones declaradas anteriormente:

<p align="center">
    <img src="img/image4.png" alt="bloques">

  </p>



### ¿Donde se inicializa y asigna memoria a la estructura thread dentro del código fuente?

`\sys\kern\kern_thread.c`  → Llamamos ahora a `init_petri_net` para inicializar y asignar memoria

<p align="center">
    <img src="img/image5.png" alt="bloques">

  </p>

### Conclusion: Primera Interacción

Con un modelo ya desarrollado para los hilos, el próximo paso consiste en
proponer un modelo inicial para representar los estados y eventos de los recursos del sistema.

---


### Segunda iteración: Recursos del sistema 📋

En esta iteración se buscara proponer un modelo inicial de red de Petri para representar el reparto de las CPU para cada uno de los hilos.

<p align="center">
    <img src="img/image6.png" alt="bloques">

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
    <img src="img/image7.png" alt="bloques">

  </p>


### ¿Cómo represento los CPU en la RdP?

`\sys\sys\sched_petri.h` se describen ahi 

<p align="center">
    <img src="img/image8.png" alt="bloques">

  </p>


### ¿Cómo represento los recursos GLOBALES en la RdP?

`sys\kern\petri_global_net.c` → representar la red de Petri de recursos propuesta y su funcionamiento.
Se declaro la matriz de incidencia base y la matriz de inhibición base, y a
su vez se implementaron las funciones declaradas anteriormente

<p align="center">
    <img src="img/image9.png" alt="bloques">

  </p>


### ¿Qué más se ha añadido en la Tercera intersección?

En la función sched_setup del archivo sched_4bsd.c identificar donde
se inicializa el scheduler para inicializar su red de recursos. Llamar a init_resource_net en sched_setup para inicializar y asignar
espacio de memoria para la red de recursos.

<p align="center">
    <img src="img/image10.png" alt="bloques">

  </p>



---


### Cuarta iteración: Encolado. 📋

Encolado equitativo de hilos en las diferentes
CPU que conforman el sistema.


<p align="center">
    <img src="img/image11.png" alt="bloques">

  </p>

- Que la CPU este en condiciones de encolar: se disparara una transicion que pase el turno y agregue un token a la cola de esa CPU.

- Que la CPU no este en condiciones de encolar: se disparara una transicion
que pasara el turno al siguiente sin agregar tokens en su cola.


Para implementar el modelo en el código fuente, se procedió a:

### ¿Donde se realiza el encolado de threads en el código fuente?

Esto se realiza en `sched_4bsd.c` en la función `sched_add`.

<p align="center">
    <img src="img/image12.png" alt="bloques">

  </p>

 Llamar a `resource_fire_net` en `sched_add` para contemplar en la red el encolado de los threads que ingresan al scheduler en la CPU que le corresponda.

<p align="center">
    <img src="img/image13.png" alt="bloques">

  </p>



### Quinta iteración: Encolado Controlado. 📋

Sistema de autocontrol para las asignaciones de los hilos que permita determinar cuales son las
CPU que tienen la mayor cantidad de hilos en sus colas y de esta forma decidir
si la CPU actual esta en condiciones de encolar.


<p align="center">
    <img src="img/image14.png" alt="bloques">

  </p>

  ### Implementación


Definir como automática la transición de descarte al momento de inicializar el vector de transiciones automáticas en `sched_petri.h`. De esta forma, cada vez que la misma quede sensibilizada, será disparada de inmediato, manteniendo siempre así en el modelo al menos una CPU que pueda encolar.

<p align="center">
    <img src="img/image15.png" alt="bloques">

  </p>


  ### Sexta iteración: Selección y Ejecución del Hilo. 📋

  Modelo para el encolado y desencolado de hilos. Las transiciones en naranja van a representar al resto de las
CPU y se las incorporan al modelo para mostrar la penalización detallada

<p align="center">
    <img src="img/image16.png" alt="bloques">

  </p>

  ### Implementación

1. Agregar en `petri_global_net.c` dos vectores:
   - `Hierarchical_transitions`: vector con las transiciones jerárquicas de la red de recursos, ordenadas de acuerdo al índice correspondiente con `hierarchical_corresponse`.
   - `Hierarchical_corresponse`: vector con las transiciones jerárquicas de la red del thread, ordenadas de acuerdo al índice correspondiente con `hierarchical_transitions`.

<p align="center">
    <img src="img/image17.png" alt="bloques">

  </p>

2. Llamar a `resource_fire_net` en `sched_switch` para contemplar en la red los threads que pasan a ejecución en la CPU que le corresponda.

3. Identificar dónde finaliza la ejecución de los threads liberando la CPU en el código fuente. Esto se realiza en `sched_4bsd.c` en `sched_switch`.

4. Llamar a `resource_fire_net` en `sched_switch` para contemplar en la red los threads que finalizan su ejecución y retornan la CPU que corresponde.

5. Incorporar en `petri_global_net.c` en la función `resource_fire_net` el disparo de las transiciones jerárquicas de la red del thread cuando una transición de la red de recursos que le corresponda se dispara.

6. Identificar dónde se realiza el desencolado de threads en el código fuente. Esto se realiza en `sched_4bsd.c` en la función `sched_choose`.

7. Llamar a `resource_fire_net` en `sched_choose` para contemplar en la red el desencolado de los threads que van a pasar a ejecución en la CPU que le corresponda.

8. Identificar dónde se manda a ejecutar a los threads en el código fuente. Esto se realiza en `sched_4bsd.c` en la función `sched_switch`.


---

Continuando con el análisis, se llevó a cabo un análisis más minucioso del modelo planteando la siguiente cuestión:

- ¿Es necesario llevar un sistema de turnos por cada CPU?
- ¿No sería más eficiente que directamente se sensibilicen las transiciones de encolado cuyas colas estén habilitadas?

---

### Septima iteración: Modelo sin turnos. 📋

El sistema de turnos propuesto
desde un principio resulta innecesario e ineficiente

<p align="center">
    <img src="img/image18.png" alt="bloques">

  </p>

  #### Analogía entre Estados de hilos y Recursos

  Como se puede observar, la mayoría de las transiciones de la red de Petri de un hilo pueden vincularse a la red de recursos. Sin embargo, es necesario realizar algunas aclaraciones:

1. Las últimas dos transiciones detalladas anteriormente generan un retorno de la CPU en la red de recursos. Es necesario categorizar el retorno en:
   - **Voluntario**: cuando la interrupción de la ejecución se debe a que el hilo no puede continuar porque espera por un evento o un recurso.
   - **Involuntario**: cuando la interrupción se produce porque el hilo consumió su tiempo asignado de CPU o bien finalizó su tarea. Para distinguir entre ambos retornos, se incluirán dos transiciones diferentes para representarlas en el modelo.

2. La transición `INACTIVE ⇒ CAN RUN` del hilo no es tarea del scheduler, por lo que la misma no tiene jerarquía en la red de recursos.

3. La transición `INHIBITED ⇒ CAN RUN` del hilo tampoco depende del scheduler y no tiene jerarquía con la red de recursos. Esta transición depende de otras partes del sistema operativo que se encargan de generar los eventos o liberar los recursos que necesita el hilo. Por este motivo, esta transición solo va a monitorear cuando se produzca esto último para disparar en ese momento esta transición previo a disparar la de encolado.


<p align="center">
    <img src="img/image19.png" alt="bloques">

  </p>


Al momento de tener que encolar un hilo en una cola de CPU, el scheduler se encarga de llevar a cabo un monitoreo general de todas las transiciones de encolado de la red de recursos para determinar cuáles de estas se encuentran sensibilizadas en ese momento y, entre las mismas, seleccionar una para disparar. Considerando este comportamiento, la simplificación propuesta en la iteración anterior se considera factible para el modelo.


#### Implementación del modelo



1. Dividir en `petri_global_net.c` las transiciones jerárquicas de cambio de contexto.
2. Agregar en `sched_petri.h` la definición de `resource_choose_cpu` e implementarla en `petri_global_net.c`:
   - `resource_choose_cpu`: recibe un thread como parámetro, busca la transición de encolado de la CPU que esté disponible y la retorna.
3. Agregar en la función `sched_add` de `sched_4bsd.c` un llamado a la función `resource_choose_cpu` antes de realizar el encolado para tener la CPU correcta.
4. Añadir a la estructura `thread` en `proc.h` el campo `td_frominh` que va a indicar cuando un thread acaba de salir de estado inhibido. Esto ocurre cuando el mismo pasa por un cambio de contexto voluntario.
5. Agregar en `sched_petri.h` la definición de `resource_expulse_thread` e implementarla en `petri_global_net.c`:
   - `resource_expulse_thread`: recibe un thread como parámetro y las flags de cambio de contexto. Según el tipo de cambio de contexto, actualiza el valor de `td_frominh` y dispara la transición de retorno de CPU correspondiente en la red de recursos y, por ende, su jerárquica.
6. Llamar a `resource_expulse_thread` en lugar de `resource_fire_net` en `sched_switch` para contemplar en la red los threads que finalizan su ejecución.
7. Disparar la transición del thread que lo saca del estado de inhibido en la función `sched_add` de `sched_4bsd.c`.

---

### Octava iteración: Afinidad de hilos. 📋

Supuesto de que los hilos pueden tener cierta afinidad con alguna CPU o grupo de CPU, se buscará modelar el caso en el que ninguna CPU afín a un hilo que está por ser encolado se encuentre disponible. Se implementará una nueva **cola general para todas las CPU**, donde serán encolados los hilos que no tienen ninguna de sus CPU afines disponibles.


<p align="center">
    <img src="img/image20.png" alt="bloques">

  </p>


#### Implementación del modelo


1. Añadir en `petri_global_net.c` la transición jerárquica del thread a la transición de encolado global.
2. Analizar en la función `resource_choose_cpu` en `petri_global_net.c` las flags que indican las CPU afines a un thread y, en base a esto, tomar la decisión de retornar una cola de CPU o bien la cola global.
3. Tener en cuenta en la función `sched_add` de `sched_4bsd.c` la nueva transición de encolado global, disparándola cuando no se retorna ninguna CPU donde encolar.

```
¿¿¿ Colas deshabilitadas ???

Se descubrió que, al momento de inicializarse el sistema operativo, las colas de las CPU se encuentran deshabilitadas hasta que todas las CPU son inicializadas, encontrándose solo la CPU0 disponible desde el inicio. Esto podría presentar un problema para el encolado de hilos, pero se determinó que la cola global añadida al modelo podría también ser utilizada para encolar a todos los hilos hasta que las colas de las CPU se encuentren disponibles. De esta forma, va a ser necesario plantearse en las próximas iteraciones una forma de representar esta situación de inicio.

Continuando el análisis, también se presentó otra cuestión. A la hora de seleccionar el próximo hilo a ejecutar por una CPU, el scheduler pregunta tanto a la cola global como a la cola de la CPU cuál es el hilo con mayor prioridad para pasarlo directamente a ejecución. En base a este funcionamiento, resulta innecesario realizar el cambio de cola propuesto anteriormente; en su lugar, resulta más factible pasar el hilo presente en la cola global directamente a ejecución.
```


---

###  Novena iteración: Selección entre colas 📋

<p align="center">
    <img src="img/image21.png" alt="bloques">

  </p>

  Los hilos presentes en la cola global son tenidos en cuenta al momento en que una CPU elige el próximo hilo a ejecutar. Esta transición, que ahora también se corresponderá a una transición de desencolado, tendrá como jerárquica del hilo a `RUNQ ⇒ RUNNING`.


El hecho de que un hilo se encuentre en la cola propia de la CPU o bien en la cola global no influye en la decisión sobre el próximo a ser ejecutado. 

#### Cambios de contexto en base al modelo obtenido

En esta iteración, también se estudió con mayor profundidad el funcionamiento de los cambios de contexto en base al modelo obtenido. Cuando se produce un cambio de contexto, es decir, que el hilo que está en ejecución libera la CPU y se lo cede al de mayor prioridad de la cola, se produce la siguiente secuencia:

1. El hilo en ejecución es expulsado, retornando la CPU y cambiando su estado de `RUNNING ⇒ CAN RUN/INHIBITED`.
2. El hilo saliente es agregado a una cola de ejecución en caso de que sea un cambio de contexto involuntario, cambiando de estado de `CAN RUN ⇒ RUNQ`.
3. Se elige el siguiente hilo a ejecutar y se lo manda a ejecución, asignándole la CPU y cambiando su estado de `RUNQ ⇒ RUNNING`.


---

###   Décima iteración: Monoprocesador/ Multiprocesador 📋

Se procederá a adaptar el modelo de tal forma que pueda representar tanto el comportamiento **monoprocesador (NO SMP)** como el comportamiento **multiprocesador (SMP)** del sistema operativo. Esto permitirá simular ambos escenarios y reflejar el manejo de hilos y CPUs en entornos con una sola CPU o múltiples CPUs, asegurando que el scheduler opere correctamente en ambas configuraciones.


<p align="center">
    <img src="img/image22.png" alt="bloques">

  </p>

- Utilizar una **plaza global** para indicar que el sistema se encuentra en modo **monoprocesador (NO SMP)**.
- Utilizar una **plaza global** para indicar que el sistema se encuentra en modo **multiprocesador (SMP)**.
- Emplear una **transición global** entre ambas plazas, la cual se disparará cuando se inicialicen todas las CPU.
- Agregar una **transición de ejecución global** que será utilizada únicamente por la CPU0 cuando el sistema se encuentre en modo monoprocesador y no castigará al resto de las CPU. Notar que esta transición no estará conectada al resto de las CPU del sistema operativo.
- La **transición global de ejecución** es equivalente a la ya existente para cada CPU y tendrá como jerárquica la misma transición `RUNQ ⇒ RUNNING` del hilo.

#### Implementación


1. Añadir en `petri_global_net.c` la transición jerárquica del thread a la transición de ejecución global.



2. Agregar en `petri_global_net.c` el campo `smp_set`, inicializado en 0, el cual va a permitir identificar el momento en que se inició el modo SMP.

<p align="center">
    <img src="img/image23.png" alt="bloques">

  </p>


3. Añadir en la función `resource_fire_net` en `petri_global_net.c` la comprobación del estado SMP del sistema representado por `smp_started`. Cuando `smp_started` se ponga en 1, se debe disparar la transición de traspaso a SMP en la red de recursos y poner en 1 a `smp_set`.

<p align="center">
    <img src="img/image24.png" alt="bloques">

  </p>


4. Agregar en `sched_petri.h` la definición de `resource_execute_thread` e implementarla en `petri_global_net.c`:
   - `Resource_execute_thread`: recibe un thread como parámetro y un número de CPU. Esta función ejecuta la transición de ejecución que corresponda, según el valor de `smp_set`.

<p align="center">
    <img src="img/image25.png" alt="bloques">

  </p>
<p align="center">
    <img src="img/image26.png" alt="bloques">

  </p>



5. Reemplazar en la función `sched_switch` en `sched_4bsd.c` el disparo de la transición de ejecución por un llamado a `resource_execute_thread`.
6. Modificar la función `resource_choose_cpu` en `petri_global_net.c` para que retorne siempre la transición de encolado global cuando el sistema se encuentre en **NO SMP**.



---

###   Undécima iteración: Expulsión de hilos 📋

Representar la expulsión de un hilo de una determinada cola.   También se buscará representar la expulsión de los hilos del sistema operativo cuando los mismos finalizan su ejecución.


<p align="center">
    <img src="img/image27.png" alt="bloques">

  </p>

<p align="center">
    <img src="img/image28.png" alt="bloques">

  </p>

  En el modelo del hilo se representa un nuevo cambio de estado para el hilo `RUNQ ⇒ CAN RUN`. La transición `T6` se ejecutará cada vez que un hilo deba ser expulsado de la cola en que se encuentra actualmente.

En cuanto al modelo de la red de recursos, para representar la expulsión de los hilos se van a incorporar dos transiciones de expulsión para cada CPU:
- La primera expulsará a un hilo de su cola cada vez que se ejecute y restará un token de habilitación de la CPU, es decir, que se premia a la CPU para tener como jerárquica la transición `RUNQ ⇒ CAN RUN` del hilo.

Este último modelo contempla las siguientes funcionalidades del scheduler:
- Encolado de hilos, ya sea en cola global o de una CPU.
- Expulsión de hilos de una cola, para asignarlos a una correcta.
- Desencolado de hilos cuando se encuentra presente la CPU, ya sea desde la cola global o la de la CPU.
- Ejecución monoprocesador para la `CPU0`.
- Ejecución multiprocesador para todas las CPU.
- Retornos voluntarios e involuntarios de la CPU.
- Transiciones jerárquicas asignadas para la conexión con cada red de hilos que pueda encolar.

La segunda expulsará a un hilo de su cola cada vez que se ejecute y la plaza de habilitación no tenga ningún token.

Por otra parte, se agregó también una transición global de expulsión para cuando el hilo expulsado se encuentre encolado en la cola global, la cual es única ya que no debe premiar el encolado de ninguna CPU.

Para realizar la nueva conexión entre ambas redes, se va a tener que tanto las transiciones de expulsión de cada CPU como la transición de expulsión global...


#### Implementación del modelo


1. Definir en `sched_petri.h` los macros de las nuevas plazas y transiciones incorporadas al modelo. Inicializarlas en `init_resource_net`.

2. Añadir en `petri_global_net.c` la transición jerárquica del thread a las transiciones de remoción de cada CPU y la global.

3. Agregar en `sched_petri.h` la definición de `resource_remove_thread` e implementarla en `petri_global_net.c`:

   - **Resource_remove_thread**: recibe un thread como parámetro y un número de CPU. Esta función ejecuta la transición de expulsión de la CPU que corresponda, según cuál sea la que se encuentre sensibilizada.

4. Identificar dónde se expulsan los threads de su cola en el código fuente. Esto se realiza en `sched_4bsd.c` en la función `sched_rem`.

5. Llamar a `resource_fire_net` en `sched_rem` para expulsar a los threads que se encuentren actualmente en la cola global y deban ser reubicados, o bien llamar a `resource_remove_thread` para expulsar a los threads que se encuentren en una cola de CPU para reubicarlos.

6. Identificar dónde son desechados los threads que finalizan su ejecución en el código fuente. Esto se realiza en `sched_4bsd.c` en la función `sched_throw`.



7. Llamar a `resource_expulse_thread` en `sched_throw` para expulsar a los threads que deben ser desechados. Posteriormente, se debe seleccionar un nuevo thread de la cola y mandarlo a ejecución. Para ello, debe dispararse primero la transición de desencolado, al igual que se hace en `sched_choose`, y posteriormente llamar a `resource_execute_thread` con el thread elegido.

<p align="center">
    <img src="img/image30.png" alt="bloques">

  </p>

  #### Análisis de resultados

Luego de probar este último modelo en el código y simularlo, el mismo resultó funcionar como se esperaba tanto para la red de los recursos como para la del thread, cumpliendo el objetivo propuesto para la iteración. Sin embargo, se llevó a cabo un análisis más profundo y se pudieron resaltar algunas falencias en la red de recursos:

1. **Ineficiencia en la penalización de CPUs**: El método propuesto de castigar las CPU que ejecutan más lento resulta poco eficiente cuando hay pocos hilos ejecutándose en el sistema, ya que las colas están en su mayor tiempo vacías y no resulta necesario castigar a CPU inactivas.

2. **Pérdida de control del estado global**: Cuando un hilo pasa a ejecución, se pierde control del estado en que se encuentra la red global. Además, para las transiciones de retorno de CPU no existe ningún mecanismo de control presente en la red global para controlar sus disparos.

Por otra parte, el modelo aún no cubre la funcionalidad del scheduler que permite a hilos que acaban de ser encolados pasar directamente a ejecución cuando su prioridad es mayor al que se encuentra actualmente ejecutando.

---


### Décimo tercera iteración: Hilos de baja prioridad 📋

Se buscará implementar el funcionamiento de los hilos de baja prioridad que pasan a ocupar la CPU cuando la misma no posee ningún hilo para ejecutar en su cola.


<p align="center">
    <img src="img/image31.png" alt="bloques">

  </p>

  Habiendo llegado a este último modelo, se detalla el marcado inicial necesario para asegurar el correcto funcionamiento del *scheduler*, tanto en la red de hilos como en la red de recursos:

- **Red de hilos**: El marcado inicial debe ubicar un token en la plaza *CAN RUN* de cada hilo, ya que cuando el hilo ingresa por primera vez al *scheduler* para ser encolado, ya ha sido inicializado (*INACTIVE → CAN RUN* ejecutado). Sin embargo, hay un hilo especial, con ID `100000`, que es responsable de inicializar al resto. Este hilo comenzará en el estado *RUNNING*, ya que está ejecutándose en la CPU0 desde el inicio.

- **Red de recursos**: La red comenzará con un token en la plaza que indica que el sistema está en modo monoprocesador. Además, las plazas que representan a las CPUs se inicializan con un token, excepto la de la CPU0, que ya está ejecutando el hilo inicial del sistema. Por lo tanto, para la CPU0, el token debe colocarse en la plaza que indica que está en estado de ejecución.

Finalmente, el comportamiento de los hilos de baja prioridad, que ocupan la CPU cuando no hay otros hilos disponibles, se abordará en el análisis de la implementación.



#### Implementación del modelo



1. **Eliminar en `petri_global_net.c` la transición jerárquica del thread a la transición de ejecución descartada**.
   
2. **Inicializar correctamente el marcado de los threads** en `init_petri_thread` de `sched_petri.c`. Notar que esta función, llamada al ser alocado en memoria un nuevo thread, nunca será llamada para el thread0 inicial.

3. **Inicializar correctamente el marcado de la red de recursos** en la función `init_resource_net` de `petri_global_net.c`. Esta función se llamará al inicializar el *scheduler* en `sched_setup` de `sched_4bsd.c`.

4. **Inicializar en la función `sched_init` de `sched_4bsd.c` el marcado del thread0**, función que es ejecutada únicamente por el mismo al inicializar el sistema.

5. **Modificar la función `sched_choose` de `sched_4bsd.c` de la siguiente manera**:
   - Si no se encuentra ningún thread para ejecutar en ninguna de las colas, se ejecutará la transición de encolado global del *idle thread*. Como los *idle threads* no se encuentran en las colas, para no perder el flujo de la red de los mismos, se los encolará "de pasaje" en la cola global.
   - Inmediatamente después del desencolado, ejecutar la transición de desencolado global para finalizar el "pasaje" por la cola global.
   
6. **El tratamiento de los *idle threads* en `sched_switch` será igual al del resto de los threads** en cuanto a pasaje a ejecución y finalización de la misma. Solo no se los tendrá en cuenta a la hora de encolarlos cuando son expulsados de la CPU.

7. **Dado que los *idle threads* también pueden sufrir cambios de contexto** (voluntarios o involuntarios), si `td_frominh` es igual a `1`, se deberá ejecutar la transición del thread que lo saca del estado de inhibido. Esto se realizará antes de encolar y desencolar el *idle thread* en `sched_choose`.


<p align="center">
    <img src="img/image32.png" alt="bloques">

  </p>



  #### Análisis de resultados

El resultado esperado en cuanto al funcionamiento de los hilos de baja prioridad fue correcto. Esta nueva incorporación permitió realizar un análisis completo de las redes en ejecución, y los resultados en cuanto al seguimiento de sus marcados fueron los esperados para el modelado del sistema propuesto desde un inicio.

Por otra parte, el agregado de los sistemas de control permitió corroborar en ejecución que las transiciones que controlan son en todo momento correctamente disparadas, sin encontrar momentos donde un hilo intente dispararlas sin encontrarse sensibilizadas.


### MODELO FINAL 📋✅

<p align="center">
    <img src="img/image33.png" alt="bloques">
<figcaption>Estados de 1 hilo</figcaption>
    </figure>

</p>



<p align="center">
    <img src="img/image36.png" alt="bloques">
<figcaption>Recursos de 1 solo CPU</figcaption>
    </figure>

</p>

| **Transición**         | **Descripción**                                                                 | **Condiciones/Acciones/Resultados**                                                      |
|------------------------|---------------------------------------------------------------------------------|------------------------------------------------------------------------------------------|
| **ADDTOQUEUE (Ti+1)**          | Un hilo es agregado a la cola del CPU correspondiente.                         | Inhibida en modo monoprocesador o cuando ya existe un hilo en la cola.                   |
| **UNQUEUE**             | Se quita el hilo próximo a ejecutar de la cola del CPU.                         | El hilo está listo para ser ejecutado.                                                   |
| **EXEC i**                | El hilo pasa a ejecución, ocupando el recurso del procesador.                   | Elimina el token de la plaza de habilitación; inhibida en modo monoprocesador.            |
| **EXECEMPTY i**          | Igual que EXEC, pero no depende de la plaza de habilitación.                    | Usada para hilos provenientes de la cola global.                                         |
| **RETURN VOL CPU i**          | Retorno del procesador para ejecutar otro hilo de su cola.                     | Ocurre cuando el hilo está esperando un evento o recurso.                                |
| **RETURN INVOL CPU i**        | Funciona igual que RETURN VOL.                                                  | Ocurre cuando el hilo agotó su tiempo de CPU o completó su tarea.                        |
| **FROM GLOBAL CPU (TG)**     | Desencolado de un hilo desde la cola global.                                    |                                                                                          |
| **REMOVEQUEUE i**        | Expulsa un hilo de la cola y resta un token de habilitación de la CPU.          | Permite que otro hilo sea encolado.                                                      |
| **REMOVEEMPTYQUEUE i**  | Igual que REMOVE QUEUE, pero se ejecuta sin ningún token en la plaza de habilitación. |                                                                                          |
| **REMOVE_GLOBAL** | Expulsa un hilo de la cola global sin premiar a la CPU.                        |                                                                                          |
| **START SMP**           | Se dispara cuando el sistema pasa de monoprocesador a multiprocesador.          |                                                                                          |
| **THROW**               | Se ejecuta cuando todas las plazas de habilitación de las CPU tienen al menos un token. | Habilita las colas con menor cantidad de hilos que estaban inhibidas.                    |
| **QUEUE GLOBAL**        | Agrega un hilo a la cola global.                                                |                                                                                          |

---




<p align="center">
    <img src="img/image34.png" alt="bloques">
  <figcaption>COMPLETO 4 CPU - Recursos</figcaption>
    </figure>

</p>

<p align="center">
    <figure>
      <img src="img/image35.png" alt="bloques">
      <figcaption>Camino 1 solo CPU</figcaption>
    </figure>

</p>


### Funciones principales

Las funciones principales del scheduler implementado son:

- **sched_add**: se encarga del encolado de los hilos. Hace uso de la función `resource_choose_cpu` para seleccionar la cola. Puede pasar al hilo directamente a ejecución si la función `maybe_preempt` lo determina.

<p align="center">
    <figure>
      <img src="img/image37.png" alt="bloques">
    </figure>

</p>

- **sched_choose**: se encarga de desencolar al hilo de mayor prioridad, fijándose tanto en la cola de la CPU actual como en la cola global.

<p align="center">
    <figure>
      <img src="img/image38.png" alt="bloques">
    </figure>

</p>



- **sched_rem**: se encarga de remover al hilo de la cola, el cual debe ser reubicado. Hace uso de la función `resource_remove_thread`.

<p align="center">
    <figure>
      <img src="img/image39.png" alt="bloques">
    </figure>

</p>


- **sched_switch**: se encarga de expulsar al hilo actual en ejecución haciendo uso de la función `resource_expulse_thread`, reubicarlo en una cola y seleccionar el próximo a ejecutar mediante `choose_thread` para mandarlo a ejecución usando la función `resource_execute_thread`.

<p align="center">
    <figure>
      <img src="img/image40.png" alt="bloques">
    </figure>

</p>

- **sched_throw**: igual a `sched_switch`, con la diferencia de que no reubica en una cola al hilo saliente ya que el mismo ha finalizado su ejecución.

<p align="center">
    <figure>
      <img src="img/image41.png" alt="bloques">
    </figure>

</p>


---

# 02-PI-Drudi-Goldman 🚀


## Encolado (add)

El sistema utiliza 64 colas, seleccionando una cola para un hilo determinado dividiendo su prioridad entre 4. Para ahorrar tiempo, los hilos dentro de cada cola no se reorganizan por prioridades. Estas colas pueden ser de los siguientes tipos: **run queue**, **turnstile queue** o **sleep queue**.

- Los hilos en estado **RUNNABLE** se ubican en las **run queue**.
- Los hilos bloqueados o esperando un evento se colocan en las **turnstile queue** o **sleep queue**.

### Comportamiento del sistema

- Si un hilo agota su tiempo permitido, se coloca al final de la cola de la que procede, y el próximo hilo en la cola se selecciona para ejecutarse.
- Si un hilo se bloquea, se coloca en una **turnstile queue** o **sleep queue**, en lugar de regresar a la **run queue**.

### Función `sched_add()`

La operación de encolado se realiza en la función `sched_add()`, que recibe como parámetros el hilo a encolar y algunos flags con información sobre este. Las etapas principales del proceso son las siguientes:

1. **Verificación del estado del hilo**: El hilo debe estar en estado **CAN RUN** o **RUNNING** para ser encolado. Si cumple con esta condición, se adquiere el lock del planificador y el hilo pasa al estado **RUNQ**.
   
2. **Selección de la cola de CPU**: Se utiliza la función `sched_pickcpu()` para elegir el CPU en el cual se encolará el hilo. Este proceso se realiza en varias etapas:
   - Se verifica si el hilo ya había sido ejecutado en un CPU previo. Si es posible, se intenta reencolarlo en el mismo procesador; si no, se asigna el valor **NOCPU** (-1).
   - Se itera sobre cada CPU disponible en el sistema y se verifica si es permitido encolar en dicho CPU.
   - Dependiendo del valor de la variable que indica el CPU previo:
     - Si la variable es **NOCPU**, se asigna el CPU actual de la iteración.
     - Si la variable tiene un CPU asignado, se compara la cantidad de procesos en la cola del CPU actual con el del CPU anterior. Si el CPU actual tiene menos hilos, se selecciona este.
   - Al finalizar la iteración, se retorna el CPU más adecuado para el hilo.

3. **Encolado en la cola del CPU**: Una vez seleccionado el CPU, se realizan los cambios de contexto necesarios para agregar el hilo a la cola del procesador. Si el CPU seleccionado es diferente al CPU en ejecución actual, se envía una señal **IPI** (inter-processor interrupt) para notificar al nuevo CPU sobre el hilo en su cola.

4. **Preemption**: Si el hilo se encola en el CPU actual, se verifica si tiene mayor prioridad que el hilo en ejecución. Si es así, se procede con la **preemptión**, reemplazando al hilo actual con el nuevo.




## Cambios de contexto (switch y throw)

En el sistema, los cambios de contexto de los hilos se gestionan principalmente mediante dos funciones clave: **`sched_switch()`** y **`sched_throw()`**.

### Función `sched_switch()`

Esta función expulsa al hilo que recibe como parámetro, el cual es el hilo actual en ejecución. Si por alguna razón el hilo continúa en estado **RUNNING**, se reencola utilizando la función **`sched_add()`**. El proceso se detalla a continuación:

1. **Expulsión del hilo**: El hilo actual es expulsado y marcado como **NO RUNNING**. Si sigue en estado **RUNNING**, se lo reencola.
   
2. **Selección de un nuevo hilo**: Una vez expulsado el hilo anterior, se utiliza la función **`choosethread()`** junto con **`sched_choose()`** para seleccionar un nuevo hilo de la cola.
   
3. **Cambio de contexto**: Si el hilo seleccionado es diferente al anterior, se procede al cambio de contexto usando la función **`cpu_switch()`**. Esta función guarda el contexto del hilo anterior y restaura el contexto del nuevo hilo. Además, marca el nuevo hilo con el estado **TD_RUNNING**, asegurando que está en ejecución.

### Función `sched_throw()`

La función **`sched_throw()`** realiza un cambio de contexto similar, pero está diseñada para manejar la expulsión de un hilo que ha finalizado su ejecución, y que no necesita ser reubicado en una cola. El proceso es el siguiente:

1. **Expulsión del hilo**: El hilo que recibe como parámetro (que puede ser nulo) es removido del planificador, liberando sus recursos.
   
2. **Selección de un nuevo hilo**: Al igual que en `sched_switch()`, se utiliza **`choosethread()`** para seleccionar un nuevo hilo para ejecutarse en el mismo CPU.

3. **Continuación de la ejecución**: Si se selecciona un nuevo hilo, la ejecución continúa con este nuevo contexto.

Ambas funciones aseguran una correcta gestión de los hilos, manteniendo el estado del sistema y asegurando que siempre haya un hilo listo para ejecutarse.



<p align="center">
    <figure>
      <img src="img/image43.png" alt="bloques">
    </figure>

</p>

## Elección de hilos (choose)

La elección del próximo hilo a ejecutar se realiza mediante la función **`sched_choose()`**, la cual es invocada por la función **`choosethread()`**.

### Funcionamiento

El objetivo de **`sched_choose()`** es seleccionar el hilo con mayor prioridad disponible para ser ejecutado, eligiéndolo entre las colas del CPU y la cola global. Los hilos en estado **RUNNABLE** son aquellos que están habilitados para ser ejecutados y cada uno tiene una prioridad asignada.

El proceso es el siguiente:

1. **Obtención de hilos**: La función obtiene el primer hilo de la cola global y el primer hilo de la cola del CPU. Estos hilos son almacenados en dos variables separadas.

2. **Comparación de prioridades**: A continuación, se comparan las prioridades de ambos hilos. El hilo con mayor prioridad será el elegido para continuar con la ejecución.

3. **Remoción del hilo**: Una vez seleccionado el hilo de mayor prioridad, este se elimina de su cola correspondiente, ya sea la global o la del CPU.

4. **Caso de colas vacías**: Si ambos hilos son nulos (es decir, si no hay hilos disponibles para ejecutar), se retorna el **idle thread** simulando una ejecución con este hilo.

De esta manera, el sistema garantiza que siempre se elige el hilo más apropiado para ser ejecutado en función de las prioridades y el estado de las colas.


## Remoción de hilos de la cola (rem)

A diferencia de la función **`sched_choose()`**, en la que un hilo es removido de la cola para ser ejecutado, la función **`sched_rem()`** tiene como propósito quitar un hilo (especificado como parámetro) de su cola por dos razones principales:

1. **Ajuste de prioridad**: 
   Si el hilo cambia de prioridad, es necesario removerlo de su cola actual y volver a encolarlo en la posición adecuada según su nueva prioridad. Este proceso se realiza llamando primero a **`sched_rem()`** para quitar el hilo, seguido de **`sched_add()`** para volver a encolarlo en la cola correcta.

2. **Afinidad con CPU**: 
   Cuando un hilo tiene afinidad con un CPU específico, también es necesario removerlo de su cola actual y volver a encolarlo en la cola del CPU correspondiente. Esto asegura que el hilo se ubique en la cola del procesador más adecuado para su ejecución, siguiendo el mismo proceso de remoción y reubicación mencionado anteriormente.

Esta función es fundamental para mantener el orden adecuado de los hilos en el sistema y asegurar que los cambios en las prioridades o afinidades sean gestionados correctamente.

## Remoción de hilos de la cola (rem)

A diferencia de la función **`sched_choose()`**, en la que un hilo es removido de la cola para ser ejecutado, la función **`sched_rem()`** tiene como propósito quitar un hilo (especificado como parámetro) de su cola por dos razones principales:

1. **Ajuste de prioridad**: 
   Si el hilo cambia de prioridad, es necesario removerlo de su cola actual y volver a encolarlo en la posición adecuada según su nueva prioridad. Este proceso se realiza llamando primero a **`sched_rem()`** para quitar el hilo, seguido de **`sched_add()`** para volver a encolarlo en la cola correcta.

2. **Afinidad con CPU**: 
   Cuando un hilo tiene afinidad con un CPU específico, también es necesario removerlo de su cola actual y volver a encolarlo en la cola del CPU correspondiente. Esto asegura que el hilo se ubique en la cola del procesador más adecuado para su ejecución, siguiendo el mismo proceso de remoción y reubicación mencionado anteriormente.

Esta función es fundamental para mantener el orden adecuado de los hilos en el sistema y asegurar que los cambios en las prioridades o afinidades sean gestionados correctamente.

## Modelado del planificador


<p align="center">
    <figure>
      <img src="img/image44.png" alt="bloques">
    </figure>

</p>



Para conectar las redes de hilos con la red de recursos de las CPU, se emplea el concepto de **redes jerárquicas**. Esto implica que cuando se dispara una transición en la red de recursos, debe dispararse simultáneamente una transición correspondiente en la red del hilo. Esta estructura permite sincronizar y coordinar las acciones entre las diferentes redes, asegurando que el estado de los recursos y los hilos permanezcan alineados. La jerarquía de redes garantiza que las decisiones en la asignación de recursos (como las CPU) afecten directamente el comportamiento de los hilos en ejecución.



<p align="center">
    <figure>
      <img src="img/image45.png" alt="bloques">
    </figure>

</p>




---

# 03-PI-Bonino-Daniele 🚀

## Primera iteración 📋

<p align="center">
    <figure>
      <img src="img/image65.png" alt="bloques">
    </figure>
</p>


### Compilación del Kernel

Al tratarse de desarrollo a nivel de kernel, para ver reflejados en el sistema los cambios realizados sobre el código es necesario recompilar el kernel con los archivos nuevos o modificados. Los archivos compilados por el kernel se encuentran dentro del source tree, cuyo path por defecto es `/usr/src/sys/`. Este proceso puede llevar mucho tiempo, por lo que es importante conocerlo a fondo y optimizarlo lo máximo posible.

El primer paso fue reducir el kernel lo más posible, modificando la configuración por defecto para deshabilitar todos los módulos que no se necesitan en las máquinas virtuales. Una vez configurado y compilado este kernel minimalista, se empezó a trabajar en la actualización de los módulos de los proyectos integradores mencionados anteriormente. Para ello, se agregaron los archivos fuente de estos módulos a la configuración del kernel para tenerlos en cuenta durante la compilación.

### Módulos Incorporados

#### Módulo Metadata ELF FreeBSD
Este módulo comprende los siguientes archivos:

- `kern/metadata_elf_reader.c`
- `sys/metadata_elf_reader.h`
- `sys/metadata_payloads.h`

Y modifica los siguientes archivos:

- `kern/imgact_elf.c`
- `kern/kern_exec.c`
- `sys/proc.h`

Este trabajo fue originalmente desarrollado sobre **FreeBSD 12.3**, por lo que las modificaciones realizadas en **FreeBSD 13.2** no trajeron grandes dificultades para adaptar el módulo, ya que no afectaron la funcionalidad de las secciones del código donde se implementa. Por ello, se agregaron solo las líneas y funciones necesarias, se incluyeron en el kernel y se recompiló el sistema.

Una vez compilado el nuevo kernel, se probó su funcionamiento utilizando los plugins **CLang** y **GCC** para insertar metadata en los ejecutables **ELF** y leerla en espacio de kernel.

#### Módulo Petri Net Scheduler
Este módulo comprende los siguientes archivos:

- `kern/petri_global_net.c`
- `sys/petri_global_net.h`
- `kern/sched_petri.c`
- `sys/sched_petri.h`

Y modifica los siguientes archivos:

- `kern/sched_4bsd.c`
- `kern/kern_thread.c`
- `sys/proc.h`

Este proyecto fue desarrollado en **FreeBSD 11**, por lo que debido a los cambios entre versiones, la adaptación a la nueva versión del kernel fue más complicada, ya que algunas funciones del scheduler, modelado con la red de Petri, sufrieron modificaciones en su comportamiento.

La mayor parte del código desarrollado por el equipo se integró en sus respectivos archivos sin dificultad, excepto el código en la función `sched_switch`, que se encarga de expulsar un hilo en ejecución y seleccionar uno nuevo para reemplazarlo.

Una vez compilado el kernel con las modificaciones mencionadas, se comenzó a utilizar el nuevo **scheduler** y se realizaron pruebas para evaluar su comportamiento.


#### Análisis de los Resultados

Luego del proceso de actualización del código de los proyectos integradores a la versión **13.2 de FreeBSD**, se comenzó a utilizar el sistema operativo con el kernel compilado con los nuevos archivos, logrando el objetivo de la iteración. Sin embargo, se observó un problema en el código de selección de núcleos de la CPU en el scheduler modelado con la red de Petri. Este nuevo código modificaba el comportamiento original del scheduler **4BSD**, ignorando la afinidad de los hilos (flags `td_pinned`, `TDF_BOUND` y `TSF_AFFINITY`).

Debido a esto, se decidió regresar al esquema original de selección de núcleos, respetando la afinidad de los hilos, pero tomando las decisiones basadas en el modelo de la red de Petri. Durante este proceso, se experimentaron **kernel panics** de manera constante, por lo que se identificó que el siguiente paso sería resolver este problema.


## Segunda iteración 📋

Solucionar el problema relacionado con el escenario donde el nuevo 
modelo de scheduler ignoraba la afinidad de los procesos a algún 
núcleo de la CPU.

*COMPLICACIÓN*:  cada vez que se desea probar algún cambio se debe recompilar el
kernel. Si este cambio produce un kernel panic, el sistema se debe reiniciar y el nuevo
kernel queda inutilizable. Es por esto que se generó un kernel sano para utilizar cada
vez que el sistema se rompa, y se *duplicó* la imagen de FreeBSD para levantar otra
máquina virtual y poder depurar el kernel de manera online.

### Implementación

Se procedió a depurar el sistema para identificar la causa de los constantes *kernel panics* observados. Se determinó que los *kernel panics* ocurrían cuando el modelo original asignaba un hilo a la cola del último núcleo de la CPU en el que se había ejecutado. Sin embargo, el *scheduler* basado en la red de Petri detectaba que esa cola no estaba disponible y reasignaba el hilo a otra.

Al profundizar en la investigación, se descubrió que el *scheduler* debe garantizar que un hilo *pinned* (cuando el sistema operativo asigna permanentemente un hilo a un núcleo particular, sin permitir su migración a otros núcleos) sea ejecutado exclusivamente en la misma CPU en la que se encontraba al momento de la llamada a `sched_pin`.

Se comprendió que, en el caso de un hilo asociado a un núcleo específico de la CPU, se debe ignorar si la transición para encolar en dicho núcleo está sensibilizada. Para solucionar esto, se modificó la red de Petri agregando una nueva transición, *TRAN_ADDTOQUEUE_PINNED*. Esta nueva transición es similar a *TRAN_ADDTOQUEUE*, pero con la diferencia de que no está inhibida cuando hay otros hilos en la cola del núcleo.



<p align="center">
    <figure>
      <img src="img/image66.png" alt="bloques">
    </figure>
</p>


Se incorporaron los cambios al código relacionados con la definición de la red (matrices, números y nombres de transiciones en el archivo `petri_global_net.c`). Además, fue necesario modificar el archivo `sched_4bsd.c` para manejar el caso en que un hilo `td_pinned` pueda encolarse en la cola de su última CPU. La siguiente sección muestra la porción de código encargada de este propósito:


<p align="center">
    <figure>
      <img src="img/image67.png" alt="bloques">
    </figure>
</p>

## Tercera iteración 📋


Abordar la implementación de un mecanismo de scheduling de
procesos en un sistema monoprocesador multinúcleo mediante información recibida
por metadata, con monitorización en tiempo real de la carga de cada uno de los
núcleos de la CPU, implementando un mecanismo de conmutación dinámica del
estado de actividad de cada núcleo controlado por el scheduler de corto plazo 4BSD
modelado mediante la red de Petri resultante de la iteración anterior.


En FreeBSD es posible obtener estadísticas detalladas sobre el uso de los
núcleos de la CPU desglosadas para los distintos modos de ejecución de los procesos.
Estos modos incluyen USER (usuario), SYS (sistema), INTR (interrupciones), NICE
(prioridad ajustada) y IDLE (inactividad). Estas métricas proporcionan una visión integral del rendimiento del sistema, permitiendo un análisis preciso de cómo se
distribuye la carga de trabajo entre los diferentes modos de ejecución, lo que resulta
fundamental para optimizar el desempeño y la eficiencia del sistema. Como primer
acercamiento, optamos por medir la carga causada por los procesos de usuario.

Se comenzó con un módulo de kernel básico para introducirse en el desarrollo
de los mismos, y de a poco se le incorporaron utilidades hasta dividirlo en 2 módulos
separados con tareas bien diferenciadas: uno para la recopilación de estadísticas
referidas exclusivamente a cada núcleo de la CPU (`cpu_stats.c`) y el otro para la
recopilación de estadísticas de los hilos y procesos (`thread_stats.c`). Cada uno de
estos módulos posee un archivo makefile para su compilación y para ofrecer una fácil
carga y descarga de los mismos en el kernel del sistema operativo.

Si bien los archivos de log eran muy completos y útiles, su tamaño crecía
rápidamente al tener tanto detalle y esto no sólo consumía más tiempo de cálculo
para los porcentajes y segundos y la escritura, sino que además dificultaba la
búsqueda de información dentro del archivo a nivel de kernel, por lo que se decidió
darle un nuevo formato menos verboso, reducido en cuanto a preservación de las
estadísticas en formato de ticks únicamente, pero que igualmente sea intuitivo.

<p align="center">
    <figure>
      <img src="img/image77.png" alt="bloques">
    </figure>
</p>



En la salida de comandos como `top`, los términos **nice**, **system**, **idle** e **interrupt** indican diferentes categorías de uso del procesador (CPU). Aquí está la descripción de cada uno:

1. **User (user mode)**
   - Tiempo que la CPU dedica a ejecutar procesos en modo usuario (no privilegiado).
   - Incluye aplicaciones y procesos normales que no requieren acceso al hardware o funciones del núcleo del sistema operativo.

2. **Nice**
   - Tiempo que la CPU dedica a procesos en modo usuario que tienen un valor de *nice* (prioridad baja).
   - El valor *nice* ajusta la prioridad de los procesos:
     - Procesos con prioridad baja (*nice* alto) consumirán menos CPU.
     - Procesos con prioridad estándar tienen *nice* igual a 0.

3. **System (system mode)**
   - Tiempo que la CPU dedica a ejecutar procesos en modo kernel.
   - Incluye tareas que requieren acceso al núcleo del sistema operativo, como:
     - Controladores de dispositivos.
     - Llamadas al sistema.

4. **Interrupt**
   - Tiempo que la CPU pasa manejando interrupciones de hardware.
   - Las interrupciones son señales del hardware que requieren atención inmediata del procesador, por ejemplo:
     - Un dispositivo solicitando servicio o datos.

5. **Idle**
   - Tiempo que la CPU permanece inactiva porque no hay procesos que necesiten ejecución.
   - Una CPU al 100% en *idle* indica que no hay trabajo pendiente.



Hubo que adoptar también un criterio para clasificar la carga del sistema.
Para esto se partió de mediciones sin ninguna carga adicional, obteniendo unas
estadísticas de un 75% para procesos IDLE y un 25% para procesos SYS. se decidió escalar en la carga del sistema con
procesos USER mediante el comando de pruebas stress para simular procesos de
carga intensiva, y un script custom que lance procesos sencillos que simulen carga en
la CPU:

<p align="center">
    <figure>
      <img src="img/image78.png" alt="bloques">
    </figure>
</p>

Con estas estadísticas tenidas en cuenta, tomamos la siguiente escala de
referencia para identificar la intensidad del consumo de recursos de la CPU en el
sistema:

<p align="center">
    <figure>
      <img src="img/image80.png" alt="bloques">
    </figure>
</p>


## Cuarta iteración 📋

El proyecto **Optimización del planificador a corto plazo con redes de Petri**
aporta dos funcionalidades al kernel: la capacidad de encender/apagar los núcleos de
la CPU del sistema, y la posibilidad de que un hilo pueda monopolizar un núcleo de la
CPU, sirviéndose del modelo de scheduler con red de Petri trabajado hasta el
momento.

### Implementación 

Para comenzar a incorporar el módulo de encendido/apagado de núcleos, se
agregaron las plazas y transiciones correspondientes a la red:

<p align="center">
    <figure>
      <img src="img/image81.png" alt="bloques">
    </figure>
</p>

Se hizo un pequeño módulo que llama a la función toggle_active_cpu, la cual conmuta
el estado de actividad del núcleo de la CPU que se le indique (exceptuando el núcleo
0) y se pudo ver cómo efectivamente los núcleos dejan de tener carga de procesos al
deshabilitarlos hasta que se los reincorpora.

El módulo revisado presentó un problema en la transición THROW, encargada de equilibrar el encolado de hilos en núcleos mediante un algoritmo round-robin. En un sistema de cuatro núcleos, esta transición asegura que un núcleo no pueda encolar más hilos hasta que los demás también lo hagan, disparándose al retirar tokens que inhiben el encolado.

Sin embargo, se detectó que un núcleo en estado SUSPENDED no agrega tokens en la plaza necesaria para disparar THROW, lo que bloquea el sistema, ya que ningún núcleo puede encolar hilos. Para resolverlo, se implementó una estructura OR en la red, permitiendo que THROW se dispare cuando todos los núcleos hayan encolado hilos o estén en estado SUSPENDED.

<p align="center">
    <figure>
      <img src="img/image82.png" alt="bloques">
    </figure>
</p>

Al disparar **TRAN_SUSPEND_PROC**, se activa automáticamente **TRAN_SUSPENDED_PROC**, llenando las plazas **PLACE_SUSPENDED** (indicando el estado suspendido) y **PLACE_QUEUED_OR_SUSP** (habilitando el equilibrado de **THROW**). Esto permite que **THROW** recupere su función, equilibrando el encolado incluso con núcleos suspendidos.

#### Cambios realizados en el código
1. **Actualización de matrices de incidencia e inhibición.**
2. **Incorporación de nuevas transiciones automáticas** para manejar núcleos encolados o suspendidos.
3. Ajustes en **toggle_active_cpu** para validar el modo SMP y evitar *kernel panics*.
4. Inclusión de funciones **turn_on_cpu** y **turn_off_cpu** para mayor control del estado de los núcleos.

#### Modificaciones en el módulo de monopolización de CPU
- Se cambió la lógica para que **procesos (y sus hilos)** adquieran núcleos, en lugar de hilos individuales, utilizando la metadata de procesos.
- Se añadieron las funciones:
  - **monopolize_cpu**: Wrapper de **toggle_pin_cpu_to_proc**.
  - **release_cpu**: Wrapper de **toggle_pin_cpu_to_proc**.
- Ajustes realizados en los archivos relacionados:
  - `sched_4bsd.c`
  - `sched_petri.c`
  - `sched_petri.h`
  - `petri_global_net.c`

## Quinta iteración 📋

Procesamiento de las estadísticas obtenidas y la toma de decisiones en base a las mismas teniendo correctamente
adaptado el módulo que controla el cambio de estado de actividad de los núcleos de la CPU.

Se procedió a parsear los strings y obtener los datos de interés para poder empezar a hacer cálculos que nos ayuden en la toma de decisiones.

Para poder medir la carga del sistema y las necesidades de los procesos para manejar el estado de actividad de los núcleos, fue necesario obtener lo siguiente:


#### 1. Carga de Usuario del Sistema
Se utiliza la métrica de "ticks" para medir el tiempo que cada núcleo pasa ejecutando procesos de usuario. En FreeBSD, esta información se puede extraer con `sysctl`.

**Ejemplo:**
Supongamos que cada núcleo registra ticks en intervalos de tiempo *(Un tick es una unidad básica de tiempo utilizada por el sistema operativo para medir intervalos de actividad en la CPU. Representa un "pulso" del temporizador del sistema)*. En un sistema con 4 núcleos:
- **Núcleo 0:** 500 ticks.
- **Núcleo 1:** 1500 ticks.
- **Núcleo 2:** 700 ticks.
- **Núcleo 3:** 200 ticks.

El núcleo 1 tiene la mayor carga de usuario (1500 ticks), mientras que el núcleo 3 es el menos cargado (200 ticks). Esto puede indicar que el núcleo 3 está menos ocupado con procesos de usuario.



#### 2. Necesidades de Cada Proceso
Los procesos pueden incluir metadata en sus ejecutables para especificar requisitos de CPU. Por ejemplo, una aplicación en tiempo real puede necesitar un núcleo reservado para garantizar que siempre tenga recursos disponibles.

**Ejemplo:**
Un sistema tiene dos procesos:
- **Proceso A:** Metadata: `"CPU=HighPriority"`.  
  Este proceso indica que necesita prioridad alta y se ejecutará en un núcleo que no esté compartido.  
- **Proceso B:** Metadata: `"CPU=LowPriority"`.  
  Este proceso puede ejecutarse en cualquier núcleo disponible.  

El sistema asigna el núcleo 0 exclusivamente al Proceso A y permite que el Proceso B comparta el núcleo 1 con otros procesos menos críticos.

**¿Ventajas de esto?**


La configuración en la que el Proceso A se ejecuta en un núcleo dedicado (no compartido) debido a su alta prioridad tiene varias ventajas, especialmente en escenarios donde la predictibilidad, el rendimiento y la latencia son críticos. A continuación, te explico las principales ventajas:

| **Ventaja**                                 | **Descripción**                                                                                     | **Escenario de Uso**                                            |
|---------------------------------------------|-----------------------------------------------------------------------------------------------------|-----------------------------------------------------------------|
| **Baja latencia y alta predictibilidad**    | Acceso exclusivo al núcleo, sin interrupciones por cambios de contexto.                            | Sistemas en tiempo real, multimedia.                           |
| **Máximo rendimiento del núcleo**           | Aprovecha todo el poder del núcleo sin competencia por recursos.                                   | Simulaciones, procesamiento de imágenes, machine learning.     |
| **Reducción de overhead de cambios de contexto** | Minimiza la pérdida de tiempo causada por alternar entre procesos.                                | Servidores de bases de datos, streaming de datos.              |
| **Mayor consistencia en el rendimiento**    | Métricas de rendimiento predecibles y constantes.                                                  | Redes críticas, sistemas financieros.                          |
| **Evita interferencias por contención de recursos** | Elimina competencia por caché y otros recursos compartidos.                                       | Algoritmos intensivos en datos, procesamiento en caché.         |
| **Mejora en aplicaciones sensibles al tiempo** | Garantiza cumplimiento de restricciones de tiempo crítico.                                         | Robótica, conducción autónoma, sistemas embebidos.             |




#### 3. Núcleo Más Ocioso
Determinar el núcleo más ocioso implica analizar los ticks y otras métricas para identificar cuál está realizando menos trabajo. Esto es útil para tomar decisiones de apagado dinámico.

**Ejemplo:**
En un sistema con 4 núcleos, los ticks (tiempo en diferentes modos) podrían verse así:
- **Núcleo 0:** 1000 ticks de usuario, 500 ticks de sistema.
- **Núcleo 1:** 1500 ticks de usuario, 700 ticks de sistema.
- **Núcleo 2:** 200 ticks de usuario, 100 ticks de sistema.
- **Núcleo 3:** 800 ticks de usuario, 400 ticks de sistema.

El núcleo 2 tiene la menor actividad general (200 ticks de usuario y 100 ticks de sistema). Basado en esta información, el módulo decide apagar el núcleo 2 para ahorrar energía.



#### Conclusión
Estos ejemplos ilustran cómo cada métrica contribuye a la toma de decisiones:
1. **Carga de usuario del sistema** ayuda a identificar el trabajo actual en cada núcleo.  
2. **Necesidades de cada proceso** permite priorizar recursos según las demandas específicas.  
3. **Núcleo más ocioso** es clave para optimizar el uso de energía y liberar recursos.  

### Implementación

#### **Callback_load**
Función principal llamada cada 30 segundos para gestionar la carga del sistema y el estado de los núcleos.

##### **Pasos principales:**
1. **Obtención de estadísticas:** Se recopilan datos de los módulos `cpu_stats` y `thread_stats`.

2. **Gestión de carga:**
   - Si el nivel de carga es **menor a LOAD_NORMAL** (LOAD_IDLE o LOAD_LOW):
     - Identificar el núcleo más ocioso (calculando ticks en modo IDLE).
     - Apagarlo, con las siguientes consideraciones:
       - **Delay de acción:** Garantiza consistencia para evitar apagar núcleos por error.
       - **Procesos monopolizadores:** Si existen, no se pueden suspender núcleos.
       - **Límite de núcleos apagados:** Previene que el sistema quede inutilizable por falta de recursos.

   - Si el nivel de carga es **mayor o igual a LOAD_NORMAL**:
     - Encender cualquier núcleo apagado previamente.
     - Reducir el tiempo de chequeo de carga para reaccionar más rápido a necesidades futuras.

3. **Cálculo de métricas:**
   - **Carga de usuario:** 
     - Calcular el porcentaje de uso de cada núcleo.
     - Promediar para asignar uno de los niveles: LOAD_IDLE, LOAD_LOW, LOAD_NORMAL, LOAD_HIGH, LOAD_INTENSE o LOAD_SEVERE.
   - **Necesidades de los procesos:**
     - Usar etiquetas de procesos (`LOWPERF`, `STANDARD`, `HIGHPERF`, `CRITICAL`) y un sistema de puntuación (0 a 100).
     - Asignar uno de los niveles de carga basados en el puntaje.

4. **Toma de decisiones:**
   - Se da **mayor peso a la carga de usuario** (realidad actual de los núcleos) sobre las necesidades de los procesos (requerimientos teóricos) para encendido o apagado de núcleos.



#### **Callback_monopolization**
Función principal llamada cada segundo para gestionar el monopolio de núcleos.

##### **Pasos principales:**
1. **Obtención de información:** Consultar el módulo encargado de recopilar datos sobre monopolización de núcleos.

2. **Estado de monopolización:** Consultar la red de Petri para determinar el estado actual de los núcleos monopolizados.

3. **Liberación de núcleos:**
   - Verificar si los núcleos monopolizados deben liberarse por:
     - No ser requeridos.
     - Existencia de un proceso prioritario que necesita monopolizar.

4. **Asignación de núcleos:**
   - Asignar núcleos disponibles a procesos prioritarios.
   - **Límite de núcleos monopolizables:** Controla cuántos núcleos pueden ser dedicados exclusivamente.



### **Conclusión**
El diseño modular y basado en callbacks permite un equilibrio dinámico entre eficiencia energética y rendimiento. Los mecanismos de delay, prioridades y límites aseguran estabilidad en las decisiones tomadas.


#### **Niveles de carga (LOAD)**

 Los niveles de carga (**LOAD_IDLE**, **LOAD_LOW**, etc.) se calculan generalmente para cada núcleo (**core**) del procesador. Esto permite tomar decisiones específicas sobre el estado de cada núcleo, como apagar, encender, o asignar procesos, dependiendo de su nivel de actividad y las necesidades del sistema. También es posible calcular un nivel general del sistema como promedio o agregado de todos los núcleos para decisiones globales.


| **Nivel de Carga**   | **Descripción**                                                                 |
|-----------------------|---------------------------------------------------------------------------------|
| **LOAD_IDLE**         | El sistema está prácticamente inactivo. Los núcleos están en su mayoría en estado `IDLE`. |
| **LOAD_LOW**          | Baja carga. Hay algo de actividad, pero no representa un uso significativo del sistema. |
| **LOAD_NORMAL**       | Carga moderada. El sistema está en un estado típico de funcionamiento.         |
| **LOAD_HIGH**         | Alta carga. Los núcleos están ocupados con procesos demandantes.               |
| **LOAD_INTENSE**      | Carga intensa. Los núcleos están cerca de su capacidad máxima de procesamiento. |
| **LOAD_SEVERE**       | Sobrecarga. El sistema está saturado, lo que podría afectar el rendimiento.    |



#### **¿Qué es la Monopolización de Núcleos?**

Se refiere a la asignación exclusiva de un núcleo a un proceso específico. Esto implica que un núcleo es dedicado exclusivamente a un proceso, sin compartir su capacidad de procesamiento con otros procesos en el sistema. 



##### **Detalles sobre la Monopolización:**

1. **Uso exclusivo:**
   - Cuando un proceso monopoliza un núcleo, tiene acceso total a sus recursos de procesamiento.
   - Otros procesos no pueden ser programados en ese núcleo mientras dure la monopolización.

2. **Propósitos:**
   - **Procesos de alta prioridad:** Procesos críticos o de tiempo real pueden necesitar un núcleo dedicado para garantizar que cumplan con sus requisitos de desempeño.
   - **Reducción de latencia:** Evita interrupciones por la planificación de otros procesos, mejorando el tiempo de respuesta.

3. **Control:**
   - El sistema operativo evalúa las condiciones para permitir la monopolización, como la carga general del sistema y las prioridades de otros procesos.
   - Si otro proceso de mayor prioridad requiere un núcleo, la monopolización puede revocarse.

4. **Limitaciones:**
   - La cantidad de núcleos que pueden ser monopolizados generalmente está limitada para evitar un uso ineficiente de los recursos del sistema.
   - El sistema operativo debe equilibrar el rendimiento general con las necesidades de los procesos individuales.



### **Ejemplo práctico:**
Un proceso de renderizado de gráficos en tiempo real puede monopolizar un núcleo para evitar retrasos debido a interrupciones causadas por procesos de menor prioridad. Durante este tiempo:
- El núcleo trabaja exclusivamente para este proceso.
- Otros procesos son reasignados a núcleos disponibles.

### RESULTADOS


Se logró un primer acercamiento a la gestión de núcleos en base a estadísticas
en tiempo real del sistema e información proporcionada por los procesos sobre sus
necesidades.

NOTA: `dmesg`: Muestra los mensajes del kernel del sistema, que incluyen información sobre el arranque del sistema, los controladores, dispositivos y otros eventos relevantes.






## Octava iteración 📋

El proyecto Comunicación desde espacio de usuario a espacio de kernel
mediante metadatos en archivos ELF permite a los procesos darle información sobre
ellos al kernel. Esto se logra a través de la inserción de metadata en sus ejecutables
mediante el uso de plugins desarrollados para GCC y CLang.

---

# 04-PI-Cabrera 💫

## Como es el kernel de freebsd?



El kernel posee un diseño modular, lo que significa que se pueden cargar o descargar partes de él, convirtiéndose estas partes en sistemas activados o desactivados según sea necesario. Esto es muy útil porque existen multitud de hardware extraíbles, permitiendo cargar un módulo del kernel cuando se inserta un hardware, sin necesidad de tenerlo en memoria cuando no se usa. Además, no es necesario recompilar todo el kernel para añadir nuevas características o funcionalidades, ni reiniciar el sistema para aplicar estos cambios. Esta característica de modularidad no implica que el núcleo sea un **micro kernel**, ya que el kernel de Prime SD es **monolítico**, pero se le ha añadido la capacidad de cargar dinámicamente módulos, lo que permite comunicarse en tiempo de ejecución con el hardware, de forma similar a los servicios de un micro kernel, aunque los módulos se ejecutan en el espacio de memoria del kernel.

<p align="center">
    <figure>
      <img src="img/image62.png" alt="bloques">
    </figure>
</p>

La modularidad puede afectar el rendimiento del sistema, su comportamiento o la compatibilidad con el hardware, ya que hace que el núcleo ocupe menos espacio en memoria. También permite agregar nuevas funcionalidades y drivers para aumentar la compatibilidad con hardware diverso, sin necesidad de recompilar el kernel. Sin embargo, es posible que un kernel sea más rápido si los módulos se integran directamente en su código fuente y se recompilan.

Los módulos que forman parte del sistema base de Prime SD están ubicados en el directorio `/boot/kernel/`, mientras que los módulos independientes o de terceros, como los instalados a través de los ports o paquetes, se encuentran en `/boot/modules/`. Generalmente, el archivo de un módulo lleva el nombre de la funcionalidad que contiene y tiene la extensión `.ko`. Por ejemplo, Prime SD requiere el módulo `wlan.ko` para manejar la capa de redes inalámbricas. Los módulos pueden cargarse y descargarse en tiempo de ejecución. Para cargar el módulo **ZFS**, se utiliza la herramienta `kldload` con el nombre del módulo o su ruta completa: `kldload /boot/kernel/wlan.ko`


La herramienta `kldstat` permite mostrar los módulos cargados en el kernel, comenzando con el propio kernel, que siempre está en memoria, seguido de otros módulos.

<p align="center">
    <figure>
      <img src="img/image63.png" alt="bloques">
    </figure>
</p>

Además, `kldstat` muestra el ID del módulo, la dirección de memoria utilizada y el tamaño del módulo. Se puede usar `kldstat -h` para obtener una representación más legible del tamaño. Cada módulo cargado puede depender de otros módulos que deben estar previamente cargados para su correcto funcionamiento.













## Compilación del Kernel en FreeBSD

El kernel es la interfaz crucial entre el software y el hardware, permitiendo aprovechar eficientemente los recursos del sistema.


<p align="center">
    <figure>
      <img src="img/image46.png" alt="bloques">
    </figure>

</p>




### ¿Por qué usar un kernel personalizado?

Un kernel personalizado ofrece varias ventajas clave, tales como:

- Ajuste preciso al hardware específico que se va a utilizar.
- Creación o adición de nuevos drivers, lo que permite funcionalidades adicionales y modifica el comportamiento del sistema.
- Reducción del tamaño del kernel para equipos con recursos limitados.
- Mejora en el rendimiento general del sistema.

### Kernel Genérico vs Kernel Personalizado

**Kernel Genérico:** Es el kernel predeterminado de FreeBSD, diseñado para soportar una amplia variedad de hardware.


 | **KERNEL PERSONAL**                                       | **KERNEL GENÉRICO**                                   |
|-----------------------------------------------------------|-------------------------------------------------------|
| Agregar nuevos drivers                                    | Gran cantidad de drivers                              |
| Eliminar drivers no usados                                | Funciones básicas                                     |
| Habilitar funciones                                       | No está optimizado                                    |
| Deshabilitar opciones que no usas                         |                                                       |
| Optimizar para mejor rendimiento                          |                                                       |
| Aprender a compilar                                       |                                                       |

#### ¿Por qué personalizar el kernel si el genérico funciona?

Aunque el kernel genérico de FreeBSD suele funcionar bien, personalizar el kernel ofrece varias ventajas clave:

- **Agregar soporte para hardware no incluido**: Puedes añadir drivers específicos para hardware que no está soportado en el kernel genérico.
- **Eliminar drivers innecesarios**: Eliminar soporte para hardware que no utilizas optimiza el uso de recursos y reduce el tamaño del kernel.
- **Habilitar funciones adicionales**: Puedes activar funcionalidades que no están habilitadas en el kernel genérico.
- **Deshabilitar funciones no deseadas**: Desactivar funciones que no necesitas puede mejorar la seguridad y el rendimiento.

Por ejemplo, compilar un kernel para un servidor será muy diferente a hacerlo para un sistema con entorno gráfico. No es lo mismo compilar un kernel para una computadora con 1 GB de RAM y un CPU de un solo núcleo que para una máquina con 64 GB de RAM, un CPU de 8 núcleos y 16 hilos. Adaptar el kernel a tus necesidades permite maximizar el rendimiento y la eficiencia de los recursos disponibles.

#### que necesitamos para compilar el kernel personalizado?

Necesitamos el código fuente en el sistema. 

<p align="center">
    <figure>
      <img src="img/image47.png" alt="bloques">
    </figure>

</p>

 **Consideraciones al Personalizar el Kernel en FreeBSD**

1. **Configurar `freebsd-update` en la rama RELEASE**: Asegúrate de configurarlo para que no sobrescriba el kernel personalizado, ya que FreeBSD integra el kernel con las funcionalidades y librerías del sistema.
   
2. **Leer el archivo `/usr/src/UPDATING`**: Este archivo contiene información crucial sobre los cambios aplicados en el código fuente. Es importante revisarlo antes de compilar.

3. **Compilar tanto el kernel como el sistema (`world`)**: Si trabajas en las ramas STABLE o CURRENT, deberás compilar ambos cuando realices actualizaciones.

4. **Hacer una copia de seguridad del kernel**: Guarda una copia del kernel genérico o el último kernel que funcionó correctamente antes de realizar modificaciones.

5. **Conservar los archivos de configuración del kernel personalizado**: Estos archivos te permitirán compilar un nuevo kernel con las mismas configuraciones que el kernel anterior.

6. **Compilar varias veces**: Es posible que necesites compilar el kernel varias veces hasta obtener una versión optimizada para tu sistema.

7. **Aprender las diferentes opciones del kernel**: Familiarízate con las opciones disponibles en el kernel para aprovechar al máximo la personalización y optimización.



### Compilar un Kernel personalizado en la rama `RELEASE`

La rama `RELEASE` es la que contiene la herramienta `freebsd-update`, la cual nos permite actualizar el sistema operativo a nivel de parches (nueva versión) utilizando paquetes precompilados.

Al actualizar, hay cuatro áreas principales que se pueden modificar:

1. **Kernel**
2. **World o Espacio de Usuario** (utilidades/librerías)
3. **Doc** (documentación del sistema)
4. **Código fuente de FreeBSD**

Si deseamos modificar el kernel, este debe estar sincronizado con la misma versión de `world` y del código fuente. Para verificar la versión de FreeBSD que estamos utilizando, podemos usar el comando:

```bash
freebsd-version -k
```

Si queremos saber el espacio de usuario o World:

```bash
freebsd-version -u
```

<p align="center">
    <figure>
      <img src="img/image48.png" alt="bloques">
    </figure>

</p>

### Instalación y actualización de FreeBSD

Cuando se instala el sistema operativo FreeBSD por primera vez, tenemos la opción de instalar también el código fuente, que se ubica en `usr/src`. Este código se va actualizando con cada `UPDATE`. Sin embargo, no siempre las versiones del kernel y del sistema coinciden, ya que en muchos casos solo se actualiza una parte del sistema.

#### ¿Qué ocurre al actualizar el sistema con un kernel personalizado?

Si combinamos el kernel de mi versión personalizada y luego actualizamos el sistema, pueden ocurrir algunos problemas:

1. **Sobreescritura del kernel**: El kernel precompilado podría sobrescribir mi kernel personalizado.
2. **Desincronización**: Si FreeBSD está configurado para no actualizar el núcleo (`kernel`), podría romperse la sincronización entre el kernel y los archivos del sistema, lo que puede generar errores.

Vamos a explicar esto con un ejemplo práctico. Supongamos que estamos en un sistema con una nueva instalación de FreeBSD de la rama `release` y que el código fuente ya está instalado.

#### Directorio del kernel en FreeBSD

El kernel por defecto siempre se instala en la carpeta `/boot/kernel`. Cuando compilamos e instalamos un nuevo kernel, el directorio actual `/boot/kernel` se renombra y se reserva, dejando `/boot/kernel` para el nuevo núcleo. El cargador de arranque BTX busca automáticamente en la carpeta `/boot` todos los kernels instalados, permitiéndonos elegir con cuál iniciar. Sin embargo, por defecto siempre arrancará con el kernel ubicado en `/boot/kernel`.

#### Comprobación del tamaño del kernel

Podemos verificar el tamaño del kernel que viene con la versión en uso mediante el comando:

`du -sh /boot/kernel`

Esto nos mostrará el tamaño total en megabytes junto con los módulos que están en la misma carpeta. Si deseamos ver el tamaño exacto del archivo del kernel, podemos usar:

`du -sh /boot/kernel/kernel`

En este caso, comprobamos que tiene un tamaño de 15 megabytes.

<p align="center">
  <figure>
    <img src="img/image49.png" alt="bloques">
  </figure>
</p>


#### Revisión del archivo UPDATING

Leer el archivo `/usr/src/UPDATING` para verificar si existe alguna indicación especial para compilar el kernel. Vemos que **NO** se informa de nada en particular, tampoco se menciona que FreeBSD ha cambiado el compilador de `gcc` a `clang`. Al final del archivo también se detallan los procedimientos para compilar el kernel o instalarlo, así como para recopilar todo el sistema y verificar su correcto funcionamiento.



Llegados a este punto, tenemos dos opciones:

1. **Hacer una copia del kernel actual (genérico)** para asegurarnos de que, si el nuevo kernel falla, podamos usar el kernel que ya funciona.
2. **Instalar el nuevo kernel en una carpeta nueva** y arrancar FreeBSD con él para evaluar su comportamiento.

Si optamos por hacer una copia del kernel actual, podemos usar el siguiente comando:  
`cp -a /boot/kernel /boot/kernel-14.1-RELEASE-GENERIC`

De esta manera, identificamos el kernel genérico de la versión 14.1 como una copia de seguridad, ya que este es el que viene por defecto.

Para mayor seguridad, vamos a usar la segunda opción e instalaremos el nuevo kernel en una carpeta diferente.


Antes de compilar un kernel, es muy recomendable conocer el hardware de nuestro equipo: la marca, el modelo de los componentes y los dispositivos integrados en la placa madre (mainboard). Esto nos permitirá determinar con precisión si el hardware es compatible con FreeBSD o si necesitamos incluir algún driver adicional en el kernel antes de compilarlo.

El archivo ubicado en `/var/run/dmesg.boot` es un buen punto de partida para obtener información sobre el hardware del equipo.



Dicho esto, nos desplazamos al directorio `cd /usr/src/sys/amd64/conf`. Una vez dentro de este directorio, podemos ver su contenido, donde encontramos varios ficheros que contienen configuraciones para el kernel. 

<p align="center">
  <figure>
    <img src="img/image50.png" alt="bloques">
  </figure>
</p>

FreeBSD no cuenta con una utilidad gráfica ni con un sistema basado en menús para configurar el kernel; solo utiliza archivos de texto donde se incluyen líneas con etiquetas y cadenas que definen la configuración del núcleo.

Si examinamos el contenido de este directorio, veremos el archivo *GENERIC*, que es el archivo utilizado por el equipo de FreeBSD para compilar el kernel de la versión que estamos utilizando. Este archivo se denomina *GENERIC* porque es el predeterminado. Además, incluye el fichero *DEFAULTS*, que contiene un listado de opciones y dispositivos predeterminados de la plataforma. 

También encontramos el archivo *MINIMAL*, que contiene una configuración muy reducida, en la que todo lo que sea posible se carga como un módulo. Por último, está el archivo *NOTES*, que contiene una extensa lista de todas las opciones posibles que podemos utilizar para la plataforma específica.


Otro archivo importante es *NOTES*, ubicado en `less /usr/src/sys/conf/NOTES`. Este archivo contiene todas las características del kernel que son independientes de la plataforma. 

Los archivos *NOTES* incluyen descripciones detalladas y una gran cantidad de información sobre las opciones y dispositivos que podemos agregar al kernel.







Vamos a trabajar con las opciones de configuración del archivo *GENERIC*. Pero antes de ver su contenido, crearemos una copia con el nombre que queramos utilizando el siguiente comando:

`cp GENERIC KERNELOPTIONS`

Este será el archivo que usaré para configurar el nuevo kernel. Lo abrimos con un editor:

`vi KERNELOPTIONS`

<p align="center">
  <figure>
    <img src="img/image51.png" alt="bloques">
  </figure>
</p>       

Observamos algunas etiquetas, como `cpu`, que le indica al kernel qué tipo de procesador admitirá. En mi caso, *HAMMER* es para todo el hardware de la plataforma amd64 o m64t. La etiqueta `IDENT` proporciona un nombre de identificación del kernel; en mi caso, voy a cambiar *GENERIC* por *KERNELCUSTOM01*, con una numeración (01) para incrementar el número a medida que compile distintos kernels.

<p align="center">
  <figure>
    <img src="img/image52.png" alt="bloques">
  </figure>
</p>

La etiqueta `makeoptions` proporciona instrucciones de compilación a la herramienta `make`, y si nos fijamos en la parte derecha, nos ofrece una breve descripción de lo que hace cada opción. Por ejemplo, `DEBUG=-g` compila el kernel con símbolos de depuración.

La siguiente etiqueta que podemos apreciar es `option`, que se refiere a funciones del kernel que requieren hardware en particular. Estas son tecnologías o características que el kernel puede utilizar para su funcionamiento. Por ejemplo, el planificador del kernel, que se llama *ULE*, lo modificaré a *4BSD* para el desarrollo de este trabajo.

Además, podemos desactivar la compatibilidad con FreeBSD hasta la versión 11. En este caso, la mayoría del software estará compilado para al menos versiones de FreeBSD superiores a la 9. Estas opciones deshabilitadas pueden aumentar el rendimiento del sistema, pero también corremos el riesgo de no poder ejecutar algunas aplicaciones antiguas, por esta razón no las deshabilitaré.

<p align="center">
  <figure>
    <img src="img/image53.png" alt="bloques">
  </figure>
</p>

Ahora vemos otra etiqueta llamada `device` que nos proporciona controladores de dispositivos o drivers al kernel, evitando que se carguen como módulos. Así podemos deshabilitar todas aquellas opciones que no vayamos a usar, reduciendo el tamaño del kernel y, potencialmente, mejorando el rendimiento del sistema. Por ejemplo, si no tenemos unidades de disquete, podemos comentar el controlador para que no lo incluya, o quitar controladores hasta que solo tengamos los necesarios.

La configuración del kernel es muy personal, y cada usuario puede activar o desactivar distintas opciones o drivers según su hardware o sus necesidades.

Guardamos los cambios, y ahora veamos cómo podemos agregar más ficheros a la configuración, en caso de que nos interese dividir opciones entre distintos archivos. Esto es muy útil cuando queremos separar opciones concretas de las opciones generales.

Por ejemplo, voy a crear el fichero con `vi KERNELCUSTOM01` y voy a agregar la línea `include KERNELOPTIONS`. Esta línea nos permite incluir todas las opciones que hemos modificado en el archivo anterior.

#### ¿Qué otras cosas podría hacer?

Podemos agregar más líneas de opciones. Por ejemplo, podríamos incluir `options ZFS` para incluir el soporte del sistema de archivos ZFS en el kernel, o también `option DEVICE_POLLING`, que permite sondear dispositivos, reduciendo la sobrecarga de interrupciones y mejorando el rendimiento del sistema. También podemos agregar `option HZ=1000`, que regula la frecuencia en hercios del temporizador para el manejo de interrupciones. Un valor más bajo puede aumentar el rendimiento, pero también podría tener efectos perjudiciales.

Vamos a probar esta configuración donde hemos eliminado componentes y funciones que no vamos a usar, y hemos añadido algunas otras que pueden ser útiles. Luego, compilaremos el kernel por primera vez para ver cómo funciona.

<p align="center">
  <figure>
    <img src="img/image54.png" alt="bloques">
  </figure>
</p>

Como vemos en la salida del comando, hemos generado dos archivos. Ahora pasamos a compilar el kernel con el comando `time make KERNCONF=KERNELCUSTOM01 KODIR=/boot/kernelcustom01 buildkernel installkernel`. Debemos estar en el directorio `/usr/src`.

El comando tiene el propósito de construir e instalar un kernel personalizado en un sistema basado en FreeBSD. A continuación, se desglosan sus partes:

- **`time`**: Mide y muestra cuánto tiempo tarda en ejecutarse el comando completo que sigue. Es útil para saber el tiempo de compilación e instalación del kernel.
  
- **`make`**: Ejecuta las instrucciones de construcción de un proyecto. En este caso, se usa para construir el kernel de FreeBSD con las configuraciones especificadas.

- **`KERNCONF=KERNELCUSTOM01`**: Indica el archivo de configuración del kernel a utilizar, en este caso `KERNELCUSTOM01`, que contiene las configuraciones específicas del kernel que estás construyendo.

- **`KODIR=/boot/kernelcustom01`**: Especifica el directorio donde se instalará el nuevo kernel. En este caso, se instalará en `/boot/kernelcustom01` en lugar del directorio por defecto (`/boot/kernel`), lo que permite tener múltiples versiones de kernel.

- **`buildkernel`**: Construye el kernel basado en el archivo de configuración definido. Este proceso compila el código fuente del kernel.

- **`installkernel`**: Instala el kernel compilado en el directorio especificado por `KODIR`. En este caso, instala el kernel en `/boot/kernelcustom01`.




<p align="center">
  <figure>
    <img src="img/image55.png" alt="bloques">
  </figure>
</p>




Una vez acabada la compilación, vemos en la salida del comando `time` que demoró 1560.64 segundos en total, lo que es equivalente a 26 minutos y 0.64 segundos. Si revisamos el contenido del directorio `/boot`, vemos que nos ha generado una nueva carpeta con el nombre que le pusimos al kernel.

<p align="center">
  <figure>
    <img src="img/image56.png" alt="bloques">
  </figure>
</p>

Ahora necesitamos reiniciar el sistema para iniciar con el nuevo kernel y comprobar que funciona correctamente, sin provocar ningún *kernel panic* o errores. Lo podemos hacer de dos formas:

1. Reiniciando el sistema y eligiendo el nuevo kernel en el cargador de arranque **BTX**.
2. Ejecutando el comando `nextboot -k kernelcustom01`, que nos permite ejecutar una sola vez el kernel que le indiquemos. Cuando reiniciemos el sistema, se cargará el kernel personalizado, pero en el siguiente reinicio volverá a usar el antiguo kernel. Esto es muy útil cuando estamos probando nuestros núcleos sin tener que modificar permanentemente la opción del kernel en el cargador **BTX**.

Vamos a reiniciar el sistema, y si observamos el cargador de arranque **BTX**, veremos que el comando ha hecho su trabajo, ya que está eligiendo el kernel personalizado.

<p align="center">
  <figure>
    <img src="img/image57.png" alt="bloques">
  </figure>
</p>

<p align="center">
  <figure>
    <img src="img/image58.png" alt="bloques">
  </figure>
</p>

<p align="center">
  <figure>
    <img src="img/image59.png" alt="bloques">
  </figure>
</p>

El comando `uname -a` muestra que actualmente estamos utilizando el kernel personalizado llamado `KERNELCUSTOM01`. Aquí está el detalle relevante:

- **Sistema operativo**: FreeBSD 14.1-RELEASE-p5
- **Nombre del kernel**: `KERNELCUSTOM01`
- **Arquitectura**: amd64

Esto confirma que tu sistema está ejecutando el kernel personalizado que se configuro.


Tenemos cargado el nuevo kernel y, de momento, parece que todo va muy bien. Incluso creo que se ha iniciado más rápido que el antiguo. Ahora que ya tenemos compilado el kernel y sabemos que funciona correctamente, podemos borrar el directorio `/boot/kernel` con el comando `rm -r /boot/kernel` y copiar el directorio `kernelcustom01` a `/boot/kernel` usando `cp -a /boot/kernelcustom01/ /boot/kernel`. Así, a partir de ahora, será el núcleo predeterminado. Recordemos que tenemos una copia del antiguo kernel que hicimos al principio.

Ahora nos enfrentamos a una actualización del sistema. Si intentamos actualizar a nivel de parche con `freebsd-update fetch`, podemos observar en la salida que modifica el kernel. Si finalmente instalamos la actualización con el comando `freebsd-update install`, me instalará el nuevo kernel.

#### ¿Cómo evitamos que la actualización del sistema sobrescriba el kernel personalizado estando en la rama release?
Podemos evitar que la herramienta `freebsd-update` modifique el kernel al actualizar. Para hacerlo, debemos editar el archivo `/etc/freebsd-update.conf` y cambiar la línea de componentes, quitando la palabra `kernel`. Esto hará que la herramienta solo actualice el componente `src`, es decir, el código fuente, y también el `world`, pero no el kernel.

<p align="center">
  <figure>
    <img src="img/image60.png" alt="bloques">
  </figure>
</p>



Voy a volver a la configuración anterior a la actualización con el comando `freebsd-update rollback`, y después reiniciaremos el sistema. Ahora, al ejecutar nuevamente el comando `freebsd-update fetch`, veremos que volvemos a tener nuestro kernel personalizado, ya que hemos modificado la configuración.

Ahora podemos observar que va a actualizar todo menos el kernel, así que podemos continuar con la instalación ejecutando `freebsd-update install`. Hay que tener en cuenta que las actualizaciones a nivel de parche no siempre afectan los mismos componentes; a veces solo son parches para el kernel, otras veces solo para el `world`, y en ocasiones son parches para todos los componentes.

Nos movemos al directorio `/usr/src` y usamos el comando `make` como hicimos antes, pero esta vez no voy a usar la opción para guardar el kernel en un directorio. Prefiero que se instale en `/boot/kernel`: `make -j5 KERNCONF=KERNELCUSTOM01`.



Ahora vamos a ser nosotros quienes sobrescribamos el *KERNELGENERIC*. Una vez compilado e instalado, reiniciamos el sistema y, al ejecutar el comando `uname -v`, vemos que tenemos de nuevo nuestro kernel personalizado. Además, en la salida del comando `freebsd-version -ku`, observamos que tanto el kernel como el `world` están actualizados al mismo nivel de parche, pero con nuestro kernel personalizado y compilado.

Personalmente, no me gusta modificar el archivo `freebsd-update.conf` porque prefiero dejar que sobrescriba mi kernel personalizado cuando actualizo, y después compilar de nuevo usando el código fuente que ya ha actualizado la herramienta `freebsd-update`. Mi recomendación es actualizar siempre el sistema conforme a las instrucciones, sin modificar el archivo de configuración, y una vez finalizada la actualización, compilar nuestro kernel personalizado. Ya sea con actualizaciones a nivel de parche o con una nueva versión menor o principal, de esta forma siempre tendremos sincronía entre nuestro kernel, el `world`, y el código fuente.

Otra cosa importante es guardar los archivos de configuración que hemos generado en una ruta independiente de `/usr/src`, ya que podemos perderlos al descargarnos un código fuente nuevo. Por eso, me creo una carpeta en `home` y mi usuario, que llamaré `config_kernel`, y copio mis archivos de configuración con el comando `cp`.

<p align="center">
  <figure>
    <img src="img/image61.png" alt="bloques">
  </figure>
</p>


### Recompilación rápida e instalación de kernel de FreeBSD

Para llevar a cabo la recompilación rápida del kernel de FreeBSD, impactando solamente en aquellos módulos del sistema operativo que son alcanzados por los cambios, se recomienda ejecutar los siguientes comandos.



Recompilacion rapida: `time make NO_KERNELCLEAN=yes NO_KERNELDEPEND=yes MODULES_WITH_WORLD=yes KERNCONF=KERNELCUSTOM01 KODIR=/boot/kernelcustom01 buildkernel installkernel`

<p align="center">
  <figure>
    <img src="img/image64.png" alt="bloques">
  </figure>
</p>

La compilación del kernel tomó 14.37 segundos en tiempo real. (ANTES 26 minutos y 0.64 segundos)


## Transferencia de Archivos entre FreeBSD (VM) y Ubuntu (NATIVO) utilizando SCP"


1. **Configuración de la Máquina Virtual (FreeBSD)**
   - Verifica la configuración de red de la máquina virtual. Utiliza un adaptador de red en modo "Puente" para permitir la comunicación con el host (Ubuntu).
   <p align="center">
  <figure>
    <img src="img/image68.png" alt="bloques">
  </figure>
</p>

2. **Instalación y Configuración del Servidor SSH en FreeBSD**
   - Accede a FreeBSD a través de la terminal.
   - Comprueba si el servicio SSH está instalado y habilitado. Ejecuta:
     ```bash
     sudo service sshd status
     ```
   - Si no está activo, puedes iniciarlo o reiniciarlo con:
     ```bash
     sudo service sshd start
     ```

3. **Verificación de la Dirección IP de FreeBSD**
   - Ejecuta `ifconfig` en FreeBSD para obtener la dirección IP.
   - Anota la dirección IP (por ejemplo, `192.168.0.212`).

4. **Desactivar el Firewall (si es necesario)**
   - Asegúrate de que no haya reglas de firewall que bloqueen el acceso. Puedes desactivar el firewall temporalmente si es necesario:
     ```bash
     sudo ufw disable
     ```

5. **Acceso a FreeBSD desde Ubuntu**
   - En Ubuntu, abre una terminal y verifica que puedes hacer ping a la dirección IP de FreeBSD:
     ```bash
     ping 192.168.0.212
     ```

6. **Transferencia de Archivos usando SCP**
   - En la terminal de Ubuntu, utiliza el comando `scp` para transferir el archivo desde tu escritorio a FreeBSD:
     ```bash
     scp ~/Escritorio/mensaje.txt root@192.168.0.212:/home/Augusto/
     ```
   - Introduce la contraseña de `root` cuando se te solicite.

7. **Verificación de la Transferencia**
   - Accede nuevamente a FreeBSD usando SSH:
     ```bash
     ssh root@192.168.0.212
     ```
   - Verifica que el archivo se haya transferido correctamente:
     ```bash
     ls /home/Augusto/
     ```

8. **Cierre de Sesión**
   - Una vez verificado que el archivo está presente, puedes salir de la sesión SSH con el comando:
     ```bash
     exit
     ```
   <p align="center">
  <figure>
    <img src="img/image69.png" alt="bloques">
  </figure>
</p>

## Procedimiento de trabajo


  <p align="center">
  <figure>
    <img src="img/image70.png" alt="bloques">
  </figure>
</p>

# Prueba Piloto

## Pasos

1. Crear copia de seguridad del kernel actual: `cp -a /boot/kernel /boot/kernel-14.1-RELEASE-GENERIC`

   <p align="center">
     <figure>
       <img src="img/image71.png" alt="bloques">
     </figure>
   </p>

2. Cambiar al directorio de configuración del kernel: `cd /usr/src/sys/amd64/conf`

3. Copiar el archivo de configuración base: `cp GENERIC VMKERNEL4BSD`

   <p align="center">
     <figure>
       <img src="img/image72.png" alt="bloques">
     </figure>
   </p>

4. Editar `VMKERNEL4BSD` para agregar tus configuraciones personalizadas: `ee VMKERNEL4BSD`

5. Compilar el nuevo kernel: `make -j4 buildkernel KERNCONF=VMKERNEL4BSD`

6. Instalar el nuevo kernel: `make installkernel KERNCONF=VMKERNEL4BSD`

7. Las modificaciones desde Ubuntu (host) se pueden hacer e intercambiar hacia FreeBSD VM con el comando: `rsync -avz -e ssh /home/augusto/Escritorio/PI_Cabrera/Notas_PI/code/releng14.1/sys/ root@192.168.0.212:/usr/src/sys/
`

8. Reiniciar el sistema: `reboot`

Para verificar si el kernel se cargó correctamente, se agregó el siguiente **print** en el código `init_main`:

<p align="center">
  <figure>
    <img src="img/image74.png" alt="bloques">
  </figure>
</p>

<p align="center">
  <figure>
    <img src="img/image75.png" alt="bloques">
  </figure>
</p>

Se observa que al bootear aparece el mensaje de verificación. ¡El kernel `VMKERNEL4BSD` se instaló correctamente!

**NOTA**: En caso de que se borre `/usr/src`, se pueden copiar los archivos de respaldo con:

```bash

cd /home/Augusto/usr_src_backup  
sudo mv * /usr/src  
```

Esto ayuda a evitar tiempos largos de `git clone`.


## Primera iteración

Habiendo mencionado la colaboración con trabajos desarrollados por otros autores, se debe tener en cuenta que los archivos pertinentes del sistema operativo FreeBSD han sufrido cambios a la fecha, por lo que el código fuente de estos trabajos debe ser actualizado a la versión del sistema operativo que se va a utilizar para este proyecto en esta iteración (versión 14.1). Es por esto que el objetivo de esta primera iteración es la adaptación de los trabajos referenciados a la versión más reciente de FreeBSD a la fecha.

Los archivos de interés a modificar/agregar son:
- `/usr/src/sys/amd64/conf/VMKERNEL4BSD`
- `/usr/src/sys/conf/files`
- `/usr/src/sys/kern/`
  - `init_main.c (PRINT)`
  - `sched_4bsd.c`
  - `kern_exec`
  - `imgact_elf.c`
  - `kern_thread.c`
  - `metadata_elf_reader.c`
  - `petri_global_net.c`
  - `sched_petri.c`
  
CONSIDERACIONES:  Se agrego la carpeta `kernel_modules` que incorpora los modulos de kernel: 


<p align="center">
  <figure>
    <img src="img/image76.png" alt="bloques">
  </figure>
</p>

Para cargar estos modulos se utilizaron los siguientes comandos:



```bash
cd kernel_modules
make
./load_all.sh
```
[Ver interacción 3 Daniele-Bonino](#tercera-iteración-)

NOTA: Modificar el /etc/syslog.conf para que imprima los log. (agregar local1.*    /var/log/local1.log y tambien local2.*    /var/log/local2.log
), *usar service syslogd restart* 

En local1.log se guardar las impresiones de cup_stats.ko

La diferencia entre LOG_LOCAL1 y LOG_LOCAL2 radica en que son identificadores diferentes para categorizar los mensajes de log. Ambos usan el nivel LOG_INFO (informativo), pero los identificadores locales permiten organizar los logs en canales separados. Por ejemplo, uno puede usarse para el módulo cpu_stats (LOG_LOCAL1) y otro para toggle_active_cpu (LOG_LOCAL2).





RECORDAR: LAS IMPRESIONES DE CPU_STATS ESTAN EN /var/log/local1.log, 
como este archivo crece mucho, se realiza lo siguiente! 








## Segunda iteración

### Pruebas con CORES

<p align="center">
  <figure>
    <img src="img/image83.png" alt="bloques">
  </figure>
</p>

<p align="center">
  <figure>
    <img src="img/image84.png" alt="bloques">
  </figure>
</p>




El resultado indica que solo hay 1 CPU lógico asignado a tu máquina virtual. Esto puede deberse a cómo se configuró la VM en el hipervisor (como VirtualBox, VMware, o KVM). Para aumentar el número de núcleos disponibles para FreeBSD, sigue estos pasos:

1. Apaga la máquina virtual.
2. Ve a la configuración de la VM.
3. Navega a la sección Sistema > Procesador.
4. Ajusta el control deslizante para aumentar el número de CPUs asignadas.

<p align="center">
  <figure>
    <img src="img/image85.png" alt="bloques">
  </figure>
</p>


<p align="center">
  <figure>
    <img src="img/image86.png" alt="bloques">
  </figure>
</p>

Ahora muestra que tienes 4 CPUs asignadas a la VM de FreeBSD. Esto significa que ajustaste correctamente la configuración del número de procesadores en VirtualBox y FreeBSD ahora los reconoce.

<p align="center">
  <figure>
    <img src="img/image87.png" alt="bloques">
  </figure>
</p>

Modificando el Modulo de `toggle_active_cpu.ko`, de la siguiente forma:

```C
static void 
timer_callback_turn_off(void *arg) 
{
    if ((stats_score < LOAD_NORMAL) && (cpus_requested < 1)) {
        if (check++ >= 3) { // al menos 90 segundos con baja carga
            check = 0; // reinicia el contador

            if (get_n_turned_off() < MAX_TURNED_OFF) {
                int target_cpu = 1; // Fijar CPU objetivo
                
                if (target_cpu > 0 && !turned_off_cpus[target_cpu]) {
                    turn_off_cpu(target_cpu);
                    turned_off_cpus[target_cpu] = true;

                    log(LOG_INFO | LOG_LOCAL2, "CPU %d turned off\n", target_cpu);
                }
            }
        }
    }

    callout_schedule(&timer_turn_off, turn_off_interval_sec * hz);
}
```
Para saturar: el scripts `cpu_load.sh`


Se puede apagar completamente el nucleo 1 (esto con fines experimentales)

<p align="center">
  <figure>
    <img src="img/image88.png" alt="bloques">
  </figure>
</p>

volvemos a la configuracion anterior del modulo...

### Pluggins Necesarios


Los plugins de Clang y GCC son herramientas que extienden la funcionalidad de estos compiladores, permitiendo realizar tareas adicionales durante el proceso de compilación. Estas extensiones son útiles para desarrolladores que desean personalizar o mejorar su flujo de trabajo. Una vez obtenido este nuevo kernel, se probó que todo funcione correctamente
utilizando los plugins CLang y GCC para insertar metadata en los ejecutables ELF y
leer la misma en espacio de kernel.

El uso de plugins de Clang y GCC para trabajar con metadata en ejecutables ELF es una técnica poderosa en FreeBSD. Permite una integración más estrecha entre el espacio de usuario y el kernel, con aplicaciones significativas en seguridad, optimización y control del sistema. 


