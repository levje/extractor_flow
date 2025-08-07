#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.input = false
params.help = false
params.debug = true

include { check_required_params; check_nb_cpus } from './modules/local/verify_inputs.nf'
include { TRANSFORM_TO_MNI; TRANSFORM_TO_ORIG; CLEAN_IF_FROM_MNI } from './modules/local/transform.nf'
include { MAJOR_FILTERING } from './modules/local/major_filtering.nf'
include { EXTRACT } from './modules/local/extraction.nf'

workflow get_data {
    main:
        if(params.help) {
            usage = file("$baseDir/USAGE")
            cpu_count = Runtime.runtime.availableProcessors()
            bindings = ["rois_folder":"$params.rois_folder",
                        "FLF": "$params.FLF",
                        "run_bet":"$params.run_bet",
                        "distance": "$params.distance",
                        "orig":"$params.orig",
                        "extended":"$params.extended",
                        "keep_intermediate_steps":"$params.keep_intermediate_steps",
                        "quick_registration": "$params.quick_registration",
                        "cpu_count":"$cpu_count",
                        "processes_bet_register_t1":"$params.processes_bet_register_t1",
                        "processes_major_filtering":"$params.processes_major_filtering"]  

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
    all_tractograms = cleaned_tractograms.cleaned_mni_tractograms.mix(transformed.tractograms)

    // wmparc_atlas = Channel.fromPath("${params.rois_folder}${params.atlas.JHU_8}")
    // csf_bin = Channel.fromPath("${params.rois_folder}${params.atlas.csf}")
    // all_tractograms = all_tractograms.combine(wmparc_atlas, csf_bin)

    rois_folder = Channel.fromPath("${params.rois_folder}")
    all_tractograms = all_tractograms.combine(rois_folder)
    filtered_tractograms = MAJOR_FILTERING(all_tractograms)

    // Start extracting bundles
    EXTRACT(filtered_tractograms.unplausible, filtered_tractograms.wb, data.sides)

    // Make sure this works properly (at first test seemed to output invalid streamlines)
    // TRANSFORM_TO_ORIG(data.t1s, transformed.tractograms, transformed.transformations_for_orig)
}
