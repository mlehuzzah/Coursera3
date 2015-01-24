if(!file.exists("data")){dir.create("data")}
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/project.zip")
dateDownloaded <- date()

unzip("./data/project.zip", overwrite=FALSE, exdir=".")


path1<-"./UCI HAR Dataset"
features<-read.table(paste(path1,"/features.txt",sep=""), sep=' ')

meanVars<-grep("mean", features[,2])
#pull out all entries of "features" which contain mean()

stdVars<-grep("std", features[,2])
#pull out all entries of "features" which contain mean()

vars2Keep<-c(meanVars,stdVars)
#vector corresponding to the entries of features which have mean or std

featuresKeep<-features[vars2Keep,2]
#names of the desired features

activities<-read.table(paste(path1,"/activity_labels.txt",sep=""), sep=" ")


testActivity<-read.table(paste(path1,"/test/y_test.txt",sep=""), sep=' ')
testSubject<-read.table(paste(path1,"/test/subject_test.txt",sep=""), sep=' ')
testData<-read.table(paste(path1,"/test/X_test.txt",sep=""))

testDataKeep<-testData[,vars2Keep]
#subset of testData corresponding to the variables we want

colnames(testDataKeep)<-featuresKeep
# rename the column names to the features

testAct<-merge(testActivity,activities,"V1",all=TRUE,sort=FALSE)
#shitty way to turn the activity numbers into words... should have figures out how to do this with factors

testTidy<-cbind(testSubject,testAct[,2],testDataKeep)
colnames(testTidy)[2]<-"activity"
colnames(testTidy)[1]<-"subject"


trainActivity<-read.table(paste(path1,"/train/y_train.txt",sep=""), sep=' ')
trainSubject<-read.table(paste(path1,"/train/subject_train.txt",sep=""), sep=' ')
trainData<-read.table(paste(path1,"/train/X_train.txt",sep=""))
trainDataKeep<-trainData[,vars2Keep]
colnames(trainDataKeep)<-featuresKeep
trainAct<-merge(trainActivity,activities,"V1",all=TRUE,sort=FALSE)
trainTidy<-cbind(trainSubject,trainAct[,2],trainDataKeep)
colnames(trainTidy)[2]<-"activity"
colnames(trainTidy)[1]<-"subject"


tidyData<-rbind(testTidy,trainTidy)

write.table(tidyData, "dataset1.txt", sep=" ") 


library(reshape2)
dataMelt<-melt(tidyData,id=c("subject","activity"))

meansByActivity <- dcast(dataMelt,activity ~ variable, mean)
#finds the mean of each variable by activity


meansBySubject <- dcast(dataMelt,subject ~ variable, mean)
meansBySubject[,1]<-paste("Subject ",as.character(meltSubject[,1]))
#finds the mean of each variable by subject, and writes the subject as a character (so rbind will work)


names(meansBySubject)[1]<-"SummaryVariable"
names(meansByActivity)[1]<-"SummaryVariable"
# renames the first column of each so that rbind will work

tidyData2<-rbind(meansByActivity,meansBySubject)

write.table(tidyData2, "dataset2.txt", sep=" ", row.name=FALSE) 
