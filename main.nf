#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.input = false
params.help = false
params.debug = true

include { check_required_params; check_nb_cpus } from './modules/local/verify_inputs.nf'
include { TRANSFORM_TO_MNI; COPY_T1_TO_ORIG; CLEAN_IF_FROM_MNI } from './modules/local/transform.nf'
include { MAJOR_FILTERING } from './modules/local/major_filtering.nf'
include { EXTRACT } from './modules/local/extraction.nf'
include { EXTRACT_BUNDLES } from './modules/local/extension.nf'

include { TRACTOGRAM_MATH as RENAME_CORTICO_STRIATE } from './modules/local/merge/main.nf'

include { REGISTRATION_TRACTOGRAM as REGISTER_TRACTOGRAM_ORIG } from './modules/nf-neuro/registration/tractogram/main.nf'
include { REGISTRATION_TRACTOGRAM as REGISTER_BUNDLES_ORIG } from './modules/nf-neuro/registration/tractogram/main.nf'

workflow get_data {
    main:
        if(params.help) {
            usage = file("$baseDir/USAGE")
            cpu_count = Runtime.runtime.availableProcessors()
            bindings = [
                "rois_folder":               "$params.rois_folder",
                "FLF":                       "$params.FLF",
                "run_bet":                   "$params.run_bet",
                "distance":                  "$params.distance",
                "orig":                      "$params.orig",
                "extract_bundles":           "$params.extract_bundles",
                "keep_intermediate_steps":   "$params.keep_intermediate_steps",
                "quick_registration":        "$params.quick_registration",
                "processes_major_filtering": "$params.processes_major_filtering",
                "cpu_count":                 "$cpu_count"
            ]

            engine = new groovy.text.SimpleTemplateEngine()
            template = engine.createTemplate(usage.text).make(bindings)
            print template.toString()
            System.exit(0)
        }

        log.info "Extractor_flow pipeline"
        log.info "==================="
        log.info "Start time: $workflow.start"
        log.info ""

        if (!params.keep_intermediate_steps) {
            log.info "Warning: You won't be able to resume your processing if you don't use the option --keep_intermediate_steps"
            log.info ""
        }

        check_required_params(['input', 'templates_dir'])
        log.info "Input: $params.input"
        log.info "Templates directory: $params.templates_dir"

        root = file(params.input)
        in_tractogram = Channel.fromFilePairs("$root/**/*.trk",
                        size:1,
                        maxDepth:1,
                        flat: true) {[id: it.parent.name]}
        t1s = Channel.fromPath("$root/**/*_t1.nii.gz", maxDepth:1).map{[[id: it.parent.name], it]}

        number_subjects = in_tractogram.count()
        number_t1s = t1s.count()

        number_subjects.subscribe { a -> if (a == 0)
            error "Error ~ No subjects found. Please check the naming convention, your --input path." }

        number_subjects
            .concat(number_t1s)
            .toList()
            .subscribe{a, b -> if (a != b && b > 0)
                error "Error ~ Some subjects have a T1w and others don't.\n" +
                    "Please be sure to have the same acquisitions for all subjects."}

        if (params.orig){
            number_t1s
                .subscribe{a -> if (a == 0)
                    error "Error ~ You cannot use --orig without having any T1w in the orig space."}
        }

        side_values = params.sides?.tokenize(',')
        sides = Channel.from(side_values)

    emit:
        tractograms = in_tractogram
        t1s = t1s
        sides = sides
}

workflow {
    // ** Now call your input workflow to fetch your files ** //
    data = get_data()

    transformed = TRANSFORM_TO_MNI(data.tractograms, data.t1s)
    cleaned_tractograms = CLEAN_IF_FROM_MNI(data.tractograms, data.t1s)
    all_mni_tractograms = cleaned_tractograms.cleaned_mni_tractograms.mix(transformed.tractograms)

    // Major filtering
    filtered_tractograms = MAJOR_FILTERING(all_mni_tractograms)

    // Extract plausible and unplausible streamlines
    EXTRACT(filtered_tractograms.unplausible, filtered_tractograms.wb, data.sides, all_mni_tractograms)

    if (params.orig) {
        // Register the tractograms to the original space
        tractograms_to_transform = EXTRACT.out.plausible.concat(EXTRACT.out.unplausible)
        
        t1s_and_transformations = data.t1s.join(transformed.transformations_for_orig)
        trks_for_register = tractograms_to_transform.combine(t1s_and_transformations, by: 0)
            .map{ sid, trk, t1, transfo, deformation ->
                [sid, t1, transfo, trk, [], deformation]}
        REGISTER_TRACTOGRAM_ORIG(trks_for_register)

        // Copy the original T1w to the subject folder.
        COPY_T1_TO_ORIG(data.t1s)

        if (params.extract_bundles) {
            // Register the extracted bundles to the original space
            t1s_and_transformations = data.t1s.join(transformed.transformations_for_orig)
            bundles_to_register = EXTRACT.out.bundles.combine(t1s_and_transformations, by: 0)
                .map{ sid, trk, t1, transfo, deformation ->
                    [sid, t1, transfo, trk, [], deformation]}
            REGISTER_BUNDLES_ORIG(bundles_to_register)
        }
    }
}
