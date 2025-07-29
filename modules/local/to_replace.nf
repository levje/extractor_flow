// include { REGISTRATION_TRACTOGRAM } from '../../modules/nf-neuro/registration/tractogram/main'
// include { REGISTRATION_TRACTOGRAM as REGISTER_TRACTOGRAM_ORIG } from '../../modules/nf-neuro/registration/tractogram/main'

// THIS SHOULD BE REPLACED WITH THE NF-NEURO MODULE REGISTRATION_TRACTOGRAM (as commented above)
process REGISTRATION_TRACTOGRAM {
//   publishDir = params.final_output_orig_space
  cpus 1

  input:
    tuple val(meta), path(t1), path(transfo), path(trk), path(ref), path(deformation)

  output:
    tuple val(meta), path("${meta.id}*.trk"), emit: warped_tractogram

  when:
  task.ext.when == null || task.ext.when

  script:
  def inverse = task.ext.inverse ? "--inverse" : ""
  def reverse_operation = task.ext.reverse_operation ? "--reverse_operation" : ""
  def keep_invalid = task.ext.keep_invalid ? "--keep_invalid" : ""
  def remove_invalid = task.ext.remove_invalid ? "--remove_invalid" : ""
  def replace_key = task.ext.suffix ? task.ext.suffix : ""
  def replace_value = task.ext.suffix ? task.ext.suffix : ""
  def suffix = task.ext.suffix ? "_${task.ext.suffix}" : ""

  def trk_output_name = trk.getSimpleName().replaceAll(replace_key, replace_value)

  """
    scil_tractogram_apply_transform.py \
      ${trk} \
      ${t1} \
      ${transfo} \
      ${trk_output_name}${suffix}.trk \
      --in_deformation ${deformation} \
      ${reverse_operation} \
      ${inverse} \
      ${keep_invalid} \
      ${remove_invalid}
  """
}
