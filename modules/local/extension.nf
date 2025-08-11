include { FILTER_LIST_EACH as RENAME_CORTICOPONTINE_F } from './filter_with_list/main.nf'
include { FILTER_LIST_EACH as RENAME_CORTICOPONTINE_POT } from './filter_with_list/main.nf'
include { FILTER_LIST_EACH as RENAME_CST } from './filter_with_list/main.nf'

include { TRACTOGRAM_MATH as RENAME_CC_HOMO_FRONTAL } from './merge/main.nf'
include { TRACTOGRAM_MATH as RENAME_CC_HOMO_OCCIPITAL } from './merge/main.nf'
include { TRACTOGRAM_MATH as RENAME_CC_HOMO_TEMPORAL } from './merge/main.nf'
include { TRACTOGRAM_MATH as RENAME_CC_HOMO_PARIETAL } from './merge/main.nf'

include { TRACTOGRAM_MATH as RENAME_CORTICO_STRIATE } from './merge/main.nf'
include { TRACTOGRAM_MATH as RENAME_CORONARADIATA } from './merge/main.nf'
include { TRACTOGRAM_MATH as RENAME_OPTICAL_RADIATION } from './merge/main.nf'
include { TRACTOGRAM_MATH as RENAME_SLF } from './merge/main.nf'

include { COPY_FILE as RENAME_CC_HOMO_INSULAR } from './copy_file/main.nf'
include { COPY_FILE as RENAME_CC_HOMO_CINGULUM } from './copy_file/main.nf'
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
    RENAME_CC_HOMO_FRONTAL(trks.key_CC_Homotopic_frontal_for_rename.map { sid, _list, tractograms -> [sid, [], tractograms]})
    RENAME_CC_HOMO_OCCIPITAL(trks.key_CC_Homotopic_occipital_for_rename.map { sid, _list, tractograms -> [sid, [], tractograms]})
    RENAME_CC_HOMO_TEMPORAL(trks.key_CC_Homotopic_temporal_for_rename.map { sid, _list, tractograms -> [sid, [], tractograms]})
    RENAME_CC_HOMO_PARIETAL(trks.key_CC_Homotopic_parietal_for_rename.map { sid, _list, tractograms -> [sid, [], tractograms]})
    RENAME_CC_HOMO_INSULAR(trks.key_CC_Homotopic_insular_for_rename.map { sid, _list, tractograms -> [sid, [], tractograms]})
    RENAME_CC_HOMO_CINGULUM(trks.key_CC_Homotopic_cingulum_for_rename.map { sid, _list, tractograms -> [sid, [], tractograms]})

    /* RENAME CORTICO_STRIATE */
    corticostriate_for_rename = trks.key_BG_ipsi_Caud_for_rename.concat(trks.key_BG_ipsi_Put_for_rename).groupTuple(by:[0,1])
    RENAME_CORTICO_STRIATE(corticostriate_for_rename)

    /* RENAME Corona radiata */
    RENAME_CORONARADIATA(trks.key_BG_ipsi_Thal_for_rename)

    /* RENAME OPTICAL RADIATION */
    RENAME_OPTICAL_RADIATION(trks.key_optic_radiation_for_rename.map { sid, side, _list, tractograms -> [sid, side, tractograms] })

    /* RENAME U-SHAPE */
    RENAME_USHAPE(trks.key_asso_u_shape_for_rename)

    /* RENAME CINGULUM */
    RENAME_CING(trks.key_Cing_for_rename)

    /* RENAME SLF */
    slf_for_rename = trks.key_asso_all_intra_inter_dorsal_all_f_O_for_rename.concat(trks.key_asso_all_intra_inter_dorsal_f_p_for_rename).groupTuple(by:[0,1])
      .map { sid, side, _list, tractogram -> [sid, side, tractogram] }
    RENAME_SLF(slf_for_rename)

    /* RENAME AF */
    af_for_rename = trks.key_asso_all_intra_inter_dorsal_all_f_T_for_rename
      .map { sid, side, _asso_list, tractogram -> [sid, side, tractogram] }
    RENAME_AF(af_for_rename)

    /* RENAME Cortico-pontine_F */
    RENAME_CORTICOPONTINE_F(trks.key_brainstem_corticopontine_frontal_for_rename, empty_lists, sides)

    /* RENAME cortico-pontine_POT */
    RENAME_CORTICOPONTINE_POT(trks.key_brainstem_ee_corticopontine_parietotemporooccipital_for_rename, empty_lists, sides)

    /* RENAME Pyramidal tract (CST) */
    RENAME_CST(trks.key_brainstem_pyramidal_for_rename, empty_lists, sides)

    /* RENAME fornix */
    fornix_with_list = trks.key_fornix_for_rename.map { sid, tractogram -> [sid, "", tractogram] }
    RENAME_FORNIX(fornix_with_list)

    /* RENAME IFOF */
    RENAME_IFOF(trks.key_asso_IFOF_for_rename)

    /* RENAME UF */
    RENAME_UF(trks.key_asso_UF_for_rename)

    /* RENAME ILF */
    RENAME_ILF(trks.key_all_O_T_for_rename)

    /* RENAME BRAINSTEM */
    brainstem_with_list = trks.key_brainstem_for_rename.map { sid, tractogram -> [sid, "", tractogram] }
    RENAME_BRAINSTEM(brainstem_with_list)

    /* RENAME CEREBELLUM */
    cerebellum_with_list = trks.key_cerebellum_for_rename.map { sid, tractogram -> [sid, "", tractogram] }
    RENAME_CEREBELLUM(cerebellum_with_list)

    /* RENAME AC_CX */
    accx_with_list = trks.key_accx_for_rename.map { sid, tractogram -> [sid, "", tractogram] }
    RENAME_ACCX(accx_with_list)

    bundles_to_register = RENAME_CC_HOMO_FRONTAL.out.tractogram
        .concat(RENAME_CC_HOMO_OCCIPITAL.out.tractogram)
        .concat(RENAME_CC_HOMO_TEMPORAL.out.tractogram)
        .concat(RENAME_CC_HOMO_PARIETAL.out.tractogram)
        .concat(RENAME_CC_HOMO_INSULAR.out.output_file)
        .concat(RENAME_CC_HOMO_CINGULUM.out.output_file)
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
        .concat(trks.key_plausible_commissural)

    emit:
    bundles = bundles_to_register
}
