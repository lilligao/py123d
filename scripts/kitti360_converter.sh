#aws s3 cp s3://perception-aisee/Pubblic_Datasets/KITTI-360/ /batch10/kitti360 --recursive
export KITTI360_DATA_ROOT=/batch10/kitti360
export PY123D_DATA_ROOT=/batch10/py123d/kitti360

/mnt/efs/users/lili.gao/environments/py123d/bin/py123d-conversion \
  dataset=kitti360
