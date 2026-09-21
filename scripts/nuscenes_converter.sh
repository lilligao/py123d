#aws s3 cp s3://perception-aisee/Pubblic_Datasets/nuScenes/sets/nuscenes/ /batch10/nuscenes --recursive
export NUSCENES_DATA_ROOT=/batch10/nuscenes
export PY123D_DATA_ROOT=/batch10/py123d/nuscenes

#'dataset.parser.splits=[nuscenes_train,nuscenes_val,nuscenes_test]'

/mnt/efs/users/lili.gao/environments/py123d/bin/py123d-conversion \
  dataset=nuscenes \
  'dataset.parser.splits=[nuscenes_val]'
