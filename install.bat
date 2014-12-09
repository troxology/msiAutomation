@rem This is a simple batch script to remove a submodule reference from a 
@rem working directory
@rem Call the script by
@rem 1) cd path\to\your\workspace
@rem 2) path\to\install.bat path\to\Installer.msi

msiexec /I %1 /quiet /passive