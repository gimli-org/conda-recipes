copy C:\Guenther.T\src\gimli\gimli\pygimli\core\*.dll %LIBRARY_BIN%
copy C:\Guenther.T\src\gimli\gimli\pygimli\core\*.pyd %LIBRARY_BIN%
rem python setup.py install --user
rem %PYTHON% setup.py install --single-version-externally-managed record=record.txt
python setup.py install
