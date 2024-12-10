#!/usr/local/bin/bash
if [ $# -ne 4 ]; then
  echo "[ERROR] Uso: $0 n_lowperf_procs n_std_procs n_hiperf_procs n_crit_procs"
  exit 1
fi

execute_program_n_times() {
    if [ ! -f "$1" ]; then
        sh test.sh test.c "$1" schedData/"$1"
        echo "[INFO] $1 compiled"
        echo ""
    fi

    for ((i=0; i<$2; i++)); do
        ./"$1" > /dev/null &
    done

    echo "[INFO] Launched $1 $2 times (sleeps for 60s)"
}

cd CLANGPlugin/test || exit 1

execute_program_n_times lowperf "$1"
echo ""
execute_program_n_times std "$2"
echo ""
execute_program_n_times hiperf "$3"
echo ""
execute_program_n_times critical "$4"

cd "$OLDPWD" || return