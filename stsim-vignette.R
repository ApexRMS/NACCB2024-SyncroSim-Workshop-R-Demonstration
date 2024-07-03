# Introduction to ST-Sim in rsyncrosim
# NACCB 2024 - SyncroSim Workshop

# Last edited by: ApexRMS, June 21, 2024

# IMPORTANT SETUP INSTRUCTIONS
#
# Before running this script:
#   1. Install SyncroSim software (preferably Windows version - see 
#      www.syncrosim.com/download)
#   2. Install rysncrosim and terra R packages (from CRAN)
#
# Note that this Exercise was developed against the following:
#   SyncroSim - version 2.5.14 (note that instructions below assume Windows 
#               version but works also with Linux)
#   R - version 4.3.1
#   SyncroSim packages:
#      stsim - version 3.4.5
#   R packages:
#      rsyncrosim - version 1.5.0
#      terra - version 1.7-55
#      this.path - version 2.3.1
#      dplyr - version 1.1.3
#      ggplot2 - version 3.4.4

# ******************************************************************************
# Task 1: Setup ----------------------------------------------------------------
# ******************************************************************************

# Load R packages
library(rsyncrosim)  # package for working with SyncroSim
library(terra)       # package for working with spatial data
library(this.path)   # package for setting the working directory
library(dplyr)       # package for dataframe manipulation
library(ggplot2)     # package for visualizing results


# Check if the stsim SyncroSim package is installed (and install if necessary)
myInstalledPackages = package()
if (!(is.element("stsim", myInstalledPackages$name))) {
  addPackage("stsim")
}

# set the working folder to the folder of this R script
setwd(this.dir()) 
getwd()

# ******************************************************************************
# Task 2: Create SyncroSim Library ---------------------------------------------
# ******************************************************************************

# Connecting R to SyncroSim using session()
mySession <- session()  # Using default install folder (Windows only)
mySession               # Displays the Session object

# Create a new Library
myLibrary <- ssimLibrary(name = "stsimLibrary.ssim",
                         session = mySession,
                         package = "stsim",
                         overwrite = TRUE)

# Open the default Project
myProject <- rsyncrosim::project(ssimObject = myLibrary, project = "Definitions")

# Create a new Scenario (associated with the default Project)
myScenario <- scenario(ssimObject = myProject, scenario = "My spatial scenario")

# View all Datasheets associated with a Library, Project, or Scenario
datasheet_list <- datasheet(myScenario)
head(datasheet_list)
tail(datasheet_list)

# ******************************************************************************
# Go to SyncroSim for Windows and open library
# ******************************************************************************


# ******************************************************************************
# Task 3: Add Model Data -------------------------------------------------------
# ******************************************************************************

## Configure project-scoped datasheets ----

### Terminology ----

# Load the Terminology Datasheet to a new R data frame 
terminology <- datasheet(myProject, name = "stsim_Terminology")

# Check the columns of the Terminology data frame
str(terminology)

# Edit the values of the StateLabelX and AmountUnits columns
terminology$AmountUnits <- "hectares"
terminology$StateLabelX <- "Forest Type"

# Saves edits as a SyncroSim Datasheet
saveDatasheet(myProject, terminology, "stsim_Terminology") 

### Stratum ----

# To load an empty copy of this Datasheet, specify the argument empty = TRUE in the datasheet() function.
stratum <- datasheet(myProject, "stsim_Stratum", empty = TRUE)

# Use the addRow() to add a value to the stratum  data frame
stratum <- addRow(stratum, "Entire Forest")

# Save edits as a SyncroSim Datasheet
saveDatasheet(myProject, stratum, "stsim_Stratum", force = TRUE)

### State Label X ----

# Create a vector containing the State Class labels 
forestTypes <- c("Coniferous", "Deciduous", "Mixed")

# Add values as a data frame to a SyncroSim Datasheet
saveDatasheet(myProject, 
              data.frame(Name = forestTypes), 
              "stsim_StateLabelX", 
              force = TRUE)

### State Label Y ----

# Add values as a data frame directly to an stsim Datasheet
saveDatasheet(myProject, 
              data.frame(Name = c("All")), 
              "stsim_StateLabelY", 
              force = TRUE)

### State Classes ----

# Create a new R data frame containing the names of the State Classes and their corresponding data
stateClasses <- data.frame(Name = forestTypes)
stateClasses$StateLabelXID <- stateClasses$Name
stateClasses$StateLabelYID <- "All"
stateClasses$ID <- c(1, 2, 3)

# Save stateClasses R data frame to a SyncroSim Datasheet
saveDatasheet(myProject, stateClasses, "stsim_StateClass", force = TRUE)

### Transition Types ----

# Create an R data frame containing transition type data 
transitionTypes <- data.frame(Name = c("Fire", "Harvest", "Succession"), 
                              ID = c(1, 2, 3))

# Save transitionTypes R data frame to a SyncroSim Datasheet
saveDatasheet(myProject, transitionTypes, "stsim_TransitionType", force = TRUE)

### Transition Groups ----

# Create an R data frame containing a column of transition type names 
transitionGroups <- data.frame(Name = c("Fire", "Harvest", "Succession"))

# Save transitionGroups R data frame to a SyncroSim Datasheet
saveDatasheet(myProject, transitionGroups, "TransitionGroup", force = T)

### Transition Types by Group ----

# Create an R data frame that contains Transition Type Group names
transitionTypesGroups <- data.frame(TransitionTypeID = transitionTypes$Name,
                                    TransitionGroupID = transitionGroups$Name)

# Save transitionTypesGroups R data frame to a SyncroSim Datasheet
saveDatasheet(myProject, 
              transitionTypesGroups, 
              "TransitionTypeGroup", 
              force = T)

### Ages ----
# Define values for age reporting
ageFrequency <- 1
ageMax <- 101
ageGroups <- c(20, 40, 60, 80, 100)

# Add values as R data frames to the appropriate SyncroSim Datasheet
saveDatasheet(myProject, 
              data.frame(Frequency = ageFrequency, MaximumAge = ageMax),
              "AgeType", 
              force = TRUE)

# ******************************************************************************
# Go to SyncroSim for Windows and select "File | Refresh All Libraries"
# While still in SyncroSim for Windows, double-click on the project 
# "Definitions" to see that all the above datasheets have been filled out
# ******************************************************************************

## Configure scenario-scoped datasheets ----

### Create a new SyncroSim Scenario ----

myScenario <- scenario(myProject, "No Harvest")

# Subset the full Datasheet list to show only Scenario-scoped Datasheets
scenario_datasheet_list <- subset(datasheet(myScenario, summary = TRUE),
                                  scope == "scenario")

head(scenario_datasheet_list)
tail(scenario_datasheet_list)

### Run Control ----

# Create an R data frame specifying to run the simulation for 7 realizations and 10 timesteps
runControl <- data.frame(MaximumIteration = 7,
                         MinimumTimestep = 0,
                         MaximumTimestep = 10,
                         IsSpatial = TRUE)

# Save transitionTypesGroups R data frame to a SyncroSim Datasheet
saveDatasheet(myScenario, runControl, "stsim_RunControl",append = FALSE)

### Deterministic Transitions ----

# Load  an empty Deterministic Transitions Datasheet to a new R data frame
dTransitions <- datasheet(myScenario, 
                          "stsim_DeterministicTransition", 
                          optional = T, 
                          empty = T)

# Add all Deterministic Transitions to the R data frame
dTransitions <- addRow(dTransitions, data.frame(
  StateClassIDSource = "Coniferous",
  StateClassIDDest = "Coniferous",
  AgeMin = 21,
  Location = "C1"))
dTransitions <- addRow(dTransitions, data.frame(
  StateClassIDSource = "Deciduous",
  StateClassIDDest = "Deciduous",
  Location = "A1"))
dTransitions <- addRow(dTransitions, data.frame(
  StateClassIDSource = "Mixed",
  StateClassIDDest = "Mixed",
  AgeMin = 11,
  Location = "B1"))

# Save dTransitions R data frame to a SyncroSim Datasheet
saveDatasheet(myScenario, dTransitions, "stsim_DeterministicTransition")

### Probabilistic Transitions ----

# Load  an empty Probabilistic Transitions Datasheet to a new R data frame
pTransitions <- datasheet(myScenario, "stsim_Transition", optional = T,
                          empty = T)

# Add all Probabilistic Transitions to the R data frame
pTransitions <- addRow(pTransitions, data.frame(
  StateClassIDSource = "Coniferous", 
  StateClassIDDest = "Deciduous", 
  TransitionTypeID = "Fire", 
  Probability = 0.01))
pTransitions <- addRow(pTransitions, data.frame(
  StateClassIDSource = "Coniferous",
  StateClassIDDest = "Deciduous", 
  TransitionTypeID = "Harvest", 
  Probability = 1, 
  AgeMin = 40))
pTransitions <- addRow(pTransitions, data.frame(
  StateClassIDSource = "Deciduous",
  StateClassIDDest = "Deciduous", 
  TransitionTypeID = "Fire", 
  Probability = 0.002))
pTransitions <- addRow(pTransitions, data.frame(
  StateClassIDSource = "Deciduous",
  StateClassIDDest = "Mixed", 
  TransitionTypeID = "Succession", 
  Probability = 0.1, 
  AgeMin = 10))
pTransitions <- addRow(pTransitions, data.frame(
  StateClassIDSource = "Mixed", 
  StateClassIDDest = "Deciduous", 
  TransitionTypeID = "Fire", 
  Probability = 0.005))
pTransitions <- addRow(pTransitions, data.frame(
  StateClassIDSource = "Mixed", 
  StateClassIDDest = "Coniferous",
  TransitionTypeID = "Succession", 
  Probability = 0.1, 
  AgeMin = 20))

# Save pTransitions R data frame to a SyncroSim Datasheet
saveDatasheet(myScenario, pTransitions, "stsim_Transition")

### Initial Conditions ----

# Load sample .tif files
stratumTif <- file.path(getwd(), "initial-stratum.tif")
sclassTif <- file.path(getwd(), "initial-sclass.tif")
ageTif <- file.path(getwd(), "./initial-age.tif")

# Create raster layers from the .tif files
rStratum <- rast(stratumTif)
rSclass <- rast(sclassTif)
rAge <- rast(ageTif)

# Plot raster layers
plot(rStratum)
plot(rSclass)
plot(rAge)

# Create an R list of the input raster layers
ICSpatial <- list(StratumFileName = stratumTif, 
                  StateClassFileName = sclassTif, 
                  AgeFileName = ageTif)

# Save initialConditionsSpatial R list to a SyncroSim Datasheet
saveDatasheet(myScenario, ICSpatial, "stsim_InitialConditionsSpatial")

### Transition Targets ----

# Set the transition target for harvest to 0
saveDatasheet(myScenario, 
              data.frame(TransitionGroupID = "Harvest", 
                         Amount = 0),
              "stsim_TransitionTarget")

### Output Options ----

# Create output options for spatial model and add it to an R data frame
outputOptionsSpatial <- data.frame(
  RasterOutputSC = T, RasterOutputSCTimesteps = 1,
  RasterOutputTR = T, RasterOutputTRTimesteps = 1,
  RasterOutputAge = T, RasterOutputAgeTimesteps = 1
)

# Save the outputOptionsSpatial R data frame to a SyncroSim Datasheet
saveDatasheet(myScenario, outputOptionsSpatial, "stsim_OutputOptionsSpatial")

# Create output options for non-spatial model and add it to an R data frame
outputOptionsNonSpatial <- data.frame(
  SummaryOutputSC = T, SummaryOutputSCTimesteps = 1,
  SummaryOutputTR = T, SummaryOutputTRTimesteps = 1
)

# Save the outputOptionsNonSpatial R data frame to a SyncroSim Datasheet
saveDatasheet(myScenario, outputOptionsNonSpatial, "stsim_OutputOptions")

### Copy scenario ----

# Create a copy of the no harvest scenario (i.e myScenario) and 
# name it myScenarioHarvest
myScenarioHarvest <- scenario(myProject, 
                              scenario = "Harvest", 
                              sourceScenario = myScenario)

# Set the transition target for harvest to 20 hectares/year
saveDatasheet(myScenarioHarvest, data.frame(TransitionGroupID = "Harvest", 
                                            Amount = 20), 
              "stsim_TransitionTarget")

### Compare scenarios ----
# View the transition targets for the Harvest and No Harvest scenarios
datasheet(myProject, scenario = c("Harvest", "No Harvest"), 
          name = "stsim_TransitionTarget")

# ******************************************************************************
# Go to SyncroSim for Windows and select "File | Refresh All Libraries"
# While still in SyncroSim for Windows, double-click on the scenarios 
# "Harvest" and "No Harvest" to see that all the above datasheets have been 
# filled out
# ******************************************************************************

# ******************************************************************************
# Task 4: Run Scenarios --------------------------------------------------------
# ******************************************************************************

myResultScenario <- run(myProject, scenario = c("Harvest", "No Harvest"), 
                        jobs = 7, summary = TRUE)

# ******************************************************************************
# Task 5: View Results ---------------------------------------------------------
# ******************************************************************************

# Retrieve scenario IDs
resultIDNoHarvest <- subset(myResultScenario, 
                            ParentID == scenarioId(myScenario))$ScenarioID
resultIDHarvest <- subset(myResultScenario, 
                          ParentID == scenarioId(myScenarioHarvest))$ScenarioID

# Retrieve output projected State Class for both Scenarios in tabular form
outputStratumState <- datasheet(
  myProject, 
  scenario = c(resultIDNoHarvest, resultIDHarvest), 
  name = "stsim_OutputStratumState")

outputStratumStateSummary <- outputStratumState %>%
  group_by(ParentName, Timestep, StateClassID) %>%
  summarize(MeanAmount = mean(Amount)) %>%
  rename(Scenario = ParentName)

ggplot(outputStratumStateSummary) +
  geom_line(aes(x = Timestep, y = MeanAmount, 
                colour = Scenario, lty = Scenario), 
            linewidth=1) +
  facet_wrap(~StateClassID) +
  theme_classic() +
  ylab("Area (hectares)")

# Retrieve the output State Class raster for the Harvest scenario at timestep 5
myRastersTimestep5 <- datasheetSpatRaster(ssimObject = myProject, 
                                          scenario = resultIDHarvest,
                                          datasheet = "stsim_OutputSpatialState", 
                                          timestep = 5)
myRastersTimestep5

# Plot raster for the first realization of timestep 5
plot(myRastersTimestep5[[1]])

# ******************************************************************************
# Go to SyncroSim for Windows and select "File | Refresh All Libraries"
# While still in SyncroSim for Windows, create a new chart and map
# ******************************************************************************