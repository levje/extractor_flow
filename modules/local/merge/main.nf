process TRACTOGRAM_MATH {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

  input:
    tuple val(meta), val(side), path(in_tractograms)

  output:
    tuple val(meta), path("${out_path}"), emit: tractogram
    tuple val(meta), val(side), path("${out_path}"), emit: tractogram_with_side
    
  script:
    operation = task.ext.op
    out_name = task.ext.out_name ? task.ext.out_name : ""
    out_suffix = task.ext.out_suffix ? task.ext.out_suffix : ""
    save_empty = task.ext.save_empty ? task.ext.save_empty : false
    force = task.ext.force ? task.ext.force : false

    if (!operation) {
        error 'Error ~ No operation specified for TRACTOGRAM_MATH process. Please set "op" in the task.ext configuration.'
    }

    save_empty_str = save_empty ? "--save_empty" : ""
    force_str = force ? "-f" : ""

    tractograms = in_tractograms.join(' ')
    side_suffix = side ? "_${side}" : ""
    out_path = "${meta.id}__${out_name}${side_suffix}${out_suffix}.trk"
    """
    scil_tractogram_math \
        ${operation} \
        ${tractograms} \
        ${out_path} \
        ${save_empty_str} \
        ${force_str}
    ls -lh
    """
}