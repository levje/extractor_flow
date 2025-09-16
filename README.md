# Extractor Flow: streamline filtering pipeline

ExtractorFlow is a streamline filtering pipeline written in nextflow. In essence, you provide any tractogram file (i.e. `*.trk`) as an input and this pipeline will output which streamlines are deemed as anatomically **plausible** and **implausible** as separate `.trk` files.

Additionnally, as described below, you can use this pipeline to extract recognized (i.e. plausible) bundles of streamlines.

When using this work, please cite using the following:
```
@article{petit2023structural,
  title={The structural connectivity of the human angular gyrus as revealed by microdissection and diffusion tractography},
  author={Petit, Laurent and Ali, Kariem Mahdy and Rheault, Fran{\c{c}}ois and Bor{\'e}, Arnaud and Cremona, Sandrine and Corsini, Francesco and De Benedictis, Alessandro and Descoteaux, Maxime and Sarubbo, Silvio},
  journal={Brain Structure and Function},
  volume={228},
  number={1},
  pages={103--120},
  year={2023},
  publisher={Springer}
}
```

## Requirements
- [Nextflow](https://www.nextflow.io/docs/latest/install.html)
- [Docker](https://www.docker.com/get-started/) (recommended) or [Apptainer](https://apptainer.org/docs/admin/main/installation.html) depending on the runtime you choose.

You should be able to run the following commands without any errors being printed:
```bash
# 1. Make sure Nextflow is installed.
nextflow -v

# 2a. Make sure Docker is installed.
docker ps

# 2b. Make sure Apptainer is installed.
apptainer version
```

## Getting started
###  Understand the input
This nextflow pipeline has **two** mandatory arguments that any user has to provide in order to run the pipeline.
1. `--input` 
2. `--templates_dir`

Both of these arguments point to two different directories that have their own particular structure:

#### `--input`
This argument points to the directory holding all the tractograms you wish to filter. Also, within this directory, each tractogram should probably be associated with a T1w image (in diffusion space). This T1w image is used to register your tractograms to MNI space, which is the space where the filtering is performed. **If no T1w image is provided, your tractograms are assumed to be already in the appropriate template (MNI) space**. This said, your directory structure should look like the following:
```
input_example
├── subject-01
│   ├── subject-01__t1.nii.gz
│   └── subject-01_tracking.trk
├── subject-02
│   ├── subject-02__t1.nii.gz
│   └── subject-02_tracking.trk
├── ...
└── subject-n
    ├── subject-n__t1.nii.gz
    └── subject-n_tracking.trk
```
If your tractograms are already in the right space, keep the same structure, but omit the `*t1.nii.gz` files.

#### `--templates_dir`  
To simplify the usage of this pipeline and to avoid cluttering the containers used, the user must download extract the different templates used and the lists that are used during filtering in this pipeline (don't worry, it's a simple process).

All you have to do is execute the following commands to download and extract the needed files into a new directory that we called `extractor_templates`.

```bash
wget https://github.com/scilus/extractor_flow/raw/refs/heads/master/containers/filtering_lists.tar.bz2 && wget https://github.com/scilus/extractor_flow/raw/refs/heads/master/containers/templates_and_ROIs.tar.bz2

mkdir -p extractor_templates

tar -xjf filtering_lists.tar.bz2 -C extractor_templates && rm filtering_lists.tar.bz2
tar -xjf templates_and_ROIs.tar.bz2 -C extractor_templates && rm templates_and_ROIs.tar.bz2
```

> If you don't have the `wget` and/or the `tar` commands and you don't want (or can't) to install them, you can always download the two archives manually from [here](https://github.com/scilus/extractor_flow/raw/refs/heads/master/containers/filtering_lists.tar.bz2) and [here](https://github.com/scilus/extractor_flow/raw/refs/heads/master/containers/templates_and_ROIs.tar.bz2) and extract them into a new directory called `extractor_templates`. Just make sure that you have the following directory structure.

From this point, you should have a directory containing the following structure that you'll use to provide as a value to the `--template_dir` argument in the following steps:
```
extractor_templates/
├── filtering_lists
│   ├── ...
└── templates_and_ROIs
    └── ...
```

#### Complete arguments list
To get a complete list of the available arguments you can provide, always refer to the usage printed by the nextflow script as follows:
```bash
nextflow run levje/nf-extractor --help
```

### Standard filtering using Docker (recommended).
The following example gives a general idea on what arguments you can provide. The key part is to select the `docker` profile as well as providing the mandatory arguments (i.e. `--input` & `--templates_dir`):
```bash
nextflow run levje/nf-extractor \  
    --input <input_folder> \  
    --templates_dir <path/to/extractor_templates> \ 
    -profile docker \  
    [--orig] 
    [--keep_intermediate_steps]
    [-resume] 
```

### Standard filering using Apptainer/Singularity.  
To use apptainer containers, you should only have to swap the profile used to `apptainer` as shown in the following example:
```bash
nextflow run levje/nf-extractor \  
    --input <input_folder> \  
    --templates_dir <path/to/extractor_templates> \ 
    -profile apptainer \ 
    [--orig] 
    [--keep_intermediate_steps]
    [-resume] 
```
### Filtering and bundle extraction.  
Notice, in the following example, the addition of the `extract_bundles` profile. This will trigger a few additionnal processes that will separate and organize new files refering to the bundles identified by this flow. The example is using Docker (as the docker profile is enabled), but the same applies for Apptainer.
```bash
nextflow run levje/nf-extractor \  
    --input <input_folder> \  
    --templates_dir <path/to/extractor_templates> \ 
    -profile docker,extract_bundles \ 
    [--orig]  
    [--keep_intermediate_steps]  
    [-resume]
```
