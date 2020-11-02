
#library(magrittr)
#library(hyperSpec)
library(dplyr)
library(readtext)
#library(rio)
#library(foreign)
library(ggplot2)
library(hexbin)
library(devtools)
#library(plotly)
library(reshape2)
#library(EEM)

#############################################################
# Data should be add by user


### Pathway of imported spectra files
Dataset_pathway <- ('C:/Users/fedorko.j/SynologyDrive/Pr?ce/Organismy/Synechocystis/projects/SynBatch/Data/EE spectra grouwth curves Izrael/')
#c:/Users/Fedor/Documents/CloudStation/Pr?ce/Organismy/Synechocystis/projects/SynBatch/Data/EE spectra grouwth curves Izrael/
#C:/Users/fedorko.j/SynologyDrive/Pr?ce/Organismy/Synechocystis/projects/SynBatch/Data/EE spectra grouwth curves Izrael/

#Set pathway where the graphs should be saved
G_export_pathway <- ('C:/Users/fedorko.j/SynologyDrive/Pr?ce/Organismy/Synechocystis/projects/SynBatch/Data/Data test/Graphs')
#C:/Users/fedorko.j/SynologyDrive/Pr?ce/Organismy/Synechocystis/projects/SynBatch/Data/Data test/Graphs

#Set pathway where the .csv files should be saved
csv_export_pathway <- ('C:/Users/fedorko.j/SynologyDrive/Pr?ce/Organismy/Synechocystis/projects/SynBatch/Data/Data test/CSV')

setwd('C:/Users/fedorko.j/SynologyDrive/Pr?ce/Organismy/Synechocystis/projects/SynBatch/Data/')#set working directory (defaultly same as pathway of imported files)

### Global variables
#z-axis Emission treshold in plots - decision step - when you want to apply treshold, write "y", when not applied write "n"
treshold <- "n" 

# When treshold for z-axis in plots is applied, set treshold values
Z_value_max_for_contour_plot  <-  4500 
Z_value_min_for_contour_plot <- 0

# Set colotrs pallete in plots
colour_plot <- c("gray20","gray8","darkblue","darkgreen", "green","lightgreen", "yellow", "orange", "darkorange", "red", "darkred", "white" )
#black","gray8","gray20","darkblue","navy","darkgreen", "green","lightgreen", "yellow", "orange", "darkorange", "red", "darkred", "white" 
scale_ratio  <-  1
width_plot <- 15
height_plot <- 7
units_plot <- "cm" #"in", "cm", or "mm"

#Set excitation spectra wchich was used
excitation_spectra <- seq(from=360, to=610, by = 5)
#############################################################

#Prepare a list of all data files 
dataset_list <- list.files(path = Dataset_pathway, ignore.case = T )

#Sort a list alphabetically
dataset_list <-  sort(dataset_list)

#Create list of pathways of individual data folders 
Dataset_pathway_list <- file.path(Dataset_pathway, c(dataset_list))

#Loop for opening all files
for (i in 1:length(dataset_list)){
  
  file_name <- dataset_list[i] #Name for expotred file
  
  pathway <- paste(Dataset_pathway,file_name,  sep = '')
  
  #Make a list of spectra files in each data folder  
  file_list <- list.files(path = pathway, pattern="*.SPC", ignore.case = T ) 
  
  file_list <- sort(file_list)
  
  #create (character) vector which contains of pathway for each spectra file in file_list (data folder)
  pathway_list <- file.path(pathway, c(file_list))
  
  #Make a list that includes all spectra files in file_list (data folder)
  data_list <- lapply(pathway_list , read.spc)
  names(data_list) <- file_list #Name individual rows in the list according to spectra files names (Disc_00 etc.)
  
  #make first line of table
  spc_data <- data_list[[1]]@data$spc
  
  
  #Create dataframe with whole Ex-Em spectra matrix
  #some files have wavelengths in reverese oreder - this condition makes the dataframe uniform
  for (j in 2:length(file_list)){
    if(data_list[[j]]@wavelength[1] == 720){
      spc_data <- rbind(spc_data, rev(data_list[[j]]@data$spc))
    }else{
      spc_data <- rbind(spc_data, data_list[[j]]@data$spc)
    }
  }
  
  #Set data as a matrix
  spc_data <-  as.matrix(spc_data)
  
  #Find the lowes value
  spc_nim <- min(spc_data, na.rm = FALSE)
  #Substract the minimal value from all values -> minimal values is 0
  spc_data <- spc_data - spc_nim
  
  #Remove possible artefacts
  spc_data[1,50:51] <- 0
  
  #add col and rownames to table
  x_axis <- data_list[[1]]@wavelength
  y_axis <- excitation_spectra
  row.names(spc_data) <- y_axis
  colnames(spc_data) <- x_axis
  
  
  #set if you want to applay a z-axis treshold
  if("y" == tolower(treshold)){
    spc_data <- pmin(spc_data, Z_value_max_for_contour_plot)
  }
  else{
    spc_data <- spc_data
    
  }
  
  #Set directory for saving .csv files (full Ex-Em matrix)
  setwd(csv_export_pathway)
  spc_data_export <- write.csv(spc_data, file =paste(file_name, ".csv", sep = "" ))
  
  
  #Melt data - necessary for plotting: Var1=ex, Var2=em, data > make a graph
  library(reshape2)
  library(manipulate)
  eem_3d =spc_data %>%
    reshape2::melt() %>%
    ggplot() +
    geom_tile(aes(x=Var1,y=Var2,fill=value)) +
    scale_x_continuous("Excitation wavelength [nm]",expand = c(0,0)) +
    scale_y_continuous("Emission wavelength [nm]",expand = c(0,0)) +
    scale_fill_gradientn("Fluorescence intensity [a.u.]",
                         colours = colour_plot , 
                         limits = c(Z_value_min_for_contour_plot, Z_value_max_for_contour_plot) ) +
    geom_raster(aes(x=Var1,y=Var2, fill=value),interpolate=TRUE) +
    theme(aspect.ratio = scale_ratio , legend.position = "right")
  
  
  #eem_3d <-  egg::set_panel_size(p=eem_3d, width=unit(10, "cm"), height=unit(10, "cm"))
  ggsave( scale = scale_ratio , width = width_plot, height = height_plot, units = units_plot, dpi = 300, limitsize = F, plot = eem_3d, 
          filename = paste(file_name, ".jpg", sep = ""), device = "jpg", path = G_export_pathway)  
  
  print(eem_3d )
  
}
#plot.margin = margin(10, 10, "cm"), scale = 1,
######################################

