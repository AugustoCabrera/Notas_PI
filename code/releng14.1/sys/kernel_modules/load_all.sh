#!/usr/local/bin/bash

echo -e "[INFO] Compilando modulo cpu_stats.\n"
cd cpu_stats/ && make load && cd ..

echo -e "[INFO] Compilando modulo thread_stats.\n"
cd thread_stats/ && make load && cd ..

echo -e "[INFO] Compilando modulo toggle_active_cpu.\n"
cd toggle_active_cpu/ && make load && cd ..