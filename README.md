# hypopy
Hypopy is the python package that creates the input file for Hypoinverse software.

#### Version info
Version 0.1

## General Features  
* Hypopy can be used to create the following Hypoinverse input files:
    1. Crustal Velocity model file: 
        - CRH:Homogeneous Mutilayer Model
        -  CRT: Mutlilayer with velocity gradient
    2. Hypoinverse Station File:
        - List of All station used for locating
    3. Hypoinverse Phase File:
        - List of all picked phases for all the events to be located.
 
 ## Important Functions
 
   * **model** (model_name,velocity,depth): create a .crh hypoinverse model file
    
   * **add_station** (station_filename,station_code, network_code,channel_code,latitude,longitude,elevation): *create .sta hypoinverse station file and add station list to it*  
    
   * **add_picks** (phase_filename,station,net,channel, p_arrival_time, s_arrival_time): *add P and S pick to .phs hypoinverse phase file*

   * **create_phase_file** (phase_filename,evid,trail_t,trail_lat,trail_long): *create .phs phase file*    
    
        
   * **locate** (model_name,station_filename,phase_filename,output_filename): *generates the .hyp file (input file ) to run hypoinverse*
    
    
   * **export_located** (output_filename):*export the located event as 'Located.csv' format* 

 
 ## Prerequisites
 
 * obspy 1.2.0: [Download](https://github.com/obspy/obspy)
 * hypoinverse 1.4 [Download](https://www.usgs.gov/software/hypoinverse-earthquake-location)

## Getting started.

#### **Setup** : 

* open the source folder
* Run setup.py to build Hypoinverse or
* Run following command in the Terminal: **make -f makefile**
* **Note** : make sure you have f77 compiler to build the hypoinverse file. If you have g77 or any other version, Open make file and find and replace f77 with your version.

#### Tutorial 

* see the Tutorial:[Tutorial on Earthquake Detection and Location.ipynb](https://github.com/singhsatyampratap/hypopy/blob/main/source/Tutorial%20on%20Earthquake%20Detection%20and%20Location.ipynb)




## Authors

* **Satyam Pratap Singh** - *Initial work* - [singhsatyampratap](https://github.com/singhsatyampratap)



## Acknowledgments

* I would like to thanks Dr. Satish Maurya (Department of Earth Science, IIT Bombay)  for his guidance. 


## Reference
*Klein, Fred. (2014). User's Guide to HYPOINVERSE-2000, a Fortran Program to Solve for Earthquake Locations and Magnitudes, Version 1.40, June 2014. 10.13140/2.1.4859.3602.* 
