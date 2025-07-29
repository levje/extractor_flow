include { REGISTRATION_ANTS } from '../../modules/nf-neuro/registration/ants/main'
include { BETCROP_ANTSBET } from '../../modules/nf-neuro/betcrop/antsbet/main'

// TODO: Replace the following processes with the NF-Neuro module REGISTRATION_TRACTOGRAM
include { REGISTRATION_TRACTOGRAM } from '../../modules/nf-neuro/registration/tractogram/main.nf'
include { REGISTRATION_TRACTOGRAM as REGISTRATION_TRACTOGRAM_ORIG } from '../../modules/nf-neuro/registration/tractogram/main.nf'

process Copy_t1_to_orig{
//   publishDir = params.final_output_orig_space
  cpus 1

  input:
    tuple val(meta), path(t1)

  output:
    file("${meta.id}__t1_orig_space.nii.gz")

  when:
    params.orig

  script:
  """
    cp ${t1} ${meta.id}__t1_orig_space.nii.gz
  """
}

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
    template_t1 = Channel.fromPath("${params.rois_folder}${params.atlas.template}")
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
    tractograms = REGISTRATION_TRACTOGRAM.out.warped_tractogram
    transformations_for_orig = transformations_for_orig

}

workflow TRANSFORM_TO_ORIG {
    take:
    t1s                 // Channel(sid, t1_orig_space)
    trks                // Channel(sid, trk)
    transformations     // Channel(sid, transfo, deformation)

    main:

    trks_for_register = t1s
        .join(trks)
        .join(transformations)
        .map { sid, t1, trk, transfo, deformation ->
            [sid, t1, transfo, trk, [], deformation] }


    // takes:
    // sid, trk, t1, transfo, inv_deformation, deformation
    REGISTRATION_TRACTOGRAM_ORIG(trks_for_register)
    
    // Copy the original T1w to the subject folder.

    Copy_t1_to_orig(t1s)
}

process Remove_invalid_streamlines {
    cpus 1

    input:
    tuple val(meta), path(tractogram)

    output:
    tuple val(meta), path("${meta.id}__rm_invalid_streamlines.trk"), emit: rm_invalid_for_remove_out_not_JHU

    script:
    """
      scil_remove_invalid_streamlines.py ${tractogram} ${meta.id}__rm_invalid_streamlines.trk --cut_invalid --remove_single_point -f
    """
}

process Copy_t1_atlas {
    cpus 1

    input:
      tuple val(meta), path(tractogram)

    output:
      path "${meta.id}__t1_mni_space.nii.gz"

    script:
    """
      cp ${params.rois_folder}${params.atlas.template} ${meta.id}__t1_mni_space.nii.gz
    """
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
    tractograms_to_clean = tractograms_to_clean.map { [ it[0], it[1] ] }

    Copy_t1_atlas(tractograms_to_clean)
    Remove_invalid_streamlines(tractograms_to_clean)

    emit:
    cleaned_mni_tractograms = Remove_invalid_streamlines.out.rm_invalid_for_remove_out_not_JHU
}