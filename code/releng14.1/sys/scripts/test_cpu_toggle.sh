#!/usr/local/bin/bash
if [ $# -ne 2 ]; then
  echo "[ERROR] Uso: $0 user_load procs_needs"
  echo "user_load is pct of cpu usage wanted (0, 25, 50, 75 or 100)"
  echo "procs_needs is distribution of type of procs:"
  echo "   0 is equal"
  echo "   1 for predominance of lowperf procs"
  echo "   2 for predominance of std procs"
  echo "   3 for predominance of hiperf procs"
  echo "   4 for predominance of critical procs"
  exit 1
fi

user_load=$1
procs_needs=$2

if [[ ! ($user_load =~ ^[0-9]+$ && $procs_needs =~ ^[0-9]+$) ]]; then
  echo "[ERROR] args need to be numbers"
  exit 1
fi

if [[ ! ("$user_load" -eq 0 || "$user_load" -eq 25 || "$user_load" -eq 50 || "$user_load" -eq 75 || "$user_load" -eq 100) ]]; then
  echo "[ERROR] invalid user_load"
  exit 1
fi

if [ "$procs_needs" -lt 0 ] || [ "$procs_needs" -gt 4 ]; then
  echo "[ERROR] invalid proc_needs"
  exit 1
fi

#obtaining how many cpus i want to keep busy
ncpus=$(sysctl hw.ncpu | cut -d " " -f2)
ncpus=$((ncpus * user_load / 100))

#distribution of metadata process launched
case $procs_needs in
    0)
        lowperf=5
        std=5
        hiperf=5
        critical=5
        ;;
    1)
        lowperf=20
        std=5
        hiperf=0
        critical=0
        ;;
    2)
        lowperf=0
        std=5
        hiperf=0
        critical=0
        ;;
    3)
        lowperf=0
        std=0
        hiperf=30
        critical=5
        ;;
    4)
        lowperf=0
        std=0
        hiperf=5
        critical=30
        ;;
esac

echo "[INFO] Launching stress for 60s using $ncpus cpus"
stress --cpu $ncpus --timeout 60s > /dev/null &

./test_metadata_procs.sh "$lowperf" "$std" "$hiperf" "$critical"