#Created by David Pasquale
#DavPasquale@gmail.com
#Last change on 7/26/17

#Purpose: To convert .DAT3 files to NetCDF files.

import os
from os.path import isfile, join
#from pandas import read_csv
from netCDF4 import Dataset
import numpy as np
import time
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
abbvDict = {'time': 'date', 'dirt': 'dirt', 'spe': 'speed', 'tem': 'temperature',
			'pre': 'pressure', 'dep': 'depth', 'con': 'conductivity', 'sal': 'salinity'}

stdNameDict = {'dirt': 'dirt', 'speed': 'sea_water_speed', 'temperature': "sea_water_temperature", 
			'pressure': 'sea_water_pressure', 'deg': "sea_water_temperature", 'depth': 'depth',
			'conductivity': 'sea_water_electrical_conductivity', 'salinity': 'sea_water_salinity'}

unitsDict = {'degt': 'degt', 'deg': 'K', 'dbar': 'dbar', 'cm/s': 'm/s', 'm':'m', 's/m': 'S/m',
			'degC': 'K', 'dbar': 'dbar', 'psu': '1e-3', 'degc': 'K'} #time is defined below

today = time.time()
today = ("File created on: ", time.strftime("%Y-%m-%d %H:%M:%S",time.gmtime(today)))
dir_path = os.path.dirname(os.path.realpath(__file__))
onlyfiles = [f for f in os.listdir(dir_path) if isfile(join(dir_path, f))]

for file in onlyfiles:

	if file.endswith("DAT3"):
		ncFileName = file[:-5] + ('.nc')
		nc = Dataset(ncFileName, 'w', format = 'NETCDF4')
		print("Working on file: ", file)

		with open(file) as f:
			content = [content.rstrip('\n') for content in open(file)]

		for i in range(0,30): #find line where data begins SHOULD NOT BE PAST 30
			temp_str = content[i]
			if temp_str[:4] == 'time': #Does it always begin with time?
				variables = content[i].split(" ") #insert into array
				variables = list(filter(('').__ne__, variables)) #remove blank entries
				for y in range(0, len(variables)): #change acronyms to known variables.
					try:
						variables[y] = abbvDict[variables[y]]
					except:
						print("There is an unknown abbreviation: \'", variables[y],"\'\nConsider adding its description to the dictionary at the top of the python file:\n", __file__)
				dataLine = i

	#XXXXXXXXXXXXX Read file header information XXXXXXXXXXXXXXXXX

		fileNameRaw = getData(0,0)
		fileNameRaw = fileNameRaw[:-5]

		instrInfo = getData(1,0) #get instrument data
		instrType = instrInfo[0]
		instrSerial = instrInfo[1]

		degrees = getData(2,0) #get lat & long data
		direction = {'N':-1, 'S':1, 'E': -1, 'W':1}
		lat = (degrees[0] + "°" + degrees[1] + '"' + degrees[2])
		new = lat.replace(u'°',' ').replace('.',' ').replace('"',' ')
		new = new.split()
		new_dir = new.pop()
		new.extend([0,0,0])
		lat = (int(new[0])+int(new[1])/60.0+int(new[2])/3600.0) * direction[new_dir]

		lon = (degrees[3] + "°" + degrees[4] + '"' + degrees[5])
		new = lon.replace(u'°',' ').replace('.',' ').replace('"',' ')
		new = new.split()
		new_dir = new.pop()
		new.extend([0,0,0])
		lon = (int(new[0])+int(new[1])/60.0+int(new[2])/3600.0) * direction[new_dir]

		location = getData(3,1)
		location = location.split("description")[0]

		depthInfo = getData(4,0)
		waterDepth = depthInfo[0]
		instrDepth = depthInfo[1]

		datetimeinfo = getData(5,0)
		startDate = datetimeinfo[0]; startTime = datetimeinfo[1]; endDate = datetimeinfo[2]; endTime = datetimeinfo[3]
		cleanStartDate = ''.join(c for c in startDate if c not in '-:')
		startTime = startTime.split(",")[0]; endTime = endTime.split(",")[0] #remove commas
		cleanStartTime = ''.join(c for c in startTime if c not in '-:')
		timeZone = datetimeinfo[4]

		intervalTime = getData(6,0)
		for timeNum in range(0,3):
			if int(intervalTime[timeNum]) != 0:
				timeSinceUnits = timeNum
				timeSinceNum = intervalTime[timeNum]
				timeSinceNum = int(timeSinceNum)

		notes = ''
		for x in range(7, dataLine):
			lineInfo = getData(x,1)
			if lineInfo.isnumeric() == True: #skip empty lines
				break #Do nothing
			else:
				lineInfo = lineInfo.split(str(x+1))[0]
				notes = notes + "\n" + lineInfo #Unsure if \n is the correct formatting

		#XXXXXXXXXXXXX end read file header information XXXXXXXXXXXXXXXXXXXXXXXXXX

		variables.insert(1,"datetime")

		for ii in range(0,len(variables)):
			dataDict.update({ii: []}) #create dictionary matching vars to empty arrays
		 
		for j in range(0, len(variables)): #find what # temp & speed is in variables
			try: #may not exist in data
				if variables[j] == "temperature":
					temperatureVar = j
			except:
				temperatureVar = 999 #will never hit

			try: #may not exist in data
				if variables[j] == "speed":
					speedVar = j
			except:
				speedVar = 999



		for iii in range(0,3): #Need to convert to just seconds
			if timeSinceUnits == 0: #Days
				timeMult = 60*60*24
				time.long_name = (timeSinceNum, " days")
			elif timeSinceUnits == 1: #hours
				timeMult = 60 * 60
			elif timeSinceUnits == 2: #minutes
				timeMult = 60
			elif timeSinceUnits == 3: #seconds
				timeMult = 1
			else:
				print("There was an error assigning time units. Make sure data gap interval is located on line 7.")

		prevday = 0
		daysSince = 0
		prevTime = 0
		timeSince = 0
		for j in range(dataLine+1, len(content)): #travels down rows
			data = getData(j,0)
			for jj in range(0, len(variables)): #travels down columns. Stores data in dictionary.
				clean = ''.join(c for c in data[jj] if c not in '-:') #workaround
				if jj == 1: #time loop
					if clean.isdigit() == False:
						dataDict[jj].append(clean)
					else: 
						if clean != cleanStartTime: #if not start time
							if clean != prevTime:
								prevTime = clean
								timeSince += timeSinceNum #add number discovered in header
								dataDict[jj].append(timeSince*timeMult)
							else:
								dataDict[jj].append(timeSince*timeMult)
						else:
							dataDict[jj].append(timeSince*timeMult)

				elif jj == speedVar:
					if j == dataLine+1 or clean == "Nan":
						dataDict[jj].append(clean)
					else:
						clean = float(clean) / 100 #cm to m
						dataDict[jj].append(clean)

				elif jj == temperatureVar:
					if j == dataLine+1 or clean == "NaN":
						dataDict[jj]. append(clean)
					else:
						clean = float(clean)+273.15 #Celcius to Kelvin
						dataDict[jj].append(clean)

				else:
					dataDict[jj].append(clean)

		nc.createDimension('time', len(dataDict[1])-1) #pair variable name to data len dimension

		nc.createDimension('timeSeries',1)

		time = nc.createVariable('time', np.double, "time")
		
		for iii in range(0,3): #Need to convert to just seconds
			if timeSinceUnits == 0:
				time.units = ("days")
				time.long_name = ("Measurements taken every ", timeSinceNum, " days")
				time.comment = ("Days since: ", startTime, startDate)
			elif timeSinceUnits == 1:
				time.units = ("hours")
				time.long_name = ("Measurements taken every ", timeSinceNum, " hours")
				time.comment = ("Hours since: ", startTime, startDate)
			elif timeSinceUnits == 2:
				time.units = ("minutes")
				time.long_name = ("Measurements taken every ", timeSinceNum, " minutes")
				time.comment = ("Minutes since: ", startTime, startDate)
			elif timeSinceUnits == 3:
				foo.units = ("seconds")
				time.long_name = ("Measurements taken every ", timeSinceNum, " seconds")
				time.comment = ("Seconds since: ", startTime, startDate)
			else:
				print("There was an error assigning time units. Make sure data gap interval is located on line 7.")

		time.standard_name = "time"
		time.calendar = "julian"
		time.axis = "T"
		
		timeSeries = nc.createVariable("timeSeries", np.int, ("timeSeries"))
		
		lat_var = nc.createVariable("lat", int, ("timeSeries"))

		lat_var.standard_name = "latitude"
		lat_var.units = "degrees_north"
		if degrees[2] == 'S':
			lat = -lat
		
		lat_var.axis = "Y"
		lat_var[:] = lat

		lon_var = nc.createVariable("lon", int, ("timeSeries"))
		lon_var.standard_name = "longitude"
		lon_var.units = "degrees_east"
		if degrees[5] == 'W':
			lon = -lon

		lon_var.axis = "X"
		lon_var[:] = lon

		if (len(variables) != 2):
			for iii in range(2,len(variables)): #variable attributes
				foo = nc.createVariable(variables[iii], np.float32, ("time"))
				try:
					foo.standard_name = stdNameDict[variables[iii]]
				except:
					print("There is an unknown standard name: \'", variables[iii],"\'\nMake sure one is located in the dictionary at the top of the Python file.")
				foo[:] = dataDict[iii][1:]
				try:
					randomVar = dataDict[iii][0]
					foo.units = unitsDict[randomVar]
				except:
					print("There is an unknown unit: \'", dataDict[iii][0],"\'\nMake sure it is located in the dictionary at the top of the Python file.")

		#global attributes
		nc.ncei_template_version = "NCEI_TimeSeries_Orthogonal"
		nc.featureType = "TimeSeries"
		nc.title = 'Mooring data collected from RV Tangaroa in Southwest Pacific and Southern Ocean from 2007-03-06 to 2008-04-15'
		nc.standard_name = ("ISO 19115-2 Geographic Information - Metadata - Part 2: Extensions for Imagery and Gridded Data")
		nc.Conventions = "CF-1.6"
		nc.id = file
		nc.notes = notes
		nc.naming_authority = "nz.co.niwa"
		nc.history = today
		nc.source = "Python script NewZealand.py"
		nc.date_created = today
		nc.date_modified = today
		nc.creator_name = "Mike Williams"
		nc.creator_email = "Mike.Williams@niwa.co.nz"
		nc.creator_url = "https://niwa.co.nz/"
		nc.institution = "National Institute of Water and Atmospheric Research"
		nc.project = fileNameRaw
		nc.publisher_name = "US National Centers for Environmental Information"
		nc.publisher_email = "ncei.info@noaa.gov"
		nc.publisher_url = "https://www.ncei.noaa.gov"
		nc.time_coverage_start = (startDate, " ", startTime)
		nc.time_coverage_end = (endDate, " ", endTime)
		nc.latitude = lat
		nc.longitude = lon
		nc.institution = 'National Institute of Water and Atmospheric Research Limited (National Institute of Water and Atmospheric Research - NIWA'
		nc.summary = 'Mooring data from the Northern Gap in the Macquarie Ridge. Includes current meter, microcat and thermistor data.'
		nc.contributor_name = 'Mike Williams, Brett Grant, Mark Rosenberg'
		nc.sea_name = 'Southern Sea'


		nc.close()
