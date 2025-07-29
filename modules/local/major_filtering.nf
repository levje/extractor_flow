process MAJOR_FILTERING {
    tag "$meta.id"
    cpus params.processes_major_filtering

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_2.1.0.sif':
        'scilus/scilus:2.1.0' }"

    input:
      tuple val(meta), path(tractogram), path(rois_folder)

    output:
      tuple val(meta), path("${meta.id}__wb_clean01.trk"), emit: wb
      tuple val(meta), path("${meta.id}__unplausible_streamlines.trk"), emit: unplausible
      path("${meta.id}/*"), optional: true

    script:
    keep_intermediate_trk_flag=""
        if (params.keep_intermediate_steps) {
            keep_intermediate_trk_flag="--save_intermediate_tractograms"
        }
    """
      ls ${rois_folder}
      scil_tractogram_filter_by_anatomy.py ${tractogram} \
        ${rois_folder}/${params.atlas.JHU_8} \
        ${meta.id} \
        --minL ${params.min_streamline_length} \
        --maxL ${params.max_streamline_length} \
        --angle ${params.loop_angle_threshold} \
        --csf_bin ${rois_folder}/${params.atlas.csf} \
        --processes ${params.processes_major_filtering} \
        --save_rejected \
        $keep_intermediate_trk_flag \
        -f

      mv ${meta.id}/${tractogram.getSimpleName()}_filtered.trk ${meta.id}__wb_clean01.trk
      mv ${meta.id}/${tractogram.getSimpleName()}_rejected.trk ${meta.id}__unplausible_streamlines.trk
    """
}