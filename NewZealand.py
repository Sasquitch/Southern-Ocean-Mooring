import os
from os.path import isfile, join
from pandas import read_csv
from netCDF4 import Dataset
import numpy as np
#from numpy import arange, dtype # array module from http://numpy.scipy.org

def getData(linenum, toStr): #analyze data in line
	if toStr == 0: #return a data array
		data = content[linenum].split(" ") #create array of data
		data = list(filter(('').__ne__, data)) #remove blank entries
		return data
	elif toStr == 1: #return a string
		data = content[linenum].split(" ") #create array of data
		data = list(filter(('').__ne__, data)) #remove blank entries
		data = ' '.join(data)
		return data
	else:
		print("getData received bad data.")

dataDict = dict()


nc = Dataset('test.nc', 'w', format = 'NETCDF4')

dir_path = os.path.dirname(os.path.realpath(__file__))
onlyfiles = [f for f in os.listdir(dir_path) if isfile(join(dir_path, f))]

fileChoice = onlyfiles[0] #change to a loop later

#http://stackoverflow.com/questions/15233340/getting-rid-of-n-when-using-readlines
with open(fileChoice) as f:
	content = [content.rstrip('\n') for content in open(fileChoice)]


for i in range(0,30): #find line where data begins
	temp_str = content[i]
	if temp_str[:4] == 'time': #Does it always begin with time?
		variables = content[i].split(" ") #insert into array
		variables = list(filter(('').__ne__, variables)) #remove blank entries
		dataLine = i

#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

instrInfo = getData(1,0) #get instrument data
instrType = instrInfo[0]
instrSerial = instrInfo[1]

degrees = getData(2,0) #get lat & long data
if degrees[2] == 'S':
	lat = str("-" + degrees[0] + " " + degrees[1])
else:
	lat = str(degrees[0] + " " + degrees[1])
if degrees[5] == 'E':
	lon = str(degrees[3] + " " + degrees[4])
else:
	lon = str('-' + degrees[3] + " " + degrees[4])

location = getData(3,1)
location = location.split("description")[0]

depthInfo = getData(4,0)
waterDepth = depthInfo[0]
instrDepth = depthInfo[1]

datetimeinfo = getData(5,0)
startDate = datetimeinfo[0]; startTime = datetimeinfo[1]; endDate = datetimeinfo[2]; endTime = datetimeinfo[3]
startTime = startTime.split(",")[0]; endTime = endTime.split(",")[0] #remove commas
timeZone = datetimeinfo[4]

notes = ''
for x in range(7, dataLine):
	lineInfo = getData(x,1)
	if lineInfo.isnumeric() == True:
		print (lineInfo)
	else:
		lineInfo = lineInfo.split(str(x+1))[0]
		notes = notes + "\n" + lineInfo

print (notes)


#CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
variables.insert(1,"HHMMSS")
entries = len(variables)


for ii in range(0,entries):
	dataDict.update({ii: []}) #create dictionary matching vars to empty arrays
 
for j in range(dataLine+1, len(content)):
	data = getData(j,0)
	for jj in range(0, entries): #loop over entries in data array 
		dataDict[jj].append(data[jj])

#print(dataDict)


for iii in range(0,len(variables)): #netcdf algorithm


	nc.createDimension(variables[iii], len(dataDict[iii])) #pair variable name to data len dimension

	dataList = np.array(dataDict[iii]).tolist()
	#tempVar = np.arange(dataList)
	tempVar = dataList
	#print(dataDict[iii])

	tempVar[:] = dataDict[iii]
	#print (tempVar[:])
	tempStr = variables[iii]
	tempStr = nc.createVariable(tempStr, np.float32, (tempStr,))
	#print(tempStr)

temp = nc.createVariable('temp', np.float32, (variables))
#print  (nc.dimensions['HHMMSS'])
nc.close()
