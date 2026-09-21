# nuScenes (py123d format) -> tokenizer range-map tars, mirrors waymo2cosmos.sh.
#
# Unlike Waymo, py123d does not inline nuScenes points as LAS -- lidar.lidar_merged.arrow only stores a
# relative path into the raw nuScenes sensor tree ($NUSCENES_DATA_ROOT, default /batch10/nuscenes), and
# the native grid is 32 rows (Velodyne HDL-32E ring index) instead of Waymo's 64. --mode ri writes
# [range, intensity] only (no elongation-equivalent channel exists for nuScenes) and --lidar_length 41
# matches the ~40 KEYFRAMES/clip py123d stored (vs Waymo's ~200 frames/clip @10Hz) -- see
# convert_py123d_to_rangemap.py's docstring for why this matters (dataloader frame-index padding bias).
export NUSCENES_DATA_ROOT=/batch10/nuscenes

cd /mnt/efs/users/lili.gao/Repos/cosmos-drive-dreams
P=/mnt/efs/users/lili.gao/environments/py123d/bin/python

# val (parallel 8 shards)
for s in 0 1 2 3 4 5 6 7; do
  $P cosmos-drive-dreams-toolkits/convert_py123d_to_rangemap.py \
    -i /batch10/py123d/nuscenes/logs/nuscenes_val \
    -o /batch10/py123d/nuscenes/cosmos-transfer-lidargen/datasets/py123d_nuscenes_val_rie \
    --dataset nuscenes --mode ri --n_rows 32 --lidar_length 41 --num_shards 8 --shard_id $s &
done; wait


cd /mnt/efs/users/lili.gao/Repos/cosmos-drive-dreams
P=/mnt/efs/users/lili.gao/environments/py123d/bin/python

# train (parallel 16 shards)
for s in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
  $P cosmos-drive-dreams-toolkits/convert_py123d_to_rangemap.py \
    -i /batch10/py123d/nuscenes/logs/nuscenes_train \
    -o /batch10/py123d/nuscenes/cosmos-transfer-lidargen/datasets/py123d_nuscenes_train_rie \
    --dataset nuscenes --mode ri --n_rows 32 --lidar_length 41 --num_shards 16 --shard_id $s &
done; wait
