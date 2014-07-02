FeatureExtract
==============

Extract acoustic features of people to wake up controlling devices which also can be called VAD

=============
##Code Structure##
DatatoSVM.m      :convert all data to txt which can be processed by svmlight tool

FeatureExtract.m :Extract acoustic features including in MFCC ZCR Energe

MergeTowindow.m  :10 frames to a window

loaddata.m       :load matlab data .Mat

makedata.m       :other data processing that can be used to perform further experiments
