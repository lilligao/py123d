aws s3 cp s3://perception-aisee/Pubblic_Datasets/PhysicalAI-Autonomous-Vehicles/ /batch10/physical-ai-av --recursive
export PHYSICAL_AI_AV_DATA_ROOT=/batch10/physical-ai-av
export PY123D_DATA_ROOT=/batch10/py123d/physical-ai-av

/mnt/efs/users/lili.gao/environments/py123d/bin/py123d-conversion \
  dataset=physical-ai-av
