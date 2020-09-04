# Empirical Analysis of Energy Markets 
Columbia University School of International and Public Affairs  
INAF U6616  
Quant III

TA material   
Eugene Tan

## Outliner
One of the goals of the class is to learn to analyze data using R.  This is the main goal of the TA sessions. We don't assume previous knowledge, and we are going to use a combination of datacamp (in ungraded homeworks), empirical exercises (in graded homeworks) and recitations.  

This GitHub Repository is going to be where I put all the material for TA sessions and homeworks (including answer keys). Everything should be posted as a R Markdown file, which means that during TA sessions, you should be able to take the files and run them on your local computers during the session (I highly encourage this!). There also may be supplemental material as needed. 

## Recitations vs Datacamp
Datacamp is great at teaching you commands and the data structures that R uses on a good, interactive, MOOC platform.
But in terms of using it to conduct analysis, it generally walks you through the exercises with a close watch, it isn't specific to energy, nor is geared at data scientists who don't analyse economic markets. 

So my TA sessions will focus on these areas, but these may evolve with the course:

1. **How to approach programming problems**.   
Because datacamp hand-holds you through the analysis, attacking a bigger problem that doesn't do so might be quite jarring and intimidating. I'll try to develop some processes about how to break down programming and analytical problems, as well as where to find help online.
1. **RStudio and presenting work**. 
Datacamp runs R direct from their servers, what if you're working locally? How do format your code so that other people can run and use it?
1. **Energy Applications**. 
Datacamp obviously isn't specific to energy, so I'll supplement stuff you should have covered there sometimes with energy related stuff. Also, some charts are used often in energy like Sankey Diagrams that don't often apply to other fields!
1. **Econometric techniques**. 
Data science as a field generally evolved out a place where you have large-n, independent and identically distributed (iid) data. Economics isn't like that - we often have small datasets, conditional dependence, serial correlation... Also. the big goal of econometrics is normally establishing causality, whereas the goal of machine learning is prediction. All of this means is that your toolbox is slightly different than an aspiring data scientists', and datacamp doesn't have content on those parts of the toolbox we'll develop. As we cover those tools during lecture, I'll supplement that with material that will teach you how to program those in R. 
1. **Skills that are not R**. 
Depending on time and your interest, we may cover some other relatively simple non-R programming stuff. These might help you get a job, but apart from the first they are supplemental to the course. 
    1. R Markdown - used to present your work nicely, needed for problem sets.
    1. git and GitHub - work on code collaboratively, near-essential for working professionally in teams.
    1. Regular expressions - parse strings, built into R but technically a separate 'language'
    1. command line tools - use your computer more effectively 
