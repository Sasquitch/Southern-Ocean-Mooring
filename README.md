# Southern-Ocean-Mooring
This code creates CF-compliant NetCDF files from .DAT3 files, as produced by New Zealand's National Institute of Water and Atmospheric Research. 

To run the code, place the NewZealand.py file in the folder containing the data and run the file.  It will generate NetCDF files for any .DAT3 files in the folder.

If Python and Anaconda are not already installed on the computer, install the newest versions of both.
Python: https://www.python.org/
Anaconda: https://www.continuum.io/downloads

Install or update any required packages in the Anaconda terminal.  The numpy package and netCDF4 packages can be installed by the commands:
pip install numpy
pip install netcdf4 

If any additional metadata needs to be added to the netCDF file, it can be added in the #global attributes section located at the end of the NewZealand.py file.  Open the file in a text editor and add the new information using the syntax 
nc.name = 'information'
nc should not be changed because it is the identity of the netCDF file.
name is the name of the variable.
information is the desired text.

Errors: 
If there is an error with any packages, they must be installed or updated in Anaconda.  All the installed packages can be updated with the command:
conda update --all
Otherwise the package must be installed.

If any errors occur stating the presence of an unknown abbreviation, open the python file in a text editor (such as sublime) and add the abbreviation to the abbvdict, stdNameDict, or unitsDict dictionaries on line 24-32 of the file using the syntax 'abbreviation': 'correct name'.  The 'correct name' can be located in the most recent netCDF standard name table.
http://cfconventions.org/standard-names.html
