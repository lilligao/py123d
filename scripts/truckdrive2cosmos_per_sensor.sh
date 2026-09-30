# py123d TruckDrive logs + raw Aeva .bin (boto3 from s3://torc-data/datasets/TruckDrivePublic/, NOT the
# /mnt/torc-data mount) -> cosmos tokenizer range-map tars, ONE PER AEVA SENSOR (7 per scene).
# Each sensor's points are transformed into ITS OWN frame with that scene's calibration and binned on a
# sector grid covering just its FOV: wide (ids 5,6,7) 64 x 1296 over az +-64.8 / el [-13.5,10.5];
# narrow (ids 1-4) 64 x 880 over az +-22 / el [-8,11]. Rows x8 -> 512 tokenizer rows. Tars are named
# {scene}__{sensor}.tar; split lists truckdrive_{wide,narrow,all7}.lst are written at the end.
# Fill ~40% per sensor vs ~25% for the merged 360 image. Extras stored: velocity, intensity, reflectivity.
# Scenes already converted are skipped ({scene}.done marker), so re-running resumes.
cd /mnt/efs/users/lili.gao/Repos/cosmos-drive-dreams
P=/mnt/efs/users/lili.gao/environments/py123d/bin/python
OUT_ROOT=/batch10/lili.gao/cosmos-lidargen/datasets/truckdrive
IO_THREADS=${IO_THREADS:-16}
C=cosmos-drive-dreams-toolkits/convert_truckdrive_to_rangemap.py

N=${VAL_SHARDS:-4}
for s in $(seq 0 $((N-1))); do
  $P $C -i /batch10/py123d/truckdrive/logs/truckdrive_val \
       -o $OUT_ROOT/py123d_truckdrive_val_persensor --per_sensor --io_threads $IO_THREADS --num_shards $N --shard_id $s &
done; wait

N=${TRAIN_SHARDS:-8}
for s in $(seq 0 $((N-1))); do
  $P $C -i /batch10/py123d/truckdrive/logs/truckdrive_train \
       -o $OUT_ROOT/py123d_truckdrive_train_persensor --per_sensor --io_threads $IO_THREADS --num_shards $N --shard_id $s &
done; wait
