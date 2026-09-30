# py123d Waymo -> cosmos range-map tars with the NATIVE AZIMUTH CONVENTION.
#
# Same data and same grid as scripts/waymo2cosmos.sh (N_COLS=3600, 64 exact `channel` beam rows, the
# dataloader then does /2 -> 1800 and rows x8 -> 512). The difference is the column numbering:
# convert_py123d_to_rangemap.py now writes col = round((32.0 - az_deg)/360 * n_cols) (clockwise), which is
# Waymo's own range-image convention, instead of the old (az + 180)/360 (counter-clockwise). Effects:
#   * these range maps line up column-for-column with the raw parquet range image (and with the tars from
#     convert_waymo_v2_to_rangemap.py) -- verified: column-fill profile correlates 0.823 with native at
#     shift 0, where the legacy tars needed a flip + 212 deg shift;
#   * back-projected point clouds come out in the correct orientation. The legacy tars are MIRRORED about
#     the x axis unless their dataset config carries azimuth_origin_deg=-180 / azimuth_increasing=True
#     (which the configs in this repo now do, so the old data is usable as-is).
# Training itself is unaffected by the convention -- this is about comparability with the raw data.
#
# Output goes to *_c3600_az32 directories so the existing legacy _c3600 tars are left untouched; the
# dataset configs lidar_range_map_rRow4_py123d_waymo_az32_{range,ri,riv} already point at them.
# Runtime is the same as the original conversion (val 4 shards, then train 8 shards).
cd /mnt/efs/users/lili.gao/Repos/cosmos-drive-dreams
P=/mnt/efs/users/lili.gao/environments/py123d/bin/python
N_COLS=${N_COLS:-3600}
OUT_ROOT=/batch10/lili.gao/cosmos-lidargen/datasets/waymo
SUFFIX=${SUFFIX:-_az32}

# val (202 clips, 4 shards)
for s in 0 1 2 3; do
  $P cosmos-drive-dreams-toolkits/convert_py123d_to_rangemap.py \
    -i /batch10/py123d/waymo/logs/wod-perception_val \
    -o $OUT_ROOT/py123d_waymo_val_rie_c${N_COLS}${SUFFIX} --mode rie --n_cols $N_COLS --num_shards 4 --shard_id $s &
done; wait

# train (798 clips, 8 shards)
for s in 0 1 2 3 4 5 6 7; do
  $P cosmos-drive-dreams-toolkits/convert_py123d_to_rangemap.py \
    -i /batch10/py123d/waymo/logs/wod-perception_train \
    -o $OUT_ROOT/py123d_waymo_train_rie_c${N_COLS}${SUFFIX} --mode rie --n_cols $N_COLS --num_shards 8 --shard_id $s &
done; wait
