# Empirical Analysis of Energy Markets 
Columbia University School of International and Public Affairs  
INAF U6616  
Quant III

TA recitation material  
Eugene Tan

## How TA sessions fit into the course
One of the goals of the class is to learn to analyze real datasets and replicate empirical papers data using R; and you're expected to become familiar with empirical analysis in R by the end of the course.  This is the main goal of the TA sessions, and generally speaking, you should come to me if you have questions regarding R or programming related rather than Ignacia.

We don't assume previous knowledge or any programming experience, but we do assume that you've taken quant I-II and have a general sense of the thought process and general concepts of manipulating and analyzing data. 

Learning R for causal effects will be based on a combination of DataCamp (ungraded but required homeworks, 0%), empirical exercises (graded homeworks, 35%), in addition to the recitations. You can access DataCamp through the courseworks site. The first deadline for these is September 19th, so I recommend looking at it sooner rather than later.

## Logistics and Github

This GitHub Repository is going to be where I put all the material for recitations and empirical exercises (including answer keys). Most material should be posted as a R Markdown file, which means that during TA sessions, you should be able to take the files and run them on your local computers during the session (I highly encourage this!). If questions come up, I'll also post answers to them here. 

## TA Sessions - Content Overview
DataCamp is great at teaching you how to program in R, in particular the commands, data structures, and libraries you'll use to become proficient at data analysis.  I'll complement DataCamp in several ways.  

1. **How to approach programming problems**.   
Because DataCamp hand-holds you through the analysis, attacking a bigger problem that doesn't do so might be quite jarring and intimidating. I'll try to develop some processes about how to thinking about breaking down programming and analytical problems, as well as how to develop your google skills. I'll also add some basics of computer science so that you'll understand what your machine is doing behind the scenes, because [I believe that] understanding more CS makes you into a better programmer.
1. **RStudio and presenting work**. 
DataCamp runs R direct from their servers, what if you're working locally? How do format your code so that other people can run and use it? Most R Programmers use RStudio, which is a beautiful GUI for R. I'll walk through how to use it and why it's useful
1. **Energy Applications**. 
DataCamp obviously isn't specific to energy, so I'll supplement R programming skills you will cover there with energy related material. Some ideas I haven't yet executed on are that there are some charts are used often in energy like Sankey Diagrams that don't often apply to other fields, and replicating papers that you don't have to do presentations/empirical exercises on.
1. **Econometrics and Economic Applications**. 
Data science as a field generally evolved out a place where you have large-n, independent and identically distributed (iid) data. Economics isn't like that - we often have small datasets, conditional dependence, serial correlation... Also, the big goal of this class (and econometrics more broadly) is normally establishing causality, whereas the goal of machine learning is prediction. All of this means is that your toolbox is slightly different than an aspiring data scientists', and DataCamp doesn't have content on those parts of the toolbox we'll develop. As we cover those tools during lecture, I'll supplement that with material that will teach you how to program those in R. 
1. **Data Science skills that are not R**. 
Time-permitting, and depending on your interest, we may cover some other relatively simple non-R programming stuff. These might help you get a job, but apart from the first they are supplemental to the course. 
    1. R Markdown - used to present your work nicely, needed for problem sets.
    1. git and GitHub - work on code collaboratively, near-essential for working professionally in teams.
    1. Regular expressions - parse strings, built into R but technically a separate 'language'
    1. command line tools - use your computer more effectively 
