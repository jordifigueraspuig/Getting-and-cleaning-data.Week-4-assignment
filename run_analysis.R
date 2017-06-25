rm(list=ls())
library(dplyr)

# Reads and joins X, y, subject data, including the names of the variables (#4).
features<-read.table("features.txt")
features<-t(select(features,V2))
X_test<-read.table("X_test.txt",col.names=features,row.names = NULL)
X_train<-read.table("X_train.txt",col.names=features)
X<-rbind(X_train,X_test)
rm(X_train,X_test)

y_test<-read.table("y_test.txt",col.names="y")
y_train<-read.table("y_train.txt",col.names="y")
y<-rbind(y_train,y_test)

subject_test<-(read.table("subject_test.txt",col.names = "subject"))
subject_train<-(read.table("subject_train.txt",col.names = "subject"))
subject<-rbind(subject_test,subject_train)

# Dataset for #1:
Total<-cbind(X,subject,y)

# With the labels for the activity (#3)
activity_labels<-read.table("activity_labels.txt",col.names=c("y","activity"))
Total<-merge(Total,activity_labels,all=TRUE)

#  # 2: Select only relevant ones (mean,std ), together w subject and activity for num2
a<-grep("mean",colnames(Total))
b<-grep("std",colnames(Total))
c<-grep("meanFreq",colnames(Total))
selected<-select(Total,subject,activity,a,b,-c)

# #5: groups and extracts the mean, and writes the file. 
grouped<-group_by(selected,subject,activity)
tidydata<-summarize_all(grouped,funs(mean))
write.table(tidydata,"tidydata.txt",row.names=FALSE)

# gets rid of the useless data:
rm(a,b,activity_labels,grouped,features,subject,subject_test,subject_train,Total,X,y,y_test,y_train)