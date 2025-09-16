include { FILTER_LIST as EXTRACT_FORNIX } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST as EXTRACT_EE_CEREBELLUM } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST as EXTRACT_EE_BRAINSTEM } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST as REMOVE_OUT_OF_CGM_DWM } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST as EXTRACT_ALL_COMMISSURAL } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST as EXTRACT_PLAUSIBLE_CC_CX } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST as EXTRACT_PLAUSIBLE_AC_CX } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST as SPLIT_NO_CC_ASSO_AND_BG } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST_EACH as SPLIT_BG_THAL } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST_EACH as SPLIT_BG_PUT } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST_EACH as SPLIT_BG_CAUD } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST_SIDE as REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST_EACH as CC_HOMOTOPIC } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST_SIDE as ASSO_VENTRAL } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST_SIDE as SPLIT_ASSO_VENTRAL_IFOF_UF } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST_SIDE as ASSO_DORSAL_F_P } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST_SIDE as ASSO_DORSAL_F_O_F_T } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST_SIDE as ASSO_P_O } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST_SIDE as ASSO_P_T } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST_SIDE as ASSO_O_T } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST_SIDE as ASSO_INS } from '../../modules/local/filtering/filter_with_list.nf'
include { FILTER_LIST_SIDE as ASSO_CING } from '../../modules/local/filtering/filter_with_list.nf'

include { TRACTOGRAM_MATH as MERGE_BG_THAL } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_BG_PUT } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_BG_CAUD } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_CC_HOMOTOPIC } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_ASSO_VENTRAL } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_ASSO_DORSAL_F_P } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_ASSO_DORSAL } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_P_O } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_P_T } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_O_T } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_INS } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_ASSO_BE_FRONTAL_GYRUS } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_ASSO_EE_FRONTAL_GYRUS } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_ASSO_BE_OCCIPITAL_GYRUS } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_ASSO_EE_OCCIPITAL_GYRUS } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_ASSO_BE_PARIETAL_GYRUS } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_ASSO_EE_PARIETAL_GYRUS } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_ASSO_BE_TEMPORAL_GYRUS } from '../../modules/local/merge/main.nf'
include { TRACTOGRAM_MATH as MERGE_ASSO_EE_TEMPORAL_GYRUS } from '../../modules/local/merge/main.nf'

include { EXTRACT_BUNDLES } from './extension.nf'

workflow EXTRACT {
  take:
    unplausible
    wb
    sides
    mni_tractograms

  main:
    // Init channels with empty values as a default value for "each"
    empty_lists = Channel.from([""])
    empty_sides = Channel.from([""])

    /*
    Fornix
    */
    EXTRACT_FORNIX(unplausible)

    /*
    Cerebellum
    */
    EXTRACT_EE_CEREBELLUM(wb)
    EXTRACT_PLAUSIBLE_CEREBELLUM(EXTRACT_EE_CEREBELLUM.out.remaining)

    /*
    Brainstem
    */
    EXTRACT_EE_BRAINSTEM(EXTRACT_EE_CEREBELLUM.out.extracted)
    EXTRACT_PLAUSIBLE_BRAINSTEM(EXTRACT_EE_BRAINSTEM.out.remaining)

    /*
    Brain - Either end in CGM SWM
    */
    REMOVE_OUT_OF_CGM_DWM(EXTRACT_EE_BRAINSTEM.out.extracted)
    EXTRACT_ALL_COMMISSURAL(REMOVE_OUT_OF_CGM_DWM.out.extracted)
    EXTRACT_PLAUSIBLE_CC_CX(EXTRACT_ALL_COMMISSURAL.out.remaining)
    EXTRACT_PLAUSIBLE_AC_CX(EXTRACT_ALL_COMMISSURAL.out.remaining)
    EXTRACT_PLAUSIBLE_CC_BG(EXTRACT_ALL_COMMISSURAL.out.remaining)

    /*
    Split not CC in asso BG and not BG
    */
    SPLIT_NO_CC_ASSO_AND_BG(EXTRACT_ALL_COMMISSURAL.out.extracted)


    bg_list = Channel.from(params.bg_lists?.tokenize(','))
    /*
    BG THAL
    */
    SPLIT_BG_THAL(SPLIT_NO_CC_ASSO_AND_BG.out.extracted, bg_list, sides)
    bg_ipsi_thal_for_rename = SPLIT_BG_THAL.out.extracted_with_side.groupTuple(by:[0,1])
    cugwm_for_combine = SPLIT_BG_THAL.out.extracted_with_side_list.filter{it[2]=='CuGWM'}
    lgwm_for_combine = SPLIT_BG_THAL.out.extracted_with_side_list.filter{it[2]=='LGWM'}
    optic_radiation_for_rename = cugwm_for_combine.concat(lgwm_for_combine).groupTuple(by:[0,1])
    bg_ipsi_thal_list_for_merge = SPLIT_BG_THAL.out.extracted.groupTuple()
      .map { sid, tractograms -> [sid, [], tractograms] }
    MERGE_BG_THAL(bg_ipsi_thal_list_for_merge)

    /*
    BG PUT
    */
    SPLIT_BG_PUT(SPLIT_NO_CC_ASSO_AND_BG.out.extracted, bg_list, sides)
    bg_ipsi_put_list_for_merge = SPLIT_BG_PUT.out.extracted.groupTuple()
      .map { sid, tractograms -> [sid, [], tractograms] }
    MERGE_BG_PUT(bg_ipsi_put_list_for_merge)

    /*
    BG CAUD
    */
    bg_caud_list = params.bg_caud_lists?.tokenize(',')
    SPLIT_BG_CAUD(SPLIT_NO_CC_ASSO_AND_BG.out.extracted, bg_caud_list, sides)
    bg_ipsi_caud_list_for_merge = SPLIT_BG_CAUD.out.extracted.groupTuple()
      .map { sid, tractograms -> [sid, [], tractograms] }
    MERGE_BG_CAUD(bg_ipsi_caud_list_for_merge)

    SPLIT_ASSO_IN_HEMI(SPLIT_NO_CC_ASSO_AND_BG.out.remaining, empty_lists, sides)
    
    /*
    Extracting U-shaped and streamlines restricted to Cortical GM and removing them from asso
    */
    SPLIT_USHAPE_CGM_ASSO(SPLIT_ASSO_IN_HEMI.out.asso_for_extract_u_shape)

    /*
    Extracting unplausible long-range association streamlines passing through subcortical structures (Cd, Put, GP, Thal, Amyg)
    */
    REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO(SPLIT_USHAPE_CGM_ASSO.out.asso_for_remove_long_range, empty_lists)

    asso_all_intra_inter = REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side
    asso_all_intra_inter_list = asso_all_intra_inter.groupTuple().map{it.flatten().toList()}
    assoCGM_list = SPLIT_USHAPE_CGM_ASSO.out.assoCGM.groupTuple().map{it.flatten().toList()}

    /*
    CC Homotopic
    */

    cc_homotopic_pairs = params.cc_homotopic_pairs?.tokenize(',')   
    CC_HOMOTOPIC(EXTRACT_PLAUSIBLE_CC_CX.out.extracted, cc_homotopic_pairs, empty_sides)


    /*
    Filter + Concat frontal
    */
    CC_IFGWM_for_combine_frontal    = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='IFGWM'}
    CC_SFGWM_for_combine_frontal    = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='SFGWM'}
    CC_MFGWM_for_combine_frontal    = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='MFGWM'}
    CC_MFOGWM_for_combine_frontal   = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='MFOGWM'}
    CC_LFOGWM_for_combine_frontal   = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='LFOGWM'}
    CC_PrCGWM_for_combine_frontal   = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='PrCGWM'}
    CC_RGGWM_for_combine_frontal    = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='RGGWM'}
    CC_Homotopic_frontal_for_rename = CC_IFGWM_for_combine_frontal.concat(CC_SFGWM_for_combine_frontal).concat(CC_MFGWM_for_combine_frontal).concat(CC_MFOGWM_for_combine_frontal).concat(CC_LFOGWM_for_combine_frontal).concat(CC_PrCGWM_for_combine_frontal).concat(CC_RGGWM_for_combine_frontal).groupTuple(by:0).map{ it }
    

    /*
    Filter + Concat occipital
    */
    CC_SOGWM_for_combine_occipital  = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='SOGWM'}
    CC_MOGWM_for_combine_occipital  = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='MOGWM'}
    CC_IOGWM_for_combine_occipital  = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='IOGWM'}
    CC_CuGWM_for_combine_occipital  = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='CuGWM'}
    CC_LGWM_for_combine_occipital   = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='LGWM'}

    CC_Homotopic_occipital_for_rename = CC_SOGWM_for_combine_occipital.concat(CC_MOGWM_for_combine_occipital).concat(CC_IOGWM_for_combine_occipital).concat(CC_CuGWM_for_combine_occipital).concat(CC_LGWM_for_combine_occipital).groupTuple(by:0)

    /*
    Filter + Concat temporal
    */
    CC_STGWM_for_combine_temporal       = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='STGWM'}
    CC_T_pole_gwm_for_combine_temporal  = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='T_pole_gwm'}
    CC_MTGWM_for_combine_temporal       = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='MTGWM'}
    CC_ITGWM_for_combine_temporal       = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='ITGWM'}
    CC_PHG_for_combine_temporal         = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='PHG'}
    CC_Hippo_for_combine_temporal       = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='Hippo'}
    CC_FuGWM_for_combine_temporal       = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='FuGWM'}

    CC_Homotopic_temporal_for_rename = CC_STGWM_for_combine_temporal.concat(CC_T_pole_gwm_for_combine_temporal).concat(CC_MTGWM_for_combine_temporal).concat(CC_ITGWM_for_combine_temporal).concat(CC_PHG_for_combine_temporal).concat(CC_Hippo_for_combine_temporal).concat(CC_FuGWM_for_combine_temporal).groupTuple(by:0)

    /*
    Filter + Concat parietal
    */
    CC_SPGWM_for_combine_parietal     = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='SPGWM'}
    CC_SMGWM_for_combine_parietal     = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='SMGWM'}
    CC_PrCuGWM_for_combine_parietal   = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='PrCuGWM'}
    CC_PoCGWM_for_combine_parietal    = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='PoCGWM'}
    CC_AGWM_for_combine_parietal      = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='AGWM'}
    CC_Homotopic_parietal_for_rename = CC_SPGWM_for_combine_parietal.concat(CC_SMGWM_for_combine_parietal).concat(CC_PrCuGWM_for_combine_parietal).concat(CC_PoCGWM_for_combine_parietal).concat(CC_AGWM_for_combine_parietal).groupTuple(by:0) 


    /*
    Filter CC Cingulum
    */
    CC_Homotopic_cingulum_for_rename = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='CingGWM'}

    /*
    Filter CC Ins
    */
    CC_Homotopic_insular_for_rename = CC_HOMOTOPIC.out.extracted_with_list.filter{it[1]=='Ins'}


    /*
    MERGE CC_Homotopic
    */
    CC_Homotopic_list_for_merge = CC_HOMOTOPIC.out.extracted.groupTuple()
      .map { sid, tractograms -> [sid, [], tractograms] }
    MERGE_CC_HOMOTOPIC(CC_Homotopic_list_for_merge)

    /*
    COMMISSURAL
    */

    all_cc_for_commissural = EXTRACT_ALL_COMMISSURAL.out.remaining.join(EXTRACT_PLAUSIBLE_AC_CX.out.extracted).join(EXTRACT_PLAUSIBLE_CC_BG.out.plausible).join(MERGE_CC_HOMOTOPIC.out.tractogram)
    CC_ALL_COMMISSURAL(all_cc_for_commissural)

    /*
    ASSO VENTRAL
    */

    asso_ventral_lists = params.asso_ventral_lists?.tokenize(',')
    ASSO_VENTRAL(REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side, asso_ventral_lists)

    asso_all_intra_inter_ventral_all_for_merge = ASSO_VENTRAL.out.extracted_with_side.groupTuple(by:[0,1]).map{it.flatten().toList()}
      .map { sid, side, t1, t2, t3 -> [sid, side, [t1, t2, t3]] }
    MERGE_ASSO_VENTRAL(asso_all_intra_inter_ventral_all_for_merge)

    SPLIT_ASSO_VENTRAL_IFOF_UF(MERGE_ASSO_VENTRAL.out.tractogram_with_side, empty_lists)

    /*
    ASSO DORSAL
    */

    asso_dorsal_f_p_lists = params.asso_dorsal_f_p_lists?.tokenize(',')
    ASSO_DORSAL_F_P(REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side, asso_dorsal_f_p_lists)
    asso_all_intra_inter_dorsal_f_p_list_for_merge = ASSO_DORSAL_F_P.out.extracted_with_side.groupTuple(by:[0,1]).map{it}
    MERGE_ASSO_DORSAL_F_P(asso_all_intra_inter_dorsal_f_p_list_for_merge)

    asso_dorsal_f_o_f_t_list=params.asso_dorsal_f_o_f_t_lists?.tokenize(',')
    ASSO_DORSAL_F_O_F_T(REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side, asso_dorsal_f_o_f_t_list)
    asso_all_intra_inter_dorsal_all_f_T_for_rename = ASSO_DORSAL_F_O_F_T.out.extracted_with_side_list.filter{it[2]=='F_T_dorsal'}
    asso_all_intra_inter_dorsal_all_f_O_for_rename = ASSO_DORSAL_F_O_F_T.out.extracted_with_side_list.filter{it[2]=='F_O_dorsal'}

    asso_all_intra_inter_dorsal_all_for_merge = MERGE_ASSO_DORSAL_F_P.out.tractogram_with_side.groupTuple(by:[0,1]).join(ASSO_DORSAL_F_O_F_T.out.extracted_with_side.groupTuple(by:[0,1]), by:[0,1]).map{it.flatten().toList()}
      .map { sid, side, t1, t2, t3 -> [sid, side, [t1, t2, t3]] }
    MERGE_ASSO_DORSAL(asso_all_intra_inter_dorsal_all_for_merge)

    /*
    ASSO P_O
    */

    asso_p_o_list = params.asso_p_o_lists?.tokenize(',')
    ASSO_P_O(REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side, asso_p_o_list)

    asso_intra_inter_p_o_list_for_merge = ASSO_P_O.out.extracted_with_side.groupTuple(by:[0,1]).map{it}
    MERGE_P_O(asso_intra_inter_p_o_list_for_merge)

    /*
    ASSO P_T
    */

    asso_p_t_list = params.asso_p_t_lists?.tokenize(',')
    ASSO_P_T(REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side, asso_p_t_list)

    asso_intra_inter_p_t_list_for_merge = ASSO_P_T.out.extracted_with_side.groupTuple(by:[0,1]).map{it}
    MERGE_P_T(asso_intra_inter_p_t_list_for_merge)

    /*
    ASSO O_T
    */

    asso_o_t_list = params.asso_o_t_lists?.tokenize(',')
    ASSO_O_T(REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side, asso_o_t_list)

    asso_intra_inter_o_t_list_for_merge = ASSO_O_T.out.extracted_with_side.groupTuple(by:[0,1]).map{it}
    MERGE_O_T(asso_intra_inter_o_t_list_for_merge)

    /*
    ASSO Ins
    */

    asso_ins_list = params.asso_ins_lists?.tokenize(',')
    ASSO_INS(REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side, asso_ins_list)

    asso_intra_inter_ins_list_for_merge = ASSO_INS.out.extracted_with_side.groupTuple(by:[0,1]).map{it}
    MERGE_INS(asso_intra_inter_ins_list_for_merge)

    /*
    ASSO CING
    */
    ASSO_CING(REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side, empty_lists)

    /*
    BE ASSO FRONTAL: extracting all streamlines with both ends in a frontal gyrus (U-shape > 20 mm)
    */

    asso_frontal_be_list=params.asso_frontal_be_lists?.tokenize(',')
    ASSO_BE_FRONTAL_GYRUS(REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side, asso_frontal_be_list)

    asso_frontal_be_list_for_merge = ASSO_BE_FRONTAL_GYRUS.out.extracted_with_side.groupTuple(by:[0,1])
      .map { sid, side, _gyrus, tractograms -> [sid, side, tractograms]}
    MERGE_ASSO_BE_FRONTAL_GYRUS(asso_frontal_be_list_for_merge)

    /*
    EE ASSO FRONTAL: extracting all streamlines with either ends in a frontal gyrus (U-shape > 20 mm)
    */

    asso_frontal_ee_list = Channel.from(['SFG_MFG', 70],
                                        ['SFG_IFG', 70],
                                        ['SFG_PrCG', 90],
                                        ['SFG_FrOrbG', 70],
                                        ['MFG_IFG', 70],
                                        ['MFG_PrCG', 110],
                                        ['MFG_FrOrbG', 60],
                                        ['IFG_PrCG', 110],
                                        ['IFG_FrOrbG', 60])
    asso_frontal_ee_for_extract = REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side.combine(asso_frontal_ee_list)
    ASSO_EE_FRONTAL_GYRUS(asso_frontal_ee_for_extract)

    asso_frontal_ee_list_for_merge = ASSO_EE_FRONTAL_GYRUS.out.extracted_with_side.groupTuple(by:[0,1])
      .map { sid, side, _gyrus, tractograms -> [sid, side, tractograms]}
    MERGE_ASSO_EE_FRONTAL_GYRUS(asso_frontal_ee_list_for_merge)

    /*
    BE ASSO OCCIPITAL: extracting all streamlines with both ends in a occipital gyrus (U-shape > 20 mm)
    */

    asso_occipital_be_list = params.asso_occipital_be_lists?.tokenize(',')
    ASSO_BE_OCCIPITAL_GYRUS(REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side, asso_occipital_be_list)

    asso_occipital_be_list_for_merge = ASSO_BE_OCCIPITAL_GYRUS.out.extracted_with_side.groupTuple(by:[0,1])
      .map { sid, side, _gyrus, tractograms -> [sid, side, tractograms]}
    MERGE_ASSO_BE_OCCIPITAL_GYRUS(asso_occipital_be_list_for_merge)

    /*
    EE ASSO OCCIPITAL: extracting all streamlines with either ends in a occipital gyrus (U-shape > 20 mm)
    */

    asso_occipital_ee_list = Channel.from(['MOG_SOG', 60],['MOG_IOG', 50], ['MOG_CuG', 60], ['SOG_CuG', 30], ['CuG_LG', 60])
    asso_occipital_ee_for_extract = REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side.combine(asso_occipital_ee_list)
    ASSO_EE_OCCIPITAL_GYRUS(asso_occipital_ee_for_extract)

    asso_occipital_ee_list_for_merge = ASSO_EE_OCCIPITAL_GYRUS.out.extracted_with_side.groupTuple(by:[0,1])
      .map { sid, side, _gyrus, tractograms -> [sid, side, tractograms]}
    MERGE_ASSO_EE_OCCIPITAL_GYRUS(asso_occipital_ee_list_for_merge)

    /*
    BE ASSO PARIETAL: extracting all streamlines with both ends in a parietal gyrus (U-shape > 20 mm)
    */

    asso_parietal_be_list = params.asso_parietal_be_lists?.tokenize(',')
    ASSO_BE_PARIETAL_GYRUS(REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side, asso_parietal_be_list)

    asso_parietal_be_list_for_merge = ASSO_BE_PARIETAL_GYRUS.out.extracted_with_side.groupTuple(by:[0,1])
      .map { sid, side, _gyrus, tractograms -> [sid, side, tractograms]}
    MERGE_ASSO_BE_PARIETAL_GYRUS(asso_parietal_be_list_for_merge)

    /*
    EE ASSO PARIETAL: extracting all streamlines with either ends in a parietal gyrus (U-shape > 20 mm)
    */

    asso_parietal_ee_list = Channel.from(['SPG_PoCG', 50], ['SPG_AG', 80], ['SPG_SMG', 70], ['SPG_PrCuG', 50], ['AG_PoCG', 10000], ['AG_SMG', 90], ['AG_PrCuG', 90] , ['SMG_PoCG', 60], ['SMG_PrCuG',100], ['PoCG_PrCuG', 80])
    asso_parietal_ee_for_extract = REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side.combine(asso_parietal_ee_list)
    ASSO_EE_PARIETAL_GYRUS(asso_parietal_ee_for_extract)

    asso_parietal_ee_list_for_merge = ASSO_EE_PARIETAL_GYRUS.out.extracted_with_side.groupTuple(by:[0,1])
      .map { sid, side, _gyrus, tractograms -> [sid, side, tractograms]}
    MERGE_ASSO_EE_PARIETAL_GYRUS(asso_parietal_ee_list_for_merge)

    /*
    BE ASSO TEMPORAL: extracting all streamlines with both ends in a temporal gyrus and merge (U-shape > 20 mm)
    */
    asso_temporal_be_list = params.asso_temporal_be_lists?.tokenize(',')
    ASSO_BE_TEMPORAL_GYRUS(REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side, asso_temporal_be_list)

    asso_temporal_be_list_for_merge = ASSO_BE_TEMPORAL_GYRUS.out.extracted_with_side.groupTuple(by:[0,1])
      .map { sid, side, _gyrus, tractograms -> [sid, side, tractograms]}
    MERGE_ASSO_BE_TEMPORAL_GYRUS(asso_temporal_be_list_for_merge)

    /*
    EE ASSO TEMPORAL: extracting all streamlines with either ends in a temporal gyrus and merge (U-shape > 20 mm)
    */

    asso_temporal_ee_list = Channel.from(['STG_MTG', 60], ['STG_ITG',80], ['STG_Tpole',110], ['MTG_ITG',60], ['MTG_Tpole', 100000], ['ITG_Tpole', 60])
    asso_temporal_ee_for_extract = REMOVE_UNPLAUSIBLE_LONG_RANGE_ASSO.out.extracted_with_side.combine(asso_temporal_ee_list)
    ASSO_EE_TEMPORAL_GYRUS(asso_temporal_ee_for_extract)

    asso_temporal_ee_list_for_merge = ASSO_EE_TEMPORAL_GYRUS.out.extracted_with_side.groupTuple(by:[0,1])
      .map { sid, side, _gyrus, tractograms -> [sid, side, tractograms]}
    MERGE_ASSO_EE_TEMPORAL_GYRUS(asso_temporal_ee_list_for_merge)

    /*
    Extracting plausible streamlines
    */
    merge_trk_plausible = EXTRACT_FORNIX.out.extracted.concat(
      EXTRACT_PLAUSIBLE_CEREBELLUM.out.plausible,
      EXTRACT_PLAUSIBLE_BRAINSTEM.out.brainstem_for_trk_plausible,
      EXTRACT_PLAUSIBLE_AC_CX.out.extracted,
      EXTRACT_PLAUSIBLE_CC_BG.out.plausible,
      MERGE_BG_THAL.out.tractogram,
      MERGE_BG_PUT.out.tractogram,
      MERGE_BG_CAUD.out.tractogram,
      SPLIT_USHAPE_CGM_ASSO.out.asso_u_shape_for_trk_plausible,
      MERGE_CC_HOMOTOPIC.out.tractogram,
      MERGE_ASSO_DORSAL.out.tractogram,
      MERGE_ASSO_VENTRAL.out.tractogram,
      MERGE_P_O.out.tractogram,
      MERGE_P_T.out.tractogram,
      MERGE_O_T.out.tractogram,
      MERGE_INS.out.tractogram,
      ASSO_CING.out.extracted,
      MERGE_ASSO_BE_FRONTAL_GYRUS.out.tractogram,
      MERGE_ASSO_EE_FRONTAL_GYRUS.out.tractogram,
      MERGE_ASSO_BE_OCCIPITAL_GYRUS.out.tractogram,
      MERGE_ASSO_EE_OCCIPITAL_GYRUS.out.tractogram,
      MERGE_ASSO_BE_PARIETAL_GYRUS.out.tractogram,
      MERGE_ASSO_EE_PARIETAL_GYRUS.out.tractogram,
      MERGE_ASSO_BE_TEMPORAL_GYRUS.out.tractogram,
      MERGE_ASSO_EE_TEMPORAL_GYRUS.out.tractogram
    ).groupTuple(by: 0)

    TRK_PLAUSIBLE(merge_trk_plausible)

    /*
    Extracting unplausible streamlines
    */
    for_trk_unplausible = mni_tractograms.join(TRK_PLAUSIBLE.out.tractogram)
    TRK_UNPLAUSIBLE(for_trk_unplausible)

    /* Pack up for bundle extraction */
    for_bundle_extraction = [
      key_CC_Homotopic_frontal_for_rename: CC_Homotopic_frontal_for_rename,
      key_CC_Homotopic_occipital_for_rename: CC_Homotopic_occipital_for_rename,
      key_CC_Homotopic_temporal_for_rename: CC_Homotopic_temporal_for_rename,
      key_CC_Homotopic_parietal_for_rename: CC_Homotopic_parietal_for_rename,
      key_CC_Homotopic_insular_for_rename: CC_Homotopic_insular_for_rename,
      key_CC_Homotopic_cingulum_for_rename: CC_Homotopic_cingulum_for_rename,
      key_BG_ipsi_Caud_for_rename: SPLIT_BG_CAUD.out.extracted_with_side,
      key_BG_ipsi_Put_for_rename: SPLIT_BG_PUT.out.extracted_with_side,
      key_BG_ipsi_Thal_for_rename: bg_ipsi_thal_for_rename,
      key_optic_radiation_for_rename: optic_radiation_for_rename,
      key_asso_u_shape_for_rename: SPLIT_USHAPE_CGM_ASSO.out.asso_u_shape_for_rename,
      key_Cing_for_rename: ASSO_CING.out.extracted_with_side,
      key_asso_all_intra_inter_dorsal_all_f_O_for_rename: asso_all_intra_inter_dorsal_all_f_O_for_rename,
      key_asso_all_intra_inter_dorsal_f_p_for_rename: ASSO_DORSAL_F_P.out.extracted_with_side_list,
      key_asso_all_intra_inter_dorsal_all_f_T_for_rename: asso_all_intra_inter_dorsal_all_f_T_for_rename,
      key_brainstem_corticopontine_frontal_for_rename: EXTRACT_PLAUSIBLE_BRAINSTEM.out.brainstem_corticopontine_frontal_for_rename,
      key_brainstem_ee_corticopontine_parietotemporooccipital_for_rename: EXTRACT_PLAUSIBLE_BRAINSTEM.out.brainstem_ee_corticopontine_parietotemporooccipital_for_rename,
      key_brainstem_pyramidal_for_rename: EXTRACT_PLAUSIBLE_BRAINSTEM.out.brainstem_pyramidal_for_rename,
      key_fornix_for_rename: EXTRACT_FORNIX.out.extracted,
      key_asso_IFOF_for_rename: SPLIT_ASSO_VENTRAL_IFOF_UF.out.extracted_with_side,
      key_asso_UF_for_rename: SPLIT_ASSO_VENTRAL_IFOF_UF.out.remaining_with_side,
      key_all_O_T_for_rename: MERGE_O_T.out.tractogram_with_side,
      key_brainstem_for_rename: EXTRACT_PLAUSIBLE_BRAINSTEM.out.brainstem_for_trk_plausible,
      key_cerebellum_for_rename: EXTRACT_PLAUSIBLE_CEREBELLUM.out.plausible,
      key_accx_for_rename: EXTRACT_PLAUSIBLE_AC_CX.out.extracted,
      key_plausible_commissural: CC_ALL_COMMISSURAL.out.plausible
    ]

    // TODO: Maybe move the following in the main.nf.
    // However, it is problematic to do so with how
    // nextflow seems to be handling the channels when
    // emitting values. Needs more investigation.

    extracted_bundles = Channel.empty()
    if (params.extract_bundles) {
      EXTRACT_BUNDLES(for_bundle_extraction, sides)
      extracted_bundles = EXTRACT_BUNDLES.out.bundles
    }

    emit:
    plausible = TRK_PLAUSIBLE.out.tractogram
    unplausible = TRK_UNPLAUSIBLE.out.tractogram
    bundles = extracted_bundles
}

process EXTRACT_PLAUSIBLE_CEREBELLUM {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

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
  scil_tractogram_filter_by_roi ${tractogram} ${meta.id}__tmp_in_cerebellum.trk\
        --filtering_list ${params.FLF}in_cerebellum.txt -f
  scil_tractogram_filter_by_roi ${meta.id}__tmp_in_cerebellum.trk ${meta.id}__all_in_cerebellum_nocx_nocerebwm.trk\
        --filtering_list ${params.FLF}cerebellum_nocx_in_cereb.txt -f
  scil_tractogram_filter_by_roi ${meta.id}__tmp_in_cerebellum.trk ${meta.id}__all_in_cerebellum_in_Medulla.trk\
        --filtering_list ${params.FLF}cerebellum_in_medulla.txt -f
  scil_tractogram_filter_by_roi ${meta.id}__tmp_in_cerebellum.trk ${meta.id}__all_in_cerebellum_in_Pons.trk\
        --filtering_list ${params.FLF}cerebellum_in_pons.txt -f
  scil_tractogram_filter_by_roi ${meta.id}__tmp_in_cerebellum.trk ${meta.id}__all_in_cerebellum_in_Midbrain.trk\
        --filtering_list ${params.FLF}cerebellum_in_midbrain.txt -f
  scil_tractogram_filter_by_roi ${meta.id}__tmp_in_cerebellum.trk ${meta.id}__all_in_cerebellum_in_redN_and_Thal.trk\
        --filtering_list ${params.FLF}cerebellum_in_rednucleus_and_thalamus.txt -f
  scil_tractogram_math union ${meta.id}__all_in_*.trk ${meta.id}__all_cerebellum_plausibles.trk --save_empty -f
  """
}

process EXTRACT_PLAUSIBLE_BRAINSTEM {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

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
  scil_tractogram_filter_by_roi ${meta.id}__all_brainstem.trk ${meta.id}__be_midbrain.trk\
      --filtering_list ${params.FLF}brainstem_be_midbrain.txt -f
  # Extract be medulla
  scil_tractogram_filter_by_roi ${meta.id}__all_brainstem.trk ${meta.id}__be_medulla.trk\
      --filtering_list ${params.FLF}brainstem_be_medulla.txt -f
  # Extract be pons
  scil_tractogram_filter_by_roi ${meta.id}__all_brainstem.trk ${meta.id}__be_pons.trk\
      --filtering_list ${params.FLF}brainstem_be_pons.txt -f

  # Extract ee thalamus
  scil_tractogram_filter_by_roi ${meta.id}__all_brainstem.trk ${meta.id}__ee_thalamus.trk\
      --filtering_list ${params.FLF}brainstem_ee_thalamus.txt -f
  # Extract ee red_nucleus
  scil_tractogram_filter_by_roi ${meta.id}__all_brainstem.trk ${meta.id}__ee_red_nucleus.trk\
      --filtering_list ${params.FLF}brainstem_ee_red_nucleus.txt -f

  # Prepartion for fronto-pontine, parietotemporooccipito-pontine, pyramidal, cortico-tectal
  scil_tractogram_filter_by_roi ${meta.id}__all_brainstem.trk ${meta.id}__ee_tmp_01.trk\
      --filtering_list ${params.FLF}brainstem_ee_tmp_01.txt -f
  scil_tractogram_filter_by_roi ${meta.id}__all_brainstem.trk ${meta.id}__ee_tmp_02.trk\
      --filtering_list ${params.FLF}brainstem_ee_tmp_02.txt -f

  scil_tractogram_math union ${meta.id}__ee_tmp_01.trk ${meta.id}__ee_tmp_02.trk\
      ${meta.id}__ee_tmp_03.trk --save_empty -f

  # Extract ee Fronto-pontine R and L
  scil_tractogram_filter_by_roi ${meta.id}__ee_tmp_03.trk ${meta.id}__ee_fronto_pontine_R.trk\
      --filtering_list ${params.FLF}brainstem_ee_F_pontine_R.txt -f
  scil_tractogram_filter_by_roi ${meta.id}__ee_tmp_03.trk ${meta.id}__ee_fronto_pontine_L.trk\
      --filtering_list ${params.FLF}brainstem_ee_F_pontine_L.txt -f
  scil_tractogram_math union ${meta.id}__ee_fronto_pontine_L.trk ${meta.id}__ee_fronto_pontine_R.trk\
      ${meta.id}__ee_fronto_pontine.trk --save_empty -f

  # Extract ee ParietoTemporooccipital pontine R and L
  scil_tractogram_filter_by_roi ${meta.id}__ee_tmp_03.trk ${meta.id}__ee_parietotemporooccipital_pontine_R.trk\
      --filtering_list ${params.FLF}brainstem_ee_PTO_pontine_R.txt -f
  scil_tractogram_filter_by_roi ${meta.id}__ee_tmp_03.trk ${meta.id}__ee_parietotemporooccipital_pontine_L.trk\
      --filtering_list ${params.FLF}brainstem_ee_PTO_pontine_L.txt -f
  scil_tractogram_math union ${meta.id}__ee_parietotemporooccipital_pontine_L.trk ${meta.id}__ee_parietotemporooccipital_pontine_R.trk\
      ${meta.id}__ee_parietotemporooccipital_pontine.trk --save_empty -f

  # Extract ee Pyramidal
  scil_tractogram_filter_by_roi ${meta.id}__ee_tmp_03.trk ${meta.id}__ee_pyramidal.trk\
      --filtering_list ${params.FLF}brainstem_ee_pyramidal.txt -f

  # Extract ee Tectal
  scil_tractogram_filter_by_roi ${meta.id}__ee_tmp_03.trk ${meta.id}__ee_cortico_tectal.trk\
      --filtering_list ${params.FLF}brainstem_ee_cortico_tectal.txt -f
  scil_tractogram_filter_by_length ${meta.id}__ee_cortico_tectal.trk ${meta.id}__ee_cortico_tectal.trk --maxL 100 -f

  rm -f ${meta.id}__*tmp_*.trk

  scil_tractogram_math union ${meta.id}__be_*.trk ${meta.id}__ee_*.trk ${meta.id}__all_brainstem_plausibles.trk --save_empty -f

  if ${params.keep_intermediate_steps}
  then
    scil_tractogram_math difference ${meta.id}__all_brainstem.trk ${meta.id}__all_brainstem_plausibles.trk ${meta.id}__all_brainstem_unplausibles.trk  --save_empty -f
  fi
  """
}

process EXTRACT_PLAUSIBLE_CC_BG {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

  input:
    tuple val(meta), path(tractogram) // from cc_for_extract_CC_BG

  output:
    tuple val(meta), path("${meta.id}__in_CC_BG_f.trk"), emit: plausible // into ccbg_for_trk_plausible, ccbg_for_commissural
    path "${meta.id}__in_CC_BG_f.txt"

  script:
  """
  scil_tractogram_filter_by_roi ${tractogram} tmp.trk \
    --filtering_list ${params.FLF}CC_BG.txt -f\
    --overwrite_distance both_ends include 1\
    --overwrite_distance either_end include 1

  scil_tractogram_filter_by_length tmp.trk\
    ${meta.id}__in_CC_BG_f.trk\
    --maxL 170

  scil_tractogram_count_streamlines ${meta.id}__in_CC_BG_f.trk > ${meta.id}__in_CC_BG_f.txt
  """
}

process SPLIT_ASSO_IN_HEMI {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

  input:
    tuple val(meta), path(tractogram) // from asso_noBG_for_split_hemi
    each list
    each side // from sides

  output:
    tuple val(meta), val(side), path("${meta.id}__asso_${side}.trk"), emit: asso_for_extract_u_shape
    path "${meta.id}__asso_${side}.txt", optional: true

  script:
  """
  scil_tractogram_filter_by_roi ${tractogram} ${meta.id}__asso_L.trk\
   --filtering_list ${params.FLF}asso_L.txt -f
   scil_tractogram_filter_by_roi ${tractogram} ${meta.id}__asso_R.trk\
    --filtering_list ${params.FLF}asso_R.txt -f
  """
}

process SPLIT_USHAPE_CGM_ASSO {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

  input:
    tuple val(meta), val(side), path(tractogram) // from asso_for_extract_u_shape

  output:
    tuple val(meta), val(side), path("${meta.id}__asso_only_in_CGM_${side}.trk"), emit: assoCGM
    tuple val(meta), val(side), path("${meta.id}__asso_Ushape_${side}.trk"), emit: assoUShape
    tuple val(meta), path("${meta.id}__asso_Ushape_${side}_u.trk"), emit: asso_u_shape_for_trk_plausible
    tuple val(meta), val(side), path("${meta.id}__asso_Ushape_${side}_u.trk"), emit: asso_u_shape_for_rename

    tuple val(meta), val(side), path("${meta.id}__asso_f_${side}.trk"), emit: asso_for_remove_long_range
    path "${meta.id}__asso_only_in_CGM_${side}.txt", optional: true
    path "${meta.id}__asso_Ushape_${side}.txt", optional: true
    path "${meta.id}__asso_f_${side}.txt", optional: true

    script:
    """
    scil_tractogram_filter_by_roi ${tractogram} ${meta.id}__tmp1_${side}.trk \
    --filtering_list ${params.FLF}all_in_CGM_${side}.txt -f

    scil_tractogram_math difference ${tractogram} ${meta.id}__tmp1_${side}.trk \
                            ${meta.id}__asso_SWM_${side}.trk --save_empty -f

    scil_tractogram_filter_by_roi ${meta.id}__tmp1_${side}.trk ${meta.id}__asso_only_in_CGM_${side}.trk \
    --filtering_list ${params.FLF}not_in_SWM_${side}.txt -f

    scil_tractogram_math difference ${meta.id}__tmp1_${side}.trk ${meta.id}__asso_only_in_CGM_${side}.trk \
                                ${meta.id}__tmp2_${side}.trk --save_empty -f

    scil_tractogram_filter_by_roi ${meta.id}__tmp2_${side}.trk ${meta.id}__asso_Ushape_${side}.trk \
    --filtering_list ${params.FLF}not_in_DWM_${side}.txt -f

    scil_tractogram_extract_ushape ${meta.id}__asso_Ushape_${side}.trk --minU 0.5 --maxU 1 ${meta.id}__asso_Ushape_${side}_u.trk -f

    scil_tractogram_math difference ${meta.id}__tmp2_${side}.trk ${meta.id}__asso_Ushape_${side}.trk \
                            ${meta.id}__asso_DWM_${side}.trk --save_empty -f

    scil_tractogram_math union ${meta.id}__asso_DWM_${side}.trk ${meta.id}__asso_SWM_${side}.trk ${meta.id}__asso_f_${side}.trk --save_empty -f

    if ${params.keep_intermediate_steps}
    then
    scil_tractogram_count_streamlines ${meta.id}__asso_only_in_CGM_${side}.trk > ${meta.id}__asso_only_in_CGM_${side}.txt
    scil_tractogram_count_streamlines ${meta.id}__asso_Ushape_${side}.trk > ${meta.id}__asso_Ushape_${side}.txt
    scil_tractogram_count_streamlines ${meta.id}__asso_f_${side}.trk > ${meta.id}__asso_f_${side}.txt
    fi
    """
}

process CC_ALL_COMMISSURAL {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

  input:
    tuple val(meta), path(tmp_cc), path(accx), path(ccbg), path(cc_homo) // from all_cc_for_commissural

  output:
    tuple val(meta), path("${meta.id}__plausible_commissural_${params.mni_space}.trk"), emit: plausible
    path "${meta.id}__unplausible_commissural.trk", optional: true

  script:
  """
    scil_tractogram_math union ${accx} ${ccbg} ${cc_homo} ${meta.id}__plausible_commissural_${params.mni_space}.trk --save_empty -f

    if ${params.keep_intermediate_steps}
    then
      scil_tractogram_math difference ${tmp_cc} ${meta.id}__plausible_commissural_${params.mni_space}.trk ${meta.id}__unplausible_commissural.trk --save_empty -f
    fi
  """
}

process ASSO_BE_FRONTAL_GYRUS {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

  input:
    tuple val(meta), val(side), path(tractogram) // from asso_all_intra_inter_for_be_frontal_filtering
    each gyrus // from asso_frontal_be_list

  output:
    tuple val(meta), val(side), val(gyrus), path("${meta.id}_asso_intra_be_frontal_${gyrus}_${side}_u.trk"), emit: extracted_with_side

  script:
  """
  scil_tractogram_filter_by_roi ${tractogram} tmp.trk\
    --filtering_list ${params.FLF}ASSO_be_${gyrus}_${side}.txt -f
  scil_tractogram_extract_ushape tmp.trk --minU 0.5 --maxU 1\
    ${meta.id}_asso_intra_be_frontal_${gyrus}_${side}_u.trk -f
  """
}

process ASSO_EE_FRONTAL_GYRUS {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

  input:
    tuple val(meta), val(side), path(tractogram), val(gyrus), val(max_length) // from asso_frontal_ee_for_extract

  output:
    tuple val(meta), val(side), val(gyrus), path("${meta.id}_asso_intra_ee_frontal_${gyrus}_${side}.trk"), emit: extracted_with_side //into asso_frontal_ee_for_merge

  script:
  """
  scil_tractogram_filter_by_roi ${tractogram} tmp_01.trk\
    --filtering_list ${params.FLF}ASSO_ee_${gyrus}_${side}.txt -f
  scil_tractogram_filter_by_length tmp_01.trk tmp_02.trk\
    --maxL ${max_length} -f
  scil_tractogram_extract_ushape tmp_02.trk\
    --minU 0.5\
    --maxU 1\
    ${meta.id}_asso_intra_ee_frontal_${gyrus}_${side}.trk -f
  """
}

process ASSO_BE_OCCIPITAL_GYRUS {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

  input:
    tuple val(meta), val(side), path(tractogram) // from asso_all_intra_inter_for_be_occipital_filtering
    each gyrus // from asso_occipital_be_list

  output:
    tuple val(meta), val(side), val(gyrus), path("${meta.id}_asso_intra_be_occipital_${gyrus}_${side}_u.trk"), emit: extracted_with_side // into asso_occipital_be_for_merge

  script:
  """
  scil_tractogram_filter_by_roi ${tractogram} tmp.trk \
    --filtering_list ${params.FLF}ASSO_be_${gyrus}_${side}.txt -f
  scil_tractogram_extract_ushape tmp.trk\
    --minU 0.5\
    --maxU 1\
    ${meta.id}_asso_intra_be_occipital_${gyrus}_${side}_u.trk -f
  """
}

process ASSO_EE_OCCIPITAL_GYRUS {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

  input:
    tuple val(meta), val(side), path(tractogram), val(gyrus), val(max_length) // from asso_occipital_ee_for_extract

  output:
    tuple val(meta), val(side), val(gyrus), path("${meta.id}_asso_intra_ee_occipital_${gyrus}_${side}.trk"), emit: extracted_with_side // into asso_occipital_ee_for_merge

  script:
  """
  scil_tractogram_filter_by_roi ${tractogram} tmp_01.trk\
    --filtering_list ${params.FLF}ASSO_ee_${gyrus}_${side}.txt -f
  scil_tractogram_filter_by_length tmp_01.trk tmp_02.trk\
    --maxL ${max_length} -f
  scil_tractogram_extract_ushape tmp_02.trk\
    --minU 0.5\
    --maxU 1\
    ${meta.id}_asso_intra_ee_occipital_${gyrus}_${side}.trk -f
  """
}

process ASSO_BE_PARIETAL_GYRUS {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

  input:
    tuple val(meta), val(side), path(tractogram) // from asso_all_intra_inter_for_be_parietal_filtering
    each gyrus // from asso_parietal_be_list

  output:
    tuple val(meta), val(side), val(gyrus), path("${meta.id}_asso_intra_be_parietal_${gyrus}_${side}_u.trk"), emit: extracted_with_side // into asso_parietal_be_for_merge

  script:
  """
  scil_tractogram_filter_by_roi ${tractogram} tmp.trk\
    --filtering_list ${params.FLF}ASSO_be_${gyrus}_${side}.txt -f
  scil_tractogram_extract_ushape tmp.trk\
    --minU 0.5\
    --maxU 1\
    ${meta.id}_asso_intra_be_parietal_${gyrus}_${side}_u.trk -f
  """
}

process ASSO_EE_PARIETAL_GYRUS {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

  input:
    tuple val(meta), val(side), path(tractogram), val(gyrus), val(max_length) // from asso_parietal_ee_for_extract

  output:
    tuple val(meta), val(side), val(gyrus), path("${meta.id}_asso_intra_ee_parietal_${gyrus}_${side}.trk"), emit: extracted_with_side //into asso_parietal_ee_for_merge

  script:
  """
  scil_tractogram_filter_by_roi ${tractogram} tmp_01.trk\
    --filtering_list ${params.FLF}ASSO_ee_${gyrus}_${side}.txt -f
  scil_tractogram_filter_by_length tmp_01.trk tmp_02.trk\
    --maxL ${max_length} -f
  scil_tractogram_extract_ushape tmp_02.trk\
    --minU 0.5\
    --maxU 1\
    ${meta.id}_asso_intra_ee_parietal_${gyrus}_${side}.trk -f
  """
}

process ASSO_BE_TEMPORAL_GYRUS {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

  input:
    tuple val(meta), val(side), path(tractogram) // from asso_all_intra_inter_for_be_temporal_filtering
    each gyrus // from asso_temporal_be_list

  output:
    tuple val(meta), val(side), val(gyrus), path("${meta.id}_asso_intra_be_temporal_${gyrus}_${side}_u.trk"), emit: extracted_with_side // into asso_temporal_be_for_merge

  script:
  """
  scil_tractogram_filter_by_roi ${tractogram} tmp.trk\
    --filtering_list ${params.FLF}ASSO_be_${gyrus}_${side}.txt -f
  scil_tractogram_extract_ushape tmp.trk\
    --minU 0.5\
    --maxU 1\
    ${meta.id}_asso_intra_be_temporal_${gyrus}_${side}_u.trk -f
  """
}

process ASSO_EE_TEMPORAL_GYRUS {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

  input:
    tuple val(meta), val(side), path(tractogram), val(gyrus), val(max_length) // from asso_temporal_ee_for_extract

  output:
    tuple val(meta), val(side), val(gyrus), path("${meta.id}_asso_intra_ee_temporal_${gyrus}_${side}.trk"), emit: extracted_with_side // into asso_temporal_ee_for_merge

  script:
  """
  scil_tractogram_filter_by_roi ${tractogram} tmp_01.trk\
    --filtering_list ${params.FLF}ASSO_ee_${gyrus}_${side}.txt -f
  scil_tractogram_filter_by_length tmp_01.trk tmp_02.trk\
    --maxL ${max_length} -f
  scil_tractogram_extract_ushape tmp_02.trk\
    --minU 0.5\
    --maxU 1\
    ${meta.id}_asso_intra_ee_temporal_${gyrus}_${side}.trk -f
  """
}

process TRK_PLAUSIBLE {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

  input:
    tuple val(meta), path(tractogram) // from merge_trk_plausible

  output:
    tuple val(meta), path("${meta.id}__plausible_${params.mni_space}.trk"), emit: tractogram

  script:
  """
    scil_tractogram_math union ${tractogram} ${meta.id}__plausible_${params.mni_space}_tmp.trk --save_empty -f --no_metadata
    scil_tractogram_shuffle ${meta.id}__plausible_${params.mni_space}_tmp.trk ${meta.id}__plausible_${params.mni_space}.trk -f
  """
}

process TRK_UNPLAUSIBLE {
  tag "$meta.id"
  cpus 1

  container 'scilus/scilpy:dev'

  input:
    tuple val(meta), path(trk01), path(trk02) // from for_trk_unplausible
  output:
    tuple val(meta), path("${meta.id}__unplausible_${params.mni_space}.trk"), emit: tractogram

  script:
  """
    scil_tractogram_math difference ${trk01} ${trk02} ${meta.id}__unplausible_${params.mni_space}.trk --save_empty -f
  """
}

