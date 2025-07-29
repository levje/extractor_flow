include { FILTER_LIST as EXTRACT_FORNIX } from './filter_with_list/main.nf'

include { FILTER_LIST as EXTRACT_EE_CEREBELLUM } from './filter_with_list/main.nf'
include { FILTER_LIST as EXTRACT_PLAUSIBLE_CEREBELLUM } from './filter_with_list/main.nf'

include { FILTER_LIST as EXTRACT_EE_BRAINSTEM } from './filter_with_list/main.nf'
include { FILTER_LIST as EXTRACT_PLAUSIBLE_BRAINSTEM } from './filter_with_list/main.nf'

include { FILTER_LIST as Remove_out_of_CGM_DWM } from './filter_with_list/main.nf'
include { FILTER_LIST as Extract_all_commissural } from './filter_with_list/main.nf'
include { FILTER_LIST as Extract_plausible_CC_Cx } from './filter_with_list/main.nf'
include { FILTER_LIST as Extract_plausible_AC_Cx } from './filter_with_list/main.nf'
include { FILTER_LIST as Extract_plausible_CC_BG } from './filter_with_list/main.nf'
include { FILTER_LIST as Split_no_CC_Asso_and_BG } from './filter_with_list/main.nf'
include { FILTER_LIST as Split_BG_Thal } from './filter_with_list/main.nf'
include { FILTER_LIST as Split_BG_Put } from './filter_with_list/main.nf'
include { FILTER_LIST as Split_BG_Caud } from './filter_with_list/main.nf'
include { FILTER_LIST as Remove_Unplausible_Long_Range_Asso } from './filter_with_list/main.nf'
include { FILTER_LIST as CC_Homotopic } from './filter_with_list/main.nf'
include { FILTER_LIST as Asso_ventral } from './filter_with_list/main.nf'
include { FILTER_LIST as Split_asso_ventral_ifof_uf } from './filter_with_list/main.nf'
include { FILTER_LIST as Asso_dorsal_f_p } from './filter_with_list/main.nf'
include { FILTER_LIST as Asso_dorsal_f_o_f_t } from './filter_with_list/main.nf'
include { FILTER_LIST as Asso_p_o } from './filter_with_list/main.nf'
include { FILTER_LIST as Asso_p_t } from './filter_with_list/main.nf'
include { FILTER_LIST as Asso_o_t } from './filter_with_list/main.nf'
include { FILTER_LIST as Asso_ins } from './filter_with_list/main.nf'
include { FILTER_LIST as Asso_Cing } from './filter_with_list/main.nf'


workflow EXTRACT {
    take:
    unplausible
    wb

    main:

    EXTRACT_FORNIX(unplausible)
    EXTRACT_EE_CEREBELLUM(wb)
    Extract_plausible_cerebellum(EXTRACT_EE_CEREBELLUM.out.remaining)
    EXTRACT_EE_BRAINSTEM(EXTRACT_EE_CEREBELLUM.out.extracted)
    Extract_plausible_brainstem(EXTRACT_EE_BRAINSTEM.out.remaining)

}

process Extract_plausible_cerebellum {
  tag "$meta.id"
  cpus 1

  container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

  input:
    tuple val(meta), path(tractogram) // from ee_cerebellum_for_extract_plausible

  output:
    tuple val(meta), path("${meta.id}__all_cerebellum_plausibles.trk"), emit: plausible
    path "${meta.id}__all_in_cerebellum_nocx_nocerebwm.trk"
    path "${meta.id}__all_in_cerebellum_in_Medulla.trk"
    path "${meta.id}__all_in_cerebellum_in_Pons.trk"
    path "${meta.id}__all_in_cerebellum_in_Midbrain.trk"
    path "${meta.id}__all_in_cerebellum_in_redN_and_Thal.trk"

  script:
  """
  scil_filter_tractogram.py ${tractogram} ${meta.id}__tmp_in_cerebellum.trk\
        --filtering_list ${params.FLF}in_cerebellum.txt -f
  scil_filter_tractogram.py ${meta.id}__tmp_in_cerebellum.trk ${meta.id}__all_in_cerebellum_nocx_nocerebwm.trk\
        --filtering_list ${params.FLF}cerebellum_nocx_in_cereb.txt -f
  scil_filter_tractogram.py ${meta.id}__tmp_in_cerebellum.trk ${meta.id}__all_in_cerebellum_in_Medulla.trk\
        --filtering_list ${params.FLF}cerebellum_in_medulla.txt -f
  scil_filter_tractogram.py ${meta.id}__tmp_in_cerebellum.trk ${meta.id}__all_in_cerebellum_in_Pons.trk\
        --filtering_list ${params.FLF}cerebellum_in_pons.txt -f
  scil_filter_tractogram.py ${meta.id}__tmp_in_cerebellum.trk ${meta.id}__all_in_cerebellum_in_Midbrain.trk\
        --filtering_list ${params.FLF}cerebellum_in_midbrain.txt -f
  scil_filter_tractogram.py ${meta.id}__tmp_in_cerebellum.trk ${meta.id}__all_in_cerebellum_in_redN_and_Thal.trk\
        --filtering_list ${params.FLF}cerebellum_in_rednucleus_and_thalamus.txt -f
  scil_tractogram_math.py union ${meta.id}__all_in_*.trk ${meta.id}__all_cerebellum_plausibles.trk --save_empty -f
  """
}

process Extract_plausible_brainstem {
  tag "$meta.id"
  cpus 1

  container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

  input:
    tuple val(meta), path(tractogram) // from all_brainstem_for_extract_plausible
  output:
    tuple val(meta), path("${meta.id}__all_brainstem_plausibles.trk"), emit: brainstem_for_trk_plausible
    path "${meta.id}__all_brainstem_unplausibles.trk", optional: true
    path "${meta.id}__be_midbrain.trk"
    path "${meta.id}__be_medulla.trk"
    path "${meta.id}__be_pons.trk"
    path "${meta.id}__ee_thalamus.trk"
    path "${meta.id}__ee_red_nucleus.trk"
    tuple val(meta), path("${meta.id}__ee_fronto_pontine.trk"), emit: brainstem_corticopontine_frontal_for_rename
    tuple val(meta), path("${meta.id}__ee_parietotemporooccipital_pontine.trk"), emit: brainstem_ee_corticopontine_parietotemporooccipital_for_rename
    tuple val(meta), path("${meta.id}__ee_pyramidal.trk"), emit: brainstem_pyramidal_for_rename
    path "${meta.id}__ee_cortico_tectal.trk"

  script:
  """
  # Extract be midbrain
  scil_filter_tractogram.py ${meta.id}__all_brainstem.trk ${meta.id}__be_midbrain.trk\
      --filtering_list ${params.FLF}brainstem_be_midbrain.txt -f
  # Extract be medulla
  scil_filter_tractogram.py ${meta.id}__all_brainstem.trk ${meta.id}__be_medulla.trk\
      --filtering_list ${params.FLF}brainstem_be_medulla.txt -f
  # Extract be pons
  scil_filter_tractogram.py ${meta.id}__all_brainstem.trk ${meta.id}__be_pons.trk\
      --filtering_list ${params.FLF}brainstem_be_pons.txt -f

  # Extract ee thalamus
  scil_filter_tractogram.py ${meta.id}__all_brainstem.trk ${meta.id}__ee_thalamus.trk\
      --filtering_list ${params.FLF}brainstem_ee_thalamus.txt -f
  # Extract ee red_nucleus
  scil_filter_tractogram.py ${meta.id}__all_brainstem.trk ${meta.id}__ee_red_nucleus.trk\
      --filtering_list ${params.FLF}brainstem_ee_red_nucleus.txt -f

  # Prepartion for fronto-pontine, parietotemporooccipito-pontine, pyramidal, cortico-tectal
  scil_filter_tractogram.py ${meta.id}__all_brainstem.trk ${meta.id}__ee_tmp_01.trk\
      --filtering_list ${params.FLF}brainstem_ee_tmp_01.txt -f
  scil_filter_tractogram.py ${meta.id}__all_brainstem.trk ${meta.id}__ee_tmp_02.trk\
      --filtering_list ${params.FLF}brainstem_ee_tmp_02.txt -f

  scil_tractogram_math.py union ${meta.id}__ee_tmp_01.trk ${meta.id}__ee_tmp_02.trk\
      ${meta.id}__ee_tmp_03.trk --save_empty -f

  # Extract ee Fronto-pontine R and L
  scil_filter_tractogram.py ${meta.id}__ee_tmp_03.trk ${meta.id}__ee_fronto_pontine_R.trk\
      --filtering_list ${params.FLF}brainstem_ee_F_pontine_R.txt -f
  scil_filter_tractogram.py ${meta.id}__ee_tmp_03.trk ${meta.id}__ee_fronto_pontine_L.trk\
      --filtering_list ${params.FLF}brainstem_ee_F_pontine_L.txt -f
  scil_tractogram_math.py union ${meta.id}__ee_fronto_pontine_L.trk ${meta.id}__ee_fronto_pontine_R.trk\
      ${meta.id}__ee_fronto_pontine.trk --save_empty -f

  # Extract ee ParietoTemporooccipital pontine R and L
  scil_filter_tractogram.py ${meta.id}__ee_tmp_03.trk ${meta.id}__ee_parietotemporooccipital_pontine_R.trk\
      --filtering_list ${params.FLF}brainstem_ee_PTO_pontine_R.txt -f
  scil_filter_tractogram.py ${meta.id}__ee_tmp_03.trk ${meta.id}__ee_parietotemporooccipital_pontine_L.trk\
      --filtering_list ${params.FLF}brainstem_ee_PTO_pontine_L.txt -f
  scil_tractogram_math.py union ${meta.id}__ee_parietotemporooccipital_pontine_L.trk ${meta.id}__ee_parietotemporooccipital_pontine_R.trk\
      ${meta.id}__ee_parietotemporooccipital_pontine.trk --save_empty -f

  # Extract ee Pyramidal
  scil_filter_tractogram.py ${meta.id}__ee_tmp_03.trk ${meta.id}__ee_pyramidal.trk\
      --filtering_list ${params.FLF}brainstem_ee_pyramidal.txt -f

  # Extract ee Tectal
  scil_filter_tractogram.py ${meta.id}__ee_tmp_03.trk ${meta.id}__ee_cortico_tectal.trk\
      --filtering_list ${params.FLF}brainstem_ee_cortico_tectal.txt -f
  scil_filter_streamlines_by_length.py ${meta.id}__ee_cortico_tectal.trk ${meta.id}__ee_cortico_tectal.trk --maxL 100 -f

  rm -f ${meta.id}__*tmp_*.trk

  scil_tractogram_math.py union ${meta.id}__be_*.trk ${meta.id}__ee_*.trk ${meta.id}__all_brainstem_plausibles.trk --save_empty -f

  if ${params.keep_intermediate_steps}
  then
    scil_tractogram_math.py difference ${meta.id}__all_brainstem.trk ${meta.id}__all_brainstem_plausibles.trk ${meta.id}__all_brainstem_unplausibles.trk  --save_empty -f
  fi
  """
}

process Merge_BG_Thal {
  cpus 1

  input:
    tuple val(meta), path(tractogram) //// from BG_ipsi_Thal_list_for_merge

  output:
    tuple val(meta), "${meta.id}__BG_ipsi_Thal_all.trk", emit: BG_ipsi_Thal_for_trk_plausible

  script:
  """
  scil_tractogram_math.py union ${tractogram} ${meta.id}__BG_ipsi_Thal_all.trk --save_empty -f
  """
}

process Merge_BG_Put {
  cpus 1

  input:
    tuple val(meta), path(tractogram) // from BG_ipsi_Put_list_for_merge

  output:
    tuple val(meta), "${meta.id}__BG_ipsi_Put_all.trk", emit: BG_ipsi_Put_for_trk_plausible

  script:
  """
  scil_tractogram_math.py union ${tractogram} ${meta.id}__BG_ipsi_Put_all.trk --save_empty -f
  """
}

process Merge_BG_Caud {
  cpus 1

  input:
    tuple val(meta), path(tractogram) // from BG_ipsi_Caud_list_for_merge

  output:
    tuple val(meta), "${meta.id}__BG_ipsi_Caud_all.trk", emit: BG_ipsi_Caud_for_trk_plausible

  script:
  """
  scil_tractogram_math.py union ${tractogram} ${meta.id}__BG_ipsi_Caud_all.trk --save_empty -f
  """
}

process Split_asso_in_hemi {
  cpus 1

  input:
    tuple val(meta), path(tractogram) // from asso_noBG_for_split_hemi
    each side // from sides

  output:
    tuple val(meta), val(side), "${meta.id}__asso_${side}.trk", emit: asso_for_extract_u_shape
    file "${meta.id}__asso_${side}.txt" optional true

  script:
  """
  scil_filter_tractogram.py ${tractogram} ${meta.id}__asso_L.trk\
   --filtering_list ${params.FLF}asso_L.txt -f
   scil_filter_tractogram.py ${tractogram} ${meta.id}__asso_R.trk\
    --filtering_list ${params.FLF}asso_R.txt -f
  """
}

process Split_ushape_CGM_asso {
  cpus 1

  input:
    tuple val(meta), val(side), path(tractogram) // from asso_for_extract_u_shape

  output:
    tuple val(meta), val(side), "${meta.id}__asso_only_in_CGM_${side}.trk", emit: assoCGM
    tuple val(meta), val(side), "${meta.id}__asso_Ushape_${side}.trk", emit: assoUShape
    tuple val(meta), "${meta.id}__asso_Ushape_${side}_u.trk", emit: asso_u_shape_for_trk_plausible
    tuple val(meta), val(side), "${meta.id}__asso_Ushape_${side}_u.trk", emit: asso_u_shape_for_rename

    tuple val(meta), val(side), "${meta.id}__asso_f_${side}.trk", emit: asso_for_remove_long_range
    file "${meta.id}__asso_only_in_CGM_${side}.txt" optional true
    file "${meta.id}__asso_Ushape_${side}.txt" optional true
    file "${meta.id}__asso_f_${side}.txt" optional true

    script:
    """
    scil_filter_tractogram.py ${tractogram} ${meta.id}__tmp1_${side}.trk \
    --filtering_list ${params.FLF}all_in_CGM_${side}.txt -f

    scil_tractogram_math.py difference ${tractogram} ${meta.id}__tmp1_${side}.trk \
                            ${meta.id}__asso_SWM_${side}.trk --save_empty -f

    scil_filter_tractogram.py ${meta.id}__tmp1_${side}.trk ${meta.id}__asso_only_in_CGM_${side}.trk \
    --filtering_list ${params.FLF}not_in_SWM_${side}.txt -f

    scil_tractogram_math.py difference ${meta.id}__tmp1_${side}.trk ${meta.id}__asso_only_in_CGM_${side}.trk \
                                ${meta.id}__tmp2_${side}.trk --save_empty -f

    scil_filter_tractogram.py ${meta.id}__tmp2_${side}.trk ${meta.id}__asso_Ushape_${side}.trk \
    --filtering_list ${params.FLF}not_in_DWM_${side}.txt -f

    scil_extract_ushape.py ${meta.id}__asso_Ushape_${side}.trk --minU 0.5 --maxU 1 ${meta.id}__asso_Ushape_${side}_u.trk -f

    scil_tractogram_math.py difference ${meta.id}__tmp2_${side}.trk ${meta.id}__asso_Ushape_${side}.trk \
                            ${meta.id}__asso_DWM_${side}.trk --save_empty -f

    scil_tractogram_math.py union ${meta.id}__asso_DWM_${side}.trk ${meta.id}__asso_SWM_${side}.trk ${meta.id}__asso_f_${side}.trk --save_empty -f

    if ${params.keep_intermediate_steps}
    then
    scil_count_streamlines.py ${meta.id}__asso_only_in_CGM_${side}.trk > ${meta.id}__asso_only_in_CGM_${side}.txt
    scil_count_streamlines.py ${meta.id}__asso_Ushape_${side}.trk > ${meta.id}__asso_Ushape_${side}.txt
    scil_count_streamlines.py ${meta.id}__asso_f_${side}.trk > ${meta.id}__asso_f_${side}.txt
    fi
    """
}

process CC_Homotopic_merge {
  cpus 1

input:
  tuple val(meta), path(tractogram) // from CC_Homotopic_list_for_merge

output:
  tuple val(meta), "${meta.id}__CC_homo.trk", emit: CC_homo_for_trk_plausible, CC_homo_for_renaming, cc_homo_for_commissural

script:
  """
  scil_tractogram_math.py union ${tractogram} ${meta.id}__CC_homo.trk --save_empty
  """
}

process CC_all_commissural {
  cpus 1

  input:
    tuple val(meta), path(tmp_cc), path(accx), path(ccbg), path(cc_homo) // from all_cc_for_commissural

  output:
    tuple val(meta), "${meta.id}__plausible_commissural_${params.template_space}.trk", emit: plausible_commissural_for_register_to_orig
    file "${meta.id}__unplausible_commissural.trk" optional true

  script:
  """
    scil_tractogram_math.py union ${accx} ${ccbg} ${cc_homo} ${meta.id}__plausible_commissural_${params.template_space}.trk --save_empty -f

    if ${params.keep_intermediate_steps}
    then
      scil_tractogram_math.py difference ${tmp_cc} ${meta.id}__plausible_commissural_${params.template_space}.trk ${meta.id}__unplausible_commissural.trk --save_empty -f
    fi
  """
}

process Merge_asso_ventral {
  cpus 1

  input:
    tuple val(meta), val(side), path(trk01), path(trk02), path(trk03) // from asso_all_intra_inter_ventral_all_for_merge

  output:
    tuple val(meta), "${meta.id}__asso_all_ventral_f_${side}.trk", emit: asso_all_ventral_for_trk_plausible
    tuple val(meta), val(side), "${meta.id}__asso_all_ventral_f_${side}.trk", emit: asso_all_ventral_for_split_ifof_uf

  script:
  """
  scil_tractogram_math.py union ${trk01} ${trk02} ${trk03} ${meta.id}__asso_all_ventral_f_${side}.trk --save_empty -f
  """
}

process Merge_asso_dorsal_f_p {
  cpus 1

  input:
    tuple val(meta), val(side), path(tractogram) // from asso_all_intra_inter_dorsal_f_p_list_for_merge

  output:
    tuple val(meta), val(side), "${meta.id}__asso_F_P_dorsal_f_${side}.trk", emit: asso_all_intra_inter_dorsal_all_f_p_for_merge

  script:
  """
  scil_tractogram_math.py union ${tractogram} ${meta.id}__asso_F_P_dorsal_f_${side}.trk --save_empty -f
  """
}

process Merge_asso_dorsal {
  cpus 1

  input:
    tuple val(meta), val(side), path(trk01), path(trk02), path(trk03) // from asso_all_intra_inter_dorsal_all_for_merge

  output:
    tuple val(meta), "${meta.id}__asso_all_dorsal_f_${side}.trk", emit: asso_all_dorsal_for_trk_plausible

  script:
  """
  scil_tractogram_math.py union ${trk01} ${trk02} ${trk03} ${meta.id}__asso_all_dorsal_f_${side}.trk --save_empty -f
  """
}

process Merge_p_o {
  cpus 1

  input:
    tuple val(meta), val(side), path(tractogram) // from asso_intra_inter_p_o_list_for_merge

  output:
    tuple val(meta), "${meta.id}__asso_all_P_O_f_${side}.trk", emit: all_P_O_for_trk_plausible

  script:
  """
  scil_tractogram_math.py union ${tractogram} ${meta.id}__asso_all_P_O_f_${side}.trk --save_empty -f
  """
}

process Merge_p_t {
  cpus 1

  input:
    tuple val(meta), val(side), path(tractogram) // from asso_intra_inter_p_t_list_for_merge

  output:
    tuple val(meta), "${meta.id}__asso_all_P_T_f_${side}.trk", emit: all_P_T_for_trk_plausible

  script:
  """
  scil_tractogram_math.py union ${tractogram} ${meta.id}__asso_all_P_T_f_${side}.trk --save_empty -f
  """
}

process Merge_o_t {
  cpus 1

  input:
    tuple val(meta), val(side), path(tractogram) // from asso_intra_inter_o_t_list_for_merge

  output:
    tuple val(meta), "${meta.id}__asso_all_O_T_f_${side}.trk", emit: all_O_T_for_trk_plausible
    tuple val(meta), val(side), "${meta.id}__asso_all_O_T_f_${side}.trk", emit: all_O_T_for_rename

  script:
  """
  scil_tractogram_math.py union ${tractogram} ${meta.id}__asso_all_O_T_f_${side}.trk --save_empty -f
  """
}

process Merge_ins {
  cpus 1

  input:
    tuple val(meta), val(side), path(tractogram) // from asso_intra_inter_ins_list_for_merge

  output:
    tuple val(meta), "${meta.id}__asso_all_Ins_f_${side}.trk", emit: Ins_for_trk_plausible

  script:
  """
  scil_tractogram_math.py union ${tractogram} ${meta.id}__asso_all_Ins_f_${side}.trk --save_empty -f
  """
}
