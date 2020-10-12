library(data.table)
data("CO2")
dt<-as.data.table(CO2)
dt[Treatment == 'chilled', chilled_bool := 1]
dt[Treatment == 'nonchilled', chilled_bool := 0]
