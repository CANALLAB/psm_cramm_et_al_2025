#!/usr/bin/env bash

# NOTE: the path to the parent folder (of all the subfolders listed below) should be passed as the first argument to this script
BASE_DIR=$1

UNTHRESHOLDED_DIR="${BASE_DIR}/tstat_unthresholded/"
THRESHOLDED_DIR="${BASE_DIR}/tstat_thresholded/"
CLUSTER_DIR_WORK="${BASE_DIR}/clusters_supp/"
CLUSTER_DIR_FINAL="${BASE_DIR}/clusters_final/"

function threshold_tstat_image () {
    infile=$1
    thresh=$2
    outfile=$3

    inpath=${UNTHRESHOLDED_DIR}${infile}
    outpath=${THRESHOLDED_DIR}${outfile}

    #echo $inpath
    #echo $outpath
    echo fslmaths "$inpath" -thr "$2" "$outpath"
    fslmaths $inpath -thr $2 $outpath 
}

function threshold_all_images () {
    threshold_tstat_image "abide_exclusion_a-c_tstat_unthresh.nii" 4.29 "abide_exclusion_a-c_tstat_thresh.nii"
    threshold_tstat_image "abide_matching_a-c_tstat_unthresh.nii" 4.22 "abide_matching_a-c_tstat_thresh.nii"
    threshold_tstat_image "abide_fullsample_a-c_tstat_unthresh.nii" 4.22 "abide_fullsample_a-c_tstat_thresh.nii"

    threshold_tstat_image "cobre_matching_c-s_tstat_unthresh.nii" 4.71 "cobre_matching_c-s_tstat_thresh.nii"
    threshold_tstat_image "cobre_fullsample_c-s_tstat_unthresh.nii" 4.69 "cobre_fullsample_c-s_tstat_thresh.nii"
    
    threshold_tstat_image "ha_fullsample_o-y_tstat_unthresh.nii" 4.54 "ha_fullsample_o-y_tstat_thresh.nii"
    threshold_tstat_image "ha_fullsample_y-o_tstat_unthresh.nii" 4.54 "ha_fullsample_y-o_tstat_thresh.nii"
    threshold_tstat_image "ha_matching_o-y_tstat_unthresh.nii" 4.57 "ha_matching_o-y_tstat_thresh.nii"
    threshold_tstat_image "ha_matching_y-o_tstat_unthresh.nii" 4.57 "ha_matching_y-o_tstat_thresh.nii"
}

function cluster_image () {
    contrast=$1
    threshold=$2
    k=$3

    thresh_img="${THRESHOLDED_DIR}${contrast}_tstat_thresh.nii.gz"

    oindex="${CLUSTER_DIR_WORK}${contrast}_cluster_index.nii.gz"
    osize="${CLUSTER_DIR_WORK}${contrast}_cluster_size.nii.gz"
    olmax="${CLUSTER_DIR_WORK}${contrast}_local_maxima.txt"
    mask_k="${CLUSTER_DIR_WORK}${contrast}_local_maxima.txt"

    cluster_final="${CLUSTER_DIR_FINAL}${contrast}_tstat_thresh_k${k}.nii.gz"

    cluster \
        --in=$thresh_img \
        --thresh=$2 \
        --oindex=$oindex \
        --osize=$osize \
        --olmax=$olmax \
        --scalarname="T"

    fslmaths $osize -thr $k -bin $mask_k

    fslmaths $thresh_img \
        -mas $mask_k \
        $cluster_final
}

function cluster_all_images () {
    cluster_image "abide_exclusion_a-c" 4.29 57
    cluster_image "abide_matching_a-c" 4.22 70
    cluster_image "abide_fullsample_a-c" 4.22 64

    cluster_image "cobre_matching_c-s" 4.71 31
    cluster_image "cobre_fullsample_c-s" 4.69 32

    cluster_image "ha_fullsample_o-y" 4.54 48
    cluster_image "ha_fullsample_y-o" 4.54 48
    cluster_image "ha_matching_o-y" 4.57 47
    cluster_image "ha_matching_y-o" 4.57 48
}

threshold_all_images 
cluster_all_images 