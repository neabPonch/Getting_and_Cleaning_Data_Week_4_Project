library(data.table)
library(dplyr)

#Set working directory
setwd("C:/Users/Ponchie/Desktop/Coursera/Course 3")

#Download data files and unzip
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destFile <- "CourseDataset.zip"
if (!file.exists(destFile)){
    download.file(URL, destfile = destFile, mode='wb')
}
if (!file.exists("./UCI HAR Dataset")){
    unzip(destFile)
}
dateDownloaded <- date()

#Read files from unzipped location
setwd("./UCI HAR Dataset")

#Read files from each test/train folder respectively into data frames
ActivityTest <- read.table("./test/y_test.txt")
ActivityTrain <- read.table("./train/y_train.txt")

FeaturesTest <- read.table("./test/X_test.txt")
FeaturesTrain <- read.table("./train/X_train.txt")

SubjectTest <- read.table("./test/subject_test.txt")
SubjectTrain <- read.table("./train/subject_train.txt")

ActivityLabels <- read.table("./activity_labels.txt")

FeaturesNames <- read.table("./features.txt")

#Merge each set of test/train data frames
FeaturesData <- rbind(FeaturesTest, FeaturesTrain)
SubjectData <- rbind(SubjectTest, SubjectTrain)
ActivityData <- rbind(ActivityTest, ActivityTrain)

#Rename columns in ActivityData & ActivityLabels data frames
names(ActivityData) <- "ActivityNumber"
names(ActivityLabels) <- c("ActivityNumber", "Activity")

#Get factor of Activity names with dplyr
Activity <- left_join(ActivityData, ActivityLabels, "ActivityNumber")[, 2]

#Rename SubjectData columns
names(SubjectData) <- "Subject"

#Rename FeaturesData columns using columns from FeaturesNames
names(FeaturesData) <- FeaturesNames$V2

#Create Dataset with only SubjectData, Activity, and FeaturesData
DataSet <- cbind(SubjectData, Activity, FeaturesData)

#Extract mean/sd from data and create new data sets
subFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
DataNames <- c("Subject", "Activity", as.character(subFeaturesNames))
DataSet <- subset(DataSet, select=DataNames)

#Rename the columns of the large dataset using more descriptive activity names
names(DataSet)<-gsub("^t", "time", names(DataSet))
names(DataSet)<-gsub("^f", "frequency", names(DataSet))
names(DataSet)<-gsub("Acc", "Accelerometer", names(DataSet))
names(DataSet)<-gsub("Gyro", "Gyroscope", names(DataSet))
names(DataSet)<-gsub("Mag", "Magnitude", names(DataSet))
names(DataSet)<-gsub("BodyBody", "Body", names(DataSet))

#Create a second, independent tidy data set with the average of each variable for each activity and each subject
SecondDataSet<-aggregate(. ~Subject + Activity, DataSet, mean)
SecondDataSet<-SecondDataSet[order(SecondDataSet$Subject,SecondDataSet$Activity),]

#Save this tidy dataset to local file
write.table(SecondDataSet, file = "TidyData.txt",row.name=FALSE)
