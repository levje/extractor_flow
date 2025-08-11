process COPY_FILE {
  tag "${meta.id}"
  cpus 1

  input:
    tuple val(meta), val(side), path(tractogram)
  output:
    tuple val(meta), path("${filename}"), emit: output_file

  script:
    out_name = task.ext.out_name ? task.ext.out_name : ""
    out_suffix = task.ext.out_suffix ? task.ext.out_suffix : ""
    force = task.ext.force ? task.ext.force : false

    side_suffix = side ? "_${side}" : ""
    force_str = force ? "-f" : ""
    filename = "${meta.id}__${out_name}${side_suffix}${out_suffix}.trk"
    """
        cp ${tractogram} ${filename} ${force_str}
    """
}