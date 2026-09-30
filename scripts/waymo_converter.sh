# Waymo Open Dataset (Perception) -> py123d logs.  STEP 1 of 2; step 2 is scripts/waymo2cosmos_native.sh.
#
# Re-run this whenever the WOD parser changes what it stores per point. As of 2026-09-22 it stores, for
# every point, BOTH of its native range-image indices: `channel` (the beam row) and `column` (the azimuth
# step, LidarFeature.COLUMN, added in src/py123d/parser/wod/wod_perception_sensor_io.py). Neither can be
# recovered later -- the exported xyz are motion compensated to the frame pose, so a point's geometric
# direction is not the direction its beam fired in. With both indices, convert_py123d_to_rangemap.py
# reproduces Waymo's raw range image exactly (verified on a real frame: 109,665/109,665 cells, 100.0000%
# occupancy agreement, max |range difference| 0.000000 m). Without `column` it falls back to geometric
# azimuth binning, which at native width loses ~6% of the points and reproduces only ~87% of the cells.
#
# keep_polar_features=true is REQUIRED: it is what makes the parser store the raw polar `range`,
# `intensity` and `elongation` next to xyz (and it is the branch the two index features live in).
#
# force_log_conversion=true OVERWRITES the existing logs under $PY123D_DATA_ROOT/logs IN PLACE (~600 GB
# for train+val, several hours). The range-map tars already built from the old logs
# (datasets/py123d_waymo_*_rie_c3600 etc.) do not depend on them and are left alone. If the run dies
# half way you end up with a MIX of old and new logs; convert_py123d_to_rangemap.py then silently falls
# back per clip, so check its output -- every [ok] line says which path it took.
#
# Add wod-perception_test to the splits if you ever need the test split; it is not used for training.
cd /mnt/efs/users/lili.gao/Repos/py123d
export WOD_PERCEPTION_DATA_ROOT=${WOD_PERCEPTION_DATA_ROOT:-/batch10/waymo}
export PY123D_DATA_ROOT=${PY123D_DATA_ROOT:-/batch10/py123d/waymo}

/mnt/efs/users/lili.gao/environments/py123d/bin/py123d-conversion \
  dataset=wod-perception \
  'dataset.parser.splits=[wod-perception_train,wod-perception_val]' \
  dataset.parser.keep_polar_features=true \
  force_log_conversion=true
