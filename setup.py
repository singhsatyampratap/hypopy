import os
os.chdir("./source")
try:
    os.system("make -f makefile")
except:
    print("unable to run makefile")
    print("Please make sure you have f77 compiler")