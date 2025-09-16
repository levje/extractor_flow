include { REGISTRATION_ANTS } from '../../modules/nf-neuro/registration/ants/main'
include { BETCROP_ANTSBET } from '../../modules/nf-neuro/betcrop/antsbet/main'
include { TRACTOGRAM_REMOVEINVALID } from '../../modules/nf-neuro/tractogram/removeinvalid/main.nf'

// TODO: Replace the following processes with the NF-Neuro module REGISTRATION_TRACTOGRAM
include { REGISTRATION_TRACTOGRAM } from '../../modules/nf-neuro/registration/tractogram/main.nf'
include { COPY_FILE as COPY_T1_TO_ORIG } from '../../modules/local/utils/copy_file.nf'
include { COPY_FILE as COPY_T1_ATLAS } from '../../modules/local/utils/copy_file.nf'

// For tractograms that have a T1w, we assume they are not in the MNI space:
// - We register the T1w to the template space and transform the tractograms to the template space.
workflow TRANSFORM_TO_MNI {
    take:
    in_tractogram
    t1s

    main:

    // SECTION A.1: For the subjects that have a T1w,
    // we bet & register the T1w and the tractograms to the template space.

    t1s_to_bet = Channel.empty()
    if (params.run_bet) {
        // takes:
        // sid, t1, template, tissues_probabilities, mask, initial_affine
        BETCROP_ANTSBET(t1s_to_bet)
        t1s_to_bet = BETCROP_ANTSBET.out.t1.join(BETCROP_ANTSBET.out.mask)
    }
    else {
        beted_t1s = t1s.map { sid, t1 -> [sid, t1, []]}
    }

    // Add the T1 template
    template_t1 = Channel.fromPath("${params.rois_folder_host}${params.atlas.template}")
    t1s_for_registration = beted_t1s
        .combine(template_t1) // Add the template T1
        .map { sid, t1, mask, template -> [sid, template, t1, mask] }
    REGISTRATION_ANTS(t1s_for_registration)

    // Transform the tractograms
    inv_transformation = REGISTRATION_ANTS.out.affine // *__output0InverseAffine.mat
    deformation = REGISTRATION_ANTS.out.inverse_warp // *__output1InverseWarp.nii.gz

    transformation_for_trk_registration = in_tractogram
        .combine(template_t1)
        .join(inv_transformation)
        .join(deformation)
        .map { sid, tractogram, template, transfo, deform -> [sid, template, transfo, tractogram, [], deform] }

    // takes:
    // sid, anat, transfo, tractogram, ref, deformation
    REGISTRATION_TRACTOGRAM(transformation_for_trk_registration)

    // Provide the transformation and T1 in case we want to transform to orig space later on
    transformations_for_orig = Channel.empty()
    if (params.orig) {
        // (sid, transfo, inv_deformation, deformation)
        transformations_for_orig = REGISTRATION_ANTS.out.affine
            .join(REGISTRATION_ANTS.out.warp)
    }

    emit:
    tractograms = REGISTRATION_TRACTOGRAM.out.tractogram
    transformations_for_orig = transformations_for_orig
}

// For tractograms that DO NOT have a T1w, we assume they are in the MNI space:
// - We remove the invalid streamlines and copy the template T1w to the subject folder.
workflow CLEAN_IF_FROM_MNI {
    take:
    in_tractogram
    t1s

    main:
    // We get (sid, tractogram, {t1 || null})
    tractograms_to_clean = in_tractogram.join(t1s, remainder: true)
    // Keep the tractograms that do not have a T1w
    tractograms_to_clean = tractograms_to_clean.filter { it[2] == null }
    // Only keep (sid, tractogram)
    tractograms_to_clean = tractograms_to_clean.map{ sid, trk, _null_t1 -> [sid, trk] }

    template_t1 = Channel.fromPath("${params.rois_folder_host}${params.atlas.template}")
    to_copy_atlas = tractograms_to_clean.combine(template_t1)
      .map{ sid, _trk, t1 -> [sid, [], t1]}
    COPY_T1_ATLAS(to_copy_atlas)

    TRACTOGRAM_REMOVEINVALID(tractograms_to_clean)


    emit:
    cleaned_mni_tractograms = TRACTOGRAM_REMOVEINVALID.out.tractograms
}