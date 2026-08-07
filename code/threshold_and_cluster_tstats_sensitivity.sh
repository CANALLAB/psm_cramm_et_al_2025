#!/usr/bin/env bash

# NOTE: the path to the parent folder (of all the subfolders listed below) should be passed as the first argument to this script
BASE_DIR=$1

UNTHRESHOLDED_DIR="${BASE_DIR}/tstat_unthresholded/"
THRESHOLDED_DIR="${BASE_DIR}/tstat_thresholded/"
CLUSTER_DIR_WORK="${BASE_DIR}/clusters_supp/"
CLUSTER_DIR_FINAL="${BASE_DIR}/clusters_final/"
SENSITIVITY_WORK_DIR="${BASE_DIR}/tstat_sensitivity_work/"
SENSITIVITY_DIR="${BASE_DIR}/tstat_sensitivity/"

function cluster_image () {
    contrast=$1
    threshold=$2
    k=$3

    unthresh_img="${UNTHRESHOLDED_DIR}${contrast}_tstat_unthresh.nii"

    oindex="${SENSITIVITY_WORK_DIR}${contrast}_${threshold}_cluster_index.nii.gz"
    osize="${SENSITIVITY_WORK_DIR}${contrast}_${threshold}_cluster_size.nii.gz"
    olmax="${SENSITIVITY_WORK_DIR}${contrast}_${threshold}_local_maxima.txt"
    mask_k="${SENSITIVITY_WORK_DIR}${contrast}_${threshold}_local_maxima.txt"

    cluster_final="${SENSITIVITY_DIR}${contrast}_tstat-${threshold}_thresh_k${k}.nii.gz"

    cluster \
        --in=$unthresh_img \
        --thresh=$2 \
        --oindex=$oindex \
        --osize=$osize \
        --olmax=$olmax \
        --scalarname="T"

    fslmaths $osize -thr $k -bin $mask_k

    fslmaths $unthresh_img \
        -mas $mask_k \
        $cluster_final
}

function cluster_all_images () {
    #cluster_image "abide_exclusion_a-c" 4.29 57
    cluster_image "abide_exclusion_a-c" 4.0 57
    cluster_image "abide_exclusion_a-c" 3.5 57
    cluster_image "abide_exclusion_a-c" 3.0 57
    cluster_image "abide_exclusion_a-c" 2.5 57
    cluster_image "abide_exclusion_a-c" 2.0 57

    #cluster_image "abide_matching_a-c" 4.22 70
    cluster_image "abide_matching_a-c" 4.0 70
    cluster_image "abide_matching_a-c" 3.5 70
    cluster_image "abide_matching_a-c" 3.0 70
    cluster_image "abide_matching_a-c" 2.5 70
    cluster_image "abide_matching_a-c" 2.0 70
        
    #cluster_image "abide_fullsample_a-c" 4.22 64
    cluster_image "abide_fullsample_a-c" 4.0 64
    cluster_image "abide_fullsample_a-c" 3.5 64
    cluster_image "abide_fullsample_a-c" 3.0 64
    cluster_image "abide_fullsample_a-c" 2.5 64
    cluster_image "abide_fullsample_a-c" 2.0 64

    #cluster_image "cobre_matching_c-s" 4.71 31
    cluster_image "cobre_matching_c-s" 4.0 31
    cluster_image "cobre_matching_c-s" 3.5 31
    cluster_image "cobre_matching_c-s" 3.0 31
    cluster_image "cobre_matching_c-s" 2.5 31
    cluster_image "cobre_matching_c-s" 2.0 31
        
    #cluster_image "cobre_fullsample_c-s" 4.69 32
    cluster_image "cobre_fullsample_c-s" 4.0 32
    cluster_image "cobre_fullsample_c-s" 3.5 32
    cluster_image "cobre_fullsample_c-s" 3.0 32
    cluster_image "cobre_fullsample_c-s" 2.5 32
    cluster_image "cobre_fullsample_c-s" 2.0 32

    #cluster_image "ha_fullsample_o-y" 4.54 48
    cluster_image "ha_fullsample_o-y" 4.0 48
    cluster_image "ha_fullsample_o-y" 3.5 48
    cluster_image "ha_fullsample_o-y" 3.0 48
    cluster_image "ha_fullsample_o-y" 2.5 48
    cluster_image "ha_fullsample_o-y" 2.0 48
    
    #cluster_image "ha_fullsample_y-o" 4.54 48
    cluster_image "ha_fullsample_y-o" 4.0 48
    cluster_image "ha_fullsample_y-o" 3.5 48
    cluster_image "ha_fullsample_y-o" 3.0 48
    cluster_image "ha_fullsample_y-o" 2.5 48
    cluster_image "ha_fullsample_y-o" 2.0 48
    
    #cluster_image "ha_matching_o-y" 4.57 47
    cluster_image "ha_matching_o-y" 4.0 47
    cluster_image "ha_matching_o-y" 3.5 47
    cluster_image "ha_matching_o-y" 3.0 47
    cluster_image "ha_matching_o-y" 2.5 47
    cluster_image "ha_matching_o-y" 2.0 47
    
    #cluster_image "ha_matching_y-o" 4.57 48
    cluster_image "ha_matching_y-o" 4.0 48
    cluster_image "ha_matching_y-o" 3.5 48
    cluster_image "ha_matching_y-o" 3.0 48
    cluster_image "ha_matching_y-o" 2.5 48
    cluster_image "ha_matching_y-o" 2.0 48
}

#threshold_all_images 
cluster_all_images 