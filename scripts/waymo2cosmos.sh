# py123d (wod-perception) -> cosmos tokenizer range-map tars, at NATIVE azimuth resolution.
# --n_cols 2656: azimuth bins of 360/2656 = 0.1355 deg, ~= Waymo TOP's native 360/2650 (vs the old
# default 3600 = 0.1 deg which the dataloader then /2 -> 1800). 2656 = 8*332 so the full frame goes
# through the 8x tokenizer with no crop, and /2 (1328) and /4 (664) are also divisible by 8 if a lower
# resolution is wanted later (set downsample_factor_col in the dataset config; no reconversion needed).
# Output dirs carry the column count in their name (py123d_waymo_{train,val}_rie_c2656) so they are
# never mixed up with 3600-col tars. The converter skips clips whose tar already exists.
cd /mnt/efs/users/lili.gao/Repos/cosmos-drive-dreams
P=/mnt/efs/users/lili.gao/environments/py123d/bin/python
N_COLS=${N_COLS:-2656}
OUT_ROOT=/batch10/py123d/waymo/cosmos-transfer-lidargen/datasets

# val(并行 4 shard)
for s in 0 1 2 3; do
  $P cosmos-drive-dreams-toolkits/convert_py123d_to_rangemap.py \
    -i /batch10/py123d/waymo/logs/wod-perception_val \
    -o $OUT_ROOT/py123d_waymo_val_rie_c${N_COLS} --mode rie --n_cols $N_COLS --num_shards 4 --shard_id $s &
done; wait

# train(并行 8 shard)
for s in 0 1 2 3 4 5 6 7; do
  $P cosmos-drive-dreams-toolkits/convert_py123d_to_rangemap.py \
    -i /batch10/py123d/waymo/logs/wod-perception_train \
    -o $OUT_ROOT/py123d_waymo_train_rie_c${N_COLS} --mode rie --n_cols $N_COLS --num_shards 8 --shard_id $s &
done; wait
