# py123d KITTI-360 logs + raw velodyne .bin -> cosmos tokenizer range-map tars.
# STEP 2 of 2; step 1 is scripts/kitti360_converter.sh (raw KITTI-360 -> py123d logs), which you have
# already run. The raw .bin files are read from $KITTI360_DATA_ROOT (py123d only stores relative paths).
#
# KITTI-360 has NO range image, NO ring and NO column field -- only x,y,z,intensity -- so the grid is
# built by spherical projection. This follows LiDAR-Diffusion (lidm/utils/lidar_utils.py::pcd2range,
# configs/lidar_diffusion/kitti/*.yaml): 64 UNIFORM elevation bins over fov [3, -25] x 1024 azimuth
# columns, nearest point per cell. Back-projection is then the exact inverse of the projection.
# Note what this costs on THIS dataset: KITTI-360's scans are motion compensated, so a beam's elevation
# drifts ~2 deg per revolution and wanders across 2-4 rows -- the range image shows horizontal banding and
# 2 of the 64 rows can end up empty (67.7% fill). --row_mode ring instead takes the beam index from the
# storage order (points are stored beam by beam, azimuth increasing, so each +180 -> -180 wrap starts a
# new beam; verified on 29 frames across all 9 drives), giving one beam per row and 76.4% fill, at the
# price of an approximate elevation table for back-projection. Side-by-side figure and numbers:
# cosmos-transfer-lidargen/outputs/kitti360_projection_compare/.
# --n_cols 2048 (instead of the default 1024) is ~the sensor's native 0.18 deg azimuth step.
#
# The 9 drives are 1,010-14,122 frames, so they are chunked into 200-frame clips (<drive>_cNNNN), ~357
# clips in total. py123d's kitti360 split has only a train split, so the val set here is carved out of
# the same drives -- see VAL_DRIVE below (drive 0003 is the one LiDAR-Diffusion holds out).
# Dataset configs: lidar_range_map_rRow4_kitti360_{range,ri}.
cd /mnt/efs/users/lili.gao/Repos/cosmos-drive-dreams
P=/mnt/efs/users/lili.gao/environments/py123d/bin/python
export KITTI360_DATA_ROOT=${KITTI360_DATA_ROOT:-/batch10/kitti360}
OUT_ROOT=/batch10/lili.gao/cosmos-lidargen/datasets/kitti360
LOGS=/batch10/py123d/kitti360/logs/kitti360_train
VAL_DRIVE=${VAL_DRIVE:-2013_05_28_drive_0003_sync}   # held out for validation (as in LiDAR-Diffusion)
C=cosmos-drive-dreams-toolkits/convert_py123d_to_rangemap.py
ARGS="--dataset kitti360 --mode ri --split_name kitti360.lst"

# val: the held-out drive
mkdir -p "$OUT_ROOT/kitti360_val_src" && ln -sfn "$LOGS/$VAL_DRIVE" "$OUT_ROOT/kitti360_val_src/$VAL_DRIVE"
$P $C -i "$OUT_ROOT/kitti360_val_src" -o "$OUT_ROOT/kitti360_val" $ARGS

# train: the other 8 drives, 4 shards
mkdir -p "$OUT_ROOT/kitti360_train_src"
for d in "$LOGS"/*/; do b=$(basename "$d"); [ "$b" = "$VAL_DRIVE" ] || ln -sfn "$d" "$OUT_ROOT/kitti360_train_src/$b"; done
for s in 0 1 2 3; do
  $P $C -i "$OUT_ROOT/kitti360_train_src" -o "$OUT_ROOT/kitti360_train" $ARGS --num_shards 4 --shard_id $s &
done; wait
