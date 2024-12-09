
# Explicacion de funcionamiento de los modulos

## `toggle_active_cpu.ko`.

Diseñado para gestionar dinámicamente la asignación y suspensión de CPUs según las necesidades de los procesos del sistema.

### Características Principales

1. **Gestión de Monopolización de CPUs**:
   - Monitorea qué procesos solicitan monopolizar un CPU.
   - Libera CPUs monopolizados si el proceso que los estaba utilizando ya no tiene alta prioridad.
   - Monopoliza CPUs si hay procesos de alta prioridad solicitándolo.

2. **Recolección de Estadísticas**:
   - Recopila estadísticas sobre la carga del sistema y las necesidades de los procesos.
   - Calcula un puntaje (`stats_score`) basado en la carga de usuario y las necesidades de procesos.

3. **Encendido y Apagado Dinámico de CPUs**:
   - Apaga CPUs cuando el sistema está en baja carga por un tiempo prolongado (mediciones consecutivas de baja carga).
   - Enciende CPUs suspendidos si la carga del sistema aumenta o si algún proceso lo requiere.

4. **Timers Periódicos**:
   - Utiliza timers para ejecutar tareas recurrentes:
     - **`timer_callback_monopolization`**: Gestiona la monopolización de CPUs.
     - **`timer_callback_stats`**: Recolecta estadísticas del sistema.
     - **`timer_callback_turn_off`**: Decide si puede suspender un CPU.
     - **`timer_callback_turn_on`**: Reactiva CPUs suspendidos si es necesario.

 ## Funcionalidades Clave

### 1. **`event_handler`**
   - Gestiona la carga (`MOD_LOAD`) y descarga (`MOD_UNLOAD`) del módulo:
     - Configura los timers.
     - Inicializa el estado de los CPUs.
     - Libera recursos al descargar el módulo.

### 2. **Timers y Callbacks**
   - **`timer_callback_monopolization`**:
     - Libera CPUs monopolizados por procesos de menor prioridad.
     - Monopoliza CPUs disponibles para procesos prioritarios.
   - **`timer_callback_stats`**:
     - Calcula un puntaje basado en la carga del sistema y las necesidades de los procesos.
   - **`timer_callback_turn_off`**:
     - Suspende CPUs tras mediciones consecutivas de baja carga.
   - **`timer_callback_turn_on`**:
     - Reactiva CPUs suspendidos si la carga del sistema aumenta.

### 3. **Funciones de Ayuda**
   - **`get_idlest_cpu`**:
     - Identifica el CPU menos cargado.
   - **`get_monopolization_info`**:
     - Obtiene información de procesos que solicitan monopolizar CPUs.
   - **`get_user_load`** y **`get_procs_needs`**:
     - Calculan cargas y necesidades de procesos para determinar el puntaje (`stats_score`).

### 4. **Definiciones de Carga**
   - **`calc_load_score`**:
     - Normaliza puntajes de carga en categorías: *IDLE*, *LOW*, *NORMAL*, *HIGH*, *INTENSE*, *SEVERE*.

## Variables Importantes

- **Timers**:
  - `timer_monopolization`, `timer_stats`, `timer_turn_off`, `timer_turn_on`: Controlan la ejecución periódica de callbacks.
- **`turned_off_cpus`**:
  - Arreglo booleano que indica cuáles CPUs están suspendidos.
- **`stats_score`**:
  - Puntaje basado en la carga del sistema.
- **`MAX_TURNED_OFF`**:
  - Límite de CPUs que pueden estar suspendidos simultáneamente.
