PIPBENCH_WORKLOAD=/home/ubuntu/pipbench/evaluation/run_workload.py
echo $PIPBENCH_WORKLOAD

python3 $PIPBENCH_WORKLOAD ./1000handlers.json

