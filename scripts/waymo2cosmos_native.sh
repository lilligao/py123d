# py123d Waymo -> cosmos range-map tars that ARE the RAW NATIVE RANGE IMAGE (64 x 2650), no projection.
#
# PREREQUISITE: the py123d logs must have been exported with the COLUMN feature (LidarFeature.COLUMN,
# added 2026-09-22 in src/py123d/parser/wod/wod_perception_sensor_io.py). Older exports carry `channel`
# (the beam row) but not `column`, and convert_py123d_to_rangemap.py then falls back to deriving the
# azimuth geometrically -- lossy at this width. So run the py123d conversion FIRST:
#
#   cd /mnt/efs/users/lili.gao/Repos/py123d
#   export WOD_PERCEPTION_DATA_ROOT=/batch10/waymo
#   export PY123D_DATA_ROOT=/batch10/py123d/waymo
#   /mnt/efs/users/lili.gao/environments/py123d/bin/py123d-conversion \
#     dataset=wod-perception \
#     'dataset.parser.splits=[wod-perception_train,wod-perception_val]' \
#     dataset.parser.keep_polar_features=true \
#     force_log_conversion=true
#
# then this script. Each point keeps its exact (row, col) in Waymo's own range image, so the tars hold
# the raw image: same values, same pixels, nothing resampled -- equivalent to what
# convert_waymo_v2_to_rangemap.py reads straight out of the parquet.
# N_COLS (default 2656): 2650 -> 2656 is an INJECTIVE widening (round(col * 2656/2650), slope 1.0023), so
# no point is ever lost -- 6 of the 2656 columns (0.23%) just stay empty -- and 2656 = 8*332 means the FULL
# frame goes through the 8x tokenizer uncropped (val latent 16 x 64 x 332). N_COLS=2650 keeps the raw width
# with nothing resampled, but is not a multiple of 8, so the config center-crops val to 2648 (0.27 deg
# dropped). Either way training random-crops 896 columns.
# Dataset configs: lidar_range_map_rRow4_py123d_waymo_native{2656,2650}_{range,ri,riv}.
cd /mnt/efs/users/lili.gao/Repos/cosmos-drive-dreams
P=/mnt/efs/users/lili.gao/environments/py123d/bin/python
OUT_ROOT=/batch10/lili.gao/cosmos-lidargen/datasets/waymo
N_COLS=${N_COLS:-2656}

# val (202 clips, 4 shards)
for s in 0 1 2 3; do
  $P cosmos-drive-dreams-toolkits/convert_py123d_to_rangemap.py \
    -i /batch10/py123d/waymo/logs/wod-perception_val \
    -o $OUT_ROOT/py123d_waymo_val_rie_native${N_COLS} --mode rie --n_cols $N_COLS --num_shards 4 --shard_id $s &
done; wait

# train (798 clips, 8 shards)
for s in 0 1 2 3 4 5 6 7; do
  $P cosmos-drive-dreams-toolkits/convert_py123d_to_rangemap.py \
    -i /batch10/py123d/waymo/logs/wod-perception_train \
    -o $OUT_ROOT/py123d_waymo_train_rie_native${N_COLS} --mode rie --n_cols $N_COLS --num_shards 8 --shard_id $s &
done; wait
