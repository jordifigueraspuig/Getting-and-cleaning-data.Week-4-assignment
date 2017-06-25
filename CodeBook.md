---
title: "CodeBook"
author: "Jordi Figueras"
date: "25 juny de 2017"
output: html_document
---


## Original Data

The original data can be found at:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The run_analysis.R scrip assumes that the data is already unzipped into the root of the working directory. 

It uses:
X_train.txt, X_test.txt for the variables
y_train.txt, y_test.txt for the activity (1-6) of the subjects.
subject_train.txt, subject_test.txt includes the subjects of each test.

It also uses features.txt to identify the columns with the names of the variables, and activity_labels.txt to assign the numbers in y_train(test) to the activity labels.


## Processing
Processing follows the following steps: 

0.- Cleans workspace and loads dplyr

    rm(list=ls())
    library(dplyr)

1.- Reads the original files and generates 3 data frames: X, y, subject, including the tests and training data.

    Reads and joins X, y, subject data, including the names of the variables (#4).
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
    

2.- Generates a data frame (Total) including the 3 data frames, introduces column names from features and merges the data frame with the activity_labels.

    Dataset for #1:
    Total<-cbind(X,subject,y)
    # With the labels for the activity (#3)
    activity_labels<-read.table("activity_labels.txt",col.names=c("y","activity"))
    Total<-merge(Total,activity_labels,all=TRUE)

3.- Generates a data frame (selected) where mean, std, subject and activity are selected.

     #  # 2: Select only relevant ones (mean,std ), together w subject and activity for num2
    a<-grep("mean",colnames(Total))
    b<-grep("std",colnames(Total))
    c<-grep("meanFreq",colnames(Total))
    selected<-select(Total,subject,activity,a,b,-c)

4.- Groups by subject and activity and extracts the mean for the variables. Writes it to tidydata.txt and clears all not relevant files.

     # #5: groups and extracts the mean, and writes the file.
    grouped<-group_by(selected,subject,activity)
    tidydata<-summarize_all(grouped,funs(mean))
    write.table(tidydata,"tidydata.txt",row.names=FALSE)
    # gets rid of the useless data:
    rm(a,b,activity_labels,grouped,features,subject,subject_test,subject_train,Total,X,y,y_test,y_train)


## Tidy Data

The final results provides the mean of the variables of interest grouped by subject and activity. The variables of interest is the selection of the original variables
> A 561-feature vector with time and frequency domain variables. 

that correspond the mean or the std deviation of a parameter. Data preserves the dimensions of the original data. 


The origin of the data is the following (http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones):

*\"The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.* 

*The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details.\"* 


