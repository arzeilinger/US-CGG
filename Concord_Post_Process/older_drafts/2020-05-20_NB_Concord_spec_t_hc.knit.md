
<!-- rnb-text-begin -->

---
title: "Concord_spec_Tommy.With loops"
output: html_notebook
---




<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucm0obGlzdD1scygpKVxuXG5yZXF1aXJlKHN0cmluZ3IpXG5yZXF1aXJlKHpvbylcbnJlcXVpcmUob3BlbmFpcilcblxuc291cmNlKFwiY29uY29yZF9maWx0ZXIuUlwiKVxuc291cmNlKFwiY29zcGVjdHJhX3Bsb3QzLlJcIilcblxubmEuY291bnQ8LWZ1bmN0aW9uKHgpIHN1bShpcy5uYSh4KSlcbm5hLm1lYW48LWZ1bmN0aW9uKHgpIGlmZWxzZShpcy5uYW4obWVhbih4LG5hLnJtPVQpKSxOQSxtZWFuKHgsbmEucm09VCkpXG5cbmBgYCJ9 -->

```r
rm(list=ls())

require(stringr)
require(zoo)
require(openair)

source("concord_filter.R")
source("cospectra_plot3.R")

na.count<-function(x) sum(is.na(x))
na.mean<-function(x) ifelse(is.nan(mean(x,na.rm=T)),NA,mean(x,na.rm=T))

```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


# Defining the data I/O directory #
hc: define all I/O upfront and reuse them for consistency


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyMgY2hhbmdlIHJvb3QucGF0aCBhcyBuZWVkZWRcbnJvb3QucGF0aDwtXCJDOlxcXFxVc2Vyc1xcXFxUb21teVxcXFxmbHV4XFxcXERhdGEtZXhwbG9yaW5nXFxcXDAyX0NvbmNvcmRcXFxcXCJcbiNyb290LnBhdGg8LVwiRDpcXFxcSG91c2VuXFxcXEZsdXhcXFxcRGF0YS1leHBsb3JpbmdcXFxcMDJfQ29uY29yZFxcXFxcIlxuZWRkeXByby5wYXRoPC1wYXN0ZTAocm9vdC5wYXRoLFwiMDFfUHJvY2Nlc3NlZF9EYXRhXFxcXE1hc3Rlcl9FZGR5XFxcXFwiKSAjIyB0aGlzIGlzIHdoZXJlIHRoZSBFZGR5UHJvIG91dHB1dHMgbG9jYXRlZFxucGxvdC5wYXRoPC1wYXN0ZTAocm9vdC5wYXRoLFwiMDFfUHJvY2Nlc3NlZF9EYXRhXFxcXHNwZWN0cnVtX3Bsb3RcXFxcXCIpICMjIHRoaXMgaXMgd2hlcmUgdGhlIG91dHB1dCBwbG90cyBsb2NhdGVkXG5cbiNwYXRoX21ldDwtXCJDOlxcXFxVc2Vyc1xcXFxUb21teVxcXFxmbHV4XFxcXERhdGEtZXhwbG9yaW5nXFxcXDAyX0NvbmNvcmRcXFxcXCJcbnBhdGguaW5fbWV0PC1wYXN0ZShyb290LnBhdGgsXCIwMV9Qcm9jY2Vzc2VkX0RhdGFcIixzZXA9XCJcIilcbnZlcjwtXCJtZXRfZGF0YVwiIFxuXG4jIGhjOiBVc2UgdGhpcyBmb3Igc3RvcmluZyBjb21iaW5lZCBmaWxlXG5wYXRoLm91dDwtcGFzdGUocm9vdC5wYXRoLFwiMDNfY29tYmluZWRfZGF0YVxcXFxcIixzZXA9XCJcIilcblxuYGBgIn0= -->

```r
## change root.path as needed
root.path<-"C:\\Users\\Tommy\\flux\\Data-exploring\\02_Concord\\"
#root.path<-"D:\\Housen\\Flux\\Data-exploring\\02_Concord\\"
eddypro.path<-paste0(root.path,"01_Proccessed_Data\\Master_Eddy\\") ## this is where the EddyPro outputs located
plot.path<-paste0(root.path,"01_Proccessed_Data\\spectrum_plot\\") ## this is where the output plots located

#path_met<-"C:\\Users\\Tommy\\flux\\Data-exploring\\02_Concord\\"
path.in_met<-paste(root.path,"01_Proccessed_Data",sep="")
ver<-"met_data" 

# hc: Use this for storing combined file
path.out<-paste(root.path,"03_combined_data\\",sep="")

```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


# Define file naming / version used
hc: Keep anything that needs to change regularly here


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyMgdXNlIGZvbGxvd3MgdG8gc3BlY2lmeSB0aGUgdmVyc2lvbnMgb2YgRWRkeVBybyBvdXRwdXRzXG4jIGZpbGUgbmFtZSBvZiB0aGUgbWFzdGVyIEVkZHlQcm8gZmlsZVxuY2RhdGEuZmlsZTI8LXBhc3RlMChcIm1hc3Rlcl9lZGR5X3Byb19jb25jb3JkLmNzdlwiKVxuXG4jIyBVc2UgZm9sbG93cyB0byBkZWZpbmUgYmlubmVkIHNwZWN0cnVtIGZpbGUgbmFtZXNcbmNkYXRhLnByb2MudGltZTwtXCIyMDIwLTA0LTE3VDE2MTAyMFwiXG5jZGF0YS5wcm9jLmV4dDwtXCJfYWR2XCJcbiMyMDE5MDYxNC0xNzAwX2Jpbm5lZF9jb3NwZWN0cmFfMjAyMC0wNC0xN1QxNjEwMjBfYWR2XG5cbiMjIHVzZSBmb2xsb3dzIHRvIHNwZWNpZnkgdGhlIHZlcnNpb25zIG9mIG1hc3RlciBtZXQgZmlsZVxuZmlsZS5uYW1lPC1wYXN0ZShcIk1FVF9kYXRhX21hc3RlclwiLHNlcD1cIlwiKVxuXG4jXCJDOlxcVXNlcnNcXFRvbW15XFxmbHV4XFxEYXRhLWV4cGxvcmluZ1xcMDJfQ29uY29yZFxcMDFfUHJvY2Nlc3NlZF9EYXRhXFxNYXN0ZXJfRWRkeVwiXG4jXCJDOlxcVXNlcnNcXFRvbW15XFxmbHV4XFxEYXRhLWV4cGxvcmluZ1xcMDJfQ29uY29yZFxcMDFfUHJvY2Nlc3NlZF9EYXRhXFxNYXN0ZXJfRWRkeVxcbWFzdGVyX2VkZHlfcHJvX2NvbmNvcmQuY3N2XCJcbiNcIkM6XFxVc2Vyc1xcVG9tbXlcXGZsdXhcXERhdGEtZXhwbG9yaW5nXFwwMl9Db25jb3JkXFwwMV9Qcm9jY2Vzc2VkX0RhdGFcXE1hc3Rlcl9FZGR5XFxlZGR5cHJvX2Jpbm5lZF9jb3NwZWN0cmFcIlxuI1wiQzpcXFVzZXJzXFxUb21teVxcZmx1eFxcRGF0YS1leHBsb3JpbmdcXDAyX0NvbmNvcmRcXDAxX1Byb2NjZXNzZWRfRGF0YVxcTWFzdGVyX0VkZHlcXGVkZHlwcm9fZnVsbF9jb3NwZWN0cmFcIlxuI1wiQzpcXFVzZXJzXFxUb21teVxcZmx1eFxcRGF0YS1leHBsb3JpbmdcXDAyX0NvbmNvcmRcXDAxX1Byb2NjZXNzZWRfRGF0YVxcTWFzdGVyX0VkZHlcXHNwZWN0cnVtX3Bsb3RcIlxuXG5gYGAifQ== -->

```r
## use follows to specify the versions of EddyPro outputs
# file name of the master EddyPro file
cdata.file2<-paste0("master_eddy_pro_concord.csv")

## Use follows to define binned spectrum file names
cdata.proc.time<-"2020-04-17T161020"
cdata.proc.ext<-"_adv"
#20190614-1700_binned_cospectra_2020-04-17T161020_adv

## use follows to specify the versions of master met file
file.name<-paste("MET_data_master",sep="")

#"C:\Users\Tommy\flux\Data-exploring\02_Concord\01_Proccessed_Data\Master_Eddy"
#"C:\Users\Tommy\flux\Data-exploring\02_Concord\01_Proccessed_Data\Master_Eddy\master_eddy_pro_concord.csv"
#"C:\Users\Tommy\flux\Data-exploring\02_Concord\01_Proccessed_Data\Master_Eddy\eddypro_binned_cospectra"
#"C:\Users\Tommy\flux\Data-exploring\02_Concord\01_Proccessed_Data\Master_Eddy\eddypro_full_cospectra"
#"C:\Users\Tommy\flux\Data-exploring\02_Concord\01_Proccessed_Data\Master_Eddy\spectrum_plot"

```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


# Read in EddyPro fulloutput file
* parse variable names and define N/As
* remove time periods that does not have enough record of high frequency data


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyMgcmVhZCBpbiBmdWxsIG91dHB1dCBmaWxlXG5jZGF0YTwtcmVhZC5jc3YocGFzdGUoZWRkeXByby5wYXRoLGNkYXRhLmZpbGUyLHNlcD1cIlwiKSxcbiAgICAgICAgICAgICAgICBza2lwPTMsXG4gICAgICAgICAgICAgICAgaGVhZGVyPUYsXG4gICAgICAgICAgICAgICAgbmEuc3RyaW5ncz1cIi05OTk5XCIsXG4gICAgICAgICAgICAgICAgc3RyaW5nc0FzRmFjdG9ycz1GKVxuY29sbmFtZXMoY2RhdGEpPC1jb2xuYW1lcyhyZWFkLmNzdihwYXN0ZShlZGR5cHJvLnBhdGgsY2RhdGEuZmlsZTIsc2VwPVwiXCIpLFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBza2lwPTEsXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGhlYWRlcj1ULFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBuYS5zdHJpbmdzPVwiTmFOXCIpKVxuXG5jZGF0YTwtY2RhdGFbY2RhdGEkZmlsZW5hbWUhPVwibm90X2Vub3VnaF9kYXRhXCImXG4gICAgICAgICAgICAgICAhaXMubmEoY2RhdGEkdXNlZF9yZWNvcmRzKSxdXG5cbmhlYWQoY2RhdGEpXG5gYGAifQ== -->

```r
## read in full output file
cdata<-read.csv(paste(eddypro.path,cdata.file2,sep=""),
                skip=3,
                header=F,
                na.strings="-9999",
                stringsAsFactors=F)
colnames(cdata)<-colnames(read.csv(paste(eddypro.path,cdata.file2,sep=""),
                                   skip=1,
                                   header=T,
                                   na.strings="NaN"))

cdata<-cdata[cdata$filename!="not_enough_data"&
               !is.na(cdata$used_records),]

head(cdata)
```

<!-- rnb-source-end -->

<!-- rnb-frame-begin eyJtZXRhZGF0YSI6eyJjbGFzc2VzIjpbImRhdGEuZnJhbWUiXSwibmNvbCI6MTIwLCJucm93Ijo2fSwicmRmIjoiSDRzSUFBQUFBQUFBQnMxYUNWaFRSOWNPK3lvZ0tpNVZpd3N1QldMWVJGU2NxUXJLb29EZ2dtaGpTQUpFUWhLeUFlN2czckxZSW90YUJGeGF3UjIxdUFBM1d0eHh3Nm9vVnJGV2NTOG9JZ3JxUDNPVGV4TW8vWDZlNzN1Ky8vbnpQTU85NXoxejVzeVpPWFBPeVlRWmsrZTRtYzh4WnpBWUJneEQvTmNJL1dFWVR3cDJjZlZ3WlRBTTlSR2xoemhtK0ptSStEM1FDM295YkhBM0RXT3dLOHZGeTVrMTJ0bkZQY3hsdEJ1THhXTEw0amhTdVpzemkrWGk2Y21Nam9udXJLY25xOHM5dXp6bW1DNlA2ZFgxbnAxcmI3OEdacU5IdWJpUHdtTC9IYUM5TmlNWHo3RXNsZzdocGlYRzZITEc2SEs4ZEFoWEZ1N0dZRmpoVVNIdmw2Sk1pN3I3a0ZjYSt1N3k3ZDdvK1duZTk5ZW1ROTVSRFg1TVF4OG5hU1RUalp3TmRvNzJqZnBvK0w3Qm5iZi9sVS9PaTdpeE9seHllS3MrVVYzWWRQRFZVQStpeXEyYmJJM1padUpNNG94M1RibVZSTmtzeXlYV1ByMkpTdVZTOS91RzkzVG05VThmdGIzaTJrbFp5Y1lPVUZMbmQvd2JEd0FsQjk3WERyNzZDTWJiZjN6emk4ODJLRDFVM1ZqVVdnOWxEM1krREgxM3BjdmpCaWdXMmcwTVVzS2dQVi9jQ2VsN0dZWUVkdnNpWHBFT3c3eEc5Y3V2U0lEejNuNGZJejB3Q0VhNGszcTdPcTdLM0xadDJLemQ5MVRtUDdwSkI0UmVWcG1XU3BJZTVUdXBMRDN6aTViMWNGU1pUUGpybTNPV2NwV1owM0daODF2anJvNEwzbHg3dm5yZzBSbWcrWTlKczdJZmZRdmVHMFRjc0gwaEJCLzlCdlI4V0hZZEdoa3FYKy9jc1JBYW5QeXFwdCs5b3E2T3U3d0J2NXBzZzRiR0piRXR5bnp3Y2QyNDdaTzlwMEJMVDl0K2gwdWRLRDU0dTF2Qll6bCszVkVPUEZ3MU9hL2kxRlJ3ZzU4UU91Q3dMM2orZE5ITHUvV1hhSDcxbi9GTXVOcXhveHl4cFdsdDI3RWgyNG10SG1ESnkrOWppRUswMnZhVlA5TDhsQktpTnZCVThOLzBwVTV5MnJrb1VRaVd2U0FPUnN3R1lLUFQrSzNvbGVZdlJwczRLRHVVa2lzL25mcmtWczJFRStXdlVsNk50eWhzOXE2UTE4Njl0WFJzK1lXWm9RczJIUCttWEJWYTc3TXNiMEo1L1psSGlibFdFYlJjd2hoVjVFMzNsdktDM1NQdFIwdzc2eTBoNG54TzJKcVdMMDIzdEQrMGZseTU5UE5EcjV5MmkrVmJXbzY1akhlbjdZT3Ntci9jYnhaR1F0YlpOYWVHcmNpRHJHT3NpbTR2UjBKV1lkL0xKbXdKWkNXN0d6N3pUNFdzeERsSjNyZVgwM0pKc2EzMXd1OG13NlNvYzRlOTV0akFKQTd5OGdVVFlkTGNuTFNnKytOZzBuejFPVWlLd01zbDA4cWRJZGNOSnAzeUtieWdXZ21UeWpWeVIzc3VlakJsSDB5cXFOeXk4MkVZd3BIN2hMeWc1UDZGWC96VHAydm5Lcm1DMUFPVEg5dGp4VEM1SmEvRTJXb1dUSEh4RERqemN3Tk11U1F2Vzdqc0EweTUzeWNUdmRGeWpndnJiMFJkbVFnZGlVSE9DUzRib09QTEJKZU0wMGJRS2RwZ2YrbFRHK2ljZmVOSzhhVjg2S3hTTkg4YzlGa3JWN1ZzeEZDTFJPZzB4RmFVa3hZTW5XYWc1ZGp5RTNTNmN0b3dXY3lBVE5QVWVvUDlSeUhUTGZsV2JkTzYvN3I5VXA5azQ2Ry9qNExTTUdSOWFBdVVjaHoxTGYyT1E2bnkwWUt2MTN0QzZWYTB1NUhUb2JRSTdTcHZybGJ1UzdUOWs3S2hsRVVlQ0NnZGozb0huSVhTVU43Yy9udE1vWFFSZnJoQTZjcjJjaTBjbk9NWnNJWGJkOU9tVFp2Ujg2SWIrc0FXL2pFMUhYMU4vWXdaaDNFR0hVLzZyR3ZoL05RTnZESGxiOXdmWkFWZXQ3R3VHMjg3Q0Y0L2dsV0pUOStCMStVdFRUSkRRL0Q2aUlYMThCTXNXbC9HejZjeTVvMW9oaG03dHQ4eTk0NkhHVVZ1cEw2TVl1eHVQV0hHM2sya3ZveDlwUC9SK25MMzdzNmZ1Y1ViNUo3OUl3V1dyZ0M1Zi9UbE8xNy9GZVMyQlUrMWF6QUJtL0F4R1pGR1BXbTV3K25meHQ4VDdBV2xKMGE5bUhYaktqajI2bE5RVzA0MnFKaHZNckZId1ZsdytvTEM0T2dYZkZDNTJLZHhjVTBGTGJjS0JjVzVxOWVCMVgyK1FrTmFnZFdCdVd6ajVvMWdOYms5WDRBMUtQaXphL2FCTlRQS3g0L3U3azdibDhWWCsyL1dMbXpBVkpoMVNZSU5oZGxNQkQ5ZkRYTUd6QnZ4OWxRR3pKa3dCWGVnNWZJZVJ1RVB6SzhqY1Zod1JMMCsyNllHVmxWVlhZSTd2ZTZTY2p2ZmJteTNMc2xwRGkrdnpzZ0V5V2V1UFREOXRRa2tvNzl2Nmp4QnlxaTl3aU1lZWlDbCtjbEl2NTE4c0xMN2w1YnVKNHRvZlNHUGR1RUFBb1BiY1BpTGdNRkI2bmxORDVPSHByK1pCZ084eURnSS9aV2tQOUZ5SzFyVis3ZEtyUGF6dGVQeUs1VG5Ec1BVU3BST0N5L0N6Rm5xY1RidXdkdTVtSmFMcjFMSGtmZ3JPQjB1aGZIWDFQVkgvQTIxdjhmZngyR0tCK1BybmliKzlyR0psck9ZY0dQNG8wR3pvZG1kNFNNaTMyNkNOZ1Y1ZmlFcHhkRHlHOUZ6eVRBRGFMWE10U0JxdkFMYTlIemx4Uno0anBhekpOTW9oS2FYeEdFQkIvZERQWGRjVmdnZ281cGNHT0xxbmFhOVpWSFRpSGRlS1hxWDJKdnA5YXpFdzhsYmdlckFVdk9YbTZyQS9tL045Tzh4cXNGZWJONkZrNFRFNE5VMnMrSWRSTnBTWXVyeWl6L1Erbm84NXA0Tk91SVB1ejh2dXRhc2x3UnRqeGxYYmF1TmhEWkxXelBYSDdHSFZodXVScWN5d21EM3ZsWkZqMStWVW5MZUl4Nzg2ZHpyVlgyNXEvS0R3UGVvZDdtajBWcFJoSjY5dDBQL2tNdWVmUjU0TzhWZEczYTZ4eDF2VnRFVmNINVVJU1ZYOW1kYjN2am1oS1hsM1k1TmRjcVpiajcrOS9xbzNrTnFENVU5YmJqK2wvWCtrV1YxbzFjcEJKY1dsWnZzdUxraW82RHRQNTBuSExJaGR0RzIrV2x3OE9raHpjdW5WY0RCZFV0V0hibDdCZzQ2N08yTE1qKzB6N20wL2p0bUhoeDBvYVJQcndMdHZrZFZXK0lDQ0VhelFuQUJBZ1dPNm4yUHVhOSt4akhWZmkvV2I3L3ZVeUl2YlYzNTV6RG84MFJkVjQyTENEN3dldkVoT0tFNEJDZENxSVNxbGJhaVhLaVlpTnhweVN0Ni96NzJ2QTBUczN1Q0QvdGF2OW8zVWc2ZURGMVNhdjdyTHZETXBHbm16OVVUaVgyTWE2Vzk1L3hCbkR2MytXZ0pOd3ZKNEs5RXhpdlFuODRhUFc2ZEpzN2NMNHBmMnBnWERXb3pWZU1xcTUxQnpaN3pnM3dMZDRMcmU0VFlvOEN0NHRBMlJqYWRYOENudW52VjZ5NUx3TWNqWVlydC9RSWhJM0ZOdUg5VEkyanBQcjk1NXJ4UThHRWtLclB2WFFkdHFHcnlMUkZTY2lxL3JLY1BEcXd2VUUxS0g0TUUzcXJHRHNMVDdxdHlCYWk4Vko1WDJiK09NZnN0cTQvS1VVV3VEeVZIbEJpVjZXMFhqU0pLTTMvUGFYYU1KVTd1YkZzV0M1NFI1MzBURG1WVkRpWnFSKzlndE81S0lhNmkxWFhZOTVoZWI5c054bWxIajUrRjNTMWIyL2l3Q2xvOUdGQldKT2dITGZvdHR2RHFPd3dhRnFjZjV2b3RoaWFSZGZsUFl1aDRSOXhlV1A2d3RYd3hjYmN0L3FheGk1U29XeTRPZU9KeG4zaW9ieFc1YVVZZzhXemNsZWxyQXpjUTlWNDdkMjNKNnQvbFBEamRGL1MwTlNxRDAyOGhxL2xPTUlBelpOdVBDWnRod0UzU1QrQVVYSzNZaXFIZlM5bXpROUgwdVZBTlhyQ0s4NzZodjJydzBkeVNwMVZIVmZaYmY1NVNZL1JZWmY4WVJabCtCYXIrQndvOTM2U0dxYjVjWklzREFhM1AvZHhseWRqVzVkRERLZDZ5Sk9zWmRLMUN5OGdzZ1c3OTYxREJNQml5dkhDNjRVQ1hxdHRQSmt5azZ6em9WM2R4NURkYnY0RCs4MUM2V0xzUlRva082clpxbWg2Y2NoRzV0OTFhT05sTlhYZjVqc3pHbVlLV0N6M3hvMVhGL1Iwd3JCOXJwaXRuQ1F5cHdZbHFJWnpoRURxczk4a0tPUDB5dVQ4dytMRi9hcS9BWEZvdVlzOUwvTVVDem5OUjU4bHdFN0tlZytFeWRkMDJjM09pY0hDTU9aeDlDSlU5MXU5cE9kNEo5VHo0QTMvK0MxVlVNSkk0ZzE4ZzEyYmhzdmUxUStBQzVsVmNZRURPU2JLZXB2ZjN4cGlVNFdtV3Z4TFYzSDBPWDljOElTNVcrLzBaVkJCQ25HRVZIRHh4SllnNDhlbk5odFZOaFVTbFczMTZYOWRidE44M2VEMzdQZHpTQWpTTVpoWDE4aXdBRFo3RkRqVzM4a0NEMjBFVGVjdzYwT0J5ZWI5RC83Nmd3YjNVS1NSbkd6MVBzZjlhVlBENFE4bDJkVDBtVVhyakJBb2xIOGo5ZzlKaWRWMGtJNHB3d2F2VnQ4eTcvMGxHUFdpUTNUaGUwc2NPTkNRYStONmR6d01OUXFYLy9aWWhvQ0VxNHBsRjRWdlFJTTcwUUNiUStpQU9LeVdmNGFRZHVLenVCWDBEak5BR25JSUJmSFdlbTJrM3k3QlBwZ0tHV3VKeW0wdnJhOHpHQmNCdDBMamtZYTl1K3lhQXhyVjJack5VdDBEalFtUzIrVlhRR0hFazcrN0FKTkFvWFZ6eTZYUWM3Wi9PZzVCYkhheFVNUytRKzZwaVdwQUJRalhxaUlPditVK0JLbGJCNTV5aDhqQ1Z5OUoyZGRxL3F3L1VwMzJiczlYdUZuakJLUVlHQVZhZ1lTQ1pOOEdibTdOYkJibis0Tk9XSzc4Ulp0bWdsZHdlOC85QUgzbXVSKzAzNVhiVy9wL3l6MUpQaXUreDQ4bm56bHBYK1F3OWRrYW5yYXQ4QmlQOEgxcFgrZFQ5REw3UU05VmdCcDNFWGN6SEYwUW1HcHppNitzMDNic2Vpbzk5eEFJMVc5VDZvV2Fwb1NtK3BjYUhjRDg3emZqbU92eUJxUFhXOEFabytySTZtVi9Iei84Vm4vY1BUWDB1V2dlU2NSbTBqaTNiS09HOUJNMGJNMjUvSE4wQ212YUhyNy9mWFFZYWYwaTN6TXR6Qis5ZWI5aDllSHFJVmc1SHpVa0UrSkJUNWZYNXBqWFV2emhoZHVqMkYrQ2Q5WlVWZDkyazRGUHEyZlQ4aFJ0QlczTFFkM1BTUFdtNU82MWJYcklhdU9EbWdrVHJ1M1oyNE9iZCtkeDEvQ3h3TFgxMGhxbXZQYmg2SmFML21xbXJ3SFgvaW9WdWk1SnB1WWYya2VhbFBZYURKdzdiZ2x0Z0gvQWlZN1JnYW00emFQeWV2RDhBYi9vVmo3MldOZ3k4M2xjRzA5TFAwM0lMQTJvTGRnN0xCcEtKTmFkMmhOMERNdjhMbitQY3pJQlMvVDBISk9CMDdQZ2JVQjdzSHpmUUpwV1Nndzd3dlZuc3NWVElDaVR2VTZEWHBQT3ZMcmJhd1VsanlUZ0h3MzY0SmV2VEZneURUclQyT2lKN1R1dTdzT0o5eG5ibEQ2REs1MU4zVzJVcnFMS1lwWmk5K1RXNDFLMHVNNVM1R0Z6dFV6LzdoL1J1NEpwMXlkRGlPOXE2SSszeDV0K2N4dWNUR2VyNm5FZy9TdGFYeEFaVXBSbW5IU00yNERBYW1rRjgvN3pkdmNXL0d3K2gyeGgxL2VybXFiNVBjUE5RNXdjM3ZDcUd6N1I4cjRMaE04STR0SnoyWGtaemo4SlJmdzlNbXZzZFRzZ3dhVDZaYjJGU0JDcHIzdnhDeS8zOVBnTlZGV016TzduUFdJa1RKUzAzSE45bUdFeUJ3OWZnY3E0N0hINE1WY3ZpYWpoaUFubmhCVWV1VU44TGpOemRiaDlnK0U5NFdsL0M4Q0p5SGpDOGVGcDFZMUViRE4rdHZqOElQMnpxTXV4cEVndy9vTkhYN2djREl4RW5qbzh2bFd3WStFY0ROV2dhSlJEeU1VTkRHL0k0Y3ZwZExxQnhnOGxCNFpwWEV4NG5TWWRqaVVkZ1MvbGNzWlFub3pDRmpNL3JnQm1FY1JTYVYrTjRMbHRMNlUybDlDR1lldGNQOUtHbWpWQ2FNT1dLWGRsUlFnVTFmUXZFN0FDWnhyaUtPM2JwQUJsUFpjdmtVdXJYQlpOQUgxMlNWS0ZMWTJFZDJnenpsVXdPVDBrQnVJTXUwQjMzaUJNTE9WSTJqeStTQ2VSSkhSaDhkcFNVdzVVTHhDSU53NFprQ0JJRm9taTJsSU1ZMURwaUhLODFXOGloOUZ0ampNZVBJbkV0M0IzUG9sT2xHc2JmbFpLTVRwUml2S05TakhXaVZDWVdDYmhzT1Q5T3drZERLS1NVVTFoekJOSk9ZRXNNUzZSOG1VeUxXV0NzdzVReEZNUG55Tmxjam9URDFUSnNNRU50cEZJc1ZOQStxTzhUcG5ucmtZRDhGM0U1RW5ISFVmWG8zbndaUFg4Sm55dUlRaWJFS09JRVBHMWYvUm1VSXhyTUNwNU0rV2NZajU5QU9ZMkNyUkJKeFhLS1ZMWW5FOXFSUmdxMkRxSFVKUkowQ1BNRWdZakhSbFBpOHpTSVZSd25rZjAzMUpSRWVBSXBOY1VrRGpVdEk0bEF6bzJoNWlzVkM0V1VRUW9tZlE0RHFOT2tGMGlOT0llNWlNbGpNaW5hSWxLY3dCZTE4d3I5TUdvQW96Z3hqMCtOYTV6SWx2QTVzZFE0aVd4eFZKU01UNXVYeUhaaE1iV0VteTdob1V0NDZoSmVOR0dzRU9sRUNoUDB5cFp4b3lqN0VKUGFKcU9wT2d3anhLQkRoakUrM2pUTEFyRTZCQXdUOHNDMzY5RWhYcGlRSVlEdVlTYVRDR0w1TW5ZTUJmVG14RW1FQXJtQ2grT2dERGttUG1WYXRnVlBLcGF3eFFxNUZyTGxSSkw5MEJrVHhBbmtPbVAxbE1YeUUwVG9oTEJqRlZLNVdDYjQxendaUFNKUElPT0tSWEtCU0NHUUMzUm45emNPTFdPdU9jM2F2alJDOTdIbXlPVWNiaXliSTRwR0lVUTdxQWhaS0pQek9id2t0WVBTSEZPMFJlVDZVTFN5QTUzUW5qWkQxcmNEek1uOWFJZVE2NitMV0hOanhCSVVYTmlCZmt4UEQvb1hWaHNlWDg3bnlzVWRjUXVKVU5nQnNwUWxpYmdkc041eGZJNEl4UTZoZ3MrZUVScnExNEdOanJHU1F4MDZkSXgxaUFRZHdoZ1pwS1ZJNzlJaHlXUkJrNllKVE5TYks2WnpTUUlUOTI4SFlBa3RZS0VVb0lXUFl1T3A2bVlzWFpvTTdGcmFDb1V0dGtRc0VNbDEwUUhrTWd1aVJSd2hUbTk4VWJROGhvMnRWWGRxWHp1WVNjVUpUS3Ard0VXNC9nb0crVEh1V0dSd2hSd1pWV1JRb0RrcUtqaE1sSDVRd0dZd1BuVVFNUkZMOEhsQlF2cjQzeG1NT2dqclNUc0ExZ29SbmduUG1SdWpFTVU2NDNMVG5LSDlHdFJOOHpUV2VVOVVxOVQvckJuS2lOb3FaTFZBUk9VRkl5RW5rZzVzVnNoaTBtQ21SSXBXanJJRW9US21YQ3puQ0xYZUtxUVEwamJHcC84Qjk5RStsc1loQUFBPSJ9 -->

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["filename"],"name":[1],"type":["chr"],"align":["left"]},{"label":["date"],"name":[2],"type":["chr"],"align":["left"]},{"label":["time"],"name":[3],"type":["chr"],"align":["left"]},{"label":["DOY"],"name":[4],"type":["dbl"],"align":["right"]},{"label":["daytime"],"name":[5],"type":["int"],"align":["right"]},{"label":["file_records"],"name":[6],"type":["int"],"align":["right"]},{"label":["used_records"],"name":[7],"type":["int"],"align":["right"]},{"label":["Tau"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["qc_Tau"],"name":[9],"type":["int"],"align":["right"]},{"label":["H"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["qc_H"],"name":[11],"type":["int"],"align":["right"]},{"label":["LE"],"name":[12],"type":["dbl"],"align":["right"]},{"label":["qc_LE"],"name":[13],"type":["int"],"align":["right"]},{"label":["co2_flux"],"name":[14],"type":["dbl"],"align":["right"]},{"label":["qc_co2_flux"],"name":[15],"type":["int"],"align":["right"]},{"label":["h2o_flux"],"name":[16],"type":["dbl"],"align":["right"]},{"label":["qc_h2o_flux"],"name":[17],"type":["int"],"align":["right"]},{"label":["H_strg"],"name":[18],"type":["dbl"],"align":["right"]},{"label":["LE_strg"],"name":[19],"type":["dbl"],"align":["right"]},{"label":["co2_strg"],"name":[20],"type":["dbl"],"align":["right"]},{"label":["h2o_strg"],"name":[21],"type":["dbl"],"align":["right"]},{"label":["co2_v.adv"],"name":[22],"type":["dbl"],"align":["right"]},{"label":["h2o_v.adv"],"name":[23],"type":["dbl"],"align":["right"]},{"label":["co2_molar_density"],"name":[24],"type":["dbl"],"align":["right"]},{"label":["co2_mole_fraction"],"name":[25],"type":["dbl"],"align":["right"]},{"label":["co2_mixing_ratio"],"name":[26],"type":["dbl"],"align":["right"]},{"label":["co2_time_lag"],"name":[27],"type":["dbl"],"align":["right"]},{"label":["co2_def_timelag"],"name":[28],"type":["int"],"align":["right"]},{"label":["h2o_molar_density"],"name":[29],"type":["dbl"],"align":["right"]},{"label":["h2o_mole_fraction"],"name":[30],"type":["dbl"],"align":["right"]},{"label":["h2o_mixing_ratio"],"name":[31],"type":["dbl"],"align":["right"]},{"label":["h2o_time_lag"],"name":[32],"type":["dbl"],"align":["right"]},{"label":["h2o_def_timelag"],"name":[33],"type":["int"],"align":["right"]},{"label":["sonic_temperature"],"name":[34],"type":["dbl"],"align":["right"]},{"label":["air_temperature"],"name":[35],"type":["dbl"],"align":["right"]},{"label":["air_pressure"],"name":[36],"type":["dbl"],"align":["right"]},{"label":["air_density"],"name":[37],"type":["dbl"],"align":["right"]},{"label":["air_heat_capacity"],"name":[38],"type":["dbl"],"align":["right"]},{"label":["air_molar_volume"],"name":[39],"type":["dbl"],"align":["right"]},{"label":["ET"],"name":[40],"type":["dbl"],"align":["right"]},{"label":["water_vapor_density"],"name":[41],"type":["dbl"],"align":["right"]},{"label":["e"],"name":[42],"type":["dbl"],"align":["right"]},{"label":["es"],"name":[43],"type":["dbl"],"align":["right"]},{"label":["specific_humidity"],"name":[44],"type":["dbl"],"align":["right"]},{"label":["RH"],"name":[45],"type":["dbl"],"align":["right"]},{"label":["VPD"],"name":[46],"type":["dbl"],"align":["right"]},{"label":["Tdew"],"name":[47],"type":["dbl"],"align":["right"]},{"label":["u_unrot"],"name":[48],"type":["dbl"],"align":["right"]},{"label":["v_unrot"],"name":[49],"type":["dbl"],"align":["right"]},{"label":["w_unrot"],"name":[50],"type":["dbl"],"align":["right"]},{"label":["u_rot"],"name":[51],"type":["dbl"],"align":["right"]},{"label":["v_rot"],"name":[52],"type":["dbl"],"align":["right"]},{"label":["w_rot"],"name":[53],"type":["dbl"],"align":["right"]},{"label":["wind_speed"],"name":[54],"type":["dbl"],"align":["right"]},{"label":["max_wind_speed"],"name":[55],"type":["dbl"],"align":["right"]},{"label":["wind_dir"],"name":[56],"type":["dbl"],"align":["right"]},{"label":["yaw"],"name":[57],"type":["dbl"],"align":["right"]},{"label":["pitch"],"name":[58],"type":["dbl"],"align":["right"]},{"label":["roll"],"name":[59],"type":["lgl"],"align":["right"]},{"label":["u."],"name":[60],"type":["dbl"],"align":["right"]},{"label":["TKE"],"name":[61],"type":["dbl"],"align":["right"]},{"label":["L"],"name":[62],"type":["dbl"],"align":["right"]},{"label":["X.z.d..L"],"name":[63],"type":["dbl"],"align":["right"]},{"label":["bowen_ratio"],"name":[64],"type":["dbl"],"align":["right"]},{"label":["T."],"name":[65],"type":["dbl"],"align":["right"]},{"label":["model"],"name":[66],"type":["int"],"align":["right"]},{"label":["x_peak"],"name":[67],"type":["dbl"],"align":["right"]},{"label":["x_offset"],"name":[68],"type":["dbl"],"align":["right"]},{"label":["x_10."],"name":[69],"type":["dbl"],"align":["right"]},{"label":["x_30."],"name":[70],"type":["dbl"],"align":["right"]},{"label":["x_50."],"name":[71],"type":["dbl"],"align":["right"]},{"label":["x_70."],"name":[72],"type":["dbl"],"align":["right"]},{"label":["x_90."],"name":[73],"type":["dbl"],"align":["right"]},{"label":["un_Tau"],"name":[74],"type":["dbl"],"align":["right"]},{"label":["Tau_scf"],"name":[75],"type":["dbl"],"align":["right"]},{"label":["un_H"],"name":[76],"type":["dbl"],"align":["right"]},{"label":["H_scf"],"name":[77],"type":["dbl"],"align":["right"]},{"label":["un_LE"],"name":[78],"type":["dbl"],"align":["right"]},{"label":["LE_scf"],"name":[79],"type":["dbl"],"align":["right"]},{"label":["un_co2_flux"],"name":[80],"type":["dbl"],"align":["right"]},{"label":["co2_scf"],"name":[81],"type":["dbl"],"align":["right"]},{"label":["un_h2o_flux"],"name":[82],"type":["dbl"],"align":["right"]},{"label":["h2o_scf"],"name":[83],"type":["dbl"],"align":["right"]},{"label":["spikes_hf"],"name":[84],"type":["int"],"align":["right"]},{"label":["amplitude_resolution_hf"],"name":[85],"type":["int"],"align":["right"]},{"label":["drop_out_hf"],"name":[86],"type":["int"],"align":["right"]},{"label":["absolute_limits_hf"],"name":[87],"type":["int"],"align":["right"]},{"label":["skewness_kurtosis_hf"],"name":[88],"type":["int"],"align":["right"]},{"label":["skewness_kurtosis_sf"],"name":[89],"type":["int"],"align":["right"]},{"label":["discontinuities_hf"],"name":[90],"type":["int"],"align":["right"]},{"label":["discontinuities_sf"],"name":[91],"type":["int"],"align":["right"]},{"label":["timelag_hf"],"name":[92],"type":["int"],"align":["right"]},{"label":["timelag_sf"],"name":[93],"type":["int"],"align":["right"]},{"label":["attack_angle_hf"],"name":[94],"type":["int"],"align":["right"]},{"label":["non_steady_wind_hf"],"name":[95],"type":["int"],"align":["right"]},{"label":["u_spikes"],"name":[96],"type":["int"],"align":["right"]},{"label":["v_spikes"],"name":[97],"type":["int"],"align":["right"]},{"label":["w_spikes"],"name":[98],"type":["int"],"align":["right"]},{"label":["ts_spikes"],"name":[99],"type":["int"],"align":["right"]},{"label":["co2_spikes"],"name":[100],"type":["int"],"align":["right"]},{"label":["h2o_spikes"],"name":[101],"type":["int"],"align":["right"]},{"label":["chopper_LI.7500"],"name":[102],"type":["int"],"align":["right"]},{"label":["detector_LI.7500"],"name":[103],"type":["int"],"align":["right"]},{"label":["pll_LI.7500"],"name":[104],"type":["int"],"align":["right"]},{"label":["sync_LI.7500"],"name":[105],"type":["int"],"align":["right"]},{"label":["mean_value_RSSI_LI.7500"],"name":[106],"type":["int"],"align":["right"]},{"label":["u_var"],"name":[107],"type":["dbl"],"align":["right"]},{"label":["v_var"],"name":[108],"type":["dbl"],"align":["right"]},{"label":["w_var"],"name":[109],"type":["dbl"],"align":["right"]},{"label":["ts_var"],"name":[110],"type":["dbl"],"align":["right"]},{"label":["co2_var"],"name":[111],"type":["dbl"],"align":["right"]},{"label":["h2o_var"],"name":[112],"type":["dbl"],"align":["right"]},{"label":["w.ts_cov"],"name":[113],"type":["dbl"],"align":["right"]},{"label":["w.co2_cov"],"name":[114],"type":["dbl"],"align":["right"]},{"label":["w.h2o_cov"],"name":[115],"type":["dbl"],"align":["right"]},{"label":["vin_sf_mean"],"name":[116],"type":["dbl"],"align":["right"]},{"label":["co2_mean"],"name":[117],"type":["dbl"],"align":["right"]},{"label":["h2o_mean"],"name":[118],"type":["dbl"],"align":["right"]},{"label":["dew_point_mean"],"name":[119],"type":["dbl"],"align":["right"]},{"label":["co2_signal_strength_7500_mean"],"name":[120],"type":["dbl"],"align":["right"]}],"data":[{"1":"2019-06-14T163000_smart3-00177.ghg","2":"6/14/2019","3":"17:00","4":"165.7082","5":"1","6":"18000","7":"18000","8":"-0.336264","9":"0","10":"254.852","11":"0","12":"54.9173","13":"0","14":"-3.25927","15":"0","16":"1.23875","17":"0","18":"NA","19":"NA","20":"NA","21":"NA","22":"-3.92e-11","23":"-1.32e-12","24":"16.8474","25":"406.749","26":"412.403","27":"0","28":"0","29":"567.815","30":"13.7088","31":"13.8994","32":"0","33":"0","34":"292.344","35":"289.994","36":"99863.5","37":"1.19349","38":"1012.97","39":"0.0241","40":"0.080300","41":"0.0102","42":"1369.38","43":"1912.85","44":"0.00857","45":"71.5884","46":"543.470","47":"284.798","48":"3.40568","49":"3.623120","50":"0.157795","51":"4.97499","52":"4.42e-14","53":"-2.33e-15","54":"4.97499","55":"9.78207","56":"182.564","57":"46.7719","58":"1.817590","59":"NA","60":"0.530800","61":"1.92990","62":"-51.17120","63":"-0.070400","64":"4.64065","65":"-0.397140","66":"0","67":"60.5488","68":"-9.18851","69":"20.7844","70":"51.7562","71":"78.9314","72":"110.7020","73":"165.852","74":"-0.331574","75":"1.01414","76":"250.329","77":"1.03082","78":"32.6304","79":"1.09915","80":"-14.5657","81":"1.09915","82":"0.736028","83":"1.09915","84":"800000099","85":"800000099","86":"800000099","87":"800000099","88":"800000099","89":"800000099","90":"899999999","91":"899999999","92":"89999","93":"89999","94":"89","95":"89","96":"1","97":"0","98":"2","99":"10","100":"12","101":"30","102":"0","103":"0","104":"0","105":"0","106":"100","107":"1.69495","108":"1.74324","109":"0.421607","110":"0.597703","111":"0.00321","112":"10.6269","113":"0.207061","114":"-0.0146","115":"0.736028","116":"19.2200","117":"406.749","118":"13.7088","119":"11.5784","120":"102.605","_rn_":"1"},{"1":"2019-06-14T170000_smart3-00177.ghg","2":"6/14/2019","3":"17:30","4":"165.7290","5":"1","6":"18000","7":"18000","8":"-0.291135","9":"0","10":"270.018","11":"0","12":"63.3446","13":"0","14":"-3.32627","15":"0","16":"1.43024","17":"0","18":"2.50327","19":"0.609896","20":"-0.02730","21":"0.01380","22":"-2.22e-10","23":"-7.58e-12","24":"16.7794","25":"406.424","26":"412.142","27":"0","28":"0","29":"572.766","30":"13.8733","31":"14.0685","32":"0","33":"0","34":"293.288","35":"291.013","36":"99889.6","37":"1.18955","38":"1013.08","39":"0.0242","40":"0.092700","41":"0.0103","42":"1386.17","43":"2040.07","44":"0.00868","45":"67.9472","46":"653.901","47":"284.983","48":"3.23152","49":"3.100310","50":"0.130386","51":"4.48014","52":"-6.56e-14","53":"-1.32e-14","54":"4.48014","55":"9.38504","56":"185.510","57":"43.8129","58":"1.667720","59":"NA","60":"0.494717","61":"1.85677","62":"-39.11110","63":"-0.092100","64":"4.26268","65":"-0.452908","66":"0","67":"61.6824","68":"-9.36054","69":"21.1736","70":"52.7252","71":"80.4092","72":"112.7750","73":"168.958","74":"-0.287334","75":"1.01323","76":"266.192","77":"1.02828","78":"39.2814","79":"1.09299","80":"-15.3951","81":"1.09299","82":"0.886922","83":"1.09299","84":"800000099","85":"800000099","86":"800000099","87":"800000099","88":"800000099","89":"800000099","90":"899999999","91":"899999999","92":"89999","93":"89999","94":"89","95":"89","96":"1","97":"0","98":"2","99":"11","100":"14","101":"23","102":"0","103":"0","104":"0","105":"0","106":"100","107":"1.70184","108":"1.66206","109":"0.349638","110":"0.754594","111":"0.00397","112":"16.2978","113":"0.220886","114":"-0.0154","115":"0.886922","116":"19.2149","117":"406.423","118":"13.8733","119":"11.7628","120":"102.648","_rn_":"2"},{"1":"2019-06-14T173000_smart3-00177.ghg","2":"6/14/2019","3":"18:00","4":"165.7498","5":"1","6":"18000","7":"18000","8":"-0.220308","9":"0","10":"267.061","11":"0","12":"69.1883","13":"0","14":"-3.08957","15":"0","16":"1.56332","17":"0","18":"1.84576","19":"0.334318","20":"-0.02950","21":"0.00755","22":"2.77e-11","23":"9.52e-13","24":"16.7234","25":"406.071","26":"411.821","27":"0","28":"0","29":"575.077","30":"13.9638","31":"14.1615","32":"0","33":"0","34":"294.073","35":"291.766","36":"99900.7","37":"1.18657","38":"1013.15","39":"0.0243","40":"0.101303","41":"0.0104","42":"1395.36","43":"2138.82","44":"0.00873","45":"65.2400","46":"743.453","47":"285.083","48":"4.15685","49":"2.150730","50":"0.061600","51":"4.68069","52":"-4.80e-14","53":"1.66e-15","54":"4.68069","55":"9.43845","56":"201.354","57":"27.3567","58":"0.754454","59":"NA","60":"0.430893","61":"2.05885","62":"-26.13170","63":"-0.137878","64":"3.85992","65":"-0.515556","66":"0","67":"54.7589","68":"-8.30987","69":"18.7969","70":"46.8071","71":"71.3837","72":"100.1170","73":"149.993","74":"-0.217355","75":"1.01359","76":"263.390","77":"1.02930","78":"44.5861","79":"1.09548","80":"-15.0232","81":"1.09548","82":"1.007430","83":"1.09548","84":"800000099","85":"800000099","86":"800000099","87":"800000099","88":"800000099","89":"800000099","90":"899999999","91":"899999999","92":"89999","93":"89999","94":"89","95":"89","96":"2","97":"2","98":"2","99":"18","100":"10","101":"22","102":"0","103":"0","104":"0","105":"0","106":"100","107":"1.41127","108":"2.34924","109":"0.357200","110":"0.892482","111":"0.00471","112":"25.2648","113":"0.219096","114":"-0.0150","115":"1.007430","116":"19.2100","117":"406.070","118":"13.9639","119":"11.8629","120":"102.661","_rn_":"3"},{"1":"2019-06-14T180000_smart3-00177.ghg","2":"6/14/2019","3":"18:30","4":"165.7707","5":"1","6":"18000","7":"18000","8":"-0.175547","9":"0","10":"274.062","11":"0","12":"80.8935","13":"0","14":"-3.52716","15":"0","16":"1.83035","17":"0","18":"3.52689","19":"0.872251","20":"-0.03400","21":"0.01970","22":"-4.79e-11","23":"-1.68e-12","24":"16.6293","25":"405.662","26":"411.505","27":"0","28":"0","29":"582.152","30":"14.2012","31":"14.4058","32":"0","33":"0","34":"295.431","35":"293.212","36":"99931.6","37":"1.18097","38":"1013.31","39":"0.0244","40":"0.118607","41":"0.0105","42":"1419.53","43":"2340.15","44":"0.00888","45":"60.6598","46":"920.619","47":"285.344","48":"3.54611","49":"2.102630","50":"0.058500","51":"4.12303","52":"3.75e-14","53":"-2.88e-15","54":"4.12303","55":"8.85203","56":"198.979","57":"30.6653","58":"0.813471","59":"NA","60":"0.385546","61":"1.50424","62":"-18.24650","63":"-0.197463","64":"3.38793","65":"-0.594001","66":"0","67":"55.6790","68":"-8.44950","69":"19.1128","70":"47.5935","71":"72.5832","72":"101.7990","73":"152.513","74":"-0.173359","75":"1.01262","76":"271.634","77":"1.02648","78":"54.7950","79":"1.08859","80":"-15.8538","81":"1.08859","82":"1.239830","83":"1.08859","84":"800000099","85":"800000099","86":"800000099","87":"800000099","88":"800000099","89":"800000199","90":"899999999","91":"899999999","92":"89999","93":"89999","94":"89","95":"89","96":"8","97":"9","98":"1","99":"26","100":"22","101":"29","102":"0","103":"0","104":"0","105":"0","106":"100","107":"1.29281","108":"1.44136","109":"0.274305","110":"1.097950","111":"0.00545","112":"38.4554","113":"0.226986","114":"-0.0159","115":"1.239830","116":"19.2352","117":"405.659","118":"14.2012","119":"12.1229","120":"102.678","_rn_":"4"},{"1":"2019-06-14T190000_smart3-00177.ghg","2":"6/14/2019","3":"19:30","4":"165.8123","5":"0","6":"18000","7":"18000","8":"-0.110688","9":"0","10":"299.239","11":"0","12":"115.8370","13":"0","14":"-2.90573","15":"0","16":"2.62718","17":"0","18":"NA","19":"NA","20":"NA","21":"NA","22":"-2.97e-11","23":"-1.08e-12","24":"16.5047","25":"405.829","26":"411.923","27":"0","28":"0","29":"601.682","30":"14.7946","31":"15.0167","32":"0","33":"0","34":"297.889","35":"295.647","36":"99965.1","37":"1.17138","38":"1013.70","39":"0.0246","40":"0.170241","41":"0.0108","42":"1479.34","43":"2716.93","44":"0.00926","45":"54.4489","46":"1237.590","47":"285.972","48":"3.81162","49":"-0.263364","50":"-0.003910","51":"3.82071","52":"5.05e-14","53":"-1.80e-15","54":"3.82071","55":"8.29649","56":"233.450","57":"356.0470","58":"-0.058600","59":"NA","60":"0.307399","61":"1.63515","62":"-8.47345","63":"-0.425210","64":"2.58328","65":"-0.819801","66":"0","67":"47.2640","68":"-7.17249","69":"16.2242","70":"40.4005","71":"61.6134","72":"86.4136","73":"129.463","74":"-0.109359","75":"1.01216","76":"298.663","77":"1.02499","78":"84.3490","79":"1.08489","80":"-16.6289","81":"1.08489","82":"1.913040","83":"1.08489","84":"800000099","85":"800000099","86":"800000099","87":"800000099","88":"800000099","89":"800000099","90":"899999999","91":"899999999","92":"89999","93":"89999","94":"89","95":"89","96":"6","97":"7","98":"1","99":"12","100":"7","101":"14","102":"0","103":"0","104":"0","105":"0","106":"100","107":"1.09828","108":"1.90937","109":"0.262656","110":"1.194010","111":"0.00570","112":"82.2944","113":"0.251520","114":"-0.0166","115":"1.913040","116":"19.2200","117":"405.828","118":"14.7946","119":"12.7505","120":"102.813","_rn_":"5"},{"1":"2019-06-14T193000_smart3-00177.ghg","2":"6/14/2019","3":"20:00","4":"165.8332","5":"0","6":"18000","7":"18000","8":"-0.159866","9":"0","10":"318.103","11":"0","12":"108.8170","13":"0","14":"-3.14684","15":"0","16":"2.46932","17":"0","18":"1.35436","19":"0.295193","20":"-0.00913","21":"0.00670","22":"-1.73e-10","23":"-6.36e-12","24":"16.4701","25":"405.718","26":"411.845","27":"0","28":"0","29":"603.887","30":"14.8759","31":"15.1006","32":"0","33":"0","34":"298.582","35":"296.207","36":"99971.7","37":"1.16920","38":"1013.76","39":"0.0246","40":"0.160012","41":"0.0109","42":"1487.57","43":"2810.79","44":"0.00931","45":"52.9235","46":"1323.220","47":"286.057","48":"4.02044","49":"-1.451540","50":"-0.014400","51":"4.27447","52":"5.92e-14","53":"-1.05e-14","54":"4.27447","55":"8.89589","56":"248.091","57":"340.1480","58":"-0.193634","59":"NA","60":"0.369771","61":"1.78986","62":"-13.87510","63":"-0.259675","64":"2.92328","65":"-0.725787","66":"0","67":"51.8551","68":"-7.86921","69":"17.8002","70":"44.3249","71":"67.5983","72":"94.8076","73":"142.039","74":"-0.157834","75":"1.01287","76":"315.979","77":"1.02724","78":"76.1949","79":"1.09045","80":"-17.4895","81":"1.09045","82":"1.729040","83":"1.09045","84":"800000099","85":"800000099","86":"800000099","87":"800000099","88":"800000099","89":"800000199","90":"899999999","91":"899999999","92":"89999","93":"89999","94":"89","95":"89","96":"3","97":"6","98":"0","99":"11","100":"10","101":"48","102":"0","103":"0","104":"0","105":"0","106":"100","107":"1.49672","108":"1.78157","109":"0.301437","110":"1.167660","111":"0.00554","112":"63.4686","113":"0.266583","114":"-0.0175","115":"1.729040","116":"19.2251","117":"405.717","118":"14.8760","119":"12.8359","120":"102.758","_rn_":"6"}],"options":{"columns":{"min":{},"max":[10],"total":[120]},"rows":{"min":[10],"max":[10],"total":[6]},"pages":{}}}
  </script>
</div>

<!-- rnb-frame-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuTkFcbmBgYCJ9 -->

```r
NA
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


# Read in Met data master file
* parse variable names and define N/As, NAN, -7999


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxubWV0X2RhdGFfbWFzdGVyPC1yZWFkLmNzdihwYXN0ZShwYXRoLmluX21ldCxcIlxcXFxcIix2ZXIsXCJcXFxcXCIsZmlsZS5uYW1lLFwiLmNzdlwiLHNlcD1cIlwiKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgaGVhZGVyPUYsXG4gICAgICAgICAgICAgICAgICAgICAgICAgIHNraXA9NCxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgbmEuc3RyaW5ncz1jKFwiTkFOXCIsXCItNzk5OVwiKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgc3RyaW5nc0FzRmFjdG9ycyA9IEYpXG5jb2xuYW1lcyhtZXRfZGF0YV9tYXN0ZXIpPC1jb2xuYW1lcyhcbiAgcmVhZC5jc3YocGFzdGUocGF0aC5pbl9tZXQsXCJcXFxcXCIsdmVyLFwiXFxcXFwiLGZpbGUubmFtZSxcIi5jc3ZcIixzZXA9XCJcIiksXG4gICAgICAgICAgIGhlYWRlcj1ULFxuICAgICAgICAgICBza2lwPSAxKSlcblxuaGVhZChtZXRfZGF0YV9tYXN0ZXIpXG5gYGAifQ== -->

```r
met_data_master<-read.csv(paste(path.in_met,"\\",ver,"\\",file.name,".csv",sep=""),
                          header=F,
                          skip=4,
                          na.strings=c("NAN","-7999"),
                          stringsAsFactors = F)
colnames(met_data_master)<-colnames(
  read.csv(paste(path.in_met,"\\",ver,"\\",file.name,".csv",sep=""),
           header=T,
           skip= 1))

head(met_data_master)
```

<!-- rnb-source-end -->

<!-- rnb-frame-begin eyJtZXRhZGF0YSI6eyJjbGFzc2VzIjpbImRhdGEuZnJhbWUiXSwibmNvbCI6NTIsIm5yb3ciOjZ9LCJyZGYiOiJINHNJQUFBQUFBQUFCdTJYUFd6VFFCVEhyNkZ4aVNGTkJRVldSaGlhMnBla1gxRHBUQnNvZ29MbFdrMlJLbGttZFV0RWJBZkhLYWppb3dnQkN4S3NvRTZ3TVNCR1prWkVZVUZpN3NMY2hiWGx6dmExOWwxUUdaQlFVVTQ2bjkvdi9WL3l6cjU3dVdpVGN3VnhUZ1FBSEFEZDVKckdGeUJNcURJc1FRQzZVOWpxd3A0TUdlOWcvMUY4VThTOWo4Z2lSKy9RSUN3TlFra2VQVGs2SmtudGFJSFMzQzZWcFYxeEVyZFZ5KzNWTWxFRGtBM3lBYWtqdU9NY1UvMjRIOFA5T080blNEYkVqd3JYWHVMMmloOHI0bmpqelhkMjNJa2IrYmF5Y2VGZFB4bzc5ZlBqOC9uVDZBd2RmeXlTaHM2dUJRQ05YLzZNMnpxTmU3QkpubWJQNno4ZE8zR2R1RTdjWDRrakpVMVl4WmQydmVQZjB4L1dQZXQ5WUNCckxhaHJ5SG9TMWp2cmJtUy9pUHpQRW5VUHlaOUkrUlNSN1BTVHdvbWtyL09rUUNLSmNsSk5WemFRdkltdDhWdmdINjBydFB3bG5NKzlTd1hTME1QN29mM29iVGcrWGc5L0g1NStBQ0QyWFBiQit1L0V0WThMemdtcjRMZnJmaS8vZnBubmZ4NlhPSmltSGRPMm1pQThsQllqbU5FdlRwZG5kR1ZhallDZ2xTZXVhcFBVZmM3MC9WbERXVjZLd0NGVnQreUdNUkZEV1dVYWxuVERzeFpqTUtNSGtyeWNad0JrUVlFRlJSYVVXRERFZ21FV2pMQmdsQUtSSmlaeFJPWUk1RWlCSTBXT2xEZ3l4SkZoam94d2hNc1pjamxETG1mSTVReTVuQ0dYTTl6SithQlM4L1RZaXhTMHFaaVZVM3hiOWF4bXMrVlo4YmQ5UlRQcytESVJNYWpZTUw1S1ZFVXphazVTbG90Z3E1elE5aExzdHZ5a3VJOVNSbjE0WnVxOElTZTEyWkJWZUNGc0k0U01VS3lZdnVXcEhORVQ4L0dzYXExaDJMYWh1MzRFZTJZcjhaMGhsT05XT2g2ZWpuKzZvQ3B4YTFZTHJPVHV6WGp1N1R6ZHdhVDhwbFpCMEFSMm0xZnJacE51Y3dyRkJkTTM4NHNlanNmV0ZoUFM0emI4bXVzMHd6K0ZJTTBFZDNrTXlMVWNrc25DUVBWR3k3azVVQUxoUWFrcjZ0bG9GR0wzeGZBclU5dlJSNlhwWkMxbnFlWllOUGU2ZWQycTAxV0FaeHhNT04vd2FnNTl4Q0ttemJ6ditpYlZpVlczVGtrd043RDFDMThDWUc2d0R3QUEifQ== -->

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["TIMESTAMP"],"name":[1],"type":["chr"],"align":["left"]},{"label":["RECORD"],"name":[2],"type":["int"],"align":["right"]},{"label":["BattV_Avg"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["PTemp_C_Avg"],"name":[4],"type":["dbl"],"align":["right"]},{"label":["AM25T_ref_Avg"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.1."],"name":[6],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.2."],"name":[7],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.3."],"name":[8],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.4."],"name":[9],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.5."],"name":[10],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.6."],"name":[11],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.7."],"name":[12],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.8."],"name":[13],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.9."],"name":[14],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.10."],"name":[15],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.11."],"name":[16],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.12."],"name":[17],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.13."],"name":[18],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.14."],"name":[19],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.15."],"name":[20],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.16."],"name":[21],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.17."],"name":[22],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.18."],"name":[23],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.19."],"name":[24],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.20."],"name":[25],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.21."],"name":[26],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.22."],"name":[27],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.23."],"name":[28],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.24."],"name":[29],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.25."],"name":[30],"type":["lgl"],"align":["right"]},{"label":["AirT_Avg"],"name":[31],"type":["dbl"],"align":["right"]},{"label":["RH_Avg"],"name":[32],"type":["dbl"],"align":["right"]},{"label":["AtmPressure_Avg"],"name":[33],"type":["dbl"],"align":["right"]},{"label":["NR_mV_Avg"],"name":[34],"type":["dbl"],"align":["right"]},{"label":["NR_Wm2_Avg"],"name":[35],"type":["dbl"],"align":["right"]},{"label":["PAR_in_mV_Avg"],"name":[36],"type":["dbl"],"align":["right"]},{"label":["PAR_in_uEm2_Avg"],"name":[37],"type":["dbl"],"align":["right"]},{"label":["PAR_out_mV_Avg"],"name":[38],"type":["dbl"],"align":["right"]},{"label":["PAR_out_uEm2_Avg"],"name":[39],"type":["dbl"],"align":["right"]},{"label":["SHF_1_mV_Avg"],"name":[40],"type":["dbl"],"align":["right"]},{"label":["SHF_1_Wm2_Avg"],"name":[41],"type":["dbl"],"align":["right"]},{"label":["SHF_2_mV_Avg"],"name":[42],"type":["dbl"],"align":["right"]},{"label":["SHF_2_Wm2_Avg"],"name":[43],"type":["dbl"],"align":["right"]},{"label":["WaterP_Avg"],"name":[44],"type":["int"],"align":["right"]},{"label":["WaterT_Avg"],"name":[45],"type":["int"],"align":["right"]},{"label":["Precip_mm_Tot"],"name":[46],"type":["dbl"],"align":["right"]},{"label":["VWC_Avg"],"name":[47],"type":["dbl"],"align":["right"]},{"label":["EC_Avg"],"name":[48],"type":["dbl"],"align":["right"]},{"label":["T_Avg"],"name":[49],"type":["dbl"],"align":["right"]},{"label":["P_Avg"],"name":[50],"type":["dbl"],"align":["right"]},{"label":["PA_Avg"],"name":[51],"type":["dbl"],"align":["right"]},{"label":["VR_Avg"],"name":[52],"type":["dbl"],"align":["right"]}],"data":[{"1":"6/25/2019 9:00","2":"530","3":"19.35","4":"24.83","5":"NA","6":"NA","7":"NA","8":"NA","9":"NA","10":"NA","11":"NA","12":"NA","13":"NA","14":"NA","15":"NA","16":"NA","17":"NA","18":"NA","19":"NA","20":"NA","21":"NA","22":"NA","23":"NA","24":"NA","25":"NA","26":"NA","27":"NA","28":"NA","29":"NA","30":"NA","31":"173.5","32":"17.79","33":"NA","34":"NA","35":"364.9","36":"NA","37":"NA","38":"NA","39":"NA","40":"NA","41":"NA","42":"NA","43":"NA","44":"NA","45":"NA","46":"NA","47":"NA","48":"NA","49":"NA","50":"NA","51":"NA","52":"NA","_rn_":"1"},{"1":"6/25/2019 9:30","2":"531","3":"19.35","4":"26.16","5":"NA","6":"NA","7":"NA","8":"NA","9":"NA","10":"NA","11":"NA","12":"NA","13":"NA","14":"NA","15":"NA","16":"NA","17":"NA","18":"NA","19":"NA","20":"NA","21":"NA","22":"NA","23":"NA","24":"NA","25":"NA","26":"NA","27":"NA","28":"NA","29":"NA","30":"NA","31":"172.9","32":"17.43","33":"NA","34":"NA","35":"468.7","36":"NA","37":"NA","38":"NA","39":"NA","40":"NA","41":"NA","42":"NA","43":"NA","44":"NA","45":"NA","46":"NA","47":"NA","48":"NA","49":"NA","50":"NA","51":"NA","52":"NA","_rn_":"2"},{"1":"6/25/2019 10:00","2":"532","3":"19.35","4":"27.16","5":"NA","6":"NA","7":"NA","8":"NA","9":"NA","10":"NA","11":"NA","12":"NA","13":"NA","14":"NA","15":"NA","16":"NA","17":"NA","18":"NA","19":"NA","20":"NA","21":"NA","22":"NA","23":"NA","24":"NA","25":"NA","26":"NA","27":"NA","28":"NA","29":"NA","30":"NA","31":"172.2","32":"16.81","33":"NA","34":"NA","35":"559.8","36":"NA","37":"NA","38":"NA","39":"NA","40":"NA","41":"NA","42":"NA","43":"NA","44":"NA","45":"NA","46":"NA","47":"NA","48":"NA","49":"NA","50":"NA","51":"NA","52":"NA","_rn_":"3"},{"1":"6/25/2019 10:30","2":"533","3":"19.34","4":"27.90","5":"NA","6":"NA","7":"NA","8":"NA","9":"NA","10":"NA","11":"NA","12":"NA","13":"NA","14":"NA","15":"NA","16":"NA","17":"NA","18":"NA","19":"NA","20":"NA","21":"NA","22":"NA","23":"NA","24":"NA","25":"NA","26":"NA","27":"NA","28":"NA","29":"NA","30":"NA","31":"171.9","32":"16.79","33":"NA","34":"NA","35":"629.3","36":"NA","37":"NA","38":"NA","39":"NA","40":"NA","41":"NA","42":"NA","43":"NA","44":"NA","45":"NA","46":"NA","47":"NA","48":"NA","49":"NA","50":"NA","51":"NA","52":"NA","_rn_":"4"},{"1":"6/25/2019 11:00","2":"534","3":"19.34","4":"28.61","5":"NA","6":"NA","7":"NA","8":"NA","9":"NA","10":"NA","11":"NA","12":"NA","13":"NA","14":"NA","15":"NA","16":"NA","17":"NA","18":"NA","19":"NA","20":"NA","21":"NA","22":"NA","23":"NA","24":"NA","25":"NA","26":"NA","27":"NA","28":"NA","29":"NA","30":"NA","31":"172.5","32":"17.88","33":"NA","34":"NA","35":"697.7","36":"NA","37":"NA","38":"NA","39":"NA","40":"NA","41":"NA","42":"NA","43":"NA","44":"NA","45":"NA","46":"NA","47":"NA","48":"NA","49":"NA","50":"NA","51":"NA","52":"NA","_rn_":"5"},{"1":"6/25/2019 11:30","2":"535","3":"19.34","4":"29.30","5":"NA","6":"NA","7":"NA","8":"NA","9":"NA","10":"NA","11":"NA","12":"NA","13":"NA","14":"NA","15":"NA","16":"NA","17":"NA","18":"NA","19":"NA","20":"NA","21":"NA","22":"NA","23":"NA","24":"NA","25":"NA","26":"NA","27":"NA","28":"NA","29":"NA","30":"NA","31":"172.4","32":"17.94","33":"NA","34":"NA","35":"759.0","36":"NA","37":"NA","38":"NA","39":"NA","40":"NA","41":"NA","42":"NA","43":"NA","44":"NA","45":"NA","46":"NA","47":"NA","48":"NA","49":"NA","50":"NA","51":"NA","52":"NA","_rn_":"6"}],"options":{"columns":{"min":{},"max":[10],"total":[52]},"rows":{"min":[10],"max":[10],"total":[6]},"pages":{}}}
  </script>
</div>

<!-- rnb-frame-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuTkFcbmBgYCJ9 -->

```r
NA
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


# Parsing time stamp of cdata (EddyPro file)
* converting it into a POSIXlt vector*
* interpreting date and time into new timestamp column
* Then taking that time stamp column and turning each time into a unique number (time.id) so I can join based on that. As it can be really tricky to join/merge based on time stamps alone**
* Or I could make sure both time stamps are characters and match them that way**
* Finally ploting time.id to make sure my times translate linearily*



<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuY2RhdGEkVElNRVNUQU1QPC1zdHJwdGltZShwYXN0ZShjZGF0YSRkYXRlLGNkYXRhJHRpbWUsc2VwPVwiIFwiKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgZm9ybWF0PVwiJW0vJWQvJVkgJUg6JU1cIiwgXG4gICAgICAgICAgICAgICAgICAgICAgICAgIHR6ID0gXCJFdGMvR01ULThcIilcblxuI2NkYXRhJFRJTUVTVEFNUD1jZGF0YSRUSU1FU1RBTVArMTgwMCBkb24ndCBuZWVkIHRvIGFkZCAxODAwLiBhbHJlYWR5IGluIGVuZHRpbWUgZm9ybWF0XG4jY2RhdGEkVElNRVNUQU1QPWNkYXRhJFRJTUVTVEFNUCAjanVzdCByZW5hbWUgaXQgZW5kLiBzbyB0aGF0IHdlIGtub3dcblxuY2RhdGEkdGltZS5pZDwtY2RhdGEkVElNRVNUQU1QJHllYXIrMTkwMCtcbiAgKGNkYXRhJFRJTUVTVEFNUCR5ZGF5KS8zNjYrXG4gIChjZGF0YSRUSU1FU1RBTVAkaG91cikvMzY2LzI0KyBcbiAgKGNkYXRhJFRJTUVTVEFNUCRtaW4pLzM2Ni8yNC82MFxuXG5jZGF0YSR0aW1lLmlkWzE6NTBdXG5gYGAifQ== -->

```r
cdata$TIMESTAMP<-strptime(paste(cdata$date,cdata$time,sep=" "),
                          format="%m/%d/%Y %H:%M", 
                          tz = "Etc/GMT-8")

#cdata$TIMESTAMP=cdata$TIMESTAMP+1800 don't need to add 1800. already in endtime format
#cdata$TIMESTAMP=cdata$TIMESTAMP #just rename it end. so that we know

cdata$time.id<-cdata$TIMESTAMP$year+1900+
  (cdata$TIMESTAMP$yday)/366+
  (cdata$TIMESTAMP$hour)/366/24+ 
  (cdata$TIMESTAMP$min)/366/24/60

cdata$time.id[1:50]
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiIFsxXSAyMDE5LjQ1MCAyMDE5LjQ1MCAyMDE5LjQ1MCAyMDE5LjQ1MCAyMDE5LjQ1MCAyMDE5LjQ1MCAyMDE5LjQ1MCAyMDE5LjQ1MCAyMDE5LjQ1MVxuWzEwXSAyMDE5LjQ1MSAyMDE5LjQ1MSAyMDE5LjQ1MSAyMDE5LjQ1MSAyMDE5LjQ1MSAyMDE5LjQ1MSAyMDE5LjQ1MSAyMDE5LjQ1MSAyMDE5LjQ1MlxuWzE5XSAyMDE5LjQ1MiAyMDE5LjQ1MiAyMDE5LjQ1MiAyMDE5LjQ1MiAyMDE5LjQ1MiAyMDE5LjQ1MiAyMDE5LjQ1MiAyMDE5LjQ1MiAyMDE5LjQ1MlxuWzI4XSAyMDE5LjQ1MiAyMDE5LjQ1MiAyMDE5LjQ1MiAyMDE5LjQ1MiAyMDE5LjQ1MiAyMDE5LjQ1MiAyMDE5LjQ1MyAyMDE5LjQ1MyAyMDE5LjQ1M1xuWzM3XSAyMDE5LjQ1MyAyMDE5LjQ1MyAyMDE5LjQ1MyAyMDE5LjQ1MyAyMDE5LjQ1MyAyMDE5LjQ1MyAyMDE5LjQ1MyAyMDE5LjQ1MyAyMDE5LjQ1M1xuWzQ2XSAyMDE5LjQ1MyAyMDE5LjQ1NCAyMDE5LjQ1NCAyMDE5LjQ1NCAyMDE5LjQ1NFxuIn0= -->

```
 [1] 2019.450 2019.450 2019.450 2019.450 2019.450 2019.450 2019.450 2019.450 2019.451
[10] 2019.451 2019.451 2019.451 2019.451 2019.451 2019.451 2019.451 2019.451 2019.452
[19] 2019.452 2019.452 2019.452 2019.452 2019.452 2019.452 2019.452 2019.452 2019.452
[28] 2019.452 2019.452 2019.452 2019.452 2019.452 2019.452 2019.453 2019.453 2019.453
[37] 2019.453 2019.453 2019.453 2019.453 2019.453 2019.453 2019.453 2019.453 2019.453
[46] 2019.453 2019.454 2019.454 2019.454 2019.454
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucGxvdChjZGF0YSRUSU1FU1RBTVAsY2RhdGEkdGltZS5pZClcbmBgYCJ9 -->

```r
plot(cdata$TIMESTAMP,cdata$time.id)
```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJjb25kaXRpb25zIjpbXSwiaGVpZ2h0Ijo0MzIuNjMyOSwic2l6ZV9iZWhhdmlvciI6MCwid2lkdGgiOjcwMH0= -->

<img src="data:image/png;base64,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" />

<!-- rnb-plot-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxud2hpY2goZHVwbGljYXRlZChjZGF0YSR0aW1lLmlkKSlcbmBgYCJ9 -->

```r
which(duplicated(cdata$time.id))
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiaW50ZWdlcigwKVxuIn0= -->

```
integer(0)
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->

# Parsing time stamp of cdata (Met file)
* Taking the met_data and turning the time stamp into posixt format#
* creating a time id for the MET Data so I I can join the MET and Eddy Pro Data#


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxubWV0X2RhdGFfbWFzdGVyJFRJTUVTVEFNUDwtc3RycHRpbWUobWV0X2RhdGFfbWFzdGVyJFRJTUVTVEFNUCxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGZvcm1hdCA9XCIlbS8lZC8lWSAlSDolTVwiLFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgdHogPSBcIkV0Yy9HTVQtOFwiKVxuXG5tZXRfZGF0YV9tYXN0ZXIkdGltZS5pZCA8LW1ldF9kYXRhX21hc3RlciRUSU1FU1RBTVAkeWVhcisxOTAwK1xuICAobWV0X2RhdGFfbWFzdGVyJFRJTUVTVEFNUCR5ZGF5KS8zNjYrXG4gIChtZXRfZGF0YV9tYXN0ZXIkVElNRVNUQU1QJGhvdXIpLzM2Ni8yNCtcbiAgKG1ldF9kYXRhX21hc3RlciRUSU1FU1RBTVAkbWluKS8zNjYvMjQvNjAgXG5cbm1ldF9kYXRhX21hc3RlciR0aW1lLmlkWzE6MjBdXG5gYGAifQ== -->

```r
met_data_master$TIMESTAMP<-strptime(met_data_master$TIMESTAMP,
                                    format ="%m/%d/%Y %H:%M",
                                    tz = "Etc/GMT-8")

met_data_master$time.id <-met_data_master$TIMESTAMP$year+1900+
  (met_data_master$TIMESTAMP$yday)/366+
  (met_data_master$TIMESTAMP$hour)/366/24+
  (met_data_master$TIMESTAMP$min)/366/24/60 

met_data_master$time.id[1:20]
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiIFsxXSAyMDE5LjQ3OSAyMDE5LjQ3OSAyMDE5LjQ3OSAyMDE5LjQ3OSAyMDE5LjQ3OSAyMDE5LjQ3OSAyMDE5LjQ4MCAyMDE5LjQ4MCAyMDE5LjQ4MFxuWzEwXSAyMDE5LjQ4MCAyMDE5LjQ4MCAyMDE5LjQ4MCAyMDE5LjQ4MCAyMDE5LjQ4MCAyMDE5LjQ4MCAyMDE5LjQ4MCAyMDE5LjQ4MCAyMDE5LjQ4MFxuWzE5XSAyMDE5LjQ4MCAyMDE5LjQ4MFxuIn0= -->

```
 [1] 2019.479 2019.479 2019.479 2019.479 2019.479 2019.479 2019.480 2019.480 2019.480
[10] 2019.480 2019.480 2019.480 2019.480 2019.480 2019.480 2019.480 2019.480 2019.480
[19] 2019.480 2019.480
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucGxvdChtZXRfZGF0YV9tYXN0ZXIkVElNRVNUQU1QLG1ldF9kYXRhX21hc3RlciR0aW1lLmlkKVxuYGBgIn0= -->

```r
plot(met_data_master$TIMESTAMP,met_data_master$time.id)
```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJjb25kaXRpb25zIjpbXSwiaGVpZ2h0Ijo0MzIuNjMyOSwic2l6ZV9iZWhhdmlvciI6MCwid2lkdGgiOjcwMH0= -->

<img src="data:image/png;base64,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" />

<!-- rnb-plot-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxud2hpY2goZHVwbGljYXRlZChtZXRfZGF0YV9tYXN0ZXIkdGltZS5pZCkpXG5gYGAifQ== -->

```r
which(duplicated(met_data_master$time.id))
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiaW50ZWdlcigwKVxuIn0= -->

```
integer(0)
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuaGVhZChtZXRfZGF0YV9tYXN0ZXIpXG5gYGAifQ== -->

```r
head(met_data_master)
```

<!-- rnb-source-end -->

<!-- rnb-frame-begin eyJtZXRhZGF0YSI6eyJjbGFzc2VzIjpbImRhdGEuZnJhbWUiXSwibmNvbCI6NTMsIm5yb3ciOjZ9LCJyZGYiOiJINHNJQUFBQUFBQUFCdTFZVFV3VFFSUWVDbTN0SWtJVU5WNE1SNDJoMGkwVi9DSFpDa1dOSWszWlVEUW16ZHBPY1dOM3QreHVRWWcvS0ZFdi9wMU1OQklUdldHaUh2WHF5UmgvTGlhZXVYRHd4TVVyT0xNN1U2WTdyYWd4TWNaTzh2Yk4rOTU3czI5KytuWmVVd05qVVdGTUFBQTBnaWI4OUtNSENQUW5JMkpNQktESmg2UUdwQWxoZmdIcHQ2Qk9qUEJtUkp1d09majExc0w0N2F6Q3FUNUVTQ0RVVElqcWQ5UWdxdmZYSUtxZnFrRlU3NnRCVlAraUJySHpxOWJhSEwyN3NJMTd1bnAvdDB2ZU5Jc2UxY2l6aFg1ZDBhQkZYdDlNeDdGZ2xuWTFWU2ZkcG5OR3lhUjlMYWRNbDAyTXNzazBWTW9tVTJzbVRkTnJmYjlxNVN5YkttWU1IWkorWUZ5empYemVHMkMyb0ZnMFFCOEJnOG5oa1dOakJUcEt3QkZ0cjZmdERPNTZOaEl3bExDemU0OE15WjNWbHEram93T3hsYlhOOG0xR2hBNjJyeDNSVmtUYkVHMEg1SkJMMFZNUFVIdkk4N1RRVjN6NnhjdkxmcjJmWnhhUFBHK1hEdXo2OXVidW1kM1NRY3FYOHJoSmh4NDVnTlIzNGoxcUg2amZsV1c4ZmNFblA4dnJmblcvdXQ4ZjhjTWZtaCtrMUxwK0hiMmI5K0JMUjVEZ0l5ZXZTZkNHbSsvZ1JTTGZJL3BiRlhsUGlyekQ2Vk9RSW5vN1RweFMxNmN6T0VGS1hSVEgyWFJtVVlvc0k2bHZBdnlsY3lWTmZuVG5jK2w0RkRmcDZtVlhubHR3K2ZVUDd2Zmg1aXNBbUhYNUI4NS8zYSs2M3pwWHJYWDEvOG84L3dzLzZmSHRyd3NMQzg4d2YzMS9maDd6dDlmdTNjSDhpejQzaS9uUzZja0p6TDhOcWxuM3Z1bGJSZGZTTm9DTElITEZsSThOSlViaytGQ1NYazlUaWY3aDFBQlZIMVpzZXpRVG54d25RSE5TaGxveDA4OUFMZkVoTVNablRKaG53SkRzbUlRallROGdlb0dvRitqMkFqRXZzTThMOUhpQlhpK3dud0lDRGF5TFF5SWNJbkpJbEVPNk9TVEdJZnM0cElkRGVqbUVpMW5rWWhhNW1FVXVacEdMV2VSaUZzc3hiNGlycHN4c1pDQjFsSkZhNDdhV05LRmxsVXpJN3ZiSlZFWmpqNG1BZ0xRbXNxY2tHVTlsVkwzU3JKV0FwVVNGN1NZTUd5VzcwcmlOb2g3cmpTTkhCek9SU3RzV0YwdnpobUlWUTlGaktLUVZHNXBKRHBFcjVtUENyRnJNYUZwR05taHRGeHhOczcrTVFJS1YvS3k3bngwOWtJeXowbWlLa1lLMnFzR3dtdlBVaXlIVG1BclRjaGduYnQ4c2NGckFOV3hjQlc0dFNSMkVuR0lyNGJ5SlhJQlRObFlNRnpTS3Rtcm9sbHRCT244eHNNNE5wZ2RvTGVuNDVibk83TG1TZnI2ekI3aTNxZ1pDTFlRSG1INnNuSUhjb2Z4MHVsQWZWOHQxdGIrZ25JVUZlZzdRSkowNWhvdW1xdE5GRmhCcWhXM0RWcWlka0RVS0ZIRkw0cFh2ZXRmbEV4b1NBQUE9In0= -->

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["TIMESTAMP"],"name":[1],"type":["S3: POSIXlt"],"align":["right"]},{"label":["RECORD"],"name":[2],"type":["int"],"align":["right"]},{"label":["BattV_Avg"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["PTemp_C_Avg"],"name":[4],"type":["dbl"],"align":["right"]},{"label":["AM25T_ref_Avg"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.1."],"name":[6],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.2."],"name":[7],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.3."],"name":[8],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.4."],"name":[9],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.5."],"name":[10],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.6."],"name":[11],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.7."],"name":[12],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.8."],"name":[13],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.9."],"name":[14],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.10."],"name":[15],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.11."],"name":[16],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.12."],"name":[17],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.13."],"name":[18],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.14."],"name":[19],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.15."],"name":[20],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.16."],"name":[21],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.17."],"name":[22],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.18."],"name":[23],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.19."],"name":[24],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.20."],"name":[25],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.21."],"name":[26],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.22."],"name":[27],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.23."],"name":[28],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.24."],"name":[29],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.25."],"name":[30],"type":["lgl"],"align":["right"]},{"label":["AirT_Avg"],"name":[31],"type":["dbl"],"align":["right"]},{"label":["RH_Avg"],"name":[32],"type":["dbl"],"align":["right"]},{"label":["AtmPressure_Avg"],"name":[33],"type":["dbl"],"align":["right"]},{"label":["NR_mV_Avg"],"name":[34],"type":["dbl"],"align":["right"]},{"label":["NR_Wm2_Avg"],"name":[35],"type":["dbl"],"align":["right"]},{"label":["PAR_in_mV_Avg"],"name":[36],"type":["dbl"],"align":["right"]},{"label":["PAR_in_uEm2_Avg"],"name":[37],"type":["dbl"],"align":["right"]},{"label":["PAR_out_mV_Avg"],"name":[38],"type":["dbl"],"align":["right"]},{"label":["PAR_out_uEm2_Avg"],"name":[39],"type":["dbl"],"align":["right"]},{"label":["SHF_1_mV_Avg"],"name":[40],"type":["dbl"],"align":["right"]},{"label":["SHF_1_Wm2_Avg"],"name":[41],"type":["dbl"],"align":["right"]},{"label":["SHF_2_mV_Avg"],"name":[42],"type":["dbl"],"align":["right"]},{"label":["SHF_2_Wm2_Avg"],"name":[43],"type":["dbl"],"align":["right"]},{"label":["WaterP_Avg"],"name":[44],"type":["int"],"align":["right"]},{"label":["WaterT_Avg"],"name":[45],"type":["int"],"align":["right"]},{"label":["Precip_mm_Tot"],"name":[46],"type":["dbl"],"align":["right"]},{"label":["VWC_Avg"],"name":[47],"type":["dbl"],"align":["right"]},{"label":["EC_Avg"],"name":[48],"type":["dbl"],"align":["right"]},{"label":["T_Avg"],"name":[49],"type":["dbl"],"align":["right"]},{"label":["P_Avg"],"name":[50],"type":["dbl"],"align":["right"]},{"label":["PA_Avg"],"name":[51],"type":["dbl"],"align":["right"]},{"label":["VR_Avg"],"name":[52],"type":["dbl"],"align":["right"]},{"label":["time.id"],"name":[53],"type":["dbl"],"align":["right"]}],"data":[{"1":"<POSIXlt>","2":"530","3":"19.35","4":"24.83","5":"NA","6":"NA","7":"NA","8":"NA","9":"NA","10":"NA","11":"NA","12":"NA","13":"NA","14":"NA","15":"NA","16":"NA","17":"NA","18":"NA","19":"NA","20":"NA","21":"NA","22":"NA","23":"NA","24":"NA","25":"NA","26":"NA","27":"NA","28":"NA","29":"NA","30":"NA","31":"173.5","32":"17.79","33":"NA","34":"NA","35":"364.9","36":"NA","37":"NA","38":"NA","39":"NA","40":"NA","41":"NA","42":"NA","43":"NA","44":"NA","45":"NA","46":"NA","47":"NA","48":"NA","49":"NA","50":"NA","51":"NA","52":"NA","53":"2019.479","_rn_":"1"},{"1":"<POSIXlt>","2":"531","3":"19.35","4":"26.16","5":"NA","6":"NA","7":"NA","8":"NA","9":"NA","10":"NA","11":"NA","12":"NA","13":"NA","14":"NA","15":"NA","16":"NA","17":"NA","18":"NA","19":"NA","20":"NA","21":"NA","22":"NA","23":"NA","24":"NA","25":"NA","26":"NA","27":"NA","28":"NA","29":"NA","30":"NA","31":"172.9","32":"17.43","33":"NA","34":"NA","35":"468.7","36":"NA","37":"NA","38":"NA","39":"NA","40":"NA","41":"NA","42":"NA","43":"NA","44":"NA","45":"NA","46":"NA","47":"NA","48":"NA","49":"NA","50":"NA","51":"NA","52":"NA","53":"2019.479","_rn_":"2"},{"1":"<POSIXlt>","2":"532","3":"19.35","4":"27.16","5":"NA","6":"NA","7":"NA","8":"NA","9":"NA","10":"NA","11":"NA","12":"NA","13":"NA","14":"NA","15":"NA","16":"NA","17":"NA","18":"NA","19":"NA","20":"NA","21":"NA","22":"NA","23":"NA","24":"NA","25":"NA","26":"NA","27":"NA","28":"NA","29":"NA","30":"NA","31":"172.2","32":"16.81","33":"NA","34":"NA","35":"559.8","36":"NA","37":"NA","38":"NA","39":"NA","40":"NA","41":"NA","42":"NA","43":"NA","44":"NA","45":"NA","46":"NA","47":"NA","48":"NA","49":"NA","50":"NA","51":"NA","52":"NA","53":"2019.479","_rn_":"3"},{"1":"<POSIXlt>","2":"533","3":"19.34","4":"27.90","5":"NA","6":"NA","7":"NA","8":"NA","9":"NA","10":"NA","11":"NA","12":"NA","13":"NA","14":"NA","15":"NA","16":"NA","17":"NA","18":"NA","19":"NA","20":"NA","21":"NA","22":"NA","23":"NA","24":"NA","25":"NA","26":"NA","27":"NA","28":"NA","29":"NA","30":"NA","31":"171.9","32":"16.79","33":"NA","34":"NA","35":"629.3","36":"NA","37":"NA","38":"NA","39":"NA","40":"NA","41":"NA","42":"NA","43":"NA","44":"NA","45":"NA","46":"NA","47":"NA","48":"NA","49":"NA","50":"NA","51":"NA","52":"NA","53":"2019.479","_rn_":"4"},{"1":"<POSIXlt>","2":"534","3":"19.34","4":"28.61","5":"NA","6":"NA","7":"NA","8":"NA","9":"NA","10":"NA","11":"NA","12":"NA","13":"NA","14":"NA","15":"NA","16":"NA","17":"NA","18":"NA","19":"NA","20":"NA","21":"NA","22":"NA","23":"NA","24":"NA","25":"NA","26":"NA","27":"NA","28":"NA","29":"NA","30":"NA","31":"172.5","32":"17.88","33":"NA","34":"NA","35":"697.7","36":"NA","37":"NA","38":"NA","39":"NA","40":"NA","41":"NA","42":"NA","43":"NA","44":"NA","45":"NA","46":"NA","47":"NA","48":"NA","49":"NA","50":"NA","51":"NA","52":"NA","53":"2019.479","_rn_":"5"},{"1":"<POSIXlt>","2":"535","3":"19.34","4":"29.30","5":"NA","6":"NA","7":"NA","8":"NA","9":"NA","10":"NA","11":"NA","12":"NA","13":"NA","14":"NA","15":"NA","16":"NA","17":"NA","18":"NA","19":"NA","20":"NA","21":"NA","22":"NA","23":"NA","24":"NA","25":"NA","26":"NA","27":"NA","28":"NA","29":"NA","30":"NA","31":"172.4","32":"17.94","33":"NA","34":"NA","35":"759.0","36":"NA","37":"NA","38":"NA","39":"NA","40":"NA","41":"NA","42":"NA","43":"NA","44":"NA","45":"NA","46":"NA","47":"NA","48":"NA","49":"NA","50":"NA","51":"NA","52":"NA","53":"2019.479","_rn_":"6"}],"options":{"columns":{"min":{},"max":[10],"total":[53]},"rows":{"min":[10],"max":[10],"total":[6]},"pages":{}}}
  </script>
</div>

<!-- rnb-frame-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuI21ldF9kYXRhX21hc3RlciRUSU1FU1RBTVBbMToyMF1cblxuYGBgIn0= -->

```r
#met_data_master$TIMESTAMP[1:20]

```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


# Create a full timestamp without gaps 
* Create a full timestamp based on the earliest and latest timestamps in EddyPro and Met files
* Use this full timestamp later when merging EddyPro and master met files


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyBjcmVhdGUgYSBmdWxsIHRpbWVzdGFtcCwgMzAgbWluc1xuZnVsbC50aW1lPC1kYXRhLmZyYW1lKFRJTUVTVEFNUD1cbiAgICAgICAgICAgICAgICAgICAgICAgIHNlcS5QT1NJWHQobWluKG1pbihtZXRfZGF0YV9tYXN0ZXIkVElNRVNUQU1QKSxtaW4oY2RhdGEkVElNRVNUQU1QKSksXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIG1heChtYXgobWV0X2RhdGFfbWFzdGVyJFRJTUVTVEFNUCksbWF4KGNkYXRhJFRJTUVTVEFNUCkpLFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB1bml0cyA9IFwic2Vjb25kc1wiLCBieSA9IDE4MDApLFxuICAgICAgICAgICAgICAgICAgIHN0cmluZ3NBc0ZhY3RvcnM9RilcblxuZnVsbC50aW1lJFRJTUVTVEFNUDwtc3RycHRpbWUoZnVsbC50aW1lJFRJTUVTVEFNUCxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGZvcm1hdCA9XCIlWS0lbS0lZCAlSDolTTolU1wiLFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgdHogPSBcIkV0Yy9HTVQtOFwiKVxuXG5mdWxsLnRpbWUkdGltZS5pZCA8LWZ1bGwudGltZSRUSU1FU1RBTVAkeWVhcisxOTAwK1xuICAoZnVsbC50aW1lJFRJTUVTVEFNUCR5ZGF5KS8zNjYrXG4gIChmdWxsLnRpbWUkVElNRVNUQU1QJGhvdXIpLzM2Ni8yNCtcbiAgKGZ1bGwudGltZSRUSU1FU1RBTVAkbWluKS8zNjYvMjQvNjAgXG5cbnByaW50KHBhc3RlKFwiU3RhcnRpbmcgdGltZXN0YW1wOlwiLGZ1bGwudGltZSRUSU1FU1RBTVBbMV0pKVxuYGBgIn0= -->

```r
# create a full timestamp, 30 mins
full.time<-data.frame(TIMESTAMP=
                        seq.POSIXt(min(min(met_data_master$TIMESTAMP),min(cdata$TIMESTAMP)),
                                   max(max(met_data_master$TIMESTAMP),max(cdata$TIMESTAMP)),
                                   units = "seconds", by = 1800),
                   stringsAsFactors=F)

full.time$TIMESTAMP<-strptime(full.time$TIMESTAMP,
                              format ="%Y-%m-%d %H:%M:%S",
                              tz = "Etc/GMT-8")

full.time$time.id <-full.time$TIMESTAMP$year+1900+
  (full.time$TIMESTAMP$yday)/366+
  (full.time$TIMESTAMP$hour)/366/24+
  (full.time$TIMESTAMP$min)/366/24/60 

print(paste("Starting timestamp:",full.time$TIMESTAMP[1]))
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIFwiU3RhcnRpbmcgdGltZXN0YW1wOiAyMDE5LTA2LTE0IDE3OjAwOjAwXCJcbiJ9 -->

```
[1] "Starting timestamp: 2019-06-14 17:00:00"
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucHJpbnQocGFzdGUoXCJFbmRpbmcgdGltZXN0YW1wOlwiLGZ1bGwudGltZSRUSU1FU1RBTVBbbnJvdyhmdWxsLnRpbWUpXSkpXG5gYGAifQ== -->

```r
print(paste("Ending timestamp:",full.time$TIMESTAMP[nrow(full.time)]))
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIFwiRW5kaW5nIHRpbWVzdGFtcDogMjAyMC0wNC0yNiAxMDozMDowMFwiXG4ifQ== -->

```
[1] "Ending timestamp: 2020-04-26 10:30:00"
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuaGVhZChmdWxsLnRpbWUpXG5gYGAifQ== -->

```r
head(full.time)
```

<!-- rnb-source-end -->

<!-- rnb-frame-begin eyJtZXRhZGF0YSI6eyJjbGFzc2VzIjpbImRhdGEuZnJhbWUiXSwibmNvbCI6MiwibnJvdyI6Nn0sInJkZiI6Ikg0c0lBQUFBQUFBQUJndHlpVERtaXVCaVlHQmdabUFCa2F4QWdvSE5PY0RReU5TSWdZR0ZDY2hqQk1wd2d1Z0tvTHd3a01FRXBibUJtQStrbklGMHdJdWtUdzRMRFpNWGhHSWhLQmFHWXBnOEh3NE1rMmZGZ1dIeTVUZ3dzZnFYNE1ESS9zTUdCTUR5a0lCbDFqYXdJSmNKdGFrQlNHRERhRkhJbXBlWW0xb010WjRiWms1eGFqS01tWnVaQjJXeVpPU1hGc0hZdVNtSmxYQWwrWEFsbGFtSmNDWGxDQ1VzbFFnMmEyWnhTbkVKVEtJcVB5OFZ5bVpMenkzSlQwdERkMkJ5VG1JeHpJRk1VRUgyQVA5Z3o0Z2NtQ2xzWUc0SnVzNFNzT0VRbmN4UVFVN1hrbVI5ZDk4UVhXekJwNkNnQUtUK1FSTU1tOFA4M2pPWGpoeWZBcUlmYnRqVkJxSS96RmxiRHFML2R5eklCTkpuK1VvbVI0Rm8yWVEySDRqOVRQL1JITXNaNHVuckdoemk2QnNBYzMxSlptNnFYbVlLbW5zNWkvTEw5V0RSQVlwREpraDhnVklOU0NFenpHQ1lCcTZVeEpKRXZiUWlvQmFJczFHTVk4OHZLTW5NendNYXhpUU1UYUxJbWhtTDBBVDRTL05BbHFmb0ptZVU1bVhyZ2hJU0YxZ2Fnbm1oTkJzU213bk54Nnl3K0VqTlM4K0V4eXRyVG1KU2FnNlV3d2YwSk5pUGVnVkZtWG13Q09RQ2loYnJsZVNYSk1MVWNTWG41OEJFSUZIeUR3Q08zckdhbWdRQUFBPT0ifQ== -->

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["TIMESTAMP"],"name":[1],"type":["S3: POSIXlt"],"align":["right"]},{"label":["time.id"],"name":[2],"type":["dbl"],"align":["right"]}],"data":[{"1":"<POSIXlt>","2":"2019.45","_rn_":"1"},{"1":"<POSIXlt>","2":"2019.45","_rn_":"2"},{"1":"<POSIXlt>","2":"2019.45","_rn_":"3"},{"1":"<POSIXlt>","2":"2019.45","_rn_":"4"},{"1":"<POSIXlt>","2":"2019.45","_rn_":"5"},{"1":"<POSIXlt>","2":"2019.45","_rn_":"6"}],"options":{"columns":{"min":{},"max":[10],"total":[2]},"rows":{"min":[10],"max":[10],"total":[6]},"pages":{}}}
  </script>
</div>

<!-- rnb-frame-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuTkFcbk5BXG5gYGAifQ== -->

```r
NA
NA
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


#Joining the Met_Data and Eddy Pro Data Sets 
* using time stamp from the full.time dataframe
* Also create a doy.id, unique for each date, later used in aggregating daily values


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG5jZGF0YTwtIG1lcmdlLmRhdGEuZnJhbWUoZnVsbC50aW1lLFxuICAgICAgICAgICAgICAgICAgICAgICAgIGNkYXRhWywtd2hpY2goY29sbmFtZXMoY2RhdGEpPT1cIlRJTUVTVEFNUFwiKV0sXG4gICAgICAgICAgICAgICAgICAgICAgICAgYnkgPSBcInRpbWUuaWRcIixcbiAgICAgICAgICAgICAgICAgICAgICAgICBhbGwgPSBUUlVFLFxuICAgICAgICAgICAgICAgICAgICAgICAgIHNvcnQgPSBUUlVFKSBcbiNhbGw9dHJ1ZSB3aGF0IGV2ZXIgYXBwZWFycyBpbiBlYWNoIGZpbGUgaXMgc2hvdyBpbiB0aGUgZmlsZSBkYXRhIGZpbGUuIHNvcnQgdHJpZXMgdG8gc29ydCBlYWNoIGRhdGEgZnJhbWUgYnkgbWVyZ2luZy4gaW4gdGhpcyBjYXNlIHByb2JhYmx5IGRvZXNub3QgbWF0dGVyLiB0aW1lc3RhbXBcblxuY2RhdGE8LSBtZXJnZS5kYXRhLmZyYW1lKGNkYXRhLFxuICAgICAgICAgICAgICAgICAgICAgICAgIG1ldF9kYXRhX21hc3RlclssLXdoaWNoKGNvbG5hbWVzKG1ldF9kYXRhX21hc3Rlcik9PVwiVElNRVNUQU1QXCIpXSxcbiAgICAgICAgICAgICAgICAgICAgICAgICBieSA9IFwidGltZS5pZFwiLFxuICAgICAgICAgICAgICAgICAgICAgICAgIGFsbCA9IFRSVUUsXG4gICAgICAgICAgICAgICAgICAgICAgICAgc29ydCA9IFRSVUUpIFxuXG4jIyBjcmVhdGUgYSB1bmlxdWUgRE9ZIGlkIFxuY2RhdGEkZG95LmlkPC1mdWxsLnRpbWUkVElNRVNUQU1QJHllYXIrMTkwMCtcbiAgKGZ1bGwudGltZSRUSU1FU1RBTVAkeWRheSkvMzY2XG5cbiNjb2xuYW1lcyhjZGF0YSlcblxuYGBgIn0= -->

```r

cdata<- merge.data.frame(full.time,
                         cdata[,-which(colnames(cdata)=="TIMESTAMP")],
                         by = "time.id",
                         all = TRUE,
                         sort = TRUE) 
#all=true what ever appears in each file is show in the file data file. sort tries to sort each data frame by merging. in this case probably doesnot matter. timestamp

cdata<- merge.data.frame(cdata,
                         met_data_master[,-which(colnames(met_data_master)=="TIMESTAMP")],
                         by = "time.id",
                         all = TRUE,
                         sort = TRUE) 

## create a unique DOY id 
cdata$doy.id<-full.time$TIMESTAMP$year+1900+
  (full.time$TIMESTAMP$yday)/366

#colnames(cdata)

```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


#Creating a CSV File of my combined Master File!#
hc: modify the filename starting with Date when the file is created


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxud3JpdGUuY3N2KGNkYXRhLFxuICAgICAgICAgIHBhc3RlKHBhdGgub3V0LFN5cy5EYXRlKCksXFxfbWFzdGVyX2VkZHlfbWV0X2NvbmNvcmRfcHJlZmlsdGVyaW5nLmNzdlxcLHNlcD1cXFxcKSxcbiAgICAgICAgICBxdW90ZSA9IFQsXG4gICAgICAgICAgcm93Lm5hbWVzID0gRilcbmBgYFxuYGBgIn0= -->

```r
```r
write.csv(cdata,
          paste(path.out,Sys.Date(),\_master_eddy_met_concord_prefiltering.csv\,sep=\\),
          quote = T,
          row.names = F)
```
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


#Filter data based on predefined criteria
* filtering criteria are defined in concord_filter function
* A few variables also convert Unit 



<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG5jZGF0YTwtY29uY29yZF9maWx0ZXIoZGF0YS5pbj1jZGF0YSlcblxuY29sbmFtZXMoY2RhdGEpXG5gYGAifQ== -->

```r

cdata<-concord_filter(data.in=cdata)

colnames(cdata)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiICBbMV0gXCJ0aW1lLmlkXCIgICAgICAgICAgICAgICAgICAgICAgIFwiVElNRVNUQU1QXCIgICAgICAgICAgICAgICAgICAgIFxuICBbM10gXCJmaWxlbmFtZVwiICAgICAgICAgICAgICAgICAgICAgIFwiZGF0ZVwiICAgICAgICAgICAgICAgICAgICAgICAgIFxuICBbNV0gXCJ0aW1lXCIgICAgICAgICAgICAgICAgICAgICAgICAgIFwiRE9ZXCIgICAgICAgICAgICAgICAgICAgICAgICAgIFxuICBbN10gXCJkYXl0aW1lXCIgICAgICAgICAgICAgICAgICAgICAgIFwiZmlsZV9yZWNvcmRzXCIgICAgICAgICAgICAgICAgIFxuICBbOV0gXCJ1c2VkX3JlY29yZHNcIiAgICAgICAgICAgICAgICAgIFwiVGF1XCIgICAgICAgICAgICAgICAgICAgICAgICAgIFxuIFsxMV0gXCJxY19UYXVcIiAgICAgICAgICAgICAgICAgICAgICAgIFwiSFwiICAgICAgICAgICAgICAgICAgICAgICAgICAgIFxuIFsxM10gXCJxY19IXCIgICAgICAgICAgICAgICAgICAgICAgICAgIFwiTEVcIiAgICAgICAgICAgICAgICAgICAgICAgICAgIFxuIFsxNV0gXCJxY19MRVwiICAgICAgICAgICAgICAgICAgICAgICAgIFwiY28yX2ZsdXhcIiAgICAgICAgICAgICAgICAgICAgIFxuIFsxN10gXCJxY19jbzJfZmx1eFwiICAgICAgICAgICAgICAgICAgIFwiaDJvX2ZsdXhcIiAgICAgICAgICAgICAgICAgICAgIFxuIFsxOV0gXCJxY19oMm9fZmx1eFwiICAgICAgICAgICAgICAgICAgIFwiSF9zdHJnXCIgICAgICAgICAgICAgICAgICAgICAgIFxuIFsyMV0gXCJMRV9zdHJnXCIgICAgICAgICAgICAgICAgICAgICAgIFwiY28yX3N0cmdcIiAgICAgICAgICAgICAgICAgICAgIFxuIFsyM10gXCJoMm9fc3RyZ1wiICAgICAgICAgICAgICAgICAgICAgIFwiY28yX3YuYWR2XCIgICAgICAgICAgICAgICAgICAgIFxuIFsyNV0gXCJoMm9fdi5hZHZcIiAgICAgICAgICAgICAgICAgICAgIFwiY28yX21vbGFyX2RlbnNpdHlcIiAgICAgICAgICAgIFxuIFsyN10gXCJjbzJfbW9sZV9mcmFjdGlvblwiICAgICAgICAgICAgIFwiY28yX21peGluZ19yYXRpb1wiICAgICAgICAgICAgIFxuIFsyOV0gXCJjbzJfdGltZV9sYWdcIiAgICAgICAgICAgICAgICAgIFwiY28yX2RlZl90aW1lbGFnXCIgICAgICAgICAgICAgIFxuIFszMV0gXCJoMm9fbW9sYXJfZGVuc2l0eVwiICAgICAgICAgICAgIFwiaDJvX21vbGVfZnJhY3Rpb25cIiAgICAgICAgICAgIFxuIFszM10gXCJoMm9fbWl4aW5nX3JhdGlvXCIgICAgICAgICAgICAgIFwiaDJvX3RpbWVfbGFnXCIgICAgICAgICAgICAgICAgIFxuIFszNV0gXCJoMm9fZGVmX3RpbWVsYWdcIiAgICAgICAgICAgICAgIFwic29uaWNfdGVtcGVyYXR1cmVcIiAgICAgICAgICAgIFxuIFszN10gXCJhaXJfdGVtcGVyYXR1cmVcIiAgICAgICAgICAgICAgIFwiYWlyX3ByZXNzdXJlXCIgICAgICAgICAgICAgICAgIFxuIFszOV0gXCJhaXJfZGVuc2l0eVwiICAgICAgICAgICAgICAgICAgIFwiYWlyX2hlYXRfY2FwYWNpdHlcIiAgICAgICAgICAgIFxuIFs0MV0gXCJhaXJfbW9sYXJfdm9sdW1lXCIgICAgICAgICAgICAgIFwiRVRcIiAgICAgICAgICAgICAgICAgICAgICAgICAgIFxuIFs0M10gXCJ3YXRlcl92YXBvcl9kZW5zaXR5XCIgICAgICAgICAgIFwiZVwiICAgICAgICAgICAgICAgICAgICAgICAgICAgIFxuIFs0NV0gXCJlc1wiICAgICAgICAgICAgICAgICAgICAgICAgICAgIFwic3BlY2lmaWNfaHVtaWRpdHlcIiAgICAgICAgICAgIFxuIFs0N10gXCJSSFwiICAgICAgICAgICAgICAgICAgICAgICAgICAgIFwiVlBEXCIgICAgICAgICAgICAgICAgICAgICAgICAgIFxuIFs0OV0gXCJUZGV3XCIgICAgICAgICAgICAgICAgICAgICAgICAgIFwidV91bnJvdFwiICAgICAgICAgICAgICAgICAgICAgIFxuIFs1MV0gXCJ2X3Vucm90XCIgICAgICAgICAgICAgICAgICAgICAgIFwid191bnJvdFwiICAgICAgICAgICAgICAgICAgICAgIFxuIFs1M10gXCJ1X3JvdFwiICAgICAgICAgICAgICAgICAgICAgICAgIFwidl9yb3RcIiAgICAgICAgICAgICAgICAgICAgICAgIFxuIFs1NV0gXCJ3X3JvdFwiICAgICAgICAgICAgICAgICAgICAgICAgIFwid2luZF9zcGVlZFwiICAgICAgICAgICAgICAgICAgIFxuIFs1N10gXCJtYXhfd2luZF9zcGVlZFwiICAgICAgICAgICAgICAgIFwid2luZF9kaXJcIiAgICAgICAgICAgICAgICAgICAgIFxuIFs1OV0gXCJ5YXdcIiAgICAgICAgICAgICAgICAgICAgICAgICAgIFwicGl0Y2hcIiAgICAgICAgICAgICAgICAgICAgICAgIFxuIFs2MV0gXCJyb2xsXCIgICAgICAgICAgICAgICAgICAgICAgICAgIFwidS5cIiAgICAgICAgICAgICAgICAgICAgICAgICAgIFxuIFs2M10gXCJUS0VcIiAgICAgICAgICAgICAgICAgICAgICAgICAgIFwiTFwiICAgICAgICAgICAgICAgICAgICAgICAgICAgIFxuIFs2NV0gXCJYLnouZC4uTFwiICAgICAgICAgICAgICAgICAgICAgIFwiYm93ZW5fcmF0aW9cIiAgICAgICAgICAgICAgICAgIFxuIFs2N10gXCJULlwiICAgICAgICAgICAgICAgICAgICAgICAgICAgIFwibW9kZWxcIiAgICAgICAgICAgICAgICAgICAgICAgIFxuIFs2OV0gXCJ4X3BlYWtcIiAgICAgICAgICAgICAgICAgICAgICAgIFwieF9vZmZzZXRcIiAgICAgICAgICAgICAgICAgICAgIFxuIFs3MV0gXCJ4XzEwLlwiICAgICAgICAgICAgICAgICAgICAgICAgIFwieF8zMC5cIiAgICAgICAgICAgICAgICAgICAgICAgIFxuIFs3M10gXCJ4XzUwLlwiICAgICAgICAgICAgICAgICAgICAgICAgIFwieF83MC5cIiAgICAgICAgICAgICAgICAgICAgICAgIFxuIFs3NV0gXCJ4XzkwLlwiICAgICAgICAgICAgICAgICAgICAgICAgIFwidW5fVGF1XCIgICAgICAgICAgICAgICAgICAgICAgIFxuIFs3N10gXCJUYXVfc2NmXCIgICAgICAgICAgICAgICAgICAgICAgIFwidW5fSFwiICAgICAgICAgICAgICAgICAgICAgICAgIFxuIFs3OV0gXCJIX3NjZlwiICAgICAgICAgICAgICAgICAgICAgICAgIFwidW5fTEVcIiAgICAgICAgICAgICAgICAgICAgICAgIFxuIFs4MV0gXCJMRV9zY2ZcIiAgICAgICAgICAgICAgICAgICAgICAgIFwidW5fY28yX2ZsdXhcIiAgICAgICAgICAgICAgICAgIFxuIFs4M10gXCJjbzJfc2NmXCIgICAgICAgICAgICAgICAgICAgICAgIFwidW5faDJvX2ZsdXhcIiAgICAgICAgICAgICAgICAgIFxuIFs4NV0gXCJoMm9fc2NmXCIgICAgICAgICAgICAgICAgICAgICAgIFwic3Bpa2VzX2hmXCIgICAgICAgICAgICAgICAgICAgIFxuIFs4N10gXCJhbXBsaXR1ZGVfcmVzb2x1dGlvbl9oZlwiICAgICAgIFwiZHJvcF9vdXRfaGZcIiAgICAgICAgICAgICAgICAgIFxuIFs4OV0gXCJhYnNvbHV0ZV9saW1pdHNfaGZcIiAgICAgICAgICAgIFwic2tld25lc3Nfa3VydG9zaXNfaGZcIiAgICAgICAgIFxuIFs5MV0gXCJza2V3bmVzc19rdXJ0b3Npc19zZlwiICAgICAgICAgIFwiZGlzY29udGludWl0aWVzX2hmXCIgICAgICAgICAgIFxuIFs5M10gXCJkaXNjb250aW51aXRpZXNfc2ZcIiAgICAgICAgICAgIFwidGltZWxhZ19oZlwiICAgICAgICAgICAgICAgICAgIFxuIFs5NV0gXCJ0aW1lbGFnX3NmXCIgICAgICAgICAgICAgICAgICAgIFwiYXR0YWNrX2FuZ2xlX2hmXCIgICAgICAgICAgICAgIFxuIFs5N10gXCJub25fc3RlYWR5X3dpbmRfaGZcIiAgICAgICAgICAgIFwidV9zcGlrZXNcIiAgICAgICAgICAgICAgICAgICAgIFxuIFs5OV0gXCJ2X3NwaWtlc1wiICAgICAgICAgICAgICAgICAgICAgIFwid19zcGlrZXNcIiAgICAgICAgICAgICAgICAgICAgIFxuWzEwMV0gXCJ0c19zcGlrZXNcIiAgICAgICAgICAgICAgICAgICAgIFwiY28yX3NwaWtlc1wiICAgICAgICAgICAgICAgICAgIFxuWzEwM10gXCJoMm9fc3Bpa2VzXCIgICAgICAgICAgICAgICAgICAgIFwiY2hvcHBlcl9MSS43NTAwXCIgICAgICAgICAgICAgIFxuWzEwNV0gXCJkZXRlY3Rvcl9MSS43NTAwXCIgICAgICAgICAgICAgIFwicGxsX0xJLjc1MDBcIiAgICAgICAgICAgICAgICAgIFxuWzEwN10gXCJzeW5jX0xJLjc1MDBcIiAgICAgICAgICAgICAgICAgIFwibWVhbl92YWx1ZV9SU1NJX0xJLjc1MDBcIiAgICAgIFxuWzEwOV0gXCJ1X3ZhclwiICAgICAgICAgICAgICAgICAgICAgICAgIFwidl92YXJcIiAgICAgICAgICAgICAgICAgICAgICAgIFxuWzExMV0gXCJ3X3ZhclwiICAgICAgICAgICAgICAgICAgICAgICAgIFwidHNfdmFyXCIgICAgICAgICAgICAgICAgICAgICAgIFxuWzExM10gXCJjbzJfdmFyXCIgICAgICAgICAgICAgICAgICAgICAgIFwiaDJvX3ZhclwiICAgICAgICAgICAgICAgICAgICAgIFxuWzExNV0gXCJ3LnRzX2NvdlwiICAgICAgICAgICAgICAgICAgICAgIFwidy5jbzJfY292XCIgICAgICAgICAgICAgICAgICAgIFxuWzExN10gXCJ3Lmgyb19jb3ZcIiAgICAgICAgICAgICAgICAgICAgIFwidmluX3NmX21lYW5cIiAgICAgICAgICAgICAgICAgIFxuWzExOV0gXCJjbzJfbWVhblwiICAgICAgICAgICAgICAgICAgICAgIFwiaDJvX21lYW5cIiAgICAgICAgICAgICAgICAgICAgIFxuWzEyMV0gXCJkZXdfcG9pbnRfbWVhblwiICAgICAgICAgICAgICAgIFwiY28yX3NpZ25hbF9zdHJlbmd0aF83NTAwX21lYW5cIlxuWzEyM10gXCJSRUNPUkRcIiAgICAgICAgICAgICAgICAgICAgICAgIFwiQmF0dFZfQXZnXCIgICAgICAgICAgICAgICAgICAgIFxuWzEyNV0gXCJQVGVtcF9DX0F2Z1wiICAgICAgICAgICAgICAgICAgIFwiQU0yNVRfcmVmX0F2Z1wiICAgICAgICAgICAgICAgIFxuWzEyN10gXCJUQ19BdmcuMS5cIiAgICAgICAgICAgICAgICAgICAgIFwiVENfQXZnLjIuXCIgICAgICAgICAgICAgICAgICAgIFxuWzEyOV0gXCJUQ19BdmcuMy5cIiAgICAgICAgICAgICAgICAgICAgIFwiVENfQXZnLjQuXCIgICAgICAgICAgICAgICAgICAgIFxuWzEzMV0gXCJUQ19BdmcuNS5cIiAgICAgICAgICAgICAgICAgICAgIFwiVENfQXZnLjYuXCIgICAgICAgICAgICAgICAgICAgIFxuWzEzM10gXCJUQ19BdmcuNy5cIiAgICAgICAgICAgICAgICAgICAgIFwiVENfQXZnLjguXCIgICAgICAgICAgICAgICAgICAgIFxuWzEzNV0gXCJUQ19BdmcuOS5cIiAgICAgICAgICAgICAgICAgICAgIFwiVENfQXZnLjEwLlwiICAgICAgICAgICAgICAgICAgIFxuWzEzN10gXCJUQ19BdmcuMTEuXCIgICAgICAgICAgICAgICAgICAgIFwiVENfQXZnLjEyLlwiICAgICAgICAgICAgICAgICAgIFxuWzEzOV0gXCJUQ19BdmcuMTMuXCIgICAgICAgICAgICAgICAgICAgIFwiVENfQXZnLjE0LlwiICAgICAgICAgICAgICAgICAgIFxuWzE0MV0gXCJUQ19BdmcuMTUuXCIgICAgICAgICAgICAgICAgICAgIFwiVENfQXZnLjE2LlwiICAgICAgICAgICAgICAgICAgIFxuWzE0M10gXCJUQ19BdmcuMTcuXCIgICAgICAgICAgICAgICAgICAgIFwiVENfQXZnLjE4LlwiICAgICAgICAgICAgICAgICAgIFxuWzE0NV0gXCJUQ19BdmcuMTkuXCIgICAgICAgICAgICAgICAgICAgIFwiVENfQXZnLjIwLlwiICAgICAgICAgICAgICAgICAgIFxuWzE0N10gXCJUQ19BdmcuMjEuXCIgICAgICAgICAgICAgICAgICAgIFwiVENfQXZnLjIyLlwiICAgICAgICAgICAgICAgICAgIFxuWzE0OV0gXCJUQ19BdmcuMjMuXCIgICAgICAgICAgICAgICAgICAgIFwiVENfQXZnLjI0LlwiICAgICAgICAgICAgICAgICAgIFxuWzE1MV0gXCJUQ19BdmcuMjUuXCIgICAgICAgICAgICAgICAgICAgIFwiQWlyVF9BdmdcIiAgICAgICAgICAgICAgICAgICAgIFxuWzE1M10gXCJSSF9BdmdcIiAgICAgICAgICAgICAgICAgICAgICAgIFwiQXRtUHJlc3N1cmVfQXZnXCIgICAgICAgICAgICAgIFxuWzE1NV0gXCJOUl9tVl9BdmdcIiAgICAgICAgICAgICAgICAgICAgIFwiTlJfV20yX0F2Z1wiICAgICAgICAgICAgICAgICAgIFxuWzE1N10gXCJQQVJfaW5fbVZfQXZnXCIgICAgICAgICAgICAgICAgIFwiUEFSX2luX3VFbTJfQXZnXCIgICAgICAgICAgICAgIFxuWzE1OV0gXCJQQVJfb3V0X21WX0F2Z1wiICAgICAgICAgICAgICAgIFwiUEFSX291dF91RW0yX0F2Z1wiICAgICAgICAgICAgIFxuWzE2MV0gXCJTSEZfMV9tVl9BdmdcIiAgICAgICAgICAgICAgICAgIFwiU0hGXzFfV20yX0F2Z1wiICAgICAgICAgICAgICAgIFxuWzE2M10gXCJTSEZfMl9tVl9BdmdcIiAgICAgICAgICAgICAgICAgIFwiU0hGXzJfV20yX0F2Z1wiICAgICAgICAgICAgICAgIFxuWzE2NV0gXCJXYXRlclBfQXZnXCIgICAgICAgICAgICAgICAgICAgIFwiV2F0ZXJUX0F2Z1wiICAgICAgICAgICAgICAgICAgIFxuWzE2N10gXCJQcmVjaXBfbW1fVG90XCIgICAgICAgICAgICAgICAgIFwiVldDX0F2Z1wiICAgICAgICAgICAgICAgICAgICAgIFxuWzE2OV0gXCJFQ19BdmdcIiAgICAgICAgICAgICAgICAgICAgICAgIFwiVF9BdmdcIiAgICAgICAgICAgICAgICAgICAgICAgIFxuWzE3MV0gXCJQX0F2Z1wiICAgICAgICAgICAgICAgICAgICAgICAgIFwiUEFfQXZnXCIgICAgICAgICAgICAgICAgICAgICAgIFxuWzE3M10gXCJWUl9BdmdcIiAgICAgICAgICAgICAgICAgICAgICAgIFwiZG95LmlkXCIgICAgICAgICAgICAgICAgICAgICAgIFxuWzE3NV0gXCJhaXJfdGVtcGVyYXR1cmVfYWRqXCIgICAgICAgICAgIFwiQ29ycmVjdF9OUlwiICAgICAgICAgICAgICAgICAgIFxuWzE3N10gXCJDb3JyZWN0X3NoZl8xXCIgICAgICAgICAgICAgICAgIFwiQ29ycmVjdF9zaGZfMlwiICAgICAgICAgICAgICAgIFxuIn0= -->

```
  [1] "time.id"                       "TIMESTAMP"                    
  [3] "filename"                      "date"                         
  [5] "time"                          "DOY"                          
  [7] "daytime"                       "file_records"                 
  [9] "used_records"                  "Tau"                          
 [11] "qc_Tau"                        "H"                            
 [13] "qc_H"                          "LE"                           
 [15] "qc_LE"                         "co2_flux"                     
 [17] "qc_co2_flux"                   "h2o_flux"                     
 [19] "qc_h2o_flux"                   "H_strg"                       
 [21] "LE_strg"                       "co2_strg"                     
 [23] "h2o_strg"                      "co2_v.adv"                    
 [25] "h2o_v.adv"                     "co2_molar_density"            
 [27] "co2_mole_fraction"             "co2_mixing_ratio"             
 [29] "co2_time_lag"                  "co2_def_timelag"              
 [31] "h2o_molar_density"             "h2o_mole_fraction"            
 [33] "h2o_mixing_ratio"              "h2o_time_lag"                 
 [35] "h2o_def_timelag"               "sonic_temperature"            
 [37] "air_temperature"               "air_pressure"                 
 [39] "air_density"                   "air_heat_capacity"            
 [41] "air_molar_volume"              "ET"                           
 [43] "water_vapor_density"           "e"                            
 [45] "es"                            "specific_humidity"            
 [47] "RH"                            "VPD"                          
 [49] "Tdew"                          "u_unrot"                      
 [51] "v_unrot"                       "w_unrot"                      
 [53] "u_rot"                         "v_rot"                        
 [55] "w_rot"                         "wind_speed"                   
 [57] "max_wind_speed"                "wind_dir"                     
 [59] "yaw"                           "pitch"                        
 [61] "roll"                          "u."                           
 [63] "TKE"                           "L"                            
 [65] "X.z.d..L"                      "bowen_ratio"                  
 [67] "T."                            "model"                        
 [69] "x_peak"                        "x_offset"                     
 [71] "x_10."                         "x_30."                        
 [73] "x_50."                         "x_70."                        
 [75] "x_90."                         "un_Tau"                       
 [77] "Tau_scf"                       "un_H"                         
 [79] "H_scf"                         "un_LE"                        
 [81] "LE_scf"                        "un_co2_flux"                  
 [83] "co2_scf"                       "un_h2o_flux"                  
 [85] "h2o_scf"                       "spikes_hf"                    
 [87] "amplitude_resolution_hf"       "drop_out_hf"                  
 [89] "absolute_limits_hf"            "skewness_kurtosis_hf"         
 [91] "skewness_kurtosis_sf"          "discontinuities_hf"           
 [93] "discontinuities_sf"            "timelag_hf"                   
 [95] "timelag_sf"                    "attack_angle_hf"              
 [97] "non_steady_wind_hf"            "u_spikes"                     
 [99] "v_spikes"                      "w_spikes"                     
[101] "ts_spikes"                     "co2_spikes"                   
[103] "h2o_spikes"                    "chopper_LI.7500"              
[105] "detector_LI.7500"              "pll_LI.7500"                  
[107] "sync_LI.7500"                  "mean_value_RSSI_LI.7500"      
[109] "u_var"                         "v_var"                        
[111] "w_var"                         "ts_var"                       
[113] "co2_var"                       "h2o_var"                      
[115] "w.ts_cov"                      "w.co2_cov"                    
[117] "w.h2o_cov"                     "vin_sf_mean"                  
[119] "co2_mean"                      "h2o_mean"                     
[121] "dew_point_mean"                "co2_signal_strength_7500_mean"
[123] "RECORD"                        "BattV_Avg"                    
[125] "PTemp_C_Avg"                   "AM25T_ref_Avg"                
[127] "TC_Avg.1."                     "TC_Avg.2."                    
[129] "TC_Avg.3."                     "TC_Avg.4."                    
[131] "TC_Avg.5."                     "TC_Avg.6."                    
[133] "TC_Avg.7."                     "TC_Avg.8."                    
[135] "TC_Avg.9."                     "TC_Avg.10."                   
[137] "TC_Avg.11."                    "TC_Avg.12."                   
[139] "TC_Avg.13."                    "TC_Avg.14."                   
[141] "TC_Avg.15."                    "TC_Avg.16."                   
[143] "TC_Avg.17."                    "TC_Avg.18."                   
[145] "TC_Avg.19."                    "TC_Avg.20."                   
[147] "TC_Avg.21."                    "TC_Avg.22."                   
[149] "TC_Avg.23."                    "TC_Avg.24."                   
[151] "TC_Avg.25."                    "AirT_Avg"                     
[153] "RH_Avg"                        "AtmPressure_Avg"              
[155] "NR_mV_Avg"                     "NR_Wm2_Avg"                   
[157] "PAR_in_mV_Avg"                 "PAR_in_uEm2_Avg"              
[159] "PAR_out_mV_Avg"                "PAR_out_uEm2_Avg"             
[161] "SHF_1_mV_Avg"                  "SHF_1_Wm2_Avg"                
[163] "SHF_2_mV_Avg"                  "SHF_2_Wm2_Avg"                
[165] "WaterP_Avg"                    "WaterT_Avg"                   
[167] "Precip_mm_Tot"                 "VWC_Avg"                      
[169] "EC_Avg"                        "T_Avg"                        
[171] "P_Avg"                         "PA_Avg"                       
[173] "VR_Avg"                        "doy.id"                       
[175] "air_temperature_adj"           "Correct_NR"                   
[177] "Correct_shf_1"                 "Correct_shf_2"                
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


#Creating a CSV File of combined Master File (post-filtering)
hc: modify the filename starting with Date when the file is created

write.csv(cdata,
   paste(eddypro.path,ver,"cdata",sep=""),
    quote = T,
  row.names = F)


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxud3JpdGUuY3N2KGNkYXRhLFxuICAgICAgICAgIHBhc3RlKHBhdGgub3V0LFN5cy5EYXRlKCksXFxfbWFzdGVyX2VkZHlfbWV0X2NvbmNvcmRfcG9zdGZpbHRlcmluZy5jc3ZcXCxzZXA9XFxcXCksXG4gICAgICAgICAgcXVvdGUgPSBULFxuICAgICAgICAgIHJvdy5uYW1lcyA9IEYpXG5gYGBcbmBgYCJ9 -->

```r
```r
write.csv(cdata,
          paste(path.out,Sys.Date(),\_master_eddy_met_concord_postfiltering.csv\,sep=\\),
          quote = T,
          row.names = F)
```
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


#Generate simple timeseries plots
* post-filtered time series plot per variable
* LOESS fit and daily average are plotted to show temporal dynamics


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG4jc3VtbWFyeShjZGF0YSlcbiMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXG4jIyBHZW5lcmljIHRpbWUgc2VyaWVzIHBsb3RcbnRhcmdldC5wbG90LnZhcjwtYyhcImNvMl9mbHV4XCIsXCJMRVwiLFwiSFwiLFwidS5cIixcbiAgICAgICAgICAgICAgICAgICBcImNvMl9taXhpbmdfcmF0aW9cIixcImgyb19taXhpbmdfcmF0aW9cIixcbiAgICAgICAgICAgICAgICAgICBcImFpcl90ZW1wZXJhdHVyZV9hZGpcIixcIlJIXCIsXG4gICAgICAgICAgICAgICAgICAgXCJ3aW5kX3NwZWVkXCIsXCJ3aW5kX2RpclwiLFwibWVhbl92YWx1ZV9SU1NJX0xJLjc1MDBcIiwgXG4gICAgICAgICAgICAgICAgICAgXCJBaXJUX0F2Z1wiLCBcIkNvcnJlY3RfTlJcIiwgIFwiQ29ycmVjdF9zaGZfMVwiICwgXCJDb3JyZWN0X3NoZl8yXCIsXG4gICAgICAgICAgICAgICAgICAgXCJWV0NfQXZnXCIsXCJQcmVjaXBfbW1fVG90XCIgLFxuICAgICAgICAgICAgICAgICAgICNcIlBBUl9pbl91RW0yX0F2Z1wiLFwiUEFSX291dF91RW0yX0F2Z1wiLFxuICAgICAgICAgICAgICAgICAgIFwiQXRtUHJlc3N1cmVfQXZnXCIsXG4gICAgICAgICAgICAgICAgICAgXCJUQ19BdmcuMS5cIixcIlRDX0F2Zy4yLlwiLFwiVENfQXZnLjMuXCIsXCJUQ19BdmcuNC5cIixcIlRDX0F2Zy41LlwiKVxudGFyZ2V0LnBsb3QudmFyLnRpdGxlPC1jKGV4cHJlc3Npb24oRkN+Jygnfm11fm1vbH5tXnstMn1+c157LTF9ficpJyksXG4gICAgICAgICAgICAgICAgICAgICAgICAgZXhwcmVzc2lvbihMRX4nKCd+V35tXnstMn1+JyknKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICBleHByZXNzaW9uKEh+Jygnfld+bV57LTJ9ficpJyksXG4gICAgICAgICAgICAgICAgICAgICAgICAgZXhwcmVzc2lvbih1WycqJ11+Jygnfm1+c157LTF9ficpJyksXG4gICAgICAgICAgICAgICAgICAgICAgICAgZXhwcmVzc2lvbihDT1syXX4nKCd+cHBtficpJyksXG4gICAgICAgICAgICAgICAgICAgICAgICAgZXhwcmVzc2lvbihXYXRlcn52YXBvcn4nKCd+cHB0ficpJyksXG4gICAgICAgICAgICAgICAgICAgICAgICAgZXhwcmVzc2lvbihBaXJ+dGVtcGVyYXR1cmV+JygnfmRlZ3JlZX5DficpJyksXG4gICAgICAgICAgICAgICAgICAgICAgICAgZXhwcmVzc2lvbihSZWxhdGl2ZX5odW1pZGl0eX4nKCd+cGVyY2VudH4nKScpLFxuICAgICAgICAgICAgICAgICAgICAgICAgIGV4cHJlc3Npb24oV2luZH5zcGVlZH4nKCd+bX5zXnstMX1+JyknKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICBleHByZXNzaW9uKFdpbmR+ZGlyZWN0aW9uficoJ35kZWdyZWV+JyknKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICBleHByZXNzaW9uKExJNzUwMH5zaWduYWx+c3RyZW5naCB+JygnfictJ34nKScpLFxuICAgICAgICAgICAgICAgICAgICAgICAgIGV4cHJlc3Npb24oQWlyfnRlbXBlcmF0dXJlfk1FVH4nKCd+ZGVncmVlfkN+JyknKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICBleHByZXNzaW9uKE5ldH5SYWRpYXRpb25+Jygnfld+bV57LTJ9ficpJyksXG4gICAgICAgICAgICAgICAgICAgICAgICAgZXhwcmVzc2lvbihTb2lsfkhlYXRmbHV4MX4nKCd+V35tXnstMn1+JyknKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICBleHByZXNzaW9uKFNvaWx+SGVhdGZsdXgyficoJ35Xfm1eey0yfX4nKScpLFxuICAgICAgICAgICAgICAgICAgICAgICAgIGV4cHJlc3Npb24oU29pbH53YXRlcn5jb250ZW50ficoJ35tXnszfX5tXnstM31+JyknKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICBleHByZXNzaW9uKFByZWNpcGl0YXRpb25+Jygnfm1tficpJyksXG4gICAgICAgICAgICAgICAgICAgICAgICAgI2V4cHJlc3Npb24oSW5jb21pbmd+UEFSficoJ35tdX5tb2x+bV57LTJ9fnNeey0xfX4nKScpLFxuICAgICAgICAgICAgICAgICAgICAgICAgICNleHByZXNzaW9uKE91dGdvaW5nflBBUn4nKCd+bXV+bW9sfm1eey0yfX5zXnstMX1+JyknKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICBleHByZXNzaW9uKEF0bW9zcGhlcmljfnByZXNzdXJlficoJ35rUGF+JyknKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICBleHByZXNzaW9uKFNvaWx+dGVtcGVyYXR1cmV+MX4nKCd+ZGVncmVlfkN+JyknKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICBleHByZXNzaW9uKFNvaWx+dGVtcGVyYXR1cmV+Mn4nKCd+ZGVncmVlfkN+JyknKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICBleHByZXNzaW9uKFNvaWx+dGVtcGVyYXR1cmV+M34nKCd+ZGVncmVlfkN+JyknKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICBleHByZXNzaW9uKFNvaWx+dGVtcGVyYXR1cmV+NH4nKCd+ZGVncmVlfkN+JyknKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICBleHByZXNzaW9uKFNvaWx+dGVtcGVyYXR1cmV+NX4nKCd+ZGVncmVlfkN+JyknKSkgIFxuXG5mb3IoazEgaW4gMTpsZW5ndGgodGFyZ2V0LnBsb3QudmFyKSl7XG4gIFxuICAjIyBsb2NhdGUgdGhlIHN0YXJ0IG9mIGVhY2ggbW9udGhcbiAgbW9udGgubG9jPC13aGljaChjZGF0YSRUSU1FU1RBTVAkbWRheT09MSZcbiAgICAgICAgICAgICAgICAgICAgIGNkYXRhJFRJTUVTVEFNUCRob3VyPT0wJlxuICAgICAgICAgICAgICAgICAgICAgY2RhdGEkVElNRVNUQU1QJG1pbj09MClcbiAgbW9udGgudGlja3MgPC0gc2VxKGNkYXRhJFRJTUVTVEFNUFttb250aC5sb2NbMV1dLFxuICAgICAgICAgICAgICAgICAgICAgY2RhdGEkVElNRVNUQU1QW21vbnRoLmxvY1tsZW5ndGgobW9udGgubG9jKV1dLGJ5PVwibW9udGhzXCIpXG5cbiAgcG5nKHBhc3RlMChwbG90LnBhdGgsXG4gICAgICAgICAgICAgXCJDb25jb3JkX1wiLFxuICAgICAgICAgICAgIGNkYXRhJFRJTUVTVEFNUCR5ZWFyWzFdKzE5MDAsXCJfXCIsXG4gICAgICAgICAgICAgY2RhdGEkVElNRVNUQU1QJHlkYXlbMV0rMSxcIl9cIixcbiAgICAgICAgICAgICBjZGF0YSRUSU1FU1RBTVAkeWVhcltucm93KGNkYXRhKV0rMTkwMCxcIl9cIixcbiAgICAgICAgICAgICBjZGF0YSRUSU1FU1RBTVAkeWRheVtucm93KGNkYXRhKV0rMSxcIl9cIixcbiAgICAgICAgICAgICB0YXJnZXQucGxvdC52YXJbazFdLFwiX1wiLFxuICAgICAgICAgICAgIFN5cy5EYXRlKCksXCIucG5nXCIpLFxuICAgICAgd2lkdGg9NixcbiAgICAgIGhlaWdodD00LFxuICAgICAgdW5pdHM9XCJpblwiLFxuICAgICAgcmVzPTMwMCxcbiAgICAgIHBvaW50c2l6ZSA9IDExLFxuICAgICAgYmcgPSBcIndoaXRlXCIpXG4gIFxuICBwYXIob21hPWMoMC41LDAuNSwwLjUsMC41KSxtYXI9Yyg0LDQuNSwwLDApKVxuICBwbG90KGNkYXRhJFRJTUVTVEFNUCxcbiAgICAgICBjZGF0YVssdGFyZ2V0LnBsb3QudmFyW2sxXV0sXG4gICAgICAgeGxhYj1cIlRJTUVTVEFNUFwiLFxuICAgICAgIHlsYWI9dGFyZ2V0LnBsb3QudmFyLnRpdGxlW2sxXSxcbiAgICAgICBjZXg9MC41LGNvbD1cImdyZXlcIixiZz1cImxpZ2h0Z3JleVwiLFxuICAgICAgIGxhcz0xLHBjaD0yMSxcbiAgICAgICB4YXhzPVwiaVwiLHlheHM9XCJpXCJcbiAgKVxuICBcbiAgYWJsaW5lKGg9MCxjb2w9XCJkYXJrZ3JleVwiKVxuICBcbiAgIyMgZGFpbHkgYXZlcmdlIGxpbmVcbiAgZGFpbHkudG1wPC1kYXRhLmZyYW1lKGRhdGU9dGFwcGx5KGNkYXRhJHRpbWUuaWQsY2RhdGEkZG95LmlkLG1pbiksXG4gICAgICAgICAgICAgICAgICAgICAgICBkYWlseT10YXBwbHkoY2RhdGFbLHRhcmdldC5wbG90LnZhcltrMV1dLGNkYXRhJGRveS5pZCxuYS5tZWFuKSlcbiAgXG4gIGxpbmVzKGNkYXRhJFRJTUVTVEFNUFt3aGljaChjZGF0YSR0aW1lLmlkICVpbiUgZGFpbHkudG1wJGRhdGUpXSxcbiAgICAgICAgZGFpbHkudG1wJGRhaWx5LFxuICAgICAgICBsd2Q9MS41LGNvbD1cImJsYWNrXCIpXG4gIFxuICAjIyBsb2VzcyBmaXQgbGluZVxuICBsb2Vzcy50bXA8LWxvZXNzKGNkYXRhWyx0YXJnZXQucGxvdC52YXJbazFdXX5jKDE6bnJvdyhjZGF0YSkpLHNwYW49MC4xKVxuICBcbiAgIyMgYXZvaWQgcGxvdHRpbmcgbG9uZyBnYXBzXG4gIGxvbmcuZ2FwPC13aGljaChsb2Vzcy50bXAkeFstMV0tbG9lc3MudG1wJHhbLWxlbmd0aChsb2Vzcy50bXAkeCldPjQ4KjMpXG4gIGlmKGxvbmcuZ2FwWzFdPjEpIGxvbmcuZ2FwPC1jKDEsbG9uZy5nYXApXG4gIGlmKGxvbmcuZ2FwW2xlbmd0aChsb25nLmdhcCldPGxlbmd0aChsb2Vzcy50bXAkeCkpIGxvbmcuZ2FwPC1jKGxvbmcuZ2FwLGxlbmd0aChsb2Vzcy50bXAkeCkpXG4gIFxuICBmb3IoazEgaW4gMToobGVuZ3RoKGxvbmcuZ2FwKS0xKSl7XG4gICAgbGluZXMoY2RhdGEkVElNRVNUQU1QW3JvdW5kKGxvZXNzLnRtcCR4W2MoKGxvbmcuZ2FwW2sxXSsxKToobG9uZy5nYXBbazErMV0tMSkpXSldLFxuICAgICAgICAgIGxvZXNzLnRtcCRmaXR0ZWRbYygobG9uZy5nYXBbazFdKzEpOihsb25nLmdhcFtrMSsxXS0xKSldLFxuICAgICAgICAgIGx3ZD0xLjUsY29sPVwicmVkXCIpXG4gIH1cbiAgXG4gIGF4aXMoMSwgYXQgPSBtb250aC50aWNrcywgbGFiZWxzID0gRkFMU0UsIHRjbCA9IC0wLjMpXG4gIGRldi5vZmYoKVxufVxuYGBgIn0= -->

```r

#summary(cdata)
##############################################################
## Generic time series plot
target.plot.var<-c("co2_flux","LE","H","u.",
                   "co2_mixing_ratio","h2o_mixing_ratio",
                   "air_temperature_adj","RH",
                   "wind_speed","wind_dir","mean_value_RSSI_LI.7500", 
                   "AirT_Avg", "Correct_NR",  "Correct_shf_1" , "Correct_shf_2",
                   "VWC_Avg","Precip_mm_Tot" ,
                   #"PAR_in_uEm2_Avg","PAR_out_uEm2_Avg",
                   "AtmPressure_Avg",
                   "TC_Avg.1.","TC_Avg.2.","TC_Avg.3.","TC_Avg.4.","TC_Avg.5.")
target.plot.var.title<-c(expression(FC~'('~mu~mol~m^{-2}~s^{-1}~')'),
                         expression(LE~'('~W~m^{-2}~')'),
                         expression(H~'('~W~m^{-2}~')'),
                         expression(u['*']~'('~m~s^{-1}~')'),
                         expression(CO[2]~'('~ppm~')'),
                         expression(Water~vapor~'('~ppt~')'),
                         expression(Air~temperature~'('~degree~C~')'),
                         expression(Relative~humidity~'('~percent~')'),
                         expression(Wind~speed~'('~m~s^{-1}~')'),
                         expression(Wind~direction~'('~degree~')'),
                         expression(LI7500~signal~strengh ~'('~'-'~')'),
                         expression(Air~temperature~MET~'('~degree~C~')'),
                         expression(Net~Radiation~'('~W~m^{-2}~')'),
                         expression(Soil~Heatflux1~'('~W~m^{-2}~')'),
                         expression(Soil~Heatflux2~'('~W~m^{-2}~')'),
                         expression(Soil~water~content~'('~m^{3}~m^{-3}~')'),
                         expression(Precipitation~'('~mm~')'),
                         #expression(Incoming~PAR~'('~mu~mol~m^{-2}~s^{-1}~')'),
                         #expression(Outgoing~PAR~'('~mu~mol~m^{-2}~s^{-1}~')'),
                         expression(Atmospheric~pressure~'('~kPa~')'),
                         expression(Soil~temperature~1~'('~degree~C~')'),
                         expression(Soil~temperature~2~'('~degree~C~')'),
                         expression(Soil~temperature~3~'('~degree~C~')'),
                         expression(Soil~temperature~4~'('~degree~C~')'),
                         expression(Soil~temperature~5~'('~degree~C~')'))  

for(k1 in 1:length(target.plot.var)){
  
  ## locate the start of each month
  month.loc<-which(cdata$TIMESTAMP$mday==1&
                     cdata$TIMESTAMP$hour==0&
                     cdata$TIMESTAMP$min==0)
  month.ticks <- seq(cdata$TIMESTAMP[month.loc[1]],
                     cdata$TIMESTAMP[month.loc[length(month.loc)]],by="months")

  png(paste0(plot.path,
             "Concord_",
             cdata$TIMESTAMP$year[1]+1900,"_",
             cdata$TIMESTAMP$yday[1]+1,"_",
             cdata$TIMESTAMP$year[nrow(cdata)]+1900,"_",
             cdata$TIMESTAMP$yday[nrow(cdata)]+1,"_",
             target.plot.var[k1],"_",
             Sys.Date(),".png"),
      width=6,
      height=4,
      units="in",
      res=300,
      pointsize = 11,
      bg = "white")
  
  par(oma=c(0.5,0.5,0.5,0.5),mar=c(4,4.5,0,0))
  plot(cdata$TIMESTAMP,
       cdata[,target.plot.var[k1]],
       xlab="TIMESTAMP",
       ylab=target.plot.var.title[k1],
       cex=0.5,col="grey",bg="lightgrey",
       las=1,pch=21,
       xaxs="i",yaxs="i"
  )
  
  abline(h=0,col="darkgrey")
  
  ## daily averge line
  daily.tmp<-data.frame(date=tapply(cdata$time.id,cdata$doy.id,min),
                        daily=tapply(cdata[,target.plot.var[k1]],cdata$doy.id,na.mean))
  
  lines(cdata$TIMESTAMP[which(cdata$time.id %in% daily.tmp$date)],
        daily.tmp$daily,
        lwd=1.5,col="black")
  
  ## loess fit line
  loess.tmp<-loess(cdata[,target.plot.var[k1]]~c(1:nrow(cdata)),span=0.1)
  
  ## avoid plotting long gaps
  long.gap<-which(loess.tmp$x[-1]-loess.tmp$x[-length(loess.tmp$x)]>48*3)
  if(long.gap[1]>1) long.gap<-c(1,long.gap)
  if(long.gap[length(long.gap)]<length(loess.tmp$x)) long.gap<-c(long.gap,length(loess.tmp$x))
  
  for(k1 in 1:(length(long.gap)-1)){
    lines(cdata$TIMESTAMP[round(loess.tmp$x[c((long.gap[k1]+1):(long.gap[k1+1]-1))])],
          loess.tmp$fitted[c((long.gap[k1]+1):(long.gap[k1+1]-1))],
          lwd=1.5,col="red")
  }
  
  axis(1, at = month.ticks, labels = FALSE, tcl = -0.3)
  dev.off()
}
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiRXJyb3IgaW4gaWYgKGxvbmcuZ2FwWzFdID4gMSkgbG9uZy5nYXAgPC0gYygxLCBsb25nLmdhcCkgOiBcbiAgbWlzc2luZyB2YWx1ZSB3aGVyZSBUUlVFL0ZBTFNFIG5lZWRlZFxuIn0= -->

```
Error in if (long.gap[1] > 1) long.gap <- c(1, long.gap) : 
  missing value where TRUE/FALSE needed
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



#Generate timeseries plots color-coded by wind direction
* similar plot as previous time series plot
* Color-coded data points based on wind direction, currently 2 groups
** hc: Revise thresholds for WD groups if needed


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxuXG4jIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjI1xuIyMgR2VuZXJpYyB0aW1lIHNlcmllcyBwbG90XG5XRC5ncnA8LXJlcCgyLG5yb3coY2RhdGEpKVxuV0QuZ3JwW3doaWNoKCFpcy5uYShjZGF0YSR3aW5kX2RpcikmXG4gICAgICAgICAgICAgICAgICAoY2RhdGEkd2luZF9kaXI+MTIwJmNkYXRhJHdpbmRfZGlyPD0zMDApKV08LTFcbldELmxlZ2VuZDwtYyhcXFNvdXRod2VzdCB3aW5kXFwsXFxOb3J0aGVhc3Qgd2luZFxcKVxuV0QuY29sPC1jKHJnYigwLDAsMSwwLjUsbWF4Q29sb3JWYWx1ZT0xKSxyZ2IoMSwwLDAsMC41LG1heENvbG9yVmFsdWU9MSkpXG5cbnRhcmdldC5wbG90LnZhcjwtYyhcXGNvMl9mbHV4XFwsXFxMRVxcLFxcSFxcLFxcdS5cXClcbnRhcmdldC5wbG90LnZhci50aXRsZTwtYyhleHByZXNzaW9uKEZDficoJ35tdX5tb2x+bV57LTJ9fnNeey0xfX4nKScpLFxuICAgICAgICAgICAgICAgICAgICAgICAgIGV4cHJlc3Npb24oTEV+Jygnfld+bV57LTJ9ficpJyksXG4gICAgICAgICAgICAgICAgICAgICAgICAgZXhwcmVzc2lvbihIficoJ35Xfm1eey0yfX4nKScpLFxuICAgICAgICAgICAgICAgICAgICAgICAgIGV4cHJlc3Npb24odVsnKiddficoJ35tfnNeey0xfX4nKScpKSAgXG5cbmZvcihrMSBpbiAxOmxlbmd0aCh0YXJnZXQucGxvdC52YXIpKXtcbiAgXG4gICMjIGxvY2F0ZSB0aGUgc3RhcnQgb2YgZWFjaCBtb250aFxuICBtb250aC5sb2M8LXdoaWNoKGNkYXRhJFRJTUVTVEFNUCRtZGF5PT0xJlxuICAgICAgICAgICAgICAgICAgICAgY2RhdGEkVElNRVNUQU1QJGhvdXI9PTAmXG4gICAgICAgICAgICAgICAgICAgICBjZGF0YSRUSU1FU1RBTVAkbWluPT0wKVxuICBtb250aC50aWNrcyA8LSBzZXEoY2RhdGEkVElNRVNUQU1QW21vbnRoLmxvY1sxXV0sXG4gICAgICAgICAgICAgICAgICAgICBjZGF0YSRUSU1FU1RBTVBbbW9udGgubG9jW2xlbmd0aChtb250aC5sb2MpXV0sYnk9XFxtb250aHNcXClcblxuICBwbmcocGFzdGUwKHBsb3QucGF0aCxcbiAgICAgICAgICAgICBcXENvbmNvcmRfXFwsXG4gICAgICAgICAgICAgY2RhdGEkVElNRVNUQU1QJHllYXJbMV0rMTkwMCxcXF9cXCxcbiAgICAgICAgICAgICBjZGF0YSRUSU1FU1RBTVAkeWRheVsxXSsxLFxcX1xcLFxuICAgICAgICAgICAgIGNkYXRhJFRJTUVTVEFNUCR5ZWFyW25yb3coY2RhdGEpXSsxOTAwLFxcX1xcLFxuICAgICAgICAgICAgIGNkYXRhJFRJTUVTVEFNUCR5ZGF5W25yb3coY2RhdGEpXSsxLFxcX1xcLFxuICAgICAgICAgICAgIHRhcmdldC5wbG90LnZhcltrMV0sXFxfY29sb3JfXFwsXG4gICAgICAgICAgICAgU3lzLkRhdGUoKSxcXC5wbmdcXCksXG4gICAgICB3aWR0aD04LFxuICAgICAgaGVpZ2h0PTQsXG4gICAgICB1bml0cz1cXGluXFwsXG4gICAgICByZXM9MzAwLFxuICAgICAgcG9pbnRzaXplID0gMTEsXG4gICAgICBiZyA9IFxcd2hpdGVcXClcbiAgXG4gIHBhcihvbWE9Yyg0LDQuNSwwLjUsMC41KSxtYXI9YygwLDAuNSwwLDAuNSksZmlnPWMoMCwwLjcsMCwxKSlcbiAgcGxvdChjZGF0YSRUSU1FU1RBTVAsXG4gICAgICAgY2RhdGFbLHRhcmdldC5wbG90LnZhcltrMV1dLFxuICAgICAgIHhsYWI9XFxcXCxcbiAgICAgICB5bGFiPVxcXFwsXG4gICAgICAgY2V4PTAuNSxjb2w9V0QuY29sW1dELmdycF0sXG4gICAgICAgbGFzPTEscGNoPTE2LFxuICAgICAgIHhheHM9XFxpXFwseWF4cz1cXGlcXFxuICApXG4gIG10ZXh0KHNpZGU9Mix0YXJnZXQucGxvdC52YXIudGl0bGVbazFdLGxpbmU9MylcbiAgbXRleHQoc2lkZT0xLFxcVElNRVNUQU1QXFwsbGluZT0yLjgpXG4gIGFibGluZShoPTAsY29sPVxcZGFya2dyZXlcXClcbiAgYXhpcygxLCBhdCA9IG1vbnRoLnRpY2tzLCBsYWJlbHMgPSBGQUxTRSwgdGNsID0gLTAuMylcbiAgXG4gIHBhcihmaWc9YygwLjcsMSwwLDEpLG5ldz1UKVxuICBoaXN0MDwtaGlzdChjZGF0YVssdGFyZ2V0LnBsb3QudmFyW2sxXV0sXG4gICAgICAgICAgICAgIHBsb3Q9RixuY2xhc3M9NTApXG4gIGhpc3QxPC1oaXN0KGNkYXRhWyx0YXJnZXQucGxvdC52YXJbazFdXVtXRC5ncnA9PTFdLFxuICAgICAgICAgICAgICBwbG90PUYsYnJlYWtzPWhpc3QwJGJyZWFrcylcbiAgaGlzdDI8LWhpc3QoY2RhdGFbLHRhcmdldC5wbG90LnZhcltrMV1dW1dELmdycD09Ml0sXG4gICAgICAgICAgICAgIHBsb3Q9RixicmVha3M9aGlzdDAkYnJlYWtzKSBcbiAgXG4gIGJhcnBsb3QoaGlzdDEkY291bnRzLFxuICAgICAgICAgIGF4ZXM9RixcbiAgICAgICAgICBob3Jpej1ULFxuICAgICAgICAgIHlsaW09YygwLGxlbmd0aChoaXN0MSRicmVha3MpKzEpLFxuICAgICAgICAgIHhsaW09YygtNSxtYXgoYyhoaXN0MSRjb3VudHMsaGlzdDIkY291bnRzKSkpLFxuICAgICAgICAgIHNwYWNlPTAsY29sPVdELmNvbFsxXSxib3JkZXI9TkEpICMgYmFycGxvdFxuICBiYXJwbG90KGhpc3QyJGNvdW50cyxcbiAgICAgICAgICBheGVzPUYsXG4gICAgICAgICAgYWRkPVQsXG4gICAgICAgICAgaG9yaXo9VCxcbiAgICAgICAgICB5bGltPWMoMCxsZW5ndGgoaGlzdDEkYnJlYWtzKSsxKSxcbiAgICAgICAgICB4bGltPWMoLTUsbWF4KGMoaGlzdDEkY291bnRzLGhpc3QyJGNvdW50cykpKSxcbiAgICAgICAgICBzcGFjZT0wLGNvbD1XRC5jb2xbMl0sYm9yZGVyPU5BKSAjIGJhcnBsb3RcbiAgbGVnZW5kKDAsXG4gICAgICAgICBsZW5ndGgoaGlzdDEkYnJlYWtzKSsxLFxuICAgICAgICAgZmlsbD1XRC5jb2wsYm9yZGVyPU5BLFxuICAgICAgICAgbGVnZW5kPVdELmxlZ2VuZCxidHk9XFxuXFwsXG4gICAgICAgICBjZXg9MC45KVxuICBkZXYub2ZmKClcbn1cblxuYGBgXG5gYGAifQ== -->

```r
```r

##############################################################
## Generic time series plot
WD.grp<-rep(2,nrow(cdata))
WD.grp[which(!is.na(cdata$wind_dir)&
                  (cdata$wind_dir>120&cdata$wind_dir<=300))]<-1
WD.legend<-c(\Southwest wind\,\Northeast wind\)
WD.col<-c(rgb(0,0,1,0.5,maxColorValue=1),rgb(1,0,0,0.5,maxColorValue=1))

target.plot.var<-c(\co2_flux\,\LE\,\H\,\u.\)
target.plot.var.title<-c(expression(FC~'('~mu~mol~m^{-2}~s^{-1}~')'),
                         expression(LE~'('~W~m^{-2}~')'),
                         expression(H~'('~W~m^{-2}~')'),
                         expression(u['*']~'('~m~s^{-1}~')'))  

for(k1 in 1:length(target.plot.var)){
  
  ## locate the start of each month
  month.loc<-which(cdata$TIMESTAMP$mday==1&
                     cdata$TIMESTAMP$hour==0&
                     cdata$TIMESTAMP$min==0)
  month.ticks <- seq(cdata$TIMESTAMP[month.loc[1]],
                     cdata$TIMESTAMP[month.loc[length(month.loc)]],by=\months\)

  png(paste0(plot.path,
             \Concord_\,
             cdata$TIMESTAMP$year[1]+1900,\_\,
             cdata$TIMESTAMP$yday[1]+1,\_\,
             cdata$TIMESTAMP$year[nrow(cdata)]+1900,\_\,
             cdata$TIMESTAMP$yday[nrow(cdata)]+1,\_\,
             target.plot.var[k1],\_color_\,
             Sys.Date(),\.png\),
      width=8,
      height=4,
      units=\in\,
      res=300,
      pointsize = 11,
      bg = \white\)
  
  par(oma=c(4,4.5,0.5,0.5),mar=c(0,0.5,0,0.5),fig=c(0,0.7,0,1))
  plot(cdata$TIMESTAMP,
       cdata[,target.plot.var[k1]],
       xlab=\\,
       ylab=\\,
       cex=0.5,col=WD.col[WD.grp],
       las=1,pch=16,
       xaxs=\i\,yaxs=\i\
  )
  mtext(side=2,target.plot.var.title[k1],line=3)
  mtext(side=1,\TIMESTAMP\,line=2.8)
  abline(h=0,col=\darkgrey\)
  axis(1, at = month.ticks, labels = FALSE, tcl = -0.3)
  
  par(fig=c(0.7,1,0,1),new=T)
  hist0<-hist(cdata[,target.plot.var[k1]],
              plot=F,nclass=50)
  hist1<-hist(cdata[,target.plot.var[k1]][WD.grp==1],
              plot=F,breaks=hist0$breaks)
  hist2<-hist(cdata[,target.plot.var[k1]][WD.grp==2],
              plot=F,breaks=hist0$breaks) 
  
  barplot(hist1$counts,
          axes=F,
          horiz=T,
          ylim=c(0,length(hist1$breaks)+1),
          xlim=c(-5,max(c(hist1$counts,hist2$counts))),
          space=0,col=WD.col[1],border=NA) # barplot
  barplot(hist2$counts,
          axes=F,
          add=T,
          horiz=T,
          ylim=c(0,length(hist1$breaks)+1),
          xlim=c(-5,max(c(hist1$counts,hist2$counts))),
          space=0,col=WD.col[2],border=NA) # barplot
  legend(0,
         length(hist1$breaks)+1,
         fill=WD.col,border=NA,
         legend=WD.legend,bty=\n\,
         cex=0.9)
  dev.off()
}

```
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


#Windrose plot 
A simple windrose plot, using openair package


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxuXG5wbmcocGFzdGUwKHBsb3QucGF0aCxcbiAgICAgICAgICAgXFxDb25jb3JkX1xcLFxuICAgICAgICAgICBjZGF0YSRUSU1FU1RBTVAkeWVhclsxXSsxOTAwLFxcX1xcLFxuICAgICAgICAgICBjZGF0YSRUSU1FU1RBTVAkeWRheVsxXSsxLFxcX1xcLFxuICAgICAgICAgICBjZGF0YSRUSU1FU1RBTVAkeWVhcltucm93KGNkYXRhKV0rMTkwMCxcXF9cXCxcbiAgICAgICAgICAgY2RhdGEkVElNRVNUQU1QJHlkYXlbbnJvdyhjZGF0YSldKzEsXFxfXFwsXG4gICAgICAgICAgIFxcV2luZHJvc2VfXFwsXG4gICAgICAgICAgIFN5cy5EYXRlKCksXFwucG5nXFwpLFxuICAgIHdpZHRoPTUsaGVpZ2h0PTUsdW5pdHM9XFxpblxcLHJlcz0zMDAscG9pbnRzaXplPTEwKVxuXG5vcGVuYWlyOjp3aW5kUm9zZShteWRhdGE9Y2RhdGFbLGMoXFx3aW5kX3NwZWVkXFwsXFx3aW5kX2RpclxcKV0sXG4gICAgICAgICB3cz1cXHdpbmRfc3BlZWRcXCxcbiAgICAgICAgIHdkPVxcd2luZF9kaXJcXCxcbiAgICAgICAgIHdzLmludCA9IDAuNSwgYW5nbGUgPSAxNSxcbiAgICAgICAgIGRpZy5sYWI9MixcbiAgICAgICAgIHBhZGRsZT1GLGtleS5wb3NpdGlvbiA9IFxcYm90dG9tXFwpXG5gYGBcbmBgYCJ9 -->

```r
```r

png(paste0(plot.path,
           \Concord_\,
           cdata$TIMESTAMP$year[1]+1900,\_\,
           cdata$TIMESTAMP$yday[1]+1,\_\,
           cdata$TIMESTAMP$year[nrow(cdata)]+1900,\_\,
           cdata$TIMESTAMP$yday[nrow(cdata)]+1,\_\,
           \Windrose_\,
           Sys.Date(),\.png\),
    width=5,height=5,units=\in\,res=300,pointsize=10)

openair::windRose(mydata=cdata[,c(\wind_speed\,\wind_dir\)],
         ws=\wind_speed\,
         wd=\wind_dir\,
         ws.int = 0.5, angle = 15,
         dig.lab=2,
         paddle=F,key.position = \bottom\)
```
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiYGFzX2RhdGFfZnJhbWUoKWAgaXMgZGVwcmVjYXRlZCBhcyBvZiB0aWJibGUgMi4wLjAuXG5QbGVhc2UgdXNlIGBhc190aWJibGUoKWAgaW5zdGVhZC5cblRoZSBzaWduYXR1cmUgYW5kIHNlbWFudGljcyBoYXZlIGNoYW5nZWQsIHNlZSBgP2FzX3RpYmJsZWAuXG5cdTAwMWJbOTBtVGhpcyB3YXJuaW5nIGlzIGRpc3BsYXllZCBvbmNlIGV2ZXJ5IDggaG91cnMuXHUwMDFiWzM5bVxuXHUwMDFiWzkwbUNhbGwgYGxpZmVjeWNsZTo6bGFzdF93YXJuaW5ncygpYCB0byBzZWUgd2hlcmUgdGhpcyB3YXJuaW5nIHdhcyBnZW5lcmF0ZWQuXHUwMDFiWzM5bWBkYXRhX2ZyYW1lKClgIGlzIGRlcHJlY2F0ZWQgYXMgb2YgdGliYmxlIDEuMS4wLlxuUGxlYXNlIHVzZSBgdGliYmxlKClgIGluc3RlYWQuXG5cdTAwMWJbOTBtVGhpcyB3YXJuaW5nIGlzIGRpc3BsYXllZCBvbmNlIGV2ZXJ5IDggaG91cnMuXHUwMDFiWzM5bVxuXHUwMDFiWzkwbUNhbGwgYGxpZmVjeWNsZTo6bGFzdF93YXJuaW5ncygpYCB0byBzZWUgd2hlcmUgdGhpcyB3YXJuaW5nIHdhcyBnZW5lcmF0ZWQuXHUwMDFiWzM5bVxuIn0= -->

```
`as_data_frame()` is deprecated as of tibble 2.0.0.
Please use `as_tibble()` instead.
The signature and semantics have changed, see `?as_tibble`.
[90mThis warning is displayed once every 8 hours.[39m
[90mCall `lifecycle::last_warnings()` to see where this warning was generated.[39m`data_frame()` is deprecated as of tibble 1.1.0.
Please use `tibble()` instead.
[90mThis warning is displayed once every 8 hours.[39m
[90mCall `lifecycle::last_warnings()` to see where this warning was generated.[39m
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxuZGV2Lm9mZigpXG5gYGBcbmBgYCJ9 -->

```r
```r
dev.off()
```
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoibnVsbCBkZXZpY2UgXG4gICAgICAgICAgMSBcbiJ9 -->

```
null device 
          1 
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


**Energy Balance of non-gapfilled data. Slope of line is energy balance closure. Ideally it should be 1:1 Net radiation - soil heat flux= to Latent heat +sensible heat. **

#Not looking great. ?????

#Add heat storage in soil!


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG5cbmNkYXRhJEVfbmcgPSAoY2RhdGEkQ29ycmVjdF9OUi0oY2RhdGEkQ29ycmVjdF9zaGZfMStjZGF0YSRDb3JyZWN0X3NoZl8yKS8yKVxuXG5cblxuc3VtbWFyeShjZGF0YSRFX25nIClcbmBgYCJ9 -->

```r


cdata$E_ng = (cdata$Correct_NR-(cdata$Correct_shf_1+cdata$Correct_shf_2)/2)



summary(cdata$E_ng )
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiICAgTWluLiAxc3QgUXUuICBNZWRpYW4gICAgTWVhbiAzcmQgUXUuICAgIE1heC4gICAgTkEncyBcbi0xMDkuMTIgIC00Ni44MCAgLTIxLjE3ICAgNDguMTUgICA5Ny41MSAgNjI2LjI5ICAgIDg1MTIgXG4ifQ== -->

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
-109.12  -46.80  -21.17   48.15   97.51  626.29    8512 
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucGxvdChjZGF0YSRFX25nKVxuYGBgIn0= -->

```r
plot(cdata$E_ng)
```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJjb25kaXRpb25zIjpbXSwiaGVpZ2h0Ijo0MzIuNjMyOSwic2l6ZV9iZWhhdmlvciI6MCwid2lkdGgiOjcwMH0= -->

<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAArwAAAGwCAMAAAB8TkaXAAAAXVBMVEUAAAAAADoAAGYAOjoAOpAAZrY6AAA6ADo6AGY6Ojo6kNtmAABmADpmZmZmtrZmtv+QOgCQOjqQkGaQ2/+2ZgC2/7a2///bkDrb/9vb////tmb/25D//7b//9v///+FKoFvAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAgAElEQVR4nO2dC2PbuHKFcdPN3tukbdKuG3edZP7/z6wlcWbO4EFBfEiCeU52bYkCAXD0YXAAynYSihpU6dEdoKilIrzUsCK81LAivNSwIrzUsCK81LAivNSwIrzUsCK81LAivNSwIrzUsCK81LAivNSwIrzUsCK81LAivNSwIrzUsCK81LAivNSwIrzUsCK81LAivNSwIrzUsCK81LAivNSwIrzUsCK81LAivNSwIrzUsCK81LAivNSwIrzUsCK81LAivNSwIrzUsCK81LAivNSwIrzUsCK81LDaGN5EUav1KHi3rY46oggvNawILzWsCC81rAgvNawILzWsCC81rHaC9/f3y0bcpx+bVEcdTV2buPvA+5q+XB686YNV1VFHU5IeRHaB9/d3Q/b1j79XV0cdTQm+Xi3WXV+ffn39pg/fGsaB8FJtPRJeZl5qlR4J77vnnVIvPS/VqbBEe6DnPRmHy25DI+8SXipThusDdxvuXh01qiZKO41Cdu7mBR9SHTWokmDSfQ54eZOC6pEx+0Tw8iYFdUUXu+DM5ku0HtPLrTLqEZpYhYQbae3abrjzTYrbf/yI+ogKdqHCwvnwVUiYeakHCOxCFdEL1tfo5U0K6gG6tj5LU0qex4Q3KahH6JqnTQk88Vwl3a1tKMJ7cF1ztLgb0SzT3VhvwYdUR42mq8uxjv2GneB9+fRDfv6Z0j/+2qQ66qPpKpo9W1L7wHtm959/hU2zFdVRH01Xb6ilHnx32uf98g7w59NDbpVRFV3bxz2v1U4F5rPzLc316pRvp71e/iTF4VWD9Mo+brpwm65slu1kG96z7iszLyUtdzu7FZbCv/mqu/vQrV9fP/04p9631oqN8B5ELXc78ymBJGZ4HwHv6dbaWZ83qo4aVU142wsy/ZzOpcCMNeY+L7Wr/CM4GYSpcsxPSeHXj8/W3d2JzUR4jyL48OP0pqeUwBfAMT9l+peyUpWqu/uwoQjvYQTJM+mXix1wLLNVneEtah3qNXd3YVnP71Qd9cyyXTFjNKWwYrM9Xc20lptnjQPhpfaWf7oR4A1QJs3GlqY1NRNe6qHSXOuuAS2BHrOthenzZFHtirt7sJ0I73E0AWppdnqid9HEk27cYrhKL+Gldle5HEMyRQK5kpE7c6eN8FL7K+TOIq2K3y1GdoN1ILzUo+Tp1RdnbnJFakbX83HrUxCEl9pfsCxzBxyTarytVv5533a13e1vJsJ7JNl+g37FG2jJcJZik2GWXcJL3UEBXvO4lmKtWGYb4FG72u72txPhPZR8vwG2d9E2wPfILu6o1Wrtbn5DEd5jyeAU3/G1RVtx6628RUF4qccq9662gwv34MxK6H/MvNRTKqBp8Cb4lIPu/9ZP725no/7uUx01kGB/QT+Do0eTfbUXZ36WgvBS95FvhQnetJhSq+2die4u6FNpw0J4qbvI7lDoJ3vxDprlXbhLIf4hM+7zUo9Ufo8tfvIGl2aSwqvuIFqVdre+mQjvsVSBFz5onvSuRXbrDZwvP9tA3V3JfwAIt3JxUyzAGz/1AN9rdXd3Yv117Fgd9aSKdx/8JpqkcAhYzn7+h/BSDxK4hbj1Bfti5xLqdcH0RojbtXd3YzMR3kPI4FV7IP55XoP4XEQ5DgjPr9cIL7Wn/EMMvsWrGGdYujnO12uEl3qIzNHaxxh0D9escH4G3BmGVN2qvLsXG4rwHkQJ7GwCu4BcY+HMJ9hDLtiox8hXZ4axwB6DFVObEPjICsVqu9vfUoT3UNIMC67XHoQsax+FhHNDoVhrd/ObivB+dMVNAl+mib35thwT3UILh+KZhJe6mxJkW9tBEMG8a4s3/AmgDPrSW4Q2ujuzqQjvx5b/7Flrw8A+xKBrtsqurj5LdWAIL7WHfI/28uz8NZZwm6AbD7WtBq2n2kh3bxZdw72qo55M0QGkSuoFT2HwOsxqffNcnFXR25ull3GX6qgHqsZWgBc2drPTjFXdRUuepFNQteHuHt5wNfevjnqcKknVydWfmKjtF2S7DbCLZp/KqW0/xJa7u7ihCO9HUXkDLDmXekO4xE8NMWRks792R4OZl9pVBbww5Qss1JxAfcGyrvhxPV0I7wdWaxFzd83Bm/CIlnJe48cWnFx3G3FDot50dx8305NEflhVNk4fpbwrfsMMc61xGvbOwFAkPFl9Az+Y8wHVfkMfoHwSsLQbPnSjBRFezKqOrfsFO5PwfiA9Fby5gMAALx5J8L89SrCOgxFBz/ux9MzwQlLFO2PqA8JaDe+92ccldcfXzyS8H0pP5HklMw64uYD7C2pj8UZEuHFsViNmXtqGD6en2W2QfCS5u0XXOj2BXicD2bcblF68L0F4qf2U06UrLsF9Xr8nMRVKOaV+kzjujhFeaj8VdGULNjO5YRHmmRkTL2JrZkIavOwE7+/vl358+rFJddQzq/i0uN0fA3AFnYAu2zJ4fatB9Lh7i2rD3T28Qa/py+XBmz5YVR313MpTY8y8yXkEF1zCi58rs6QdDESt3e4O9ur3d0P29Y+/V1dHPbfyzBs9r382DG9SCBzNqknGbLg/XG24u4f9+vX1mz58axgHwvtxlEyXp3DIPzgWLbDfjyishG7xJge/5RuYeamVSiixzQXbTgADDGsvKwzw2nbD9NxrrdO7l+edUi8974eXT+3JJn6kTqYE6iCLHQrwQjYWfzTnHHbabfj19dL5Rt4lvB9HJa1mWt0p2L1hv6WmhjdusWn2TbVBUTbd3cdNRXg/gnBa98eCB+OqC3xxA0k3HRIqriFDeKnF8tsKEV2Y9KeCtgIzEO1JKuoUSNXO7v3g5U2KAygkXMQXXppKTvDiCs73crNK4ati29jr3WvBxpsUH18pGlPPwT7va8ls+k+eW8WfaVnYNUs+Emod6O7pDVfFrbJDyD8BFpMwWFYrGbOtcqvwhgScu+NafrZqe3var/ZNCrhCanRlbgHfWzcQWlQXbnbbwjGAmxv6vdgPvh+8zLyHUJNd86qhrCEM9yJwqzfAavktvpp1oLunt1wWb1IcQZndDYnX0PSysLPmvlefqU8A9u2llmvgTQpqsSpLtckZuKuFwuL32eDOhb6odQSoNfs2XOZO8N67OuoBiuCKo2toZiXxxpsks7+CZgF3Kmp31UIHunu65PLuVh11f3niFcQ3B1I0z+oh/6gYWluHVxDeVtK1eju7ert+/vmt9RLhHVueIzPXUHEFzrIS6akW8rQb4uQHZA6VnbbK/KL4ed6PIkyCtmubZUnkGLYT7BTDFkqpSUZnAUl6hpV9Mu+0ycDM+9yanZOLwpJvxULalYlU3ciF1ZvDm/wGsSSDWa1twjvGQPnd4X3Pvad9BsL71Jqfk4vCSpaeZZM8whm2vNS0ukFAdgF7TNbJW5THwCvy8o+/CO9TK8HXjtK26vJT0SfE/S1LspajYQsMi4mNIbAM3ggm69YVdF+qBEPbRPOk1/SF8D6zboW36hsM0egijFVBZNHnJky++HEIBzg59vVuLsi8F0P7lr79+tq4fXbRzz//jfA+sTrhjbDh0TzzQiGwvPDMDDGWsk5gWg5NN/t5O7y/v38+f3/94+/WBxesZDs3E97Hq8vzKoQGI57uB80yOLoSb5h5WgaLYJnXzw0rOTxev4DuKz1LPzL29ulH6+fab6mOWqaWD9yyjsAiJsZikxc2wEK2lbAthvXhfpov53zHIuRvhT7vX/eF6gP9yNgp8xLeR+mmnYLi5D7wA6Gwb4BG1ul0F2DbD+IYOo64svO1WPLdiVCpPk+1q13jedVALBHhXaXbFluVkztODfkyzPmYEPNvWEB80YXp12v2nQQ4EbfcYNxUurwA3st+w3vSfVmeeAnvOq2Bt+tcz46RVkietX0EKwYmObDvKEMjsVNYU2itcSXdl7yZCO8q7Q2vsTYj3NjSL0qcb1IE5yrOrRjI5nrNzKQS/WqPCe+YWuF5O+DFqb1MnFWSBQ2tA+d7EXAo20LAElPzanh9GG3kea/+WPtt1VGL5Hnq9lNlJv7KaC3rttm1+R6/GoJh5gdIvSuwShMgGQdM40K6r/iiNVb39nap7TUDPqTFWc8AeCFzsF+QoCmzCgAydmVCVAQSNThsafByO7xX7qvdWh31TArrqECord7wZdhEMHZxrTbBGH2uH4ZmQxParJJsPav1tvuyToKfa18hwvuUaifcfE8BXsD9sInBsOTrgNdzbBguWrdsBe+a3d0F7VL3VKQny71VpmGZJo5qCsstwK8NL27ser6dRsJW8J5uT9wakxXtUlso9S7vInRtZisIa84FDG3bwjvguRRbzTyK1Qfpt9bZ7svXB/aRSO42DKPZ/YWpCGxTzfAq5RFYbmkdsG7LthfQUYfGHXcfEW6Z651fkHk3EeG9oxJ8nSmi83qvBDNkgBcotDolQKjmWqBNtSCYhmfH3Sp4f//3X72nL26XWq9r8AKM7nk7d8rgdDCqwLRl0QTAoqEtlml+siRppt3ZK+ooSHjHUAveHLaWcZBIY5ZZfa9BLWqRvgXWdbb8sqyawj+oUK44dcJ7BOVzr6e/ZPtUSVGJZgDZTfF4nqBxRywBhXEFKHHLQXMrlPN8S3ipfO7F3aqUwQusGZpOccGv6N4YZmJ3sZBztTbR1IuoZz7Zn8xfVfflV44R3iGl7mB6ojN+svk8z7Mxu+JxN6ZasYFpKdXBRMcLD3GzwSYJGwJXL6T7iqMI7yN1LS9dORGXRDpzuzsGRusrN8dUM2x2stUppUkW8MBOabZW08Q9cyHdV1w5RngfqCtv7MyJNi+Lg4RTPjKr66gwp9cmeQF4cZPAEcbdBkjS7pG9YeuFeEWNEPRdcuUY4X2cPDXdfCLiaTXYLO73F2A2LxMvoiwZvE4x9jMMEBHnM3kPUsAb3XPjUrqvuRDhfZx6VuP188yMAnFYLfxXl+fhML97wkUmE1jqBpZWENaBYsZER1rtWrov+sYg3be64wmz2+XhVZJDCm3A6wxFdj1Nloe9FhgZll1LOwtYOvngG7CL1tXaxd0Ib/vv/NwowrtSeea9ZoEVMiVGwFba61OSC+DCYzsJ8Aq1GK8+NMAwKKhmTDTRe8Gpe76AdIhr19QdrPPXM7yX39xAeB+q4CUribgsHjcRPK3pmZY2Y3LNn2fLN1/7icPryzWA19eJ8Wy/HCwn7lxiT8NFdQfrJML7NErh/zq8ni3zmTo5NSIGS0y6gVpYoRU4QzUpZfBafoUNDBw7WtBxnvYbzGHo6CiRIbyDCuZeMf9QrL5Cwsxspp+SpeXWYi1wjSd6NfAqruH8bJHArrFv7epIygZTeXHVI81gnUR4n0U4LYvBF4soKpD01FRCDWFRb/kvpEn7Eo85fLrEE38dNhE8X3s3oV7Ntoa8ty9wXYT3wyiDN9lbHYuAcwSOnC77v0yy0SCoG4DZ3OZ3yNlZMvbaddHlPU06YaTwL1yO5+MaMYR3VBXo2dHLAwU0IOj0oe0UAf4869qR2prN8FY0BcpCV8BPeBqNYy24hOwCHflGCLpjRXifSQaJIScVPAzXsFRTcNS4BnhhStfkGvOgewhnM/oSOyqGrOVdbQEHXIodELHOVamFAn2hOn/t+CNVt1RHrZC/rxMPl4cB25gv4TsmNnCqYJMnRr0Q+AVDWKr1CxIMcGr/0C9AJaIupLzCRgS6Q9Ud1EdUd0BBmorpTqSGlD2DdRNkWFxs5We5wcUXg3cOx7VTU9cCo8a82ImeYdFDd4WgO1a9BR9S3fEEVgGAtSyc0Rq4Q0Q8C0bYgxFFcu1FADvKunD+ZgnbHHryfuNXT+St9VkZg+5gTd9fTn+H4jVd+VNA27VL1RXfeE2CCG8wBe4OYLWkR7EOPMHNAmDtgyRUb6MCWwdDLQYvTBPhGqbMq5fSQcit8L7+46/3tdr831i7oTpqqRzVBGsnz8h5pswAD4b1cp7nW8ipIqEm5FS9rzYnyTtlZQK3oQPRsYOVTm6bu2LQHaxfXz/rL3x6mf9TQFu1S9VltiHM3FJjDXG8nCsCpOS52tZUajDgtdzuuhu2QaSdgJ5YktZu55fidQbmr0FyI7wvISorfl0k4V0rxQKzXMzEyG/KXpGUwSaRQDO7QJQ9FKvRnYjNAoYtfLPXLJ0XV6K52YbV+ZUrIeiO1fnr+febnlwDM+/DFbAzksGklgq+00gUc8o2FGYr8dpEdDtB6RMcIjgzKOAp9F6gbRt/yV4sQY8R6A7V5dvLpx8X1/C2Ju8S3pWKb72nSmfR0YzsAiH2DPK3HgFMJTyCuvBE70yWvYP/9X57KoaBYw7F0vo8KLfCezIOl/2Gdb9imvCuERjHOLWHdx2SqGZdm5ynFZumQq9F4D88UrALJyTsV/AHPjnAP3FgceGY9aLDOtwM70YivCuUwlcHSvNozMcJmRCE144BlcndQ/THgVoRA9Hyr8ATEfDEPnp0DGk58UEEc4do70TEvzfj0B2wzUR4VwjhjcZUnIMsORooBovRgfQoz55sA38OFPgGgakA+xCKKp0lvNjj5NVlZrgdh+6AnaSfb+BnGx4lz2AiSBxylKqKk73iFb2wAPruOcRwFW1EQbUsi437O2y9hWGEJ2U9zMaBWY5aHLoDZo9e/vj79TNvUjxQ7g8z2yDgIKvcCk7zvkoTe25pzpZXiltYmcHSKuMQl2pQMvRJD4u5huhLQkqGThZx6A6YPjjtlr29r9leuVX2IMGkX/hRyJ0FNW4lHYoUTa+3kYpDMKGLDyAcDNaE9RIqcnI9f2tKh+EF12XdkNiP0KHOiE06faT3579+nP9fLsK7XG5n4Z1HjxkdLOIDHgGzp+ONLwlwJmhE/TRrSwxlr1CiozVLGyotBhkyXwE+BKI7Yvrg9FH0X//x1zy8V/9KJuFdLuDF5lxxDywtw5tsPWTsieMv6poVF8ip4oumBPzCwWRcRtoAQRg0cCkOPeJrI9RbqgaiO2Kq19MffP8yaxtsF7h5K4PwLhdm22AJLi+WxFoeFcu7duxyACb+AJoNC/Qa2grAiyNGC1rl0b0m4NArc+9iyVsc3nASBKI7Yv7w5fNpx2Fms+Hyc0JntRAnvMuFHtHNgr6oGTbS7YgATU6UHY0Me/XWqjePr2spqDHZiVA0cjiNuQJtSMV+ejUQ3RHrV8cvhSK8y4V5znC0F7Pk6/7T+ZSMz4ANFILJ32HH6gXhDkleeykAc7LqtKt6HDO68mz44ijJAtEdMX1w8rsnzfwAJjPvrgJ0/H3W17KpFhgv4Cym8wg+pEl/zVDU/6xVxc/MMpa3jA/Eu0G2axEo4PxKHJ4QiO6I6QOF93XGN7zqz1nQ8+4hd53Ba15ewiwqIYelmIMjjwW2U0Oe+9R45IUuFTp37ozFMdS+gdXBMSPeM8zv3kGp0XsrvPCB3rlP5uhduOaijvCuUbL0KZEBQZ7RX4DTnYoBgDoQosVERgFswRO9P9aEWOa0rhrDNgPAlOAdt9e8gz6casgsz7zrRHhXKbztSedwcBKTYQ2HfBr28oB5YMVeixY62NDILtYdvYZ22H0CTAhWAPO1wQ4Lt03g3UaEd5WCuzR4bZ6vwpgQp2xmxrxqGwDJCMuyoJeeOoMvoeuVSF3SMaUJGoxzyq/PMrmm403g7flgDm9S7Ct//wVoEkGaAaWAntvOGpbOFpIaQA9uF2sJXIJzza1xLFRLq/66VbCB55WuD+bwJsXe8rTr9F6OX1524HI2xVKu+9GQtxXDlHK6oznBnmATycaMgomp1/0ruBhP4mCI9fxYIgahO1qTOj6Yw62yvaWMoD/IlkkFUFgIeM9SalYgq6VMvUBrQl7Be0PmFRgxFSJ1LJlx1noaUegOlz7o+GBO+yYFBINaLrOOySnAtzkhjNlDKcGEN8VTX1iG5RRDweCdoTNTWYHM672o59LJ2yrehsl28HZ8MIeZd1/5e2sLH8nSoQB2khIUDxlUND3ihH+pocJ+HCWOYMJzYa3nJ4pVmjLXgZdlwGcXtB28fR/M4U2KHaUzu8++SAmygwk1ZQyHklpDlp0hg4dpEyhNAcqk3sGddEioBmZ+SQk64L4Bzm/EoTtgk65+MIc3KfZVhNcWWv5W24opeFDIZxE2BDYy70lVky2YFawqubu114zB0kbjNAFXkLL+SV6ujEN3wDYU4V0jJ0Kf2nM0nLict/kYDAJkzYQDoGBSNwgkQQuGM7KI6FuCnYpix1JCBmB8hfFzhRPCO6AMGH1q87pnZIcvRUk+/4MDxrzoBayJ0uT6YfHewD+1NQovMmr992Ttg8NH0GwcugN2Uu9vRrffgdr6+A7hXa5sFeMJ1FwCkpayx4KH4DREBzywxP89/5pNCY5bR0FmTOy1MIzCJfjBhKZ7jpQFmfeyCLv8wrKGTr8I9fwLJQnvDorwIpR63LIhvKo5tTAXKczphWMwhvErVIDtAbbGeQpdsG5ZYpbMD+tTuU7v7fBeflVZexNMdKvs9/fTrQzCu7kCvCmAKDEHg4WNeS/O3sqvRILzRmEQZPlzSvc2CtxsO/IOekj5Ao4XPUjKCrUD0R0x8TsQMx9G1yKnG8mEd3uZq7XvnlDNM0qNNMUyZEA7HXxGqsCrX+MIADNipPrU79UqlFVDjSk7mybyjhR96gzYWXoHYuZXnNpNipfPhHcPJQNFYsKyV2vYGpOGrmTHDckKMu5LsIjil2As+Omw/hLoKg4jcXiDz05+VU1YFnneU159nfW8E7Lt7WDCu0LGkQAIYaJPgFOGqKdCWxMFmlrs2jGY2J1LCSkXugdnltsNPlcA+XrAXHKTlgXwXrYc5n9fjt5i+/2d8G4uS2oAb8ZbzKEAridZAWYnHKXAKrRpnqHSaNGcnpWwQj/Zx414RxxcuAi74kYguiO2nQjvckHKQ1eJ+CbIgzWIzSIDWFK8Dk3qV0/PCqG9juMhIYPixiaca8tES70SqvHsTng/ilLEDgyuh7V0tJDcMBFK5Dd3syn5N6U6moypOeuXnW1ZE1+UjMgIOTgay7rT8KtHojtk/vC0VFv5W/0J72JlkGUbT0Zv7mADvA6/7QugfXZyRKd6s6uwLvOUiGMAoc6bl3i2zx9eVscWHpYGLwvgvWwzXO5BLBbhXSqYhScOcaVkNIVci45AgqlwivLBIDhI3H9E6L1P0B5kXYlu2F2vNmrFjGVDWsqvlVB0x+ysjn3eW6qjbpSnqdzRmoUszKbOvpJTm+rgAoWaS/PXdZqfOhXwNbcxveRnq7X10WFXAzbFnkDN7VB0x0x8E3ful47cUB11qzydRYeolhQJCEVEtCxCqYutQGadVwe+hDfiG+BNcX7wOrwc9E6f2+X5hdUi0R2yiy7bYD//5J+yepD0jRXkKSBjrhZAmM6V4E5h5sYR4OwEsxAGSYI3URMpMI6NyUQ6VGvTRDLG/XwoES8tD0R3xPzhzz/f65q7R3FbddTtgnwbnKmUKIRJ1y0E5L+YMoGWDFj4No2LqTbdD8CTpuagAWPXkrCdPJUN7lhCJ6u5dwm8W4jwrpKzEJOiAFICnMBpMMVrkkZOwRMHnLISkLL9fDAw2A1/BYDEEaJFzTLEZWV2ERCF7nAtjfNdqjuYAKw4qYtTM5UDXt12mvl09kqkqoomBC0AZl03rlbI832WYXHM6KWppwbXUkOG8A6owCz6Vfe8YeGjpfSQAE9eXU6onxsfhvfOxkTEVqbhk0IhtA9Wp3gHdSjh4s4GIOH9EMJcGowDuFBAw5gCZhRCPA4GAQ8Gfwp1WVPWCxhGErnFktkYsUnCRh26EBt/VWII73AybDNEJVgGex4TLJAPGTXUhiPDGXO6sV5MkYIlBWpwFxvGgFIPlPtgwau0ay4i0R2yRYG+V3VHkgOGZKTK+x0MguMJ0GJCDIkOz7K0CP+JYCf0QIrH1FCLm5Yi/9vJDqkPIfHXq5HoDtmySN+puiMpGoVgYn1BlizbppAFPS0qPuCLjXdbgcUHAd6QJi8dy6yz4Wst4DiyPpq1wFWb+1/xgmUkukO2qQjvcvnSaUJDxN9oyQnKTUGYl40XQ1zr15neG43w+sjB5Jo3bakVfIqPLmXSKfYhBGah4XgJ75ByEs01hve/ho+xq18MXpzs7TBM9NqoewAn3o9Ysqxha6fEweTVW+qGhC6hAnreDyIkAB1slmYjj4F4cMriTjPyhnBpq5gr87EhcehAiteTJcCr4+Ncn5sD64KPIhHC+1GE4FgWDAkUsIUtgMC7kiaOnLiHdhcNzeIxZFTAccS2/bF3MkPbr6kw69BFwvtBlHlLmF4reTdLdUoNYJf0QLG6ypsVsK5i5+lhiXQCtu6lw6Bzz5t1frpI6DE970cR8OdrpkBdDV2budHtCppdYCd3DOLJGjsg4DsMstCyddWADx3Ei9JGkrpnsY4UAymc1BWyTUV4FyuzjpbFGqv9LBeiKz3XBmVy4xkahXWUdwHssWXYShdwHYa535uCMSBwRnOtJrMvLC74kOoOJae3mW2b/Ao+EEy8nswju8kXTnmlYI8F4I2rtizxBz7j/3rQTPmM3Z1/YXHBh1R3LAGG5dcKtJJqr4shhS/pLB3SItKHpwWvXbhicXa9CBAs3oxeVIIKwqv1OHQHbFmc71TdwYTU6dInElijuIQ3ICyY9SzZ6pFUGGzYLEDIFDtnvJ74pYRXv07/2Vov0fN+HJkt9USWW81iire8Bgfzc6AiIwgzq/Hl8EGPEHBd2uU9MUythJ5uPRAk3+1MMw7dAdtOhHeFAKGm460lX4mIB3sKuwKONWTAWI/VYF2CZOq4JXxup0B3RLBCgdOw4zJBXYtDd8A2FOFdIYdKU1SFYFgLORfBW5RbA2Ls1mwyMm0LLutT8vnAJ/yKp47ZNk/OhmroUaoDQ3hHFLzRTnEBL3hFADPimBtlXFDl+Ep4GRyvWW84Eyf8OABsVGlGzY2P91fwXyUM3fFaEev9qzuWHAwE8D8AAA4JSURBVLYw6wbMavNsfN3wz45Ams6rTOIwaQPJknxCGrE9pT24Zq8teJo4WIx42oYPIkt0JVz4dntxfGgYJqmcZ+eaI84bMQJtc2FaYGWDSSAVe1PQbYGGoAVN70XTtUB0R2xhpO9T3aFUEpu/1RPfXlofiYNU4F9UESoHE2qcChqM0IBvP4TqJDYrqYQXII59qwWiO2LrAr5zdUcSkhUJiQwYTJAIC55qs3SY2SNQsMFlmwWeKMHCireq7lWwU8kyfIA79giPViPRHbJVAd+7ugPJkhIAU3MQ0QzndtOXXTX4jfLw1TOsJ1f0zIK8whNI+LUxgSMNv0LThPeDyBGMC5qM3ZSA68w9VnCNZwtkRSc3JF5Nv4Cdr9nMpniNXg6tS7VPUNBeaoaiO2YbivAulaVFMWIkwzfHOHrLSn4Lk38ESs+V4LXFPYCiHb77ZoMfCGncWsX8a2MhI7rlGwjvcMqBzZiANz9wXEBTS3z16Txhw4YY0om2FpoLvE8DKBiYAl/zQWK12vEyEt0h2yTwe1V3KCWjyMDIUMnJyRkHOLBEZQAAN8qkel5g28qFesQr8FGQ9U3gP6vEZwa8wEoguiO2TeB3qu5QyidxT2QVWusP6+m5yLriBjZQlw8TN8CGHaZmP8mNgeRNe0XYHQlbF9VAdEdsMxHeFcphrS3Yah445ySnOmN8amyCx00rJFZsWSRru94F8fPdMiOtoWa73BoxhHdA1aFoH6wZiAL/YrY2yARSa1GTFwomuNodzbnod9F4QF+8flHDUolDd8A2Cvw+1R1KTg0umZq5Ns+DOjXLvNfQtZPYf41Rk6yySgHBMrA+c++t1vlcvz/18nqsEojuiK0N+a7VHUkFF5VMmnxdZU+dI1FEcp/g9Yq5T/HN3AysvLlixedLOP1a6WXRi8w6z0WiO2QrQ75vdQcSvMeATTZPZ342w803rAAt3RWYkLJngtO7WVEENGn7YeMrb936GnqkV2SlbF7QuudC0R2zdSHfuboDqcQS6ageiQstfTxVhoPAUu3lNU+YhnOkD+gXr6CpOBckdSOht2EeaRqGKRTdMVse7jtUdyBVZ19kFHlKlr70uaKoM3YwuckXSAK2I/cMCJ+3VNR3BWT3L0lPtw6jx2mjQnhHUw5ria8/0PKeVLNdtQw1s5xhN07yAaDwidtaCWdgm573wXJA8xIzOM4TYSKohaI7ZmuDvmt1R1KBbHUXyzKWF0mOA2wk1KrzaRudssNWIhZPQzihQ+FF7FY+6rIJoRmJ7pCti/jO1R1KVdqqBIomxHBWJc8hkMqUu0/l1cmCf42Ka6hGKqeGqqMuv5ZGILojti7gO1d3JJXTL7CEBy6Fz18RnGkboWmd7UXNzjmDAnM9LKxKVCs1+yDIUm6eriVBd5uR6A7ZpiK8S5V7S+OtSFfJvEPAIyc/4zKcXyDpy7OU5fNYLzSb9zMmZRwajq1kPWmHojtmG4rwLlUV3spySQ2DEZNN2DWw8ioryRlgK5df6DvaaR0fBNOs7dbKt0LRHbMNRXiXqrHIyp7miy6Z210rngBXCqsExny555taxfZWu63cdCPQAWVvvQYM4R1ONQZLF5lN6/XzSqAiQtEJ2HMzwrCMy3zv1NGq9ahbklg8P16ll/COpxKGiK8+RcSurKXqr9oSL+MWsi2uwXBnV/sZ6i/y6vw8glu9ifB+DGW4tcADwCoUxTI1ZGuViwIqzlfKUMXXi3rqXkIqZZB0wvtRlCrKgJY2fg3lI8JTbQo4eqo0OypqSuKuWiujogvxyssTROJJtUh0h2y76O9Q3YFU5aI8Wu4wNDJ0tkCqru0E9mezrJrdBC6O13oaikh4BkViBq+GojtmN0X49/dLk59+bFId5QoTakvl7IzuEhNexm69FtszTtMmQ55eL2yjlciHU3mzI288HAYPP9VdC0V3zG4J8Gv6cnnwpg9WVUeBKjP8VZhrBjnSMVOHpGTACkz1ZWqcqcZtReZkr8iWdPVQdMesX7+/G7Kvf/y9ujoqaB61gEu1YA+wXlZTPc7u+cm2BZG7hpqTaXa0cQ3qqWuR6A7ZDeH99fWbPnyLxgH6RS1UF3VVELpyXaX66dTALNIpwTBUKmu3W15NDe/zZVci0R2yG8LLzLunOtirAbLkJPC44VM/jRakcqzZn9wgt0oqK3fbKntNU+ql591evfhtIdtkgN2GAtGFPepZeqrPljvC+24cLo038i7hXa5lpGSU3VZL3DYucmXTXff1av5M0d27Wii6Y7Zd+Heo7kC6nZCF0kW+r/hbdKXgiW9tobauw+r1IxSVUHTHbKvg71LdgXQrIUundU2K+X2LlrGdW5Y1+iLVc7JDM6wQ3tHUQciNDHUUbTW7sjvVHZDWdkMlFN0x2yj2+1R3IC2lZM15facvsQ19dyrueoft7tUdSLcSopgsV+/JfcYhq7bjFGnRS3hH0y18bKTORm/cwmhvs1WcRD0U3THbLPp7VHck3YTINtqrzVusdy0S3SHbLvo7VHck7QTSY9R5NVKll/AOp31purNW5V7CO5z2I+kRWpN6Ce9w2hem+6p/I4PwfgjtCdMzqxKJ7pBtGX/Cu0KPhugxuuOnyu5d3ZH0aIwepFokukO2Yfi3r+5IejRFD1ItEt0h2zD821d3JIV39FEo3V+1SHSHbMPwb1/dkRTe0QPhW4lEd8i2jD/hXaOZt/eOLN1dlUB0R2zL8BPeVfL3M76798bpvqrEoTtgW0af8K4SvKHZj8zcnag7qhKH7oBtGX3Cu0rwfuIPpC//Kd4hVIlDd8C2jD7hXSN4P9eTd4dsvVELlUB0R2zL8BPeNYKfQZCAcuS6G4lt2NpdtUB0R2xTEd7lim9nfHeXILHmN4c0Kt2yMqu0DER3xLYJ/E7VHUrx7fQfqNEXexB2qyyyefrdJ5dXAtEdsS3Cvlt1h1J8Ow2Y/NU5ipBdPeXGDDy33Vx48Zt+CrldbR6I7oitDfmu1R1KSVPl5Zlk723y3IvPpi+wO+EnpbBxkX8vGLzyQ+uS70TLJsm4EojuiC0P9h2qO5ZS+HR2kmY4y7d8Msb+tVZtJ0otIsNLVnVKczNBR6OVy+sOWG/Bh1R3LGXvZvWNbZ5qX2beAwcm5+c6bjo+QmovDMmCTFzpZvdVd8fnEdUdS813s//ci0+42kKBjvJb1AWlm33EfFwzJWjgixcJ74dQOxX1n1xxDaEUfC1eAZQdqxxz3AHBxi0f49CwsgWxWKDRy56L7i34kOoOpTwb3nSu3+CYhdfcRa316tOsU/UacNgYtFPSxUrAb8yMVcI7nmyGXXSuV3CljVvrz06p1hDyMYCaHOic1JmhSnjHk6avJ4O3mZPDQWy4QmXZbqo7EK2sr2e9BR9S3bE0zfzLTtXz59mFr9sqZtWykaJjafLZtbq6G+3v3wOqO5iWOl6btx8Hb9ZOx2WkZjHCezD5wn3ZbsMD1CSc8B5NqQfeudt2zyPCe0D15NWlvuSeIrxH1BB59boI7yE1Ql69LsJLDSvCSw0rwksNK8JLDSvCSw0rwksNK8JLDauHwUtRq/UgeB/YyJZih3fWNv0lvDWxwzuL8O4ndnhnEd79xA7vLMK7n9jhnUV49xM7vLMI735ih3cW4d1P7PDOIrz7iR3eWQPBS1F7iPBSw4rwUsOK8FLDivBSw4rwUsOK8FLDivBSw4rwUsOK8FLDivBSw4rwUsOK8FLDan9431L6x1+7t7JKv76efuD6s0BnywfPo5//+nH6NtPX5+r0pb87BHl3eN/ee/X2RJGs6ec/p/5ZZ8sHz6NfXz+dYJjp63N1eurvDkHeG97f37+8f335vHMz6/R2ji50tnzwPHrPUqfuzvT1uTo99XePIO8N788/v71/fZ06/qR6neJmnS0fPLB3UW/pyxmDmb4+Vae1v3sEeXd4z5PF23MEsqWXf393Y1+gs+WDB/cw6AJvu6/P1ulLT3YI8t7wXqzM8xiwmn59/ePv9+B+8c6WDx7cxaDz2zzT12fr9Lm/ewSZ8KreQ/z8HJw1JLz2cCB4n20Ka+vdeT3/DHzWmLbhrG2DzAWb6j2ET772UQ21YJMI76ZB5laZcvAe4mffdZr0NtRWWRhs2waZNylkitv7WuLp9/svehvrJoXuNmwf5P1vD78+1a3Kul5SSqfE4J0tHzyPpml4pq/P1empv9sHmR/MoYYV4aWGFeGlhhXhpYYV4aWGFeGlhhXhpYYV4aWGFeGlhhXhpYYV4aWGFeGlhhXhpYYV4aWGFeGlhhXhpYYV4aWGFeGlhhXhpYYV4aWGFeGlhhXhpYYV4aWGFeGlhhXhpYYV4aWGFeGlhhXh3VfF7497ol+AN7wI774ivDuK8O4rwrujCO++emf119f/+nr55Z6n3+T5Pyd4Xy9/GOf0y8B/ff3y6D4OK8K7r87wvvP6+v7/yzurb2l68vPPL+dfCf56+iM51CIR3n11hvfL5S+JnH+x/ct04Pwrl98+/e9/0EUsFuHdV2d4v53+DNk3+238F9t7ZvklPc1fjhhQhHdfAbyvBm+66Nvpj5t+e3QPBxbh3VftzHvS7+//+TR/cGpAEd59BfBOf25sOnDW6x//952bDYtFePcVwHveZLDdhsvK7dsT/aHK8UR49xXCG/d536F9+ePvd+fAJdtSEV5qWBFealgRXmpYEV5qWBFealgRXmpYEV5qWBFealgRXmpYEV5qWBFealgRXmpYEV5qWBFealgRXmpYEV5qWBFealgRXmpYEV5qWBFealgRXmpYEV5qWBFealgRXmpY/T8hW6VlmPzMpQAAAABJRU5ErkJggg==" />

<!-- rnb-plot-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG5jZGF0YSRFX2xlX2FuZF9IID0oY2RhdGEkTEUrY2RhdGEkSClcbnN1bW1hcnkoY2RhdGEkRV9sZV9hbmRfSCAgKVxuYGBgIn0= -->

```r

cdata$E_le_and_H =(cdata$LE+cdata$H)
summary(cdata$E_le_and_H  )
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiICAgIE1pbi4gIDFzdCBRdS4gICBNZWRpYW4gICAgIE1lYW4gIDNyZCBRdS4gICAgIE1heC4gICAgIE5BJ3MgXG4tMTcyLjAxNiAgLTE3LjQ4NiAgICA2LjcyNSAgIDcxLjg5NCAgMTUwLjg4MiAgNDg3LjkxOSAgICAgNjExMCBcbiJ9 -->

```
    Min.  1st Qu.   Median     Mean  3rd Qu.     Max.     NA's 
-172.016  -17.486    6.725   71.894  150.882  487.919     6110 
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucGxvdChjZGF0YSRFX2xlX2FuZF9IIClcbmBgYCJ9 -->

```r
plot(cdata$E_le_and_H )
```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJjb25kaXRpb25zIjpbXSwiaGVpZ2h0Ijo0MzIuNjMyOSwic2l6ZV9iZWhhdmlvciI6MCwid2lkdGgiOjcwMH0= -->

<img src="data:image/png;base64,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" />

<!-- rnb-plot-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG5zY2F0dGVyLnNtb290aChjZGF0YSRFX25nLCBjZGF0YSRFX2xlX2FuZF9ILFxuICAgICAgeGxhYj1leHByZXNzaW9uKE5ldH5SYWRpYXRpb25+bWludXN+c29pbH5oZWF0fmZsdXh+Jygnfld+bV57LTJ9ficpJyksIFxuICAgICB5bGFiPSBleHByZXNzaW9uKExhdGVudH5hbmR+U2Vuc2libGV+SGVhdH4nKCd+V35tXnstMn1+JyknKSwgXG4gICAgIG1haW49JycpXG5gYGAifQ== -->

```r

scatter.smooth(cdata$E_ng, cdata$E_le_and_H,
      xlab=expression(Net~Radiation~minus~soil~heat~flux~'('~W~m^{-2}~')'), 
     ylab= expression(Latent~and~Sensible~Heat~'('~W~m^{-2}~')'), 
     main='')
```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJjb25kaXRpb25zIjpbXSwiaGVpZ2h0Ijo0MzIuNjMyOSwic2l6ZV9iZWhhdmlvciI6MCwid2lkdGgiOjcwMH0= -->

<img src="data:image/png;base64,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" />

<!-- rnb-plot-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuI3BhcihOZXc9VFJVRSlcbiNwbG90KGNkYXRhJEVfbmcsIGNkYXRhJEVfbGVfYW5kX0gsXG4gICAgICMgeGxhYj1leHByZXNzaW9uKE5ldH5SYWRpYXRpb25+bWludXN+c29pbH5oZWF0fmZsdXh+Jygnfld+bV57LTJ9ficpJyksIFxuICAgICAjeWxhYj0gZXhwcmVzc2lvbihMYXRlbnR+YW5kflNlbnNpYmxlfkhlYXR+Jygnfld+bV57LTJ9ficpJyksIFxuICAgICMgbWFpbj0nJylcbiAgICAgICAgICAgICAgIFxubG0oY2RhdGEkRV9sZV9hbmRfSCAgfiBjZGF0YSRFX25nKVxuYGBgIn0= -->

```r
#par(New=TRUE)
#plot(cdata$E_ng, cdata$E_le_and_H,
     # xlab=expression(Net~Radiation~minus~soil~heat~flux~'('~W~m^{-2}~')'), 
     #ylab= expression(Latent~and~Sensible~Heat~'('~W~m^{-2}~')'), 
    # main='')
               
lm(cdata$E_le_and_H  ~ cdata$E_ng)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiXG5DYWxsOlxubG0oZm9ybXVsYSA9IGNkYXRhJEVfbGVfYW5kX0ggfiBjZGF0YSRFX25nKVxuXG5Db2VmZmljaWVudHM6XG4oSW50ZXJjZXB0KSAgIGNkYXRhJEVfbmcgIFxuICAgIDEyLjE2MjEgICAgICAgMC42Mjg2ICBcbiJ9 -->

```

Call:
lm(formula = cdata$E_le_and_H ~ cdata$E_ng)

Coefficients:
(Intercept)   cdata$E_ng  
    12.1621       0.6286  
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuc3VtbWFyeShsbShjZGF0YSRFX2xlX2FuZF9IICB+IGNkYXRhJEVfbmctMSkpXG5gYGAifQ== -->

```r
summary(lm(cdata$E_le_and_H  ~ cdata$E_ng-1))
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiXG5DYWxsOlxubG0oZm9ybXVsYSA9IGNkYXRhJEVfbGVfYW5kX0ggfiBjZGF0YSRFX25nIC0gMSlcblxuUmVzaWR1YWxzOlxuICAgICBNaW4gICAgICAgMVEgICBNZWRpYW4gICAgICAgM1EgICAgICBNYXggXG4tMjI1Ljk4MyAgIC03LjQ2NyAgICA5LjcxNyAgIDI2Ljk1MSAgMTgwLjI0NCBcblxuQ29lZmZpY2llbnRzOlxuICAgICAgICAgICBFc3RpbWF0ZSBTdGQuIEVycm9yIHQgdmFsdWUgUHIoPnx0fCkgICAgXG5jZGF0YSRFX25nIDAuNjU3NzI3ICAgMC4wMDQyMDEgICAxNTYuNiAgIDwyZS0xNiAqKipcbi0tLVxuU2lnbmlmLiBjb2RlczogIDAg4oCYKioq4oCZIDAuMDAxIOKAmCoq4oCZIDAuMDEg4oCYKuKAmSAwLjA1IOKAmC7igJkgMC4xIOKAmCDigJkgMVxuXG5SZXNpZHVhbCBzdGFuZGFyZCBlcnJvcjogMzguNjggb24gMzM1MSBkZWdyZWVzIG9mIGZyZWVkb21cbiAgKDExODUyIG9ic2VydmF0aW9ucyBkZWxldGVkIGR1ZSB0byBtaXNzaW5nbmVzcylcbk11bHRpcGxlIFItc3F1YXJlZDogIDAuODc5NyxcdEFkanVzdGVkIFItc3F1YXJlZDogIDAuODc5NyBcbkYtc3RhdGlzdGljOiAyLjQ1MmUrMDQgb24gMSBhbmQgMzM1MSBERiwgIHAtdmFsdWU6IDwgMi4yZS0xNlxuIn0= -->

```

Call:
lm(formula = cdata$E_le_and_H ~ cdata$E_ng - 1)

Residuals:
     Min       1Q   Median       3Q      Max 
-225.983   -7.467    9.717   26.951  180.244 

Coefficients:
           Estimate Std. Error t value Pr(>|t|)    
cdata$E_ng 0.657727   0.004201   156.6   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 38.68 on 3351 degrees of freedom
  (11852 observations deleted due to missingness)
Multiple R-squared:  0.8797,	Adjusted R-squared:  0.8797 
F-statistic: 2.452e+04 on 1 and 3351 DF,  p-value: < 2.2e-16
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


#Work on (co)spectra data

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxuaGVhZChjZGF0YSlcbmBgYFxuYGBgIn0= -->

```r
```r
head(cdata)
```
```

<!-- rnb-source-end -->

<!-- rnb-frame-begin eyJtZXRhZGF0YSI6eyJjbGFzc2VzIjoiZGF0YS5mcmFtZSIsIm5jb2wiOjE3OCwibnJvdyI6Nn0sInJkZiI6Ikg0c0lBQUFBQUFBQUJ1MWJDVmhUeDlvT1M4SytpQmFYcWhlMXVGd2hKbUVURmM4b3Nna0lRa1J4YVF4SmdFQTJzaEN3TG1oZFd3VmI5MW9FWE5wcTYxcTlhaFdUV3BkV3dRWHJWcTFpclhXcFdseEtVVkR2ekVuTzVDVEJ5bTJmLzMvKysveWU1eGxtdnZlYmQrYWI3WnM1azBQYWlIRWg3dVBjR1F5R0U4TVovV1hDUHd4V2RDcVhGOFpqTUp3ZG9lUUFOVzRvTG9MNjlqQ3hBd1p2bEExVUxLcXBPM1IwS1lxdmJmdHFMb29iUHQ2c1IvR0wrWlZTR05kNmE1ZU1SM0czeVhPVHpId1Bpcy80eng4dkdxOTdLekdsYjJjT2Z1YlEzaHdvdmZkTEFxVm52aVJRZXYxTFFsdjU2MThTNk8xcjdmRWw5YVlCY2VyUEdmaFhrK2FhU3VDZjFvTE4wRE1WUXJsRVk2N2VneXBISXhGUlNibFVZVTQ2NXlwMWFpb3RGd3VMY1JZbHpsSXNFZUlzZWtzVzUySkxtaW5WaURWYVNqRkZxWkNZMDZ3Y3VWYVpuVzFyb0VnbTFGQUdPcHBCbDlTVTlJUnhNcW9VRmlscWJabGFzbkFUMDhrTXVzVm9SUVBpa3ZuQnJYVmZRRUFBako3YkRFWlBIb2NiR2N3SkQrYUc4cm5oSVJ3T1I2Q1JDOVhha0dBT2h4c1J3YzdKeldrdFp3U256VG5iWE9iQTFzdUV6WG9CbjlZWWtTOWowRnZvRmo2QUd6b0EwZjRLWUYyN2xZSmVDWk1iTVlqRG9Ra2hGbUVnWFRNUWFhd0xaWElqVGFESk9Zbi90WEdKUi8xVklONmQvc2VKaXgxaC9IemlCNmRIQWZFZUVwL1JnS2E1eTFvZzNrdml0TVhuUUE4bGxzVm4xc2VtMG9OSmo5S3YxSk4yR2M3T3lWVHRYT05vcUt0NnZQMytXMkdHbWhBdnpWeTNqd3hIaXRMK2VMenlFR1dYWVgrRzUxU2ZtSTZNbHpnRm1sMm05aW92UlMrYnlRb0VxdnFFcjk0T0k0QnEyNU5MUFUvZEFBVUJ6eDc5SzJZdGJxLzZ5N29IRzV0dnRybmNSRjJlZi9lVVFwRHl4WnMvak81OEFveE84bnF6UUZjSytKRUR1bFFjME9OeUovNytRYTU2VzQrMmxtdDA5MnZwbmZINUZhUDd4eUhxYnVrbmpLNjdWY1UzS29LTW5oRVZHNmUzNzArVmEzUVordHZiMzNwcTIxb3U4ZWowcjNPNjcwa2pHbitLemxoKzR6M2lpZE9FczM1M1pjU3poRzRkcnU4L2crMWxPaGMrM0xBK3I2M2xZcDR6YTBkK1UyRUY4V3orNEhVam91S0FaNFJmbDUyN2d5ZzlGZHZ5aU91elI1UWZPQmhQbkpYbzA3dnRqQ1YrdlQzbDN1V2J0YS9pR1ZZL250ZXl0OWM2dzVvd1l1cTlEM0lOVmJDWEF3NTkvTXI2RmtZSGJaaFNKQ09tM3pWc256Q1dJSllHRFZrRGt5L2pWUjllZU92OGhhSDdxdS9QdWovRW82b3g2b0QyMHZqejB3WlZIeHVUUG5ueFYyOVQrYXVONlRkanBwY1B4VHo5UUdQV3VkQ202c3JQK3dYMFRUNGFwVExJWS9iNXVWWlBLL1VNK0hMQllNeFR2N2dldWFMbE9NVURuQXUvaFo2cnlnS2NvM01QOWk0cEI1eTluQU5lOS9vQlRsWG5FeTRDRmU1dnpzeFE1enNqRjJKZWNYN3pUZG43STBCeDlyYzdJOGY1Z21JaG5PV1RoNFBpOFNzV3BWekY5WUhpU2VSNnNQQ09rUDBHaWcvR1ZCMHp2Z3VLcTgyOFBSMm1YSXZiWXVFZE9MUjZ3M1UrbzQySEZGby9Vay9iMXRYTUEzQ2FqcjRMWnY0U2dDb0VNNXZLZHdSN1o0QlozSWpFSTU4MllIdG0xV3IzNTAxL2lubjk4MjZlelQ0NUhQUTM5QWpXY3hlRC92ZjAzTExEVEJDVTQ3UjE5MjFmekF0ZWZ2YmtwdG9LQzY5bWV0KzNQSXBBVUM4L3hZcEZxU0FvRFhiSDZrOUEwTW5EempPVnVCMkE3YnJ3cHRQV1BmL2o3US9oUWk4a1d3eENleUgvSEFCQzd5Sy9CVUI0M0crd0kzeG5OSm50R1ZpTi9Fd0o1cW4vQVljL2VqbFFjOGdGQWRSRGhpMklTRHdLMU9uaThWMi9jTFg0dVNsSTVHSmVrN0FJYVVDVHFQT3FWYXMrZ3ZIeEVQaUFKc2xlSkdOZVU4NXBKRE93UCtrMHYwbjRpUmZ4eUZXeWRHdUtOL0d3aFhPR3RYWTc4ZkFHcUNtNi9RZGVidytybXg1cm5KMXhmV1dmSGl5YjJMY1JsSDIyN3J4N1ZBRW8yeGhDMWxlMkNVMjNEcmkrc3MycnJPcGJ1Zm56aWpHcm80aVZSMythQlhhWEVDdC82aXpwZitZYlltVkxhcngvZ3d1dWJ4VmFMbjBYWWQ3TzB2Y0tya2czRTd2M0RiaWJjZllVc2ZmKzg1U1dGY3VKQTVOY2hyZXZQSXA1aDQvcG5QYThLY0c4MmRBcGpwOHpuNWpUNlord1NHOWlUdEpLQWF0eEtURm5KdXV0SHdlOGlYbHo0U1lndUxBRnQyK1p4RFIvbDMyMkJTNmdlTENzVm9VYUNwYXpJZnpySE55K0ZkMG05djM5WUJubWxWL1BSZytvcUk5RFJGQzV5OVEvYStPVGFtcHFzRDhFR3lJdjAzbkV6RVdCOTA2bExTRm1Iamw5emZXYng4Uk0rUGRSZlFReGE4Qm0yYTR3QjJ6bnJNWmIvUkkyNFBhQjBUYytHMWNjZFJHa3RpRDNOd0drcHBEMmdGRjhiWHJwbzJSY1gyS2tyclRIOG5UTUsyazJqZDlzcFdtZXpSdGNjYUR3MjUxZzRTRzRuVllkeDd3bEdkYnRLNmdoL1Fjb09JbTI0V21nNExUcC9GRndsdXhRekN1NGl0eVZHUE04aHA3dGM2UEhXT0QyUTUrK1diK3ZBcjZWNVFtaloyMENubThyZmxYMWRzSTg3K204eXV3aE9zenpKTGRSQUZ4cmxmekU3VnVCUXlnNlZrZ0JvNDdzR0x5UG5Qcmg4ZWI5MmNtNFB3K2hZclROaEhIYk5QZDdxMnFJcmUrNU9WNWgxQkdiVWZPT2ZZMTVLcWY3YTkwMnJjZjF0ZjlGZERSbDEwalE3dGVOcHhzZGlvSGZYbGJOMmt0WndIZGE4NUlGdXdJc2RpNCtsYk9RZ2Yxb1ZOOXJQd2UvY2Y5bU5hL3dxVFIyVDFSMWYrWTh4UVNIZ0tqQXJxTlBSSFM2UnZHaWd1U25leDl1L3dQRjIvOXpTL21RUnYyMGFxKzk4VUVyUnJrUCtmRm1kc2RlbDc3Y2Y3dmh6RzgrVy90UnZQMzE0Yk4xMHRvcGY5ZE8wR3R4L3BTMWt4YUJub2Q3TmM1SVBnQjYxaytkdmV2eUVkQmpaMVFzM1BreEwyQkY3WUwzMmVXWWwxM25TVHF3SE01b2RBQUIwdjZtY2MrOVNzYVlKMmVUOHgvejRySnExN3o3YzI4UWM4dDByaG84SVhYYnczZStCRU0zalVZYkllWVZBdU83Zm9xVmVQeWVkYmdJaXBaM0lKNXVhZjdubG41YTR0WmJVM2U3Zi9NWmNjZmw4WmhQNjRiajhkdkNPTDI3NDdpZm9JRGU4Ly9rbGM5Y2JyM0p6eEJYTnhaTWUxQ2VRMXhhWWh4OHFDNll1UERGZHoxaXF6YmdkWGJtQ3htYVVaajN2UDVLM2Z3VEt1TFpMcjV1WFpja3dDaWFtem55OFFPaXFkMmt4akVUMHpIdmFUOTQvTDV5aHVJWkU1YmR2clp0UWFVeHVuUWdKUHh1SE5RRG1kdlp5Q09nMnkvOERwOERBeDdtdW4yL3JCUEZNK3hnN25kWXB4aGcyTDNreHhXTi9mTU5YMjlvbVo1UDNERjhGNnYvY3RtaG5yajlsOExYTTVvL200WDcyMjh4YTlHZXI0NkNkcDdOTFJKUUE3eXZkZHUvVWRvRmVIUjV4eU95YzIvTE9XOVQ2VTVSd2p1NHZvdDUxZGVicTk4eFhHNHBPTWZpcWczMU01U0p0OEt1R3E0N2VtZXRTa3ZDOWQwWmZITFV2S1RGakxidWc2TmlpUTUrelAxZzFIbllha2tRU0JUMld2dXgvaU9RZU81MjBmZlBIbU43NHRDcHhVK0orNjNuNU5uQ0p3MWRqVDMzck54eHUyYVBNV0ROcDNFWG1MOFlBMzZCWHFaTEplNjNydHVxSWg0dHRNenYwRzlQcUFZMXp3QmhRUVdlTzViZEFid2EySTNzSFNDa2E3MnU4Um51TjhDSlJOdU9FUE1TNm8vM2Uzdk5tMkRrUkxoZHpGc0s0bkpTdkdZbk80QzQ0M0I2KzgvRHZCRWgxdWV1OUgwZmV4KzR1aDd3dTNERzhJUlR3ZWdMYUtQS0EybUI2YjA3Zm4wQTgwYWRlUGZud0MyL1lONkVMKzZoRndvd2tVdnVqeURUQlIxL05TQlRRNTdiTUcvTVIwV3lucm51bUNmZVozb1BrblQvRkIwa1FKYmhDRW9Ba1cvZTlDZVhlbUhlWkRZc1p0Z0NQTDVuQjg3cXM4anpHME9kYUV2Z3NBdTNETWZyRW41T3FSeHRPTUtwM0w3dlpBb2UzMzNQSHkyZTg3Z0t6L3VHeURzL1pucDZFQTNobkkxdlJGUVNEUkdiQWkrY0x5Y2FRcmE3YUhQbjQzbmZ3RDJ4TmJCcloyeW5jdVM4L282ZUk0RnFuZWs4cGlxTVFoc29VRDIxR2orZzNnUzNrL1FtUzMzVG83cCt6YmhKTkdqT2ZyV2prei9SVU9RVWUzbVNtR2lRRlk2ODJ0VExVbC8yaERzZVZiL2orZ0J5S3p0ZWdPajE2RGo5Qm9oTlpNSUJPQWdTSmVRK1orbFAvd3puVGt2dy9rSThXSTQyL292RWc2blgzL0RhTXBSNE1NL2ZMY040bm5pUUI1dnRmZ3JYOTJEQ3J2TEwzWXZ4L0F6dUFhZlY5a05HOWpGWVc5SktJOXVEZEJER0Fic0NZOTAvd2V2RnlLbDhzZUl0TGYvdjFrZmNYUFRlaWpYKzU0bTd3azJFVTZJMzBkQ2QzRGVKUitmR05rdFhqc1M4NTZ0UGZtOXdXLzQzNmlQWDlZQ3RyaUo2UU9zYXhmOUg5VWR0OVdIcmI3MmdCNlJIY1Z2MURBZEJHVDJRZmcybDI2cG5NRExwZ2RTYjBtM1ZVM2MwNkQ3UDFheG5NZXo5THRLN21mVXVOTDBqTFZEM1BBNDBQZklwNkxJYVhTQjNNZXM5YVhwUDh4eEMrZnhiS1I5ZFNLUDdHMzhZdXBuMTlFdG1xNmZFa3Z6ZjBvdnB3YXpINTFHaXVUdnBqNG5tUWZ1WHFzVDNpTWFsWlJlZmhUY1JqN2RtTHJqYVRtTlpGeCtXZXBhWGgxcDR5R3RHRzRpbksyb2lYNXp6QVk3SGg0NU5YM2VYK01QblpNbmxFTFZsSFM0OFdscVJ0eFR6Zm1oZWZZL1RJQ0xPVFM3eXVlenZUNXk3UEVrMFg3S01PRjBhWHVZYWk4OXJ4S21URTdyT2paK05lZGNEc3R4M3QrOUQzQXBjbTlvRU9oRjN5OEtsOFN1eFAzdlpmUWVSbDNpcGNrUHY1WVJxK0lXRDYvbFhDTTNJWXkva0lXNUVZVnIxa1BCMm9iZytQZHFXKzM5UDhVQWdlT0tXdjNjaDRDU1I5eWtnTXZxNys4ZWIvVUgwSU5MUFlUL0svL0M4cGxOTEtxN3ZXTW1Uc25XRkh4STFNYy9iK1JVMkV6VWVHYnF4SHowa2FyM3FsNlN6MzdHMHI5UE5zUitXZWpHd0h5VmZHME9NN0JyMDFCclpwb0V5RGpESjFIdXlrYlBLK2ozeUwvcERFRExRZEg0TmlTRHZFMEJJbU9rOUtBVDFpdk1kM0Q1elBzeXozTXVZM24rS2hlUjdJQ2dlL3o3YWtHbjNNdVE5RnViWjMyZkFVOFdnSmErOHoraURiak9jNGtDZnVlZzQxdzcwMlF0UHk4bzYwSGNvZWVHRmVmMUt5UHNCek12OEJKbjFENUM1RVI2dkh2MExaRzVLcm51d3NRVmtmbTU5ZjVDNTA1WGIremIyOXlXTVB6ODN2MnkrdldvZXZ1YTk1cjNtL1ZmeFh2VWUvVnIvMmwrKzV2My80NzNxblBENkhQRmZ4QU1WaTQ2ZFY3dzdvNjB4NW5FdStHWWxuMkVBN21YVC9SV1AvRm5QRjRUNlhCMHNIaCtBZjljS253SEZydHV3bldhOHJmSGY1djNIL1lLK20zRjhBZCtXZlJub0l6RHpSelphcVZ6Q2xvcXBEenY0Q2NreDZmeGh5YWxtd0RWYktwT2d6NGVvYjNuRVFpMU9JeTcxV2MySWxFeXFTTEd3bUtieFJDVUkxQktSVWkzV1VKaE9JeEhiWUU1OG9ZNzYxS2RBSkxCSUR2RlVmUkNtMG81Sk1kUm5JeERGZ3F0SXlSTmt5M1JGWnRrREttMGcxMXllMGphTERjU0tGMmkwYXVyakhKZWtHTHBJVmtHWEVaa211eUY5SVZzb0xxUUFsSUVPdEVNNTVFcVpVQzBRU3hRYXFiYllSaUVSWkt1RklxMFVmM0xsU3lxa1JWSkZqa0F0aEFxcUh4R08rbG9nRTFMMSt5Qk1MTWttY1F2Y0RsblJhcVZtaFgybHBLS1ZTaEZ1V3luQ1dxbFVvMVJJUlFLdFJLNlN3Q0owYW1wUytBaWw2bFpnVHdTcjFCS054b0o1SU16R1pBVGxTb1JhZ1Vpb0Vvb3NDbCtrTURXeVVDblQ0VG5vR01NM3A5cnI0ZnlGV3FGS2FWdXFBODR0MFdEN1ZSS1JOQnMySVZjbmw0b3RlUjNUcUlub2xKRTZncHFmZkxGRVQwMGFuVUNuVUN1cGo5ZGNDcTFGdlpYSTFBbG9RaUZkME5NRWQ3MVVJUlpBa3lUVWN2V1dDNHNFZHFncmlZaWwxRWQ2VHNWQ3lpeW1TcW9WNVZMMnFwVXlHZFVnSFJ1dncwUnFOVGtrVVNXT1kwOWhpOWxzU3ZiSVV1b2xDcXRaNGNpbkNtREtsV0lKVlM2clNLQ1NDUE9wY29vRXl1eHNqUVEzcjBqQTViQXRRZ2hkQ0tNTEVYUWhFZ3NzbllMbUtWeGdVcUFSWlZQdGcwcHFtSmp4TkFVVEtyRExZS0hsalZVZVVHWGpNRnpJQlcrVnc4WmZ1SkF1QU9kdzA2aWsrUktOSUpjQ09ncmxLcGxVcXhNalA2aUJFeE90TW92YVE2eFdxZ1JLbmRZQytRbXp5SHh3alVubFVpMnRyQTZhZklsZUFWZUlJRituMWlvMTBqL1hhWENKWXFsR3BGUm9wUXFkVkN1bFcyZW53UngzODJxMjVNVUl6dU1qMUdxRm9ueUJVSkVEWFlpbFVBVnNvVVlyRVlxTFRSTVVhMXpoRUpIOVE4bUZOckxlV25hRHJiY0MzTW54c0VMSS9xY2pQcUpjcFFvNkYwRlNBanNpREg5MzZDdVdhQ1VpcmRJVzkxREpaRGFRcDZaWUliTEJPc29sUWdYMEhUS2RSSkNXbnA1Z280Ykx1QkIvR1F1WE1VM1Ewd1FXYkpCRkltY1hUU1EzQ3l5NjZ0a3d0MGlKOXhJOUcrVzNBaEREQW5nVVNtSEhad3VRcWZRZGl5NlRqdDBpZTBPM0pWQXBwUW90SGUxR2RyTTBSeUdVb2UxTm9zalI1Z3BRYSttWldHa3gwU2xwbEFOMEd3NG5RNFpnV0NIbC96MVMrZERIQzZKcGtOZXdaRjRZSDY2RGJCcm94aWV6c0xsc0c0Qm5DNFRZQXFHMlFKZ3RFRzRMUk5nQ0EyMkJTQXB3cHd6ajJDRmNPNFJuaDRUWUlhRjJTSmdkRW02SFJOZ2hBKzBRTzV0NWRqYno3R3ptMmRuTXM3T1paMmN6RDl2c09reXE1dE1Ha3BVV1Q1TjhobW5scWViZG5EN2FvOUlFY3ZvMGNZZkFXRG1QUGt0U2g2VUo0RVMyeXVaakJuVXhWbm05RVl5OHAxVm1Yd3ExeWUyWkhoOHI0RnJuOVRKaFkrMHo4bHJKeUxQSjZENFdIU2xTN1JDK1ZYdmdZVmVxRXNqbEFyN2xGSkF4bHI0eVdERjBpVW1uTSttbHMxS0gwYVdNTkxva1ZoWmJUdlB0YlU1WkFxRTRqekl4V3FtR0pta0ZvOUlvRXlsRWs1c3Q0TFlHOG15K3ZYZFRLL1ZzNmw4TDBNdXhZd21EZkZpbWpFN294MFpmR3NFZHZqd0kyZkNZS1VlZmR6MjNLYzVGcVVMN0lpek1FZjJyQjlPRzdLQzJBWHgxQ2xTNU9GaVVxMVBrQjNNakdLYXJLK3BuUlM5enpLS2xkK0RYSUZOWlRLcmZvSHVUNG45U1lNcUVXZmdFNHcxYlNUYVNyVkpERjBrMUJhSWF0bGFwRlZMNTRMWWtveERUL3hjOC96Y2pCdnZjbnpNQUFBPT0ifQ== -->

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["time.id"],"name":[1],"type":["dbl"],"align":["right"]},{"label":["TIMESTAMP"],"name":[2],"type":["S3: POSIXlt"],"align":["right"]},{"label":["filename"],"name":[3],"type":["chr"],"align":["left"]},{"label":["date"],"name":[4],"type":["chr"],"align":["left"]},{"label":["time"],"name":[5],"type":["chr"],"align":["left"]},{"label":["DOY"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["daytime"],"name":[7],"type":["int"],"align":["right"]},{"label":["file_records"],"name":[8],"type":["int"],"align":["right"]},{"label":["used_records"],"name":[9],"type":["int"],"align":["right"]},{"label":["Tau"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["qc_Tau"],"name":[11],"type":["int"],"align":["right"]},{"label":["H"],"name":[12],"type":["dbl"],"align":["right"]},{"label":["qc_H"],"name":[13],"type":["int"],"align":["right"]},{"label":["LE"],"name":[14],"type":["dbl"],"align":["right"]},{"label":["qc_LE"],"name":[15],"type":["int"],"align":["right"]},{"label":["co2_flux"],"name":[16],"type":["dbl"],"align":["right"]},{"label":["qc_co2_flux"],"name":[17],"type":["int"],"align":["right"]},{"label":["h2o_flux"],"name":[18],"type":["dbl"],"align":["right"]},{"label":["qc_h2o_flux"],"name":[19],"type":["int"],"align":["right"]},{"label":["H_strg"],"name":[20],"type":["dbl"],"align":["right"]},{"label":["LE_strg"],"name":[21],"type":["dbl"],"align":["right"]},{"label":["co2_strg"],"name":[22],"type":["dbl"],"align":["right"]},{"label":["h2o_strg"],"name":[23],"type":["dbl"],"align":["right"]},{"label":["co2_v.adv"],"name":[24],"type":["dbl"],"align":["right"]},{"label":["h2o_v.adv"],"name":[25],"type":["dbl"],"align":["right"]},{"label":["co2_molar_density"],"name":[26],"type":["dbl"],"align":["right"]},{"label":["co2_mole_fraction"],"name":[27],"type":["dbl"],"align":["right"]},{"label":["co2_mixing_ratio"],"name":[28],"type":["dbl"],"align":["right"]},{"label":["co2_time_lag"],"name":[29],"type":["dbl"],"align":["right"]},{"label":["co2_def_timelag"],"name":[30],"type":["int"],"align":["right"]},{"label":["h2o_molar_density"],"name":[31],"type":["dbl"],"align":["right"]},{"label":["h2o_mole_fraction"],"name":[32],"type":["dbl"],"align":["right"]},{"label":["h2o_mixing_ratio"],"name":[33],"type":["dbl"],"align":["right"]},{"label":["h2o_time_lag"],"name":[34],"type":["dbl"],"align":["right"]},{"label":["h2o_def_timelag"],"name":[35],"type":["int"],"align":["right"]},{"label":["sonic_temperature"],"name":[36],"type":["dbl"],"align":["right"]},{"label":["air_temperature"],"name":[37],"type":["dbl"],"align":["right"]},{"label":["air_pressure"],"name":[38],"type":["dbl"],"align":["right"]},{"label":["air_density"],"name":[39],"type":["dbl"],"align":["right"]},{"label":["air_heat_capacity"],"name":[40],"type":["dbl"],"align":["right"]},{"label":["air_molar_volume"],"name":[41],"type":["dbl"],"align":["right"]},{"label":["ET"],"name":[42],"type":["dbl"],"align":["right"]},{"label":["water_vapor_density"],"name":[43],"type":["dbl"],"align":["right"]},{"label":["e"],"name":[44],"type":["dbl"],"align":["right"]},{"label":["es"],"name":[45],"type":["dbl"],"align":["right"]},{"label":["specific_humidity"],"name":[46],"type":["dbl"],"align":["right"]},{"label":["RH"],"name":[47],"type":["dbl"],"align":["right"]},{"label":["VPD"],"name":[48],"type":["dbl"],"align":["right"]},{"label":["Tdew"],"name":[49],"type":["dbl"],"align":["right"]},{"label":["u_unrot"],"name":[50],"type":["dbl"],"align":["right"]},{"label":["v_unrot"],"name":[51],"type":["dbl"],"align":["right"]},{"label":["w_unrot"],"name":[52],"type":["dbl"],"align":["right"]},{"label":["u_rot"],"name":[53],"type":["dbl"],"align":["right"]},{"label":["v_rot"],"name":[54],"type":["dbl"],"align":["right"]},{"label":["w_rot"],"name":[55],"type":["dbl"],"align":["right"]},{"label":["wind_speed"],"name":[56],"type":["dbl"],"align":["right"]},{"label":["max_wind_speed"],"name":[57],"type":["dbl"],"align":["right"]},{"label":["wind_dir"],"name":[58],"type":["dbl"],"align":["right"]},{"label":["yaw"],"name":[59],"type":["dbl"],"align":["right"]},{"label":["pitch"],"name":[60],"type":["dbl"],"align":["right"]},{"label":["roll"],"name":[61],"type":["lgl"],"align":["right"]},{"label":["u."],"name":[62],"type":["dbl"],"align":["right"]},{"label":["TKE"],"name":[63],"type":["dbl"],"align":["right"]},{"label":["L"],"name":[64],"type":["dbl"],"align":["right"]},{"label":["X.z.d..L"],"name":[65],"type":["dbl"],"align":["right"]},{"label":["bowen_ratio"],"name":[66],"type":["dbl"],"align":["right"]},{"label":["T."],"name":[67],"type":["dbl"],"align":["right"]},{"label":["model"],"name":[68],"type":["int"],"align":["right"]},{"label":["x_peak"],"name":[69],"type":["dbl"],"align":["right"]},{"label":["x_offset"],"name":[70],"type":["dbl"],"align":["right"]},{"label":["x_10."],"name":[71],"type":["dbl"],"align":["right"]},{"label":["x_30."],"name":[72],"type":["dbl"],"align":["right"]},{"label":["x_50."],"name":[73],"type":["dbl"],"align":["right"]},{"label":["x_70."],"name":[74],"type":["dbl"],"align":["right"]},{"label":["x_90."],"name":[75],"type":["dbl"],"align":["right"]},{"label":["un_Tau"],"name":[76],"type":["dbl"],"align":["right"]},{"label":["Tau_scf"],"name":[77],"type":["dbl"],"align":["right"]},{"label":["un_H"],"name":[78],"type":["dbl"],"align":["right"]},{"label":["H_scf"],"name":[79],"type":["dbl"],"align":["right"]},{"label":["un_LE"],"name":[80],"type":["dbl"],"align":["right"]},{"label":["LE_scf"],"name":[81],"type":["dbl"],"align":["right"]},{"label":["un_co2_flux"],"name":[82],"type":["dbl"],"align":["right"]},{"label":["co2_scf"],"name":[83],"type":["dbl"],"align":["right"]},{"label":["un_h2o_flux"],"name":[84],"type":["dbl"],"align":["right"]},{"label":["h2o_scf"],"name":[85],"type":["dbl"],"align":["right"]},{"label":["spikes_hf"],"name":[86],"type":["int"],"align":["right"]},{"label":["amplitude_resolution_hf"],"name":[87],"type":["int"],"align":["right"]},{"label":["drop_out_hf"],"name":[88],"type":["int"],"align":["right"]},{"label":["absolute_limits_hf"],"name":[89],"type":["int"],"align":["right"]},{"label":["skewness_kurtosis_hf"],"name":[90],"type":["int"],"align":["right"]},{"label":["skewness_kurtosis_sf"],"name":[91],"type":["int"],"align":["right"]},{"label":["discontinuities_hf"],"name":[92],"type":["int"],"align":["right"]},{"label":["discontinuities_sf"],"name":[93],"type":["int"],"align":["right"]},{"label":["timelag_hf"],"name":[94],"type":["int"],"align":["right"]},{"label":["timelag_sf"],"name":[95],"type":["int"],"align":["right"]},{"label":["attack_angle_hf"],"name":[96],"type":["int"],"align":["right"]},{"label":["non_steady_wind_hf"],"name":[97],"type":["int"],"align":["right"]},{"label":["u_spikes"],"name":[98],"type":["int"],"align":["right"]},{"label":["v_spikes"],"name":[99],"type":["int"],"align":["right"]},{"label":["w_spikes"],"name":[100],"type":["int"],"align":["right"]},{"label":["ts_spikes"],"name":[101],"type":["int"],"align":["right"]},{"label":["co2_spikes"],"name":[102],"type":["int"],"align":["right"]},{"label":["h2o_spikes"],"name":[103],"type":["int"],"align":["right"]},{"label":["chopper_LI.7500"],"name":[104],"type":["int"],"align":["right"]},{"label":["detector_LI.7500"],"name":[105],"type":["int"],"align":["right"]},{"label":["pll_LI.7500"],"name":[106],"type":["int"],"align":["right"]},{"label":["sync_LI.7500"],"name":[107],"type":["int"],"align":["right"]},{"label":["mean_value_RSSI_LI.7500"],"name":[108],"type":["int"],"align":["right"]},{"label":["u_var"],"name":[109],"type":["dbl"],"align":["right"]},{"label":["v_var"],"name":[110],"type":["dbl"],"align":["right"]},{"label":["w_var"],"name":[111],"type":["dbl"],"align":["right"]},{"label":["ts_var"],"name":[112],"type":["dbl"],"align":["right"]},{"label":["co2_var"],"name":[113],"type":["dbl"],"align":["right"]},{"label":["h2o_var"],"name":[114],"type":["dbl"],"align":["right"]},{"label":["w.ts_cov"],"name":[115],"type":["dbl"],"align":["right"]},{"label":["w.co2_cov"],"name":[116],"type":["dbl"],"align":["right"]},{"label":["w.h2o_cov"],"name":[117],"type":["dbl"],"align":["right"]},{"label":["vin_sf_mean"],"name":[118],"type":["dbl"],"align":["right"]},{"label":["co2_mean"],"name":[119],"type":["dbl"],"align":["right"]},{"label":["h2o_mean"],"name":[120],"type":["dbl"],"align":["right"]},{"label":["dew_point_mean"],"name":[121],"type":["dbl"],"align":["right"]},{"label":["co2_signal_strength_7500_mean"],"name":[122],"type":["dbl"],"align":["right"]},{"label":["RECORD"],"name":[123],"type":["int"],"align":["right"]},{"label":["BattV_Avg"],"name":[124],"type":["dbl"],"align":["right"]},{"label":["PTemp_C_Avg"],"name":[125],"type":["dbl"],"align":["right"]},{"label":["AM25T_ref_Avg"],"name":[126],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.1."],"name":[127],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.2."],"name":[128],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.3."],"name":[129],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.4."],"name":[130],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.5."],"name":[131],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.6."],"name":[132],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.7."],"name":[133],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.8."],"name":[134],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.9."],"name":[135],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.10."],"name":[136],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.11."],"name":[137],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.12."],"name":[138],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.13."],"name":[139],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.14."],"name":[140],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.15."],"name":[141],"type":["dbl"],"align":["right"]},{"label":["TC_Avg.16."],"name":[142],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.17."],"name":[143],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.18."],"name":[144],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.19."],"name":[145],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.20."],"name":[146],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.21."],"name":[147],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.22."],"name":[148],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.23."],"name":[149],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.24."],"name":[150],"type":["lgl"],"align":["right"]},{"label":["TC_Avg.25."],"name":[151],"type":["lgl"],"align":["right"]},{"label":["AirT_Avg"],"name":[152],"type":["dbl"],"align":["right"]},{"label":["RH_Avg"],"name":[153],"type":["dbl"],"align":["right"]},{"label":["AtmPressure_Avg"],"name":[154],"type":["dbl"],"align":["right"]},{"label":["NR_mV_Avg"],"name":[155],"type":["dbl"],"align":["right"]},{"label":["NR_Wm2_Avg"],"name":[156],"type":["dbl"],"align":["right"]},{"label":["PAR_in_mV_Avg"],"name":[157],"type":["dbl"],"align":["right"]},{"label":["PAR_in_uEm2_Avg"],"name":[158],"type":["dbl"],"align":["right"]},{"label":["PAR_out_mV_Avg"],"name":[159],"type":["dbl"],"align":["right"]},{"label":["PAR_out_uEm2_Avg"],"name":[160],"type":["dbl"],"align":["right"]},{"label":["SHF_1_mV_Avg"],"name":[161],"type":["dbl"],"align":["right"]},{"label":["SHF_1_Wm2_Avg"],"name":[162],"type":["dbl"],"align":["right"]},{"label":["SHF_2_mV_Avg"],"name":[163],"type":["dbl"],"align":["right"]},{"label":["SHF_2_Wm2_Avg"],"name":[164],"type":["dbl"],"align":["right"]},{"label":["WaterP_Avg"],"name":[165],"type":["int"],"align":["right"]},{"label":["WaterT_Avg"],"name":[166],"type":["int"],"align":["right"]},{"label":["Precip_mm_Tot"],"name":[167],"type":["dbl"],"align":["right"]},{"label":["VWC_Avg"],"name":[168],"type":["dbl"],"align":["right"]},{"label":["EC_Avg"],"name":[169],"type":["dbl"],"align":["right"]},{"label":["T_Avg"],"name":[170],"type":["dbl"],"align":["right"]},{"label":["P_Avg"],"name":[171],"type":["dbl"],"align":["right"]},{"label":["PA_Avg"],"name":[172],"type":["dbl"],"align":["right"]},{"label":["VR_Avg"],"name":[173],"type":["dbl"],"align":["right"]},{"label":["doy.id"],"name":[174],"type":["dbl"],"align":["right"]},{"label":["air_temperature_adj"],"name":[175],"type":["dbl"],"align":["right"]},{"label":["Correct_NR"],"name":[176],"type":["dbl"],"align":["right"]},{"label":["Correct_shf_1"],"name":[177],"type":["dbl"],"align":["right"]},{"label":["Correct_shf_2"],"name":[178],"type":["dbl"],"align":["right"]}],"data":[{"1":"2019.45","2":"<POSIXlt>","3":"2019-06-14T163000_smart3-00177.ghg","4":"6/14/2019","5":"17:00","6":"165.7082","7":"1","8":"18000","9":"18000","10":"-0.336264","11":"0","12":"254.852","13":"0","14":"54.9173","15":"0","16":"-3.25927","17":"0","18":"1.23875","19":"0","20":"NA","21":"NA","22":"NA","23":"NA","24":"-3.92e-11","25":"-1.32e-12","26":"16.8474","27":"406.749","28":"412.403","29":"0","30":"0","31":"567.815","32":"13.7088","33":"13.8994","34":"0","35":"0","36":"19.194","37":"289.994","38":"99863.5","39":"1.19349","40":"1012.97","41":"0.0241","42":"0.080300","43":"0.0102","44":"1369.38","45":"1912.85","46":"0.00857","47":"71.5884","48":"543.470","49":"284.798","50":"3.40568","51":"3.623120","52":"0.157795","53":"4.97499","54":"4.42e-14","55":"-2.33e-15","56":"4.97499","57":"9.78207","58":"182.564","59":"46.7719","60":"1.817590","61":"NA","62":"0.530800","63":"1.92990","64":"-51.17120","65":"-0.070400","66":"4.64065","67":"-0.397140","68":"0","69":"60.5488","70":"-9.18851","71":"20.7844","72":"51.7562","73":"78.9314","74":"110.7020","75":"165.852","76":"-0.331574","77":"1.01414","78":"250.329","79":"1.03082","80":"32.6304","81":"1.09915","82":"-14.5657","83":"1.09915","84":"0.736028","85":"1.09915","86":"800000099","87":"800000099","88":"800000099","89":"800000099","90":"800000099","91":"800000099","92":"899999999","93":"899999999","94":"89999","95":"89999","96":"89","97":"89","98":"1","99":"0","100":"2","101":"10","102":"12","103":"30","104":"0","105":"0","106":"0","107":"0","108":"100","109":"1.69495","110":"1.74324","111":"0.421607","112":"0.597703","113":"0.00321","114":"10.6269","115":"0.207061","116":"-14.6","117":"0.736028","118":"19.2200","119":"406.749","120":"13.7088","121":"11.5784","122":"102.605","123":"NA","124":"NA","125":"NA","126":"NA","127":"NA","128":"NA","129":"NA","130":"NA","131":"NA","132":"NA","133":"NA","134":"NA","135":"NA","136":"NA","137":"NA","138":"NA","139":"NA","140":"NA","141":"NA","142":"NA","143":"NA","144":"NA","145":"NA","146":"NA","147":"NA","148":"NA","149":"NA","150":"NA","151":"NA","152":"NA","153":"NA","154":"NA","155":"NA","156":"NA","157":"NA","158":"NA","159":"NA","160":"NA","161":"NA","162":"NA","163":"NA","164":"NA","165":"NA","166":"NA","167":"NA","168":"NA","169":"NA","170":"NA","171":"NA","172":"NA","173":"NA","174":"2019.448","175":"16.844","176":"NA","177":"NA","178":"NA","_rn_":"1"},{"1":"2019.45","2":"<POSIXlt>","3":"2019-06-14T170000_smart3-00177.ghg","4":"6/14/2019","5":"17:30","6":"165.7290","7":"1","8":"18000","9":"18000","10":"-0.291135","11":"0","12":"270.018","13":"0","14":"63.3446","15":"0","16":"-3.32627","17":"0","18":"1.43024","19":"0","20":"2.50327","21":"0.609896","22":"-0.0273","23":"0.01380","24":"-2.22e-10","25":"-7.58e-12","26":"16.7794","27":"406.424","28":"412.142","29":"0","30":"0","31":"572.766","32":"13.8733","33":"14.0685","34":"0","35":"0","36":"20.138","37":"291.013","38":"99889.6","39":"1.18955","40":"1013.08","41":"0.0242","42":"0.092700","43":"0.0103","44":"1386.17","45":"2040.07","46":"0.00868","47":"67.9472","48":"653.901","49":"284.983","50":"3.23152","51":"3.100310","52":"0.130386","53":"4.48014","54":"-6.56e-14","55":"-1.32e-14","56":"4.48014","57":"9.38504","58":"185.510","59":"43.8129","60":"1.667720","61":"NA","62":"0.494717","63":"1.85677","64":"-39.11110","65":"-0.092100","66":"4.26268","67":"-0.452908","68":"0","69":"61.6824","70":"-9.36054","71":"21.1736","72":"52.7252","73":"80.4092","74":"112.7750","75":"168.958","76":"-0.287334","77":"1.01323","78":"266.192","79":"1.02828","80":"39.2814","81":"1.09299","82":"-15.3951","83":"1.09299","84":"0.886922","85":"1.09299","86":"800000099","87":"800000099","88":"800000099","89":"800000099","90":"800000099","91":"800000099","92":"899999999","93":"899999999","94":"89999","95":"89999","96":"89","97":"89","98":"1","99":"0","100":"2","101":"11","102":"14","103":"23","104":"0","105":"0","106":"0","107":"0","108":"100","109":"1.70184","110":"1.66206","111":"0.349638","112":"0.754594","113":"0.00397","114":"16.2978","115":"0.220886","116":"-15.4","117":"0.886922","118":"19.2149","119":"406.423","120":"13.8733","121":"11.7628","122":"102.648","123":"NA","124":"NA","125":"NA","126":"NA","127":"NA","128":"NA","129":"NA","130":"NA","131":"NA","132":"NA","133":"NA","134":"NA","135":"NA","136":"NA","137":"NA","138":"NA","139":"NA","140":"NA","141":"NA","142":"NA","143":"NA","144":"NA","145":"NA","146":"NA","147":"NA","148":"NA","149":"NA","150":"NA","151":"NA","152":"NA","153":"NA","154":"NA","155":"NA","156":"NA","157":"NA","158":"NA","159":"NA","160":"NA","161":"NA","162":"NA","163":"NA","164":"NA","165":"NA","166":"NA","167":"NA","168":"NA","169":"NA","170":"NA","171":"NA","172":"NA","173":"NA","174":"2019.448","175":"17.863","176":"NA","177":"NA","178":"NA","_rn_":"2"},{"1":"2019.45","2":"<POSIXlt>","3":"2019-06-14T173000_smart3-00177.ghg","4":"6/14/2019","5":"18:00","6":"165.7498","7":"1","8":"18000","9":"18000","10":"-0.220308","11":"0","12":"267.061","13":"0","14":"69.1883","15":"0","16":"-3.08957","17":"0","18":"1.56332","19":"0","20":"1.84576","21":"0.334318","22":"-0.0295","23":"0.00755","24":"2.77e-11","25":"9.52e-13","26":"16.7234","27":"406.071","28":"411.821","29":"0","30":"0","31":"575.077","32":"13.9638","33":"14.1615","34":"0","35":"0","36":"20.923","37":"291.766","38":"99900.7","39":"1.18657","40":"1013.15","41":"0.0243","42":"0.101303","43":"0.0104","44":"1395.36","45":"2138.82","46":"0.00873","47":"65.2400","48":"743.453","49":"285.083","50":"4.15685","51":"2.150730","52":"0.061600","53":"4.68069","54":"-4.80e-14","55":"1.66e-15","56":"4.68069","57":"9.43845","58":"201.354","59":"27.3567","60":"0.754454","61":"NA","62":"0.430893","63":"2.05885","64":"-26.13170","65":"-0.137878","66":"3.85992","67":"-0.515556","68":"0","69":"54.7589","70":"-8.30987","71":"18.7969","72":"46.8071","73":"71.3837","74":"100.1170","75":"149.993","76":"-0.217355","77":"1.01359","78":"263.390","79":"1.02930","80":"44.5861","81":"1.09548","82":"-15.0232","83":"1.09548","84":"1.007430","85":"1.09548","86":"800000099","87":"800000099","88":"800000099","89":"800000099","90":"800000099","91":"800000099","92":"899999999","93":"899999999","94":"89999","95":"89999","96":"89","97":"89","98":"2","99":"2","100":"2","101":"18","102":"10","103":"22","104":"0","105":"0","106":"0","107":"0","108":"100","109":"1.41127","110":"2.34924","111":"0.357200","112":"0.892482","113":"0.00471","114":"25.2648","115":"0.219096","116":"-15.0","117":"1.007430","118":"19.2100","119":"406.070","120":"13.9639","121":"11.8629","122":"102.661","123":"NA","124":"NA","125":"NA","126":"NA","127":"NA","128":"NA","129":"NA","130":"NA","131":"NA","132":"NA","133":"NA","134":"NA","135":"NA","136":"NA","137":"NA","138":"NA","139":"NA","140":"NA","141":"NA","142":"NA","143":"NA","144":"NA","145":"NA","146":"NA","147":"NA","148":"NA","149":"NA","150":"NA","151":"NA","152":"NA","153":"NA","154":"NA","155":"NA","156":"NA","157":"NA","158":"NA","159":"NA","160":"NA","161":"NA","162":"NA","163":"NA","164":"NA","165":"NA","166":"NA","167":"NA","168":"NA","169":"NA","170":"NA","171":"NA","172":"NA","173":"NA","174":"2019.448","175":"18.616","176":"NA","177":"NA","178":"NA","_rn_":"3"},{"1":"2019.45","2":"<POSIXlt>","3":"2019-06-14T180000_smart3-00177.ghg","4":"6/14/2019","5":"18:30","6":"165.7707","7":"1","8":"18000","9":"18000","10":"-0.175547","11":"0","12":"274.062","13":"0","14":"80.8935","15":"0","16":"-3.52716","17":"0","18":"1.83035","19":"0","20":"3.52689","21":"0.872251","22":"-0.0340","23":"0.01970","24":"-4.79e-11","25":"-1.68e-12","26":"16.6293","27":"405.662","28":"411.505","29":"0","30":"0","31":"582.152","32":"14.2012","33":"14.4058","34":"0","35":"0","36":"22.281","37":"293.212","38":"99931.6","39":"1.18097","40":"1013.31","41":"0.0244","42":"0.118607","43":"0.0105","44":"1419.53","45":"2340.15","46":"0.00888","47":"60.6598","48":"920.619","49":"285.344","50":"3.54611","51":"2.102630","52":"0.058500","53":"4.12303","54":"3.75e-14","55":"-2.88e-15","56":"4.12303","57":"8.85203","58":"198.979","59":"30.6653","60":"0.813471","61":"NA","62":"0.385546","63":"1.50424","64":"-18.24650","65":"-0.197463","66":"3.38793","67":"-0.594001","68":"0","69":"55.6790","70":"-8.44950","71":"19.1128","72":"47.5935","73":"72.5832","74":"101.7990","75":"152.513","76":"-0.173359","77":"1.01262","78":"271.634","79":"1.02648","80":"54.7950","81":"1.08859","82":"-15.8538","83":"1.08859","84":"1.239830","85":"1.08859","86":"800000099","87":"800000099","88":"800000099","89":"800000099","90":"800000099","91":"800000199","92":"899999999","93":"899999999","94":"89999","95":"89999","96":"89","97":"89","98":"8","99":"9","100":"1","101":"26","102":"22","103":"29","104":"0","105":"0","106":"0","107":"0","108":"100","109":"1.29281","110":"1.44136","111":"0.274305","112":"NA","113":"0.00545","114":"38.4554","115":"0.226986","116":"-15.9","117":"1.239830","118":"19.2352","119":"405.659","120":"14.2012","121":"12.1229","122":"102.678","123":"NA","124":"NA","125":"NA","126":"NA","127":"NA","128":"NA","129":"NA","130":"NA","131":"NA","132":"NA","133":"NA","134":"NA","135":"NA","136":"NA","137":"NA","138":"NA","139":"NA","140":"NA","141":"NA","142":"NA","143":"NA","144":"NA","145":"NA","146":"NA","147":"NA","148":"NA","149":"NA","150":"NA","151":"NA","152":"NA","153":"NA","154":"NA","155":"NA","156":"NA","157":"NA","158":"NA","159":"NA","160":"NA","161":"NA","162":"NA","163":"NA","164":"NA","165":"NA","166":"NA","167":"NA","168":"NA","169":"NA","170":"NA","171":"NA","172":"NA","173":"NA","174":"2019.448","175":"20.062","176":"NA","177":"NA","178":"NA","_rn_":"4"},{"1":"2019.45","2":"<POSIXlt>","3":"NA","4":"NA","5":"NA","6":"NA","7":"NA","8":"NA","9":"NA","10":"NA","11":"NA","12":"NA","13":"NA","14":"NA","15":"NA","16":"NA","17":"NA","18":"NA","19":"NA","20":"NA","21":"NA","22":"NA","23":"NA","24":"NA","25":"NA","26":"NA","27":"NA","28":"NA","29":"NA","30":"NA","31":"NA","32":"NA","33":"NA","34":"NA","35":"NA","36":"NA","37":"NA","38":"NA","39":"NA","40":"NA","41":"NA","42":"NA","43":"NA","44":"NA","45":"NA","46":"NA","47":"NA","48":"NA","49":"NA","50":"NA","51":"NA","52":"NA","53":"NA","54":"NA","55":"NA","56":"NA","57":"NA","58":"NA","59":"NA","60":"NA","61":"NA","62":"NA","63":"NA","64":"NA","65":"NA","66":"NA","67":"NA","68":"NA","69":"NA","70":"NA","71":"NA","72":"NA","73":"NA","74":"NA","75":"NA","76":"NA","77":"NA","78":"NA","79":"NA","80":"NA","81":"NA","82":"NA","83":"NA","84":"NA","85":"NA","86":"NA","87":"NA","88":"NA","89":"NA","90":"NA","91":"NA","92":"NA","93":"NA","94":"NA","95":"NA","96":"NA","97":"NA","98":"NA","99":"NA","100":"NA","101":"NA","102":"NA","103":"NA","104":"NA","105":"NA","106":"NA","107":"NA","108":"NA","109":"NA","110":"NA","111":"NA","112":"NA","113":"NA","114":"NA","115":"NA","116":"NA","117":"NA","118":"NA","119":"NA","120":"NA","121":"NA","122":"NA","123":"NA","124":"NA","125":"NA","126":"NA","127":"NA","128":"NA","129":"NA","130":"NA","131":"NA","132":"NA","133":"NA","134":"NA","135":"NA","136":"NA","137":"NA","138":"NA","139":"NA","140":"NA","141":"NA","142":"NA","143":"NA","144":"NA","145":"NA","146":"NA","147":"NA","148":"NA","149":"NA","150":"NA","151":"NA","152":"NA","153":"NA","154":"NA","155":"NA","156":"NA","157":"NA","158":"NA","159":"NA","160":"NA","161":"NA","162":"NA","163":"NA","164":"NA","165":"NA","166":"NA","167":"NA","168":"NA","169":"NA","170":"NA","171":"NA","172":"NA","173":"NA","174":"2019.448","175":"NA","176":"NA","177":"NA","178":"NA","_rn_":"5"},{"1":"2019.45","2":"<POSIXlt>","3":"2019-06-14T190000_smart3-00177.ghg","4":"6/14/2019","5":"19:30","6":"165.8123","7":"0","8":"18000","9":"18000","10":"-0.110688","11":"0","12":"299.239","13":"0","14":"115.8370","15":"0","16":"-2.90573","17":"0","18":"2.62718","19":"0","20":"NA","21":"NA","22":"NA","23":"NA","24":"-2.97e-11","25":"-1.08e-12","26":"16.5047","27":"405.829","28":"411.923","29":"0","30":"0","31":"601.682","32":"14.7946","33":"15.0167","34":"0","35":"0","36":"24.739","37":"295.647","38":"99965.1","39":"1.17138","40":"1013.70","41":"0.0246","42":"0.170241","43":"0.0108","44":"1479.34","45":"2716.93","46":"0.00926","47":"54.4489","48":"1237.590","49":"285.972","50":"3.81162","51":"-0.263364","52":"-0.003910","53":"3.82071","54":"5.05e-14","55":"-1.80e-15","56":"3.82071","57":"8.29649","58":"233.450","59":"356.0470","60":"-0.058600","61":"NA","62":"0.307399","63":"1.63515","64":"-8.47345","65":"-0.425210","66":"2.58328","67":"-0.819801","68":"0","69":"47.2640","70":"-7.17249","71":"16.2242","72":"40.4005","73":"61.6134","74":"86.4136","75":"129.463","76":"-0.109359","77":"1.01216","78":"298.663","79":"1.02499","80":"84.3490","81":"1.08489","82":"-16.6289","83":"1.08489","84":"1.913040","85":"1.08489","86":"800000099","87":"800000099","88":"800000099","89":"800000099","90":"800000099","91":"800000099","92":"899999999","93":"899999999","94":"89999","95":"89999","96":"89","97":"89","98":"6","99":"7","100":"1","101":"12","102":"7","103":"14","104":"0","105":"0","106":"0","107":"0","108":"100","109":"1.09828","110":"1.90937","111":"0.262656","112":"NA","113":"0.00570","114":"82.2944","115":"0.251520","116":"-16.6","117":"1.913040","118":"19.2200","119":"405.828","120":"14.7946","121":"12.7505","122":"102.813","123":"NA","124":"NA","125":"NA","126":"NA","127":"NA","128":"NA","129":"NA","130":"NA","131":"NA","132":"NA","133":"NA","134":"NA","135":"NA","136":"NA","137":"NA","138":"NA","139":"NA","140":"NA","141":"NA","142":"NA","143":"NA","144":"NA","145":"NA","146":"NA","147":"NA","148":"NA","149":"NA","150":"NA","151":"NA","152":"NA","153":"NA","154":"NA","155":"NA","156":"NA","157":"NA","158":"NA","159":"NA","160":"NA","161":"NA","162":"NA","163":"NA","164":"NA","165":"NA","166":"NA","167":"NA","168":"NA","169":"NA","170":"NA","171":"NA","172":"NA","173":"NA","174":"2019.448","175":"22.497","176":"NA","177":"NA","178":"NA","_rn_":"6"}],"options":{"columns":{"min":{},"max":[10],"total":[178]},"rows":{"min":[10],"max":[10],"total":[6]},"pages":{}}}
  </script>
</div>

<!-- rnb-frame-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->




<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxuXG5cbnpMLmN1dC5ybmc8LWMoLTUsLTAuMSwwLjEsMSkgIyMgc2V0dGluZyB0aGUgMyBaL0wgcmFuZ2VzIGZvciBwbG90dGluZ1xuY3NwZWMuZGF0YS5wcmU8LU5VTExcblxuZGF0YS5wcmU8LWNkYXRhICBcblxuIyMgd29yayBvbiBmaWxlIG5hbWUgb2Ygc3BlY3RydW0gZmlsZXNcbmNzcGVjLm5hbWUubHMucGFyc2U8LXBhc3RlKFRJTUVTVEFNUCR5ZWFyKzE5MDAsXG4gICAgICAgICAgICAgICAgICAgICAgICAgICBzcHJpbnRmKFxcJTAyZFxcLFRJTUVTVEFNUCRtb24rMSksXG4gICAgICAgICAgICAgICAgICAgICAgICAgICBzcHJpbnRmKFxcJTAyZFxcLFRJTUVTVEFNUCRtZGF5KSxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgIFxcLVxcLFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgc3ByaW50ZihcXCUwMmRcXCxUSU1FU1RBTVAkaG91ciksXG4gICAgICAgICAgICAgICAgICAgICAgICAgICBzcHJpbnRmKFxcJTAyZFxcLFRJTUVTVEFNUCRtaW4pLFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgXFxfYmlubmVkX2Nvc3BlY3RyYVxcLFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgc2VwPVxcXFwpXG5gYGBcbmBgYCJ9 -->

```r
```r


zL.cut.rng<-c(-5,-0.1,0.1,1) ## setting the 3 Z/L ranges for plotting
cspec.data.pre<-NULL

data.pre<-cdata  

## work on file name of spectrum files
cspec.name.ls.parse<-paste(TIMESTAMP$year+1900,
                           sprintf(\%02d\,TIMESTAMP$mon+1),
                           sprintf(\%02d\,TIMESTAMP$mday),
                           \-\,
                           sprintf(\%02d\,TIMESTAMP$hour),
                           sprintf(\%02d\,TIMESTAMP$min),
                           \_binned_cospectra\,
                           sep=\\)
```
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiRXJyb3IgaW4gcGFzdGUoVElNRVNUQU1QJHllYXIgKyAxOTAwLCBzcHJpbnRmKFxcJTAyZFxcLCBUSU1FU1RBTVAkbW9uICsgIDogXG4gIG9iamVjdCAnVElNRVNUQU1QJyBub3QgZm91bmRcbiJ9 -->

```
Error in paste(TIMESTAMP$year + 1900, sprintf(\%02d\, TIMESTAMP$mon +  : 
  object 'TIMESTAMP' not found
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->




<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxuIyMgc2NhbiBpZiBzcGVjdHJ1bSBmaWxlcyBleGlzdFxuY3NwZWMubmFtZS5sczwtcmVwKE5BLGxlbmd0aChjc3BlYy5uYW1lLmxzLnBhcnNlKSlcbmBgYFxuYGBgIn0= -->

```r
```r
## scan if spectrum files exist
cspec.name.ls<-rep(NA,length(cspec.name.ls.parse))
```
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiRXJyb3I6IG9iamVjdCAnY3NwZWMubmFtZS5scy5wYXJzZScgbm90IGZvdW5kXG4ifQ== -->

```
Error: object 'cspec.name.ls.parse' not found
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->





<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxuIyMgd2hpY2ggc3BlY3RydW0gdmFyaWFibGVzIHRvIHBsb3QgXG50YXJnZXQuY3NwZWM8LWMoXFxmU3dcXCxcXGZTdFxcLFxcZlNjXFwsXFxmU3FcXCxcbiAgICAgICAgICAgICAgICBcXGZDd3VcXCxcXGZDd3RcXCxcXGZDd2NcXCxcXGZDd3FcXClcbmBgYFxuYGBgIn0= -->

```r
```r
## which spectrum variables to plot 
target.cspec<-c(\fSw\,\fSt\,\fSc\,\fSq\,
                \fCwu\,\fCwt\,\fCwc\,\fCwq\)
```
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


#for running just one month comment out 331


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxuIyMjIGxvb3AgdGhyb3VnaCB0aGUgc3BldHJ1bSBmaWxlcywgY29tYmluZSB0aGVtIGludG8gYSBzaW5nbGUgZGF0YWZyYW1lIGZvciBwbG90dGluZ1xubW9udGguaWQ8LXBhc3RlMChUSU1FU1RBTVAkeWVhcisxOTAwLFxcLVxcLHNwcmludGYoXFwlMDJkXFwsVElNRVNUQU1QJG1vbisxKSlcbm1vbnRoLmlkLmxzPC1saXN0KG5hbWVzKHRhYmxlKG1vbnRoLmlkKSksXG4gICAgICAgICAgICAgICAgICBhcy52ZWN0b3IodGFibGUobW9udGguaWQpKSlcbiNjYW4gY29tbWVudCBvdXQgMzUxIGlmIHlvdSB3YW50IHRvIHJ1biBqdXN0IG9uZSBtb250aFxuI2ZvcihqMSBpbiAxOmxlbmd0aChtb250aC5pZC5sc1tbMV1dKSl7XG5qMT0xICNhZGQganVzdCB0aGUgbW9udGggaGVlcmUuIGNvbW1lbnQgb3V0IGlmIHdhbiB0byBydW4gZnVsbCBsb29wXG5jc3BlYy5kYXRhLnByZTwtZGF0YS5mcmFtZSgpXG50YXJnZXQubW9uPC1tb250aC5pZC5sc1tbMV1dW2oxXVxudGFyZ2V0Lm1vbi5sb2M8LXdoaWNoKG1vbnRoLmlkPT10YXJnZXQubW9uKVxuXG5wcmludChwYXN0ZTAoXFwjIyMjIyMgIFxcLHRhcmdldC5tb24sXFwgICMjIyMjI1xcKSlcblxuZm9yKGkxIGluIDE6bGVuZ3RoKGNzcGVjLm5hbWUubHNbdGFyZ2V0Lm1vbi5sb2NdKSl7XG4gIGlmKGNzcGVjLmZpbGUuZXhpc3RbdGFyZ2V0Lm1vbi5sb2NdW2kxXSl7XG4gICAgXG4gICAgIyMgcmVhZCBpbiBlYWNoIChjbylzcGVjdHJhIGZpbGVzXG4gICAgY3NwZWMuZGF0YTwtcmVhZC5jc3YocGFzdGUoZWRkeXByby5wYXRoLFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIFxcZWRkeXByb19iaW5uZWRfY29zcGVjdHJhXFxcXFxcLFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGNzcGVjLm5hbWUubHNbdGFyZ2V0Lm1vbi5sb2NdW2kxXSxzZXA9XFxcXCksXG4gICAgICAgICAgICAgICAgICAgICAgICAgc2tpcD0xMSxcbiAgICAgICAgICAgICAgICAgICAgICAgICBoZWFkZXI9VCxcbiAgICAgICAgICAgICAgICAgICAgICAgICBuYS5zdHJpbmdzPWMoXFwtOTk5OVxcLFxcLTk5OTkuMFxcKSlcbiAgICBcbiAgICBjb2xuYW1lcyhjc3BlYy5kYXRhKTwtY3NwZWMudmFyLm5hbWVcbiAgICBcbiAgICAjIyBjb21iaW5lIHNwZXRydW0gZGF0YSB3aXRoIGJhc2ljIHN0YXRlIHZhcmlhYmxlcywgZS5nLiwgV1MsIFdEXG4gICAgY3NwZWMuZGF0YS50bXA8LWRhdGEuZnJhbWUoZGF0ZT1yZXAoZGF0YS5wcmUkZGF0ZVt0YXJnZXQubW9uLmxvY11baTFdLG5yb3coY3NwZWMuZGF0YSkpLFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHRpbWU9cmVwKGRhdGEucHJlJHRpbWVbdGFyZ2V0Lm1vbi5sb2NdW2kxXSxucm93KGNzcGVjLmRhdGEpKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB6TD1yZXAoZGF0YS5wcmUkWC56LmQuLkxbdGFyZ2V0Lm1vbi5sb2NdW2kxXSxucm93KGNzcGVjLmRhdGEpKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBMPXJlcChkYXRhLnByZSRMW3RhcmdldC5tb24ubG9jXVtpMV0sbnJvdyhjc3BlYy5kYXRhKSksXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgV1M9cmVwKGRhdGEucHJlJHdpbmRfc3BlZWRbdGFyZ2V0Lm1vbi5sb2NdW2kxXSxucm93KGNzcGVjLmRhdGEpKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBXRD1yZXAoZGF0YS5wcmUkd2luZF9kaXJbdGFyZ2V0Lm1vbi5sb2NdW2kxXSxucm93KGNzcGVjLmRhdGEpKSxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBjc3BlYy5kYXRhWyxjc3BlYy52YXIubmFtZS5zZWxlY3RdKVxuICAgIFxuICAgICMjIyBmaWx0ZXIgc3BldHJ1bSBkYXRhIGJhc2VkIG9uIGNvcnJlc3BvbmRpbmcgdmFyaWFuY2UvY292YXJpYW5jZVxuICAgIFxuICAgIGlmKGlzLm5hKGRhdGEucHJlJHUuW3RhcmdldC5tb24ubG9jXVtpMV0pKXtcbiAgICAgIGNzcGVjLmRhdGEudG1wJGZTdTwtTkFcbiAgICAgIGNzcGVjLmRhdGEudG1wJGZDd3U8LU5BXG4gICAgICBjc3BlYy5kYXRhLnRtcCRmU3Y8LU5BXG4gICAgICBjc3BlYy5kYXRhLnRtcCRmQ3d2PC1OQVxuICAgICAgY3NwZWMuZGF0YS50bXAkZlN3PC1OQVxuICAgIH1cbiAgICBpZihpcy5uYShkYXRhLnByZSRIW3RhcmdldC5tb24ubG9jXVtpMV0pKXtcbiAgICAgIGNzcGVjLmRhdGEudG1wJGZTdDwtTkFcbiAgICAgIGNzcGVjLmRhdGEudG1wJGZDd3Q8LU5BXG4gICAgfVxuICAgIGlmKGlzLm5hKGRhdGEucHJlJGNvMl9mbHV4W3RhcmdldC5tb24ubG9jXVtpMV0pKXtcbiAgICAgIGNzcGVjLmRhdGEudG1wJGZTYzwtTkFcbiAgICAgIGNzcGVjLmRhdGEudG1wJGZDd2M8LU5BXG4gICAgfVxuICAgIGlmKGlzLm5hKGRhdGEucHJlJExFW3RhcmdldC5tb24ubG9jXVtpMV0pKXtcbiAgICAgIGNzcGVjLmRhdGEudG1wJGZTcTwtTkFcbiAgICAgIGNzcGVjLmRhdGEudG1wJGZDd3E8LU5BXG4gICAgfVxuICAgIGNzcGVjLmRhdGEucHJlPC1yYmluZC5kYXRhLmZyYW1lKGNzcGVjLmRhdGEucHJlLGNzcGVjLmRhdGEudG1wKVxuICB9ZWxzZXtcbiAgICBwcmludChwYXN0ZShjc3BlYy5uYW1lLmxzLnBhcnNlW3RhcmdldC5tb24ubG9jXVtpMV0sXFxoYXMgbm8gc3BlY3RydW0gZmlsZXNcXCkpICBcbiAgfSAgICAgICAgICAgICAgICAgICAgICAgXG59XG5cblxuIyMjIG91dHB1dCBzaXRlLXNwZWNpZmljIChjbylzcGVjdHJhIGZpbGUgKGNvbXBvc2l0ZSBhbGwgcmVjb3JkcylcbndyaXRlLmNzdihjc3BlYy5kYXRhLnByZSxcbiAgICAgICAgICBwYXN0ZTAocGxvdC5wYXRoLFxuICAgICAgICAgICAgICAgICB0YXJnZXQubW9uLFxuICAgICAgICAgICAgICAgICBcXF9jb3NwZWN0cmFfY29tcGlsZWRfXFwsXG4gICAgICAgICAgICAgICAgIFN5cy5EYXRlKCksXFwuY3N2XFwsXG4gICAgICAgICAgICAgICAgIHNlcD1cXFxcKSxcbiAgICAgICAgICByb3cubmFtZXM9RilcblxuIyMjIyBsb29wIHRocm91Z2ggdGhlIHRhcmdldC52YXIsIGRvIHNwZXRydW0gcGxvdHRpbmcgXG5mb3IobTIgaW4gMTpsZW5ndGgodGFyZ2V0LmNzcGVjKSl7XG4gIFxuICBjb3NwZWN0cmFfcGxvdDMoY3NwZWMuZGF0YS5wcmU9Y3NwZWMuZGF0YS5wcmUsXG4gICAgICAgICAgICAgICAgICB0YXJnZXQudmFyPXRhcmdldC5jc3BlY1ttMl0sIFxuICAgICAgICAgICAgICAgICAgY2FzZT1cXENvbmNvcmRcXCxcbiAgICAgICAgICAgICAgICAgIHllYXI9VElNRVNUQU1QJHllYXJbdGFyZ2V0Lm1vbi5sb2NdWzFdKzE5MDAsXG4gICAgICAgICAgICAgICAgICBkb3kuaT1USU1FU1RBTVAkeWRheVt0YXJnZXQubW9uLmxvY11bMV0rMSxcbiAgICAgICAgICAgICAgICAgIGRveS5mPVRJTUVTVEFNUCR5ZGF5W3RhcmdldC5tb24ubG9jXVtsZW5ndGgodGFyZ2V0Lm1vbi5sb2MpXSsxLFxuICAgICAgICAgICAgICAgICAgb3V0cHV0PVQsXG4gICAgICAgICAgICAgICAgICBvdXREaXI9cGxvdC5wYXRoLFxuICAgICAgICAgICAgICAgICAgcGxvdC5sb2Vzcz1ULFxuICAgICAgICAgICAgICAgICAgcG9zdGZpeD1wYXN0ZTAoXFxfXFwsU3lzLkRhdGUoKSksXG4gICAgICAgICAgICAgICAgICBsb2cueS52YWx1ZT1ULFxuICAgICAgICAgICAgICAgICAgekwuY3V0LnJuZz16TC5jdXQucm5nKSAgXG4gIFxufVxuI30gI2NvbW1lbnQgb3V0IGZvciBqdXN0IHJ1bm5pbmcgb25lIG1vbnRoLiByZW1vdmUgIyBpZiB5b3Ugd2FudCB0byBydW4gYSBmdWxsIGxvb3AuIFxuXG5cblxuYGBgXG5gYGAifQ== -->

```r
```r
### loop through the spetrum files, combine them into a single dataframe for plotting
month.id<-paste0(TIMESTAMP$year+1900,\-\,sprintf(\%02d\,TIMESTAMP$mon+1))
month.id.ls<-list(names(table(month.id)),
                  as.vector(table(month.id)))
#can comment out 351 if you want to run just one month
#for(j1 in 1:length(month.id.ls[[1]])){
j1=1 #add just the month heere. comment out if wan to run full loop
cspec.data.pre<-data.frame()
target.mon<-month.id.ls[[1]][j1]
target.mon.loc<-which(month.id==target.mon)

print(paste0(\######  \,target.mon,\  ######\))

for(i1 in 1:length(cspec.name.ls[target.mon.loc])){
  if(cspec.file.exist[target.mon.loc][i1]){
    
    ## read in each (co)spectra files
    cspec.data<-read.csv(paste(eddypro.path,
                               \eddypro_binned_cospectra\\\,
                               cspec.name.ls[target.mon.loc][i1],sep=\\),
                         skip=11,
                         header=T,
                         na.strings=c(\-9999\,\-9999.0\))
    
    colnames(cspec.data)<-cspec.var.name
    
    ## combine spetrum data with basic state variables, e.g., WS, WD
    cspec.data.tmp<-data.frame(date=rep(data.pre$date[target.mon.loc][i1],nrow(cspec.data)),
                               time=rep(data.pre$time[target.mon.loc][i1],nrow(cspec.data)),
                               zL=rep(data.pre$X.z.d..L[target.mon.loc][i1],nrow(cspec.data)),
                               L=rep(data.pre$L[target.mon.loc][i1],nrow(cspec.data)),
                               WS=rep(data.pre$wind_speed[target.mon.loc][i1],nrow(cspec.data)),
                               WD=rep(data.pre$wind_dir[target.mon.loc][i1],nrow(cspec.data)),
                               cspec.data[,cspec.var.name.select])
    
    ### filter spetrum data based on corresponding variance/covariance
    
    if(is.na(data.pre$u.[target.mon.loc][i1])){
      cspec.data.tmp$fSu<-NA
      cspec.data.tmp$fCwu<-NA
      cspec.data.tmp$fSv<-NA
      cspec.data.tmp$fCwv<-NA
      cspec.data.tmp$fSw<-NA
    }
    if(is.na(data.pre$H[target.mon.loc][i1])){
      cspec.data.tmp$fSt<-NA
      cspec.data.tmp$fCwt<-NA
    }
    if(is.na(data.pre$co2_flux[target.mon.loc][i1])){
      cspec.data.tmp$fSc<-NA
      cspec.data.tmp$fCwc<-NA
    }
    if(is.na(data.pre$LE[target.mon.loc][i1])){
      cspec.data.tmp$fSq<-NA
      cspec.data.tmp$fCwq<-NA
    }
    cspec.data.pre<-rbind.data.frame(cspec.data.pre,cspec.data.tmp)
  }else{
    print(paste(cspec.name.ls.parse[target.mon.loc][i1],\has no spectrum files\))  
  }                       
}


### output site-specific (co)spectra file (composite all records)
write.csv(cspec.data.pre,
          paste0(plot.path,
                 target.mon,
                 \_cospectra_compiled_\,
                 Sys.Date(),\.csv\,
                 sep=\\),
          row.names=F)

#### loop through the target.var, do spetrum plotting 
for(m2 in 1:length(target.cspec)){
  
  cospectra_plot3(cspec.data.pre=cspec.data.pre,
                  target.var=target.cspec[m2], 
                  case=\Concord\,
                  year=TIMESTAMP$year[target.mon.loc][1]+1900,
                  doy.i=TIMESTAMP$yday[target.mon.loc][1]+1,
                  doy.f=TIMESTAMP$yday[target.mon.loc][length(target.mon.loc)]+1,
                  output=T,
                  outDir=plot.path,
                  plot.loess=T,
                  postfix=paste0(\_\,Sys.Date()),
                  log.y.value=T,
                  zL.cut.rng=zL.cut.rng)  
  
}
#} #comment out for just running one month. remove # if you want to run a full loop. 

```
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->








<!-- rnb-text-end -->

