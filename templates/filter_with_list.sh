#!/bin/bash
set -e

# Print the parameters for debugging
echo "==============================="
echo "filter_with_list.sh arguments:"
echo "Distance:            ${distance}"
echo "Tractogram:          ${tractogram}"
echo "Basename:            ${basename}"
echo "Output Extension:    ${out_extension}"
echo "Remaining Extension: ${remaining_extension}"
echo "Filtering List:      ${filtering_list}"
echo "Extract Masks:       ${extract_masks}"
echo "Keep:                ${keep}"
echo "==============================="

if [ "${distance}" = "0" ]
then
scil_tractogram_filter_by_roi ${tractogram} ${basename}__${out_extension}.trk \
    --filtering_list ${filtering_list} ${extract_masks} -f \
    --display_count  > ${basename}__${out_extension}.txt;
else
scil_tractogram_filter_by_roi ${tractogram} ${basename}__${out_extension}.trk \
    --filtering_list ${filtering_list} ${extract_masks} -f \
     --overwrite_distance both_ends include ${distance} --overwrite_distance either_end include ${distance} --display_count  > ${basename}__${out_extension}.txt;
fi

if [ "${keep}" = "true" ]
then
    scil_tractogram_math difference ${tractogram} \
                                        ${basename}__${out_extension}.trk \
                                        ${basename}__${remaining_extension}.trk \
                                        --save_empty;
    scil_tractogram_count_streamlines ${basename}__${remaining_extension}.trk > ${basename}__${remaining_extension}.txt;
fi

echo "Done."
