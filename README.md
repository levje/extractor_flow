# Extractor Flow: streamline filtering pipeline

## Requirements
- [Nextflow](https://www.nextflow.io/docs/latest/install.html)
- Either [Docker](https://www.docker.com/get-started/) (recommended) or [Apptainer](https://apptainer.org/docs/admin/main/installation.html) depending on the runtime you choose.

You should be able to run the following commands without any errors being printed:
```bash
# 1. Make sure Nextflow is installed.
nextflow -v

# 2a. Make sure Docker is installed.
docker ps

# 2b. Make sure Apptainer is installed.
apptainer version
# or
singularity version
```

## Getting started
0. **Getting help with the input.**  
To get a complete list of the available arguments you can provide, always refer to the usage printed by the nextflow script as follows:
```bash
nextflow run levje/nf-extractor --help
```
1. **Download the templates folder.**  
This pipeline requires templates files and multiple filtering lists that you should [download here]() (available soon) and extract into your directory of choice. You can do it manually, or simply paste the following command in the terminal:
```bash
# Download the tar files.
wget https://github.com/scilus/extractor_flow/raw/refs/heads/master/containers/filtering_lists.tar.bz2 && wget https://github.com/scilus/extractor_flow/raw/refs/heads/master/containers/templates_and_ROIs.tar.bz2

mkdir -p extractor_templates

tar -xjf filtering_lists.tar.bz2 -C extractor_templates && rm filtering_lists.tar.bz2
tar -xjf templates_and_ROIs.tar.bz2 -C extractor_templates && rm templates_and_ROIs.tar.bz2
```
From this point, you should have a directory containing the following structure that you'll use to provide as a value to the `--template_dir` argument in the following steps:
```
extractor_templates/
├── filtering_lists
│   ├── ...
└── templates_and_ROIs
    └── ...
```

2. **Standard filtering using Docker (recommended).**  
The following example gives a general idea on what arguments you can provide. The key part is to select the `docker` profile as well as providing the mandatory arguments (i.e. `--input` & `--templates_dir`):
```bash
nextflow run levje/nf-extractor \  
    --input <input_folder> \  
    --templates_dir <path to templates_folder> \ 
    -profile docker 
    [--orig] 
    [--keep_intermediate_steps]
    [-resume] 
```

3. **Standard filering using Apptainer/Singularity.**  
To use apptainer containers, you should only have to swap the profile used to `apptainer` as shown in the following example:
```bash
nextflow run levje/nf-extractor \  
    --input <input_folder> \  
    --templates_dir <path to templates_folder> \ 
    -profile apptainer 
    [--orig] 
    [--keep_intermediate_steps]
    [-resume] 
```
4. **Filtering and bundle extraction.**  
Notice, in the following example, the addition of the `extract_bundles` profile. This will trigger a few additionnal processes that will separate and organize new files refering to the bundles identified by this flow. The example is using Docker (as the docker profile is enabled), but the same applies for Apptainer.
```bash
nextflow run levje/nf-extractor \  
    --input <input_folder> \  
    --templates_dir <path to templates_folder> \ 
    -profile docker,extract_bundles
    [--orig] 
    [--keep_intermediate_steps]
    [-resume] 
```
