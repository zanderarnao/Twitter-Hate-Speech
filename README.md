# hw09

### For this homework assignment, you will need the following libraries: 
library(tidyverse)
library(rvest)
library(RColorBrewer)
library(tidytext)
library(knitr)
library(downloader)
library(here)
library(topicmodels)
library(furrr)
library(textrecipes)

### Overview of the assignment: 

This assignment entailed me importing and cleaning a data set containing hate speech posted to Twitter. Using Latent Dirichlet allocation, I modeled the topics present in posts that were coded as hate speech. I then visualized 36 of those topics, interpreted the topics, and finally analyzed the patterns those topics represent. I plan to return to this analysis at a later date. 

Note: The scripts in the pull request are not needed to replicate this analysis. Simply run the .Rmd. I used them initially for coding (I prefer the interface) and include them as a matter of practice. 

### Links to Relevant Documents:  

* [hate-speech-report.Rmd](https://github.com/zanderarnao/hw09/blob/ab688b727c325a3e4647192bca188815cadc2141/hate-speech-report.Rmd)

* [hate-speech-report.md](https://github.com/zanderarnao/hw09/blob/ab688b727c325a3e4647192bca188815cadc2141/hate-speech-report.md)

* [topic-catalogue.Rmd](https://github.com/zanderarnao/hw09/blob/ab688b727c325a3e4647192bca188815cadc2141/topic-catalogue.Rmd)

* [topic-catalogue.md](https://github.com/zanderarnao/hw09/blob/ab688b727c325a3e4647192bca188815cadc2141/topic-catalogue.md)
