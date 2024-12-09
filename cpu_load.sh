#!/bin/sh
num_procs=10
cpu_load_cmd="for _ in $(seq 1 1000000000); do :; done"
for i in $(seq 1 $num_procs); do
sh -c "$cpu_load_cmd" &
done
wait
