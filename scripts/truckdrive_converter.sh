export TRUCKDRIVE_DATA_ROOT=/mnt/torc-data/datasets/TruckDrivePublic
export PY123D_DATA_ROOT=/batch10/py123d/truckdrive

/mnt/efs/users/lili.gao/environments/py123d/bin/py123d-conversion \
  dataset=truckdrive \
  'dataset.parser.scene_names=[]'
