#### Custom function for labeling panels in ggplot
#### From: https://stackoverflow.com/questions/17576381/label-individual-panels-in-a-multi-panel-ggplot2
require(ggplot2)
make_labelstring <- function(mypanels) {
  mylabels <- sapply(mypanels, 
                     function(x) {LETTERS[which(mypanels == x)]})
  
  return(mylabels)
}
label_panels <- ggplot2::as_labeller(make_labelstring)
