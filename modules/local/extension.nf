include { FILTER_LIST_EACH as RENAME_CORTICOPONTINE_F } from './filter_with_list/main.nf'
include { FILTER_LIST_EACH as RENAME_CORTICOPONTINE_POT } from './filter_with_list/main.nf'
include { FILTER_LIST_EACH as RENAME_CST } from './filter_with_list/main.nf'

include { TRACTOGRAM_MATH as RENAME_CORTICO_STRIATE } from './merge/main.nf'
include { TRACTOGRAM_MATH as RENAME_CORONARADIATA } from './merge/main.nf'
include { TRACTOGRAM_MATH as RENAME_OPTICAL_RADIATION } from './merge/main.nf'
include { TRACTOGRAM_MATH as RENAME_SLF } from './merge/main.nf'

include { COPY_FILE as RENAME_USHAPE } from './copy_file/main.nf'
include { COPY_FILE as RENAME_CING } from './copy_file/main.nf'
include { COPY_FILE as RENAME_AF } from './copy_file/main.nf'
include { COPY_FILE as RENAME_FORNIX } from './copy_file/main.nf'
include { COPY_FILE as RENAME_IFOF } from './copy_file/main.nf'
include { COPY_FILE as RENAME_UF } from './copy_file/main.nf'
include { COPY_FILE as RENAME_ILF } from './copy_file/main.nf'
include { COPY_FILE as RENAME_BRAINSTEM } from './copy_file/main.nf'
include { COPY_FILE as RENAME_CEREBELLUM } from './copy_file/main.nf'
include { COPY_FILE as RENAME_ACCX } from './copy_file/main.nf'

workflow EXTRACT_BUNDLES {
    take:
    trks
    sides
    
    main:
    empty_lists = Channel.from([""])

    /* RENAME CC CC_Homotopic */
    ch = trks.CC_Homotopic_frontal_for_rename
      .combine(trks.CC_Homotopic_occipital_for_rename)
      .combine(trks.CC_Homotopic_temporal_for_rename)
      .combine(trks.CC_Homotopic_parietal_for_rename)
      .combine(trks.CC_Homotopic_insular_for_rename)
      .combine(trks.CC_Homotopic_cingulum_for_rename)
      .map { frontal, occipital, temporal, parietal, insular, cingulum ->
          def meta = frontal[0]
          def list = frontal[1]
          def tractogram_map = [
              cc_homotopic_frontal:   frontal[2],
              cc_homotopic_occipital: occipital[2],
              cc_homotopic_temporal:  temporal[2],
              cc_homotopic_parietal:  parietal[2],
              cc_homotopic_insular:   insular[2],
              cc_homotopic_cingulum:  cingulum[2],
          ]
          tuple(meta, list, tractogram_map)
      }
    RENAME_CC_HOMOTOPIC(ch)

    /* RENAME CORTICO_STRIATE */
    corticostriate_for_rename = trks.BG_ipsi_Caud_for_rename.concat(trks.BG_ipsi_Put_for_rename).groupTuple(by:[0,1])
    RENAME_CORTICO_STRIATE(corticostriate_for_rename)

    /* RENAME Corona radiata */
    RENAME_CORONARADIATA(trks.BG_ipsi_Thal_for_rename)

    /* RENAME OPTICAL RADIATION */
    RENAME_OPTICAL_RADIATION(trks.optic_radiation_for_rename)

    /* RENAME U-SHAPE */
    RENAME_USHAPE(trks.asso_u_shape_for_rename)

    /* RENAME CINGULUM */
    RENAME_CING(trks.Cing_for_rename)

    /* RENAME SLF */
    slf_for_rename = trks.asso_all_intra_inter_dorsal_all_f_O_for_rename.concat(trks.asso_all_intra_inter_dorsal_f_p_for_rename).groupTuple(by:[0,1])
      .map { sid, side, _list, tractogram -> [sid, side, tractogram] }
    RENAME_SLF(slf_for_rename)

    /* RENAME AF */
    af_for_rename = trks.asso_all_intra_inter_dorsal_all_f_T_for_rename
      .map { sid, side, _asso_list, tractogram -> [sid, side, tractogram] }
    RENAME_AF(af_for_rename)

    /* RENAME Cortico-pontine_F */
    RENAME_CORTICOPONTINE_F(trks.brainstem_corticopontine_frontal_for_rename, empty_lists, sides)

    /* RENAME cortico-pontine_POT */
    RENAME_CORTICOPONTINE_POT(trks.brainstem_ee_corticopontine_parietotemporooccipital_for_rename, empty_lists, sides)

    /* RENAME Pyramidal tract (CST) */
    RENAME_CST(trks.brainstem_pyramidal_for_rename, empty_lists, sides)

    /* RENAME fornix */
    fornix_with_list = trks.fornix_for_rename.map { sid, tractogram -> [sid, "", tractogram] }
    RENAME_FORNIX(fornix_with_list)

    /* RENAME IFOF */
    RENAME_IFOF(trks.asso_IFOF_for_rename)

    /* RENAME UF */
    RENAME_UF(trks.asso_UF_for_rename)

    /* RENAME ILF */
    RENAME_ILF(trks.all_O_T_for_rename)

    /* RENAME BRAINSTEM */
    brainstem_with_list = trks.brainstem_for_rename.map { sid, tractogram -> [sid, "", tractogram] }
    RENAME_BRAINSTEM(brainstem_with_list)

    /* RENAME CEREBELLUM */
    cerebellum_with_list = trks.cerebellum_for_rename.map { sid, tractogram -> [sid, "", tractogram] }
    RENAME_CEREBELLUM(cerebellum_with_list)

    /* RENAME AC_CX */
    accx_with_list = trks.accx_for_rename.map { sid, tractogram -> [sid, "", tractogram] }
    RENAME_ACCX(accx_with_list)

    bundles = RENAME_CC_HOMOTOPIC.out.cc_homotopic_frontal
        .concat(RENAME_CC_HOMOTOPIC.out.cc_homotopic_occipital)
        .concat(RENAME_CC_HOMOTOPIC.out.cc_homotopic_temporal)
        .concat(RENAME_CC_HOMOTOPIC.out.cc_homotopic_parietal)
        .concat(RENAME_CC_HOMOTOPIC.out.cc_homotopic_insular)
        .concat(RENAME_CC_HOMOTOPIC.out.cc_homotopic_cingulum)
        .concat(RENAME_CORTICO_STRIATE.out.tractogram)
        .concat(RENAME_CORONARADIATA.out.tractogram)
        .concat(RENAME_OPTICAL_RADIATION.out.tractogram)
        .concat(RENAME_USHAPE.out.output_file)
        .concat(RENAME_CING.out.output_file)
        .concat(RENAME_SLF.out.tractogram)
        .concat(RENAME_AF.out.output_file)
        .concat(RENAME_CORTICOPONTINE_F.out.extracted)
        .concat(RENAME_CORTICOPONTINE_POT.out.extracted)
        .concat(RENAME_CST.out.extracted)
        .concat(RENAME_FORNIX.out.output_file)
        .concat(RENAME_IFOF.out.output_file)
        .concat(RENAME_UF.out.output_file)
        .concat(RENAME_ILF.out.output_file)
        .concat(RENAME_BRAINSTEM.out.output_file)
        .concat(RENAME_CEREBELLUM.out.output_file)
        .concat(RENAME_ACCX.out.output_file)
        .concat(trks.plausible_commissural)

    emit:
    bundles 
}

process RENAME_CC_HOMOTOPIC {
  cpus 1

  container "mrzarfir/scilus-tmp:1.6.0"

  input:
    // The tractogram_list should contain exactly the following: [
    //    cc_homotopic_frontal:   "<path>",
    //    cc_homotopic_occipital: "<path>",
    //    cc_homotopic_temporal:  "<path>",
    //    cc_homotopic_parietal:  "<path>",
    //    cc_homotopic_insular:   "<path>",
    //    cc_homotopic_cingulum:  "<path>",
    // ]
    tuple val(meta), val(list), path(tractogram_list)
  output:
    tuple val(meta), path("${meta.id}__cc_homotopic_frontal_${params.mni_space}.trk"), emit: cc_homotopic_frontal
    tuple val(meta), path("${meta.id}__cc_homotopic_occipital_${params.mni_space}.trk"), emit: cc_homotopic_occipital
    tuple val(meta), path("${meta.id}__cc_homotopic_temporal_${params.mni_space}.trk"), emit: cc_homotopic_temporal
    tuple val(meta), path("${meta.id}__cc_homotopic_parietal_${params.mni_space}.trk"), emit: cc_homotopic_parietal
    tuple val(meta), path("${meta.id}__cc_homotopic_insular_${params.mni_space}.trk"), emit: cc_homotopic_insular
    tuple val(meta), path("${meta.id}__cc_homotopic_cingulum_${params.mni_space}.trk"), emit: cc_homotopic_cingulum

  script:

    // Make sure that we have exactly 6 tractograms
    if (tractogram_list.size() != 6) {
      error "Expected exactly 6 tractograms for CC_Homotopic, but got ${tractogram_list.size()}"
    }

    trk01 = tractogram_list.cc_homotopic_frontal
    trk02 = tractogram_list.cc_homotopic_occipital
    trk03 = tractogram_list.cc_homotopic_temporal
    trk04 = tractogram_list.cc_homotopic_parietal
    trk05 = tractogram_list.cc_homotopic_insular
    trk06 = tractogram_list.cc_homotopic_cingulum
  """
  scil_tractogram_math.py union ${trk01} "${meta.id}__cc_homotopic_frontal_${params.mni_space}.trk" --save_empty -f
  scil_tractogram_math.py union ${trk02} "${meta.id}__cc_homotopic_occipital_${params.mni_space}.trk" --save_empty -f
  scil_tractogram_math.py union ${trk03} "${meta.id}__cc_homotopic_temporal_${params.mni_space}.trk" --save_empty -f
  scil_tractogram_math.py union ${trk04} "${meta.id}__cc_homotopic_parietal_${params.mni_space}.trk" --save_empty -f
  cp ${trk05} ${meta.id}__cc_homotopic_insular_${params.mni_space}.trk -f
  cp ${trk06} ${meta.id}__cc_homotopic_cingulum_${params.mni_space}.trk -f
  """
}
