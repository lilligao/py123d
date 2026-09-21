aws s3 cp s3://perception-aisee/Pubblic_Datasets/Waymo/waymo_open_dataset_v_1_4_3/waymo_format /batch10/waymo --recursive
export WOD_PERCEPTION_DATA_ROOT=/batch10/waymo
export PY123D_DATA_ROOT=/batch10/py123d/waymo

#'dataset.parser.splits=[wod-perception_train,wod-perception_val,wod-perception_test]'

/mnt/efs/users/lili.gao/environments/py123d/bin/py123d-conversion \
  dataset=wod-perception \
  'dataset.parser.splits=[wod-perception_train,wod-perception_test,wod-perception_val]'


cd /mnt/efs/users/lili.gao/Repos/py123d
export WOD_PERCEPTION_DATA_ROOT=/batch10/waymo
export PY123D_DATA_ROOT=/batch10/py123d/waymo

/mnt/efs/users/lili.gao/environments/py123d/bin/py123d-conversion \
  dataset=wod-perception \
  'dataset.parser.splits=[wod-perception_train,wod-perception_test,wod-perception_val]' \
  dataset.parser.keep_polar_features=true \
  force_log_conversion=true
