# INSTALACION GCC en FREEBSD  - RAW BINARY METADATA

1. Instalar GCC 
``` Bash
$ sudo pkg install gcc
```

2. Compilar plugin. El mismo detecta la version de GCC y FreeBSD y genera los archivos necesarios.

``` Bash
$ sh setup.sh

g++11 -shared -O2 -pipe -fPIC -fno-rtti -O2 -I/usr/src/sys -I/usr/local/lib/gcc11/gcc/x86_64-portbld-freebsd13.0/11.2.0/plugin/include insertPayload_GCCPlugin.c -o InsertPayload_GCCPlugin.so 
```

3. Compilar programa cargando el plugin de GCC. Ejecutar el script **test.sh**  
   El primer argumento es el nombre del código fuente del programa de usuario (**test.c** del directorio /test/). El resto de los argumentos son el nombre de los archivos que tienen datos a insertar en el ejecutable final.

``` Bash
$ sh test.sh test/test.c test/schedData/hiperf test/dataToInsert/decl_payA.txt test/dataToInsert/decl_payB.txt test/dataToInsert/decl_payC.txt
Plugin argument - 2: test/schedData/hiperf
Plugin argument - 3: test/dataToInsert/decl_payA.txt
Plugin argument - 4: test/dataToInsert/decl_payB.txt
Plugin argument - 5: test/dataToInsert/decl_payC.txt

make test PLUGIN_ARGS='-fplugin-arg-InsertPayload_GCCPlugin-2=test/schedData/hiperf -fplugin-arg-InsertPayload_GCCPlugin-1=test/dataToInsert/decl_payA.txt -fplugin-arg-InsertPayload_GCCPlugin-1=test/dataToInsert/decl_payB.txt -fplugin-arg-InsertPayload_GCCPlugin-1=test/dataToInsert/decl_payC.txt '
gcc -o metadataTestProgramGCC test/test.c -fplugin=./InsertPayload_GCCPlugin.so -fplugin-arg-InsertPayload_GCCPlugin-2=test/schedData/hiperf -fplugin-arg-InsertPayload_GCCPlugin-1=test/dataToInsert/decl_payA.txt -fplugin-arg-InsertPayload_GCCPlugin-1=test/dataToInsert/decl_payB.txt -fplugin-arg-InsertPayload_GCCPlugin-1=test/dataToInsert/decl_payC.txt  -I/usr/src/sys

Number of arguments of this plugin: 4
Arg [0]: - Key: [2] - Value: [test/schedData/hiperf]
Arg [1]: - Key: [1] - Value: [test/dataToInsert/decl_payA.txt]
Arg [2]: - Key: [1] - Value: [test/dataToInsert/decl_payB.txt]
Arg [3]: - Key: [1] - Value: [test/dataToInsert/decl_payC.txt]

To be replaced: 
__PAYLOAD__=static Metadata_Hdr metadata_header __attribute__((__used__, __section__(".metadata"))) = {4, sizeof(Payload_Hdr)};
static Payload_Sched payloads_sched[] __attribute__((__used__, __section__(".metadata"), __aligned__(8))) = {{false,"HIGHPERF"}};
static Payload_Binary payloads_bin[] __attribute__((__used__, __section__(".metadata"), __aligned__(8))) = {{24,48,"5061796C6F61645F412F322F342F632F696E745F73697A65"},{26,52,"5061796C6F61645F422F31362F7A2F772F636861725F73697A65"},{28,56,"5061796C6F61645F432F362F31302F652F666C6F61745F73697A650A"}};
static Payload_Hdr payload_headers[] __attribute__((__used__, __section__(".metadata"))) = {{2, sizeof(payloads_sched[0])},{1, sizeof(payloads_bin[0])},{1, sizeof(payloads_bin[1])},{1, sizeof(payloads_bin[2])}};
```

4. Ejecutar programa con metadata insertada

``` Bash
$ ./metadataTestProgramGCC
```

5. Chequear que metadata fue extraida del ejecutable "metadataTestProgramGCC" en el log de kernel (si estan activados en el codigo compilado por el kernel)

``` Bash
$ dmesg
```