# Clear/setup workspace ---------------------------------------------------

rm(list=ls()); par(mfrow = c(1,1))


#Other users of this script will have to set their own working directory
setwd("/Users/spencercastro/Documents/Getting-and-Cleaning-Data-Course-Project")

# SETUP: Get zipped file from UCI website ---------------------------------
  #Make directory UCIdata
if(!file.exists("./UCIdata"))
{dir.create("./UCIdata")}


  #Get url
UCIurl <- "http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip"

  #download file to /UCIdata
if(!file.exists("./UCIdata/Dataset.zip"))
  {download.file(UCIurl,destfile="./UCIdata/Dataset.zip")}

  #Unzip Dataset.zip to /UCIdata folder
if(!file.exists(".UCIdata/UCI HAR Dataset/activity_labels.txt"))
   {unzip(zipfile="./UCIdata/Dataset.zip",exdir="./UCIdata")}


# 1. "Merges the training and the test sets to create one data set --------

  #I. Read files

    #A. Read activity_labels.txt:
actLabels = read.table('./UCIdata/UCI HAR Dataset/activity_labels.txt')

    #B. Read features.txt:
features <- read.table('./UCIdata/UCI HAR Dataset/features.txt')

    #C. Read train/training sets:
xtrain <- read.table("./UCIdata/UCI HAR Dataset/train/x_train.txt")
ytrain <- read.table("./UCIdata/UCI HAR Dataset/train/y_train.txt")
subjecttrain <- read.table("./UCIdata/UCI HAR Dataset/train/subject_train.txt")

    #D. Read test/test sets:
xtest <- read.table("./UCIdata/UCI HAR Dataset/test/x_test.txt")
ytest <- read.table("./UCIdata/UCI HAR Dataset/test/y_test.txt")
subjecttest <- read.table("./UCIdata/UCI HAR Dataset/test/subject_test.txt")

  # II. Get names:
    #...For the training data
colnames(xtrain) <- features[,2] 
colnames(ytrain) <-"actId"
colnames(subjecttrain) <- "subjectId"
    #...For the test data
colnames(xtest) <- features[,2] 
colnames(ytest) <- "actId"
colnames(subjecttest) <- "subjectId"

colnames(actLabels) <- c('actId','actType')

  #III Merge data:
mrgtrain <- cbind(ytrain, subjecttrain, xtrain)
mrgtest <- cbind(ytest, subjecttest, xtest)
alldata <- rbind(mrgtrain, mrgtest)


# 2. "Extracts only the measurements on the mean and standard dev ---------


  #I. Read names:
colNames <- colnames(alldata)

  #II. Create subid, mean and SD:
meanSD <- (grepl("actId" , colNames) | 
                   grepl("subjectId" , colNames) | 
                   grepl("mean.." , colNames) | 
                   grepl("std.." , colNames) 
)

# 2.3 Making nessesary subset from alldata:
meanSDdata <- alldata[ , meanSD == TRUE]


# 3. "Uses descriptive activity names to name the activities in th --------


ActNames <- merge(meanSDdata, actLabels,
                              by='actId',
                              all.x=TRUE)



# 4. "Appropriately labels the data set with descriptive variable  --------



# 5. "From the data set in step 4, creates a second, independent t --------


# with the average of each variable for each activity and each subject."
# 5.1 Making second tidy data set 
CastroTidyData <- aggregate(. ~subjectId + actId, ActNames, mean)
CastroTidyData <- CastroTidyData[order(CastroTidyData$subjectId, CastroTidyData$actId),]

# 5.2 Writing second tidy data set in txt file
write.table(CastroTidyData, "CastroTidyData.txt", row.name=FALSE)
View(CastroTidyData)
