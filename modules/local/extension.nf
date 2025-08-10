
workflow EXTRACT_BUNDLES {
    take:
    tractograms
    
    main:
    println "This remains to be implemented!"
    println "Received:"
    tractograms.view()

    emit:
    bundles = Channel.empty() // Placeholder
}