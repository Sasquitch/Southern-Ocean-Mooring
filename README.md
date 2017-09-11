# Southern-Ocean-Mooring
This code creates CF-compliant NetCDF files from .DAT3 files, as produced by New Zealand's National Institute of Water and Atmospheric Research. 

To run the code, place the NewZealand.py file in the folder containing the data and run the file.  It will generate NetCDF files for any .DAT3 files in the folder.

If Python and Anaconda are not already installed on the computer, install the newest versions of both.
Python: https://www.python.org/
Anaconda: https://www.continuum.io/downloads

Install or update any required packages in the Anaconda terminal.  The numpy package and netCDF4 packages can be installed by the commands:
pip install numpy
pip install netcdf4 

To run the file, navigate to the file location in Anaconda, and run it with the command:
python NewZealand.py

If any additional metadata needs to be added to the netCDF file, it can be added in the #global attributes section located at the end of the NewZealand.py file.  Open the file in a text editor and add the new information using the syntax:
nc.name = 'information'

nc should not be changed because it is the identity of the netCDF file.
name is the name of the variable.
information is the desired text.

Example:
Adding the unit type of a temperature variable.
Starting at the #Global Attributes line 
One line down in a empty line the code inserted would be:
nc.temperature_unit = "Degrees Celcius"

Errors: 
If there is an error with any packages, they must be installed or updated in Anaconda.  All the installed packages can be updated with the command:
conda update --all
Otherwise the package must be installed.

If any errors occur stating the presence of an unknown abbreviation, open the python file in a text editor (such as sublime) and add the abbreviation to the abbvdict, stdNameDict, or unitsDict dictionaries on line 24-32 of the file using the syntax:
'abbreviation': 'correct name'

The 'correct name' can be located in the most recent netCDF standard name table.
http://cfconventions.org/standard-names.html

Example:
In the DAT3 file there is an unlisted dataset named 'Nothern Current Velocity' with the abbreviation 'vel_v' and the unit 'v'.
In the abbvDict after the 'salinity' entry, the abbreviation would be listed as the key and the complete name would be the entry.
... 'sal': 'salinity','vel_v':'north_velocity'}

Then, in the stdNameDict the abbreviation would be listed as the key and the corresponding name in the http://cfconventions.org/standard-names.html website would be the entry.
... 'sal': 'salinity','vel_v':'northward_sea_water_velocity'}
If there is not a suitable entry in the cfcconventions website, a descriptive name should be used as the entry.

Finally in the unitsDict, the unit in the Dat3 file would be listed as the key, and the corresponding unit in the cfcconventions.org entry would be listed as the entry.
...'degc': 'K','v': 'm s-1'}
