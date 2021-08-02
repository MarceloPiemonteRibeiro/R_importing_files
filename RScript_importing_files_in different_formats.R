# Objective of this script: upload. manipulate and join several type of data sources (JSON, CSV, SQL, SAS, SPSS, etc.)

# First, find the path file
getwd()
# change the path file
setwd("C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output")

# Install packages to be used
install.packages('jsonlite')
# if you have it installed already, use instead:
library(jsonlite)

#import data from JSON
reclamacao_2009<-fromJSON('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2009.json')
# error if there're special character in the file
# Error in parse_con(txt, bigint_as_char) : 
#  lexical error: invalid bytes in UTF8 string.
#"DescCNAEPrincipal":"FABRICAÇÃO DE COLCHÕES","Atendida":"S",
# (right here) ------^

# therefore, use the below instead which will read line by line
reclamacao_string<-paste(readLines('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2009.json'), collapse = '')
# paste work as a concat function
paste('hello', 'word')
# a long string is created, to correct we use:
reclamacao_2009<-fromJSON(reclamacao_string)
# now the correct dataFrame was created

# Alternatively, use another package:
install.packages('RJSONIO')
# activate package
library(RJSONIO)

# This package is ideal when you face issues of encoding (e.g. presence of ^,~, etc.)
reclamacao_2009<-RJSONIO::fromJSON('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2009.json') # this sintax is recommended as these 2 libraries were called
# the data was uploaded as a list and no longer as a dataFrame
# to verify use
reclamacao_2009[1]

# to solve the encoding issue we could use instead
reclamacao_2009_2<-RJSONIO::fromJSON('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2009.json',encoding='utf-8') 
reclamacao_2009_2[1]
# utf-8 as encoding option was not satisfatory, use latin1 instead:
reclamacao_2009_2<-RJSONIO::fromJSON('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2009.json',encoding='latin1') 
reclamacao_2009_2[1]

# Other references about encoding:
# https://pt.wikipedia.org/wiki/Codifica%C3%A7%C3%A3o_de_caracteres
# https://rstudio-pubs-static.s3.amazonaws.com/279354_f552c4c41852439f910ad620763960b6.html
# https://support.rstudio.com/hc/en-us/articles/200532197-Character-Encoding
# https://cran.r-project.org/web/packages/jsonlite/index.html
# https://cran.r-project.org/web/packages/RJSONIO/index.html

# Transform list to DataFrame:
install.packages("data.table")
# use the library:
library(data.table)

data_2009<-rbindlist(l=reclamacao_2009_2)
# will bring an error because some columns are not filled 
# Error in rbindlist(l = reclamacao_2009_2) : 
# Item 23226 has 14 columns, inconsistent with item 1 which has 16 columns. To fill missing columns use fill=TRUE.

# to overcome this issue use the option "fill" that will use N/A for blank cells
data_2009<-rbindlist(l=reclamacao_2009_2,fill = TRUE) 

# as data_2009 will be kept, the previous dataFrames can be removed to save memory:
rm(reclamacao_2009,reclamacao_2009_2,reclamacao_string)

# count unique values for a giving colum ("UF")
table(data_2009$UF)
# The output contain "N/D", to filter (remove it), we use:
data_2009_clean<-data_2009[data_2009$UF !='N/D',]

# saving:
# we use this sintax "::" because jsonlite and rjsonio packages are active and both have this command
sub_json<-jsonlite::toJSON(data_2009_clean)
write(sub_json,'C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2009_cleaned.json')

# alternatively:
sub_json<-RJSONIO::toJSON(data_2009_clean)
write(sub_json,'C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2009_cleaned.json')

# Evaluate jsonlite vs RJSONIO
system.time(
reclamacao_2009<-jsonlite::fromJSON(paste(readLines('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2009.json'),collapse = ''))
)
system.time(
reclamacao_2009_2<-RJSONIO::fromJSON('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2009.json')
)
# the time to import the file is shorter for RJSONIO

# compare sizes of the files created:
jsolite<-jsonlite::toJSON(data_2009_clean)
rjsonio<-RJSONIO::toJSON(data_2009_clean)
# The package rjsonio create a lighter json file (almost half size of the MB)

# compare conversion format: verifying just the first 10 obs
jsolite<-jsonlite::toJSON(data_2009_clean[1:10.])
jsolite
rjsonio<-RJSONIO::toJSON(data_2009_clean[1:10.])
rjsonio
# rjsonio show all elements of the colum at once, but all tools will recognize the json either way

#convert the file formatting it with pretty option
jsolite<-jsonlite::toJSON(data_2009_clean[1:10.],pretty=T)
jsolite
write(jsolite,'jsonlite_2009.json')
rjsonio<-RJSONIO::toJSON(data_2009_clean[1:10.],pretty = T)
rjsonio
write(rjsonio,'rjsonio_2009.json')

#remove previous non-used files
rm(rjsonio,sub_json,jsolite,jsolite,reclamacao_2009,reclamacao_2009_2,data_2009)



# Importing data from Excel:
# data is contained in two sheets
install.packages('xlsx')
library(xlsx)

# if this library is not activate try the below
if(Sys.getenv("JAVA_HOME")!=""){
  Sys.setenv(JAVA_HOME="")
}
library(rJava)
# reference: https://stackoverflow.com/questions/17376939/problems-when-trying-to-load-a-package-in-r-due-to-rjava

# upload the excel file
read.xlsx(file='C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2010_2011.xlsx')
# the code will have an error as output "could not find function "read.xlsx" as the excel sheet was not specified
excel<-read.xlsx(file='C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2010_2011.xlsx',sheetIndex = 1)
# however, if encoding issues persists:
data_2010<-read.xlsx2(file='C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2010_2011.xlsx',sheetIndex = 1)
# upload another sheet:
data_2011<-read.xlsx2(file='C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2010_2011.xlsx',sheetIndex = '2011',stringAsFactors=F)
# stringAsFactor as option assign values for each category of our variables, but this is not always advisable.

# verify the columns names of your datasets
colnames(data_2010)
# some columns can be deleted if needed
data_2010_cleaned<-data_2010[,-17]
# where -17 means to delete the column 17
colnames(data_2010_cleaned)

colnames(data_2011)
data_2011_cleaned<-data_2011[,-17]
colnames(data_2011_cleaned)

# saving
write.xlsx(x=data_2010_cleaned,file='C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2010_2011_cleaned.xlsx',row.names = F, sheetName = '2010')
# where rownames option does not save the index as an extra column, sheetname option name the sheet

write.xlsx(x=data_2011_cleaned,file='C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2010_2011_cleaned.xlsx',row.names = F, sheetName = '2011', append = T)
# append = T allow us to append a new sheet, in this case 2011, to the previous file saved

rm(data_2010,data_2011,excel)



# Importing data from SPSS and SAS:
install.packages('haven')
library(haven)

# importing from SPSS
data_2012<-read_spss(file='C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2012.sav')
# importing from SAS
data_2013<-read_sas('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2013.sas')

# verify content of a column:
table(data_2012$SexoConsumidor)
# table counts unique values in this column.
# altering/normalize categorical names such as
data_2012_cleaned<-data_2012
data_2012_cleaned$SexoConsumidor<-gsub('feminino','F',data_2012_cleaned$SexoConsumidor)
# command change the name of the categorical to the one we would like to change to (F) in the column specified $SexoConsumidor
# the same for the other category
data_2012_cleaned$SexoConsumidor<-gsub('masculino','M',data_2012_cleaned$SexoConsumidor)

# verifying:
table(data_2012_cleaned$SexoConsumidor)

# saving:
write_sav(data_2012_cleaned,'C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2012_cleaned.sav')

# same procedure for SAS file
table(data_2013$SexoConsumidor)
data_2013_cleaned<-data_2013
data_2013_cleaned$SexoConsumidor<-gsub('feminino','F',data_2013_cleaned$SexoConsumidor)
data_2013_cleaned$SexoConsumidor<-gsub('masculino','M',data_2013_cleaned$SexoConsumidor)
table(data_2013$SexoConsumidor)
write_sas(data_2013_cleaned,'C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2013_cleaned.sas')

rm(data_2012,data_2013)


# Importing csv:
data_2014<-read.csv('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2014.csv')
# however all information is contained in just one column, to solve it is needed to indicate a separator different from the default, comma:
data_2014<-read.csv('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2014.csv',sep=';', stringsAsFactors = F)

# alternatively:
data_2015<-read.csv2('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2015.csv')
data_2015<-read.csv2('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2015.csv',sep=',', stringsAsFactors = F)

# alternatively (best option):
library(data.table)
data_2016<-fread('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2016.csv')
# this function recognizes the separator and avoid us to use the option StringAsFactor

# encoding issues:
data_2014<-read.csv2('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2014.csv',sep=';', stringsAsFactors = F,encoding='Latin-1')
data_2015<-read.csv2('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2015.csv',sep=',',stringsAsFactors = F,encoding='utf-8')
data_2016<-read.csv2('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2016.csv',sep='|',stringsAsFactors = F,encoding='Latin-1')

# saving:
table(data_2014$Atendida)
# modify name of the unique value content
data_2014_cleaned<-data_2014
data_2014_cleaned$Atendida<-gsub('nao','N',data_2014_cleaned$Atendida)
data_2014_cleaned$Atendida<-gsub('sim','S',data_2014_cleaned$Atendida)
table(data_2014_cleaned$Atendida)

write.csv(x=data_2014_cleaned,'C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2014_cleaned.csv')
# as the index is not of our interested row.name option can be used
write.csv(x=data_2014_cleaned,'C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2014_cleaned.csv',row.names = F)

# write,csv2 will use ; as sep instead of , as the write.csv
# alternatively use fwrite
data_2016_cleaned<-data_2016
data_2016_cleaned$Atendida<-gsub('nao','N',data_2016_cleaned$Atendida)
data_2016_cleaned$Atendida<-gsub('sim','S',data_2016_cleaned$Atendida)
table(data_2016_cleaned$Atendida)

# differently from the previous functions, fwrite allows us to change the separator
fwrite(x=data_2016_cleaned,'C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2016_cleaned.csv',row.names = F,quote = T,sep='_')

# pros and cons of the previous functions:
system.time(data<-read.csv('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2014.csv',stringsAsFactors = F, sep=';',encoding = 'Latin-1'))
system.time(data<-read.csv2('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2014.csv',stringsAsFactors = F, encoding = 'Latin-1'))
system.time(data<-fread('C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/reclamacao_2014.csv',stringsAsFactors = F, encoding = 'UTF-8'))
# fread has a much better

rm(data,data_2014,data_2015,data_2016)


# Merge the dataframes created
merge_data_2009_10_12_14<-rbind(data_2009_clean,
                  data_2010_cleaned,
                  data_2012_cleaned,
                  data_2014_cleaned)
# saving
fwrite(merge_data_2009_10_12_14,'C:/Users/Ribeiro/OneDrive/Documents/OneDrive/_MARCELO/Allura/Formacao Data Science/R input and output/r_io-dataset/dados/data_9_10_12_14.csv',quote=T, row.names = F)




# reference: Curso (I/O) com R: Formatos diferentes de entrada e saída
# https://www.alura.com.br/curso-online-io-em-r 
# https://github.com/alura-cursos/r_io/tree/aula_7