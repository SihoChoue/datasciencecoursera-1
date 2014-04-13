rm(list = ls())
library(data.table)

setwd('')
# this is the root under which the directories train and test, and the files are README, features_info, features, and activity_labels are extracted from the zip archive downloaded from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

# part 1 ---------------------------------------------------------------
# reading and merging training and testing dataset
DT <- data.table(rbind(
read.table('./test/X_test.txt', header = FALSE),
read.table('./train/X_train.txt', header = FALSE)
))

# part 2a ---------------------------------------------------------------
# reading features.txt
ColumnNames <- data.table(read.table('features.txt'))

# there are some duplicate column name, fixing it, i assume they refer to x, y, and z in that order
# ColumnNames[,.N, by = V2][N > 1]
ColumnNames[,Freq := .N, by = V2]
ColumnNames[,FreqIndex := .SD[,.I], by = V2]
ColumnNames[Freq > 1 & FreqIndex == 1, V2 := paste0(V2,'_X')]
ColumnNames[Freq > 1 & FreqIndex == 2, V2 := paste0(V2,'_Y')]
ColumnNames[Freq > 1 & FreqIndex == 3, V2 := paste0(V2,'_Z')]

# setting as names of DT
setnames(DT, as.character(ColumnNames[,V2]))

# part 3 and 4 ----------------------------------------------------------
# reading and merging training and testing dataset activity labels
DTActivityLabels <- data.table(rbind(
  read.table('./test/y_test.txt', header = FALSE),
  read.table('./train/y_train.txt', header = FALSE)
))
DT <- data.table(cbind(DTActivityLabels,DT))

# adding descriptive activity names as in activity_labels.txt
ActivityNames <- data.table(read.table('activity_labels.txt'))
DT <- merge(ActivityNames,DT, all.y = TRUE, by = 'V1')
setnames(DT, 'V2', 'ACTIVITY')
DT[,V1 := NULL]

# part 2b ---------------------------------------------------------------
# filtering out only the mean and std columns
DTSubset <- DT[,
               grep(as.character(ColumnNames[,V2]), pattern = 'mean|std', value = TRUE), 
               with = FALSE
               ]
write.csv(DTSubset, 'DTSubset.txt', quote = FALSE, na = '')

# part 5 ---------------------------------------------------------------
DTSubjectLabels <- data.table(rbind(
  read.table('./test/subject_test.txt', header = FALSE),
  read.table('./train/subject_train.txt', header = FALSE)
))
setnames(DTSubjectLabels, 'V1', 'SUBJECT')
DT <- data.table(cbind(DTSubjectLabels,DT))
DTAggregated <- DT[,lapply(.SD, mean, na.rm = TRUE), by = list(SUBJECT,ACTIVITY)]
write.csv(DTAggregated, 'DTAggregated.txt', quote = FALSE, na = '')
