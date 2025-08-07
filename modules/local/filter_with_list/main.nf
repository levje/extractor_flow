process FILTER_LIST {
  tag "$meta.id"
  cpus 1

  container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

  input:
    tuple val(meta), path(tractogram)

  output:
    tuple val(meta), path("${meta.id}__${task.ext.out_extension}.trk"), emit: extracted
    tuple val(meta), path("${meta.id}__${task.ext.remaining_extension}.trk"), optional: true, emit: remaining
    path "${meta.id}__${task.ext.out_extension}.txt"
    
  script:
    basename            = "${meta.id}"
    filtering_list      = task.ext.filtering_list
    out_extension       = task.ext.out_extension
    remaining_extension = task.ext.remaining_extension
    keep                = task.ext.keep
    extract_masks       = ""
    distance            = task.ext.distance

    template "old_filter_with_list.sh"
}

// This is the same as above, except that it supports input repeater for lists
// and sides.
process FILTER_LIST_EACH {
  tag "${meta.id}"
  cpus 1

  container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

  input:
    tuple val(meta), path(tractogram)
    each list
    each side

  output:
    tuple val(meta), path("${meta.id}__${task.ext.out_extension}${out_suffix}.trk"), emit: extracted
    tuple val(meta), val(side), path("${meta.id}__${task.ext.out_extension}${out_suffix}.trk"), emit: extracted_with_side
    tuple val(meta), val(list), path("${meta.id}__${task.ext.out_extension}${out_suffix}.trk"), emit: extracted_with_list
    tuple val(meta), val(side), val(list), path("${meta.id}__${task.ext.out_extension}${out_suffix}.trk"), emit: extracted_with_side_list
    tuple val(meta), path("${meta.id}__${task.ext.remaining_extension}${out_suffix}.trk"), optional: true, emit: remaining
    tuple val(meta), val(side), path("${meta.id}__${task.ext.remaining_extension}${out_suffix}.trk"), optional: true, emit: remaining_with_side
    tuple val(meta), val(list), path("${meta.id}__${task.ext.remaining_extension}${out_suffix}.trk"), optional: true, emit: remaining_with_list
    tuple val(meta), val(side), val(list), path("${meta.id}__${task.ext.remaining_extension}${out_suffix}.trk"), optional: true, emit: remaining_with_side_list
    path "${meta.id}__${task.ext.out_extension}${out_suffix}.txt"
    
  script:
    mid_suffix          = task.ext.mid_suffix != null ? task.ext.mid_suffix : ""
    reverse_suffix      = task.ext.reverse_suffix != null ? task.ext.reverse_suffix : false
    out_suffix          = task.ext.out_suffix != null ? task.ext.out_suffix : buildSuffix(side, list, mid_suffix, reverse_suffix)
    list_suffix         = task.ext.list_suffix != null ? task.ext.list_suffix : buildSuffix(side, list, mid_suffix, reverse_suffix)
    basename            = "${meta.id}"
    filtering_list      = addSuffixToFile(task.ext.filtering_list, list_suffix)
    out_extension       = task.ext.out_extension + out_suffix
    remaining_extension = task.ext.remaining_extension + out_suffix
    keep                = task.ext.keep
    extract_masks       = ""
    distance            = task.ext.distance

    template "old_filter_with_list.sh"
}

// This is the same as above, except that it takes a side as an input.
process FILTER_LIST_SIDE {
  tag "${meta.id}"
  cpus 1

  container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

  input:
    tuple val(meta), val(side), path(tractogram)
    each list

  output:
    tuple val(meta), path("${meta.id}__${task.ext.out_extension}${out_suffix}.trk"), emit: extracted
    tuple val(meta), val(side), path("${meta.id}__${task.ext.out_extension}${out_suffix}.trk"), emit: extracted_with_side
    tuple val(meta), val(list), path("${meta.id}__${task.ext.out_extension}${out_suffix}.trk"), emit: extracted_with_list
    tuple val(meta), path("${meta.id}__${task.ext.remaining_extension}${out_suffix}.trk"), optional: true, emit: remaining
    tuple val(meta), val(side), path("${meta.id}__${task.ext.remaining_extension}${out_suffix}.trk"), optional: true, emit: remaining_with_side
    tuple val(meta), val(list), path("${meta.id}__${task.ext.remaining_extension}${out_suffix}.trk"), optional: true, emit: remaining_with_list
    path "${meta.id}__${task.ext.out_extension}${out_suffix}.txt"
    
  script:
    mid_suffix          = task.ext.mid_suffix != null ? task.ext.mid_suffix : ""
    reverse_suffix      = task.ext.reverse_suffix != null ? task.ext.reverse_suffix : false
    out_suffix          = task.ext.out_suffix != null ? task.ext.out_suffix : buildSuffix(side, list, mid_suffix, reverse_suffix)
    list_suffix         = task.ext.list_suffix != null ? task.ext.list_suffix : buildSuffix(side, list, mid_suffix, reverse_suffix)
    basename            = "${meta.id}"
    filtering_list      = addSuffixToFile(task.ext.filtering_list, list_suffix)
    out_extension       = task.ext.out_extension + out_suffix
    remaining_extension = task.ext.remaining_extension + out_suffix
    keep                = task.ext.keep
    extract_masks       = ""
    distance            = task.ext.distance

    template "old_filter_with_list.sh"
}

def addSuffixToFile(str, suffix) {
  def file = new File(str)

  def name = file.name                           // 'file.txt'
  def baseName = name.lastIndexOf('.') >= 0 ? name[0..name.lastIndexOf('.') - 1] : name
  def extension = name.lastIndexOf('.') >= 0 ? name[name.lastIndexOf('.')..-1] : ''

  def newFileName = "${baseName}${suffix}${extension}"
  def newPath = new File(file.parent, newFileName).path

  return newPath
}

def buildSuffix(side, list, mid_suffix, reversed) {
  def suffix = ""
  // The suffix has the following format:
  // _${side}_${mid_suffix}_${list}
  // or
  // _${list}_${mid_suffix}_${side} (if reversed)
  if (!reversed) {
    if (side != null && side.trim() != "") {
      suffix += "_${side}"
    }
  }
  else {
    if (list != null && list.trim() != "") {
      suffix += "_${list}"
    }
  }

  // Middle part of the suffix if there is one.
  if (mid_suffix != null && mid_suffix.trim() != "") {
    suffix += "_${mid_suffix}"
  }
  
  if (!reversed) {
    if (list != null && list.trim() != "") {
      suffix += "_${list}"
    }
  }
  else {
    if (side != null && side.trim() != "") {
      suffix += "_${side}"
    }
  }

  return suffix
}