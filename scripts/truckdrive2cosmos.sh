# py123d TruckDrive logs + raw Aeva .bin (read from s3://torc-data/datasets/TruckDrivePublic/ with boto3,
# NOT the /mnt/torc-data mount) -> cosmos tokenizer range-map tars.
# Grid: 128 uniform elevation rows over [-17.5, 7.5] deg x 3600 azimuth cols, max range ~400 m, plus
# `intensity` and `velocity` tar members. Each shard process keeps 16 S3 GETs in flight (~10 frames/s,
# ~200-500 MB/s per process); N_SHARDS processes run in parallel. Train is ~624k frames / ~30 TB of .bin
# -> expect on the order of a day with 8 shards. The converter skips scenes whose tar already exists, so
# re-running resumes. Credentials: EC2 instance role (the ~/.aws SSO profile is ignored on purpose).
cd /mnt/efs/users/lili.gao/Repos/cosmos-drive-dreams
P=/mnt/efs/users/lili.gao/environments/py123d/bin/python
OUT_ROOT=/batch10/lili.gao/cosmos-lidargen/datasets/truckdrive
IO_THREADS=${IO_THREADS:-16}

# val (139 scenes, 4 shards)
N=${VAL_SHARDS:-4}
for s in $(seq 0 $((N-1))); do
  $P cosmos-drive-dreams-toolkits/convert_truckdrive_to_rangemap.py \
    -i /batch10/py123d/truckdrive/logs/truckdrive_val \
    -o $OUT_ROOT/py123d_truckdrive_val_rv --io_threads $IO_THREADS --num_shards $N --shard_id $s &
done; wait

# train (3463 scenes with lidar, 8 shards)
N=${TRAIN_SHARDS:-8}
for s in $(seq 0 $((N-1))); do
  $P cosmos-drive-dreams-toolkits/convert_truckdrive_to_rangemap.py \
    -i /batch10/py123d/truckdrive/logs/truckdrive_train \
    -o $OUT_ROOT/py123d_truckdrive_train_rv --io_threads $IO_THREADS --num_shards $N --shard_id $s &
done; wait
