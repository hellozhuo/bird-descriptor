<p align="center"><h1>Read me</h1></p>

This code is for the BMVC 2019 paper, [*BIRD: Learning Binary and Illumination Robust Descriptor for Face Recognition*](http://www.ee.oulu.fi/~zsu18/public_dataset/BMVC2019-BIRD-Learning-Binary-and-Illumination-Robust-Descriptor-for-Face-Recognition.pdf)

## Prerequisites

- Matlab (the code is currently tested on 2019a, while other versions might also be compatible), 
- CAS_PEAL_R1 dataset, code about how to crop and load it are in [dataset/code/crop_cas_peal_r1.m](dataset/code/crop_cas_peal_r1.m) and [dataset/code/load_face.m](dataset/code/load_face.m) respectively, then save the cropped data in `dataset` directory.

## Run
1. run `demo_init.m` to add all directories and sub-directories into the matlab path;
2. run `demo_cas_peal_r1.m` in the `face` directory.


