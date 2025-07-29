process FILTER_LIST {
  tag "$meta.id"
  cpus 1

  container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

  input:
    tuple val(meta), path(tractogram)

  output:
    tuple val(meta), path("${meta.id}__${task.ext.out_extension}.trk"), emit: extracted
    tuple val(meta), path("${meta.id}__${task.ext.remaining_extension}.trk"), optional: true, emit: remaining
    path "${meta.id}__${task.ext.out_extension}.txt"
    
  script:
    basename            = "${meta.id}"
    filtering_list      = task.ext.filtering_list
    out_extension       = task.ext.out_extension
    remaining_extension = task.ext.remaining_extension
    keep                = task.ext.keep
    extract_masks       = ""
    distance            = task.ext.distance

    template "old_filter_with_list.sh"
}