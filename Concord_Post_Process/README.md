# Workflow for Concord flux tower data

This handles the Concord flux tower data after processing in EddyPro. It first merges the processed Eddypro data and the tower's biomet data. It then gapfills any missing biomet data with data from the local CIMIS station. It then gapfills (and partitions) the NEE, RECO, GPP, LE, and H in ReadyProc. 

## A typical workflow for processing flux tower data

* Take from EddyPro output & merge with biomet file. The main point of the notebook is to merge the MET and eddy pro files, create some basic figures of key IRGA and MET variables, and do some basic data filtering. 
  
  * Input: master_eddy_pro_concord.csv
  * Input: MET_data_master.csv
  * Code: 01_Merge_edddy_pro_MET_filt_spectral.Rmd
  * Accompanying Functions: concord_filter, cospectra_plot3, sgl_spec_plot, spec_mdl
  * Output: {YYYY}-{MM}-{DD}_master_eddy_met_concord_postfiltering.csv

* Merge with CIMIS file. This notebook fills in MET data gaps with CIMIS data. We do this so that we have the most complete MET data set for gap filling. It outputs a CSV file. but this CSV file needs to be slightly manually edited so that when it is saved as a text file and used in the following notebook it is in the correct format

  * Input: {YYYY}-{MM}-{DD}_master_eddy_met_concord_postfiltering.csv
  * Input: CIMIS_hourly.csv 
  * Code: 02_Merging_CIMIS_gapfill_met.Rmd
  * Output: {YYYY}-{MM}-{DD}_reddy_proc.csv
  * Output: {YYYY}-{MM}-{DD}_eddy_met_cimis_gap_filled.csv
  
* Gapfill in ReadyProc. NEE, LE, H. Partition Reco and GPP
  * Input: {YYYY}-{MM}-{DD}_reddy_proc.txt
  * Code: 03_readyproc_GF_overall_tower_data.RMD
  * Output: {YYYY}-{MM}-{DD}_Gap_fill_combined_Concord.csv
  * Output: Graphs of gapfilled variables before and after gapfilling

* Create 1/2 hourly footprints for the fluxes. Determines percentage of flux's landing in treatment and control areas. 
  * Input: {YYYY}-{MM}-{DD}_eddy_met_cimis_gap_filled.csv
  * Input: 07B_Concord_growing_season_basemap.RData
  * Input: shape file for pre-defined areas (located in the folder 01_Data -> 08_shp_files)
  * Code: 07A_footprint_workflow_v2_cgg.RMD
    * Code (required functions to run code):
      * math_util.R
      * calc_footprint_FFP_climatology_v2.R
      * XY_to_latlon2.R, polar2cart.R
      * pbl_height.R,find_equal_dist.R
      * footprint_plot_v6.R
      * crop_fpt_climt.R
      * ext_radiation_v2.R
      * get_extent.R
      * data_filtering.R
  * Output:
    * 4 shape files for all half-hourly footprint contours (50%-80%)
    * 1 geo-tiff (stack) for all half-hourly footprint weights
    * 1 csv file containing basic information for all half-hourly footprints target.mon_fpt_valid_list.csv 

* Visualize and produce figures of ReadyProc data. 
  * This notebook's primary purpose is to create two figures. The first figure summarizes NEE, RECO, and GPP data for the overall site. The second figure summarizes Tair Tsoil, Precipitation, VWC, and Rg for the entire site, deliniating pre and post compost application.  This notebook also joins the gapfilled data with the csv with the percentage of each half-hourly footprint in the treatment and control areas (created in the footprint notebook -footprint_workflow_v1_cgg). It does a basic visaulization and comparison of the treatment, control, and seasonal wetland areas. However, a more accurated and detailined comparison is found in the Branch out for concord manuscript section
    * Input: {YYYY}-{MM}-{DD}_Gap_fill_combined_Concord.csv
    * Input: {YYYY}-{MM}-{DD}_master_eddy_met_concord_postfiltering.csv
    * Input: Master_fp_lc.csv
    * Code:  04_Visualizing_GF_readproc_overall_tower_data.RMD
    * Output: Concord_2019_182_2021_138_all_met_{YYYY}-{MM}-{DD}.png
    * Output: Concord_2019_182_2021_138_all_NEE_2022-04-04_{YYYY}-{MM}-{DD}.png


## Branch out for Concord manuscript

This branch is for Concord paper specific analyses.

* Merge gap-filled met data, eddypro full output, with footprint weight info. 
The output data contain a treatment column specifying the subgroups of combination
of treatment/control sides, pre/post-compost application

  * Input: {YYYY}-{MM}-{DD}_eddy_met_cimis_gap_filled.csv & Master_fp_lc.csv
  * Code: 11-Merge_fulloutput_CIMIS_landcover.Rmd
  * Output: {YYYY}-{MM}-{DD}_all_GAM_data.csv

* GAM modeling, reading flux tower data previously grouped and eosense data, 
splitting subgroups based on treatment/control, pre/post-compost, day/nighttime,
training GAMS models, making prediction and storing all prediction & summary.

  * Input: {YYYY}-{MM}-{DD}_all_GAM_data.csv & eo_sense_20210806.csv
  * Code: 12-Concord_bootstrap_GAMS_all.Rmd
  * Output: {YYYY}-{MM}-{DD}_all_data.rda
  * Output: {YYYY}-{MM}-{DD}_all_data_daily.rda
  * Output: {YYYY}-{MM}-{DD}_all_filled_matrix.rda
  * Ouput: {YYYY}-{MM}-{DD}_all_predict_matrix.rda
 
* Creating Figure 3 and Figure S2 of the appendix. 

  * Input: {YYYY}-{MM}-{DD}_all_data.rda
  * Input:{YYYY}-{MM}-{DD}_all_data_daily.rda
  * Input: {YYYY}-{MM}-{DD}_all_filled_matrix.rda
  * Input: {YYYY}-{MM}-{DD}_all_predict_matrix.rda
  * Code: 14-Final_Figures_Manuscript.Rmd
  * Output: Cumulative_NEE_GPP_Reco_post_compost_concord2020_306_2021_120_NEE_{YYYY}-{MM}-{DD}.png
  * Output: Cumulative_NEE_GPP_Reco_pre_compost_concord2019_305_2020_121_NEE_{YYYY}-{MM}-{DD}.png
  * Output: NEE_control_appendix_model_observed_daily2020_306_2021_120_NEE_{YYYY}-{MM}-{DD}.png
  * Output: NEE_treatment_appendix_model_observed_daily2020_306_2021_120_NEE_{YYYY}-{MM}-{DD}.png

* Performing the energy balance closure for the two years of the study and creating Figure S1 of the appendix, which is a visualization of the energy balance closure. 

  * Input: {YYYY}-{MM}-{DD}_eddy_met_cimis_gap_filled.csv
  * Code: 06_Energy_Balance_Closure.Rmd
  * Output: {YYYY}-{MM}-{DD}_2023-10-20Energy_balance_closure_no_int.png
  * Output: {YYYY}-{MM}-{DD}_2023-10-20coefs_both_year.csv
  * Output: {YYYY}-{MM}-{DD}_2023-10-20model_both_year.csv
