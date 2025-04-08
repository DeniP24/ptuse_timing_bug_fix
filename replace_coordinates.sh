#!/bin/bash

while IFS=' ' read -r file replacement_ra replacement_dec; do 
    coords="$replacement_ra$replacement_dec"    
    psredit -m -c "coord=$coords" "$file"
    psredit -m -c "ext:stt_crd1=$replacement_ra" "$file"
    psredit -m -c "ext:stt_crd2=$replacement_dec" "$file"
    psredit -m -c "ext:stp_crd1=$replacement_ra" "$file"
    psredit -m -c "ext:stp_crd2=$replacement_dec" "$file"
done < "pulsar_timing_bug_replacement_coords.txt"
