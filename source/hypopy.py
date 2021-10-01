''' Hypopy is the python package that creates the input file for Hypoinverse software. 

Hyopy can be used to create the following Hypoinverse input files:
    1. Crustal Velocity model file: 
        a) CRH:Homogeneous Mutilayer Model
        b) CRT: Mutlilayer with velocity gradient
    2. Hypoinverse Station File:
        List of All station used for locating
    3. Hypoinverse Phase File:
        List of all picked phases for all the events to be located
        
        
Dependencies:
    Numpy
    Obspy

Important Functions:
    model(model_name,velocity,depth):                           create a .crh hypoinverse model file
    
    add_station(station_filename,station_code,
    network_code,channel_code,latitude,longitude,elevation):    create .sta hypoinverse station file and add station list to it  
    
    add_picks(phase_filename,station,net,channel,                
    p_arrival_time, s_arrival_time):                            add P and S pick to .phs hypoinverse phase file

    create_phase_file(phase_filename,evid,trail_t,              create .phs phase file    
    trail_lat,trail_long):
        
    locate(model_name,station_filename,phase_filename,          generates the .hyp file (input file ) to run hypoinverse
    output_filename):
    
    export_located(output_filename):                            export the located event as 'Located.csv' format 

created by Satyam Pratap Singh
'''

def setup():
    import os
    #os.chdir("./source")
    try:
        os.system("make -f makefile")
    except:
        print("unable to run makefile")
        print("Please make sure you have f77 compiler")
    #os.system('cd ..')

def model(model_name,velocity,depth):
    
    filename=model_name+".crh"
    f=open(filename,'w')
    f.write(model_name)
    f.write("\n")
    f.close()
    for i in range(len(velocity)):
        f=open(filename,'a')
        f.write('{:5.2f} {:5.2f}'.format(velocity[i],depth[i]))
        f.write("\n")
        f.close()
    
    print("Model file successfully created as {}".format(filename))


def _decimalDegrees2DMS(value,type):
    
    'Converts a Decimal Degree Value into Degrees Minute Seconds Notation. Pass value as double type = {Latitude or Longitude} as string returns a string as D:M:S:Direction created by: anothergisblog.blogspot.com' 

    degrees = int(value)
    submin = abs( (value - int(value) ) * 60)
    direction = ""
    if type == "Longitude":
        if degrees < 0:
            direction = "W"
        elif degrees > 0:
            direction = " "
        else:
            direction = ""
        notation = ["{:>3}".format(str(abs(degrees))), direction, "{:>5}".format(str(round(submin, 2)))] 

    elif type == "Latitude":
        if degrees < 0:
            direction = "S"
        elif degrees > 0:
            direction = " "
        else:
            direction = "" 
        notation =["{:>2}".format(str(abs(degrees))), direction, "{:>5}".format(str(round(submin, 2)))] 
        
    return notation






def add_station(station_filename,station_code,network_code,channel_code,latitude,longitude,elevation):
    from hypopy import _decimalDegrees2DMS
    
    
    
    filename=station_filename+".sta"
    sc=station_code.ljust(5)
    nc=network_code.ljust(2)
    cc=channel_code
    lat = _decimalDegrees2DMS(float(latitude),  "Latitude")
    long = _decimalDegrees2DMS(float(longitude),  "Longitude")
    #print(lat)


    latmin=str("{:.4f}".format(float(lat[2]))).rjust(7)
    latdeg=str(lat[0]).ljust(2)

 
    longmin=str("{:.4f}".format(float(long[2]))).rjust(7)
    longdeg=str(long[0]).rjust(3)

    elev=str(int(elevation)).rjust(4)
    
    


    line=sc+" "+nc+"  "+cc+"  "+latdeg+" "+latmin+lat[1]+longdeg+" "+longmin+long[1]+elev+"0.2     0.00  0.00  0.00  0.00 7  1.00--"+cc
    file1 = open(filename, "a")  # append mode
    
    file1.write(line)
    file1.write("\n")
    file1.close()
    
    print("Station information added to the file {}".format(filename))












def phase_header(phase_filename,t,st_latitude,st_longitude):
    import obspy
    from hypopy import _decimalDegrees2DMS
    
    filename=phase_filename+".phs"
    yr = "{:>4}".format(str(t.year))
    mo = "{:>2}".format(str(t.month))
    dy = "{:>2}".format(str(t.day)) 
    hr = "{:>2}".format(str(t.hour)) 
    mi = "{:>2}".format(str(t.minute)) 
    sec = "{:>4}".format(str(t.second)) 
    st_lat_DMS = _decimalDegrees2DMS(float(st_latitude),  "Latitude")
    st_lon_DMS = _decimalDegrees2DMS(float(st_longitude),  "Longitude")
    depth = 5.0
    mag = 0.0
    
    Y2000_writer= open(filename, "a")
    Y2000_writer.write("%4d%2d%2d%2d%2d%4.2f%2.0f%1s%4.2f%3.0f%1s%4.2f%5.2f%3.2f\n"%
                                           (int(yr),int(mo),int(dy), int(hr),int(mi),float(sec),float(st_lat_DMS[0]), 
                                            str(st_lat_DMS[1]), float(st_lat_DMS[2]),float(st_lon_DMS[0]), str(st_lon_DMS[1]), 
                                            float(st_lon_DMS[2]),float(depth), float(mag)))
    print("Phase header is successfully created as {}".format(filename))
    print("Now you can add picks using add_picks function")
    
    
    
def add_picks(phase_filename,station,net,channel,p_arrival_time, s_arrival_time):
    
    filename=phase_filename+".pick"
 

    
    station = "{:<5}".format(station)
    net = "{:<2}".format(net) 
    yrp = "{:>4}".format(str(p_arrival_time.year))
    mop = "{:>2}".format(str(p_arrival_time.month)) 
    dyp = "{:>2}".format(str(p_arrival_time.day)) 
    hrp = "{:>2}".format(str(p_arrival_time.hour)) 
    mip = "{:>2}".format(str(p_arrival_time.minute)) 
    sec_p = "{:>4}".format(str(p_arrival_time.second))
    Pweight=1.0
    
    #yrs = "{:>4}".format(str(s_arrival_time.year))
    #mos = "{:>2}".format(str(s_arrival_time.month)) 
    #dys = "{:>2}".format(str(s_arrival_time.day)) 
    #hrs = "{:>2}".format(str(s_arrival_time.hour)) 
    #mis = "{:>2}".format(str(s_arrival_time.minute))                             
    #sec_s = "{:>4}".format(str(s_arrival_time.second))  
    #Sweight=1.0
    
    Y2000_writer= open(filename, "a")
    #if sec_s:
    #    Y2000_writer.write("%5s%2s  HHE     %4d%2d%2d%2d%2d%5.2f       %5.2fES %1d\n"%(station,net,int(yrs),int(mos),int(dys),int(hrs),int(mis),float(0.0),float(sec_s), Sweight))
    if sec_p:
        Y2000_writer.write("%5s%2s  %3s IP %1d%4d%2d%2d%2d%2d%5.2f       %5.2f   0\n"%(station,net,channel,Pweight,int(yrp),int(mop),int(dyp),int(hrp),int(mip),float(sec_p),float(0.0)))   
    
    print("Picks successfully added to {}".format(filename))
    
    
def phase_footer(phase_filename,evid):
    filename=phase_filename+".phs"
    Y2000_writer= open(filename, "a")
    Y2000_writer.write("{:<62}".format(' ')+"%10d"%(evid)+'\n')
    
    
def create_phase_file(phase_filename,evid,trail_t,trail_lat,trail_long):
    from hypopy import phase_header
    #import os
    phase_header(phase_filename,trail_t,trail_lat,trail_long)
    
    filename1=phase_filename+".pick"
    filename2=phase_filename+".phs"
    with open(filename1,'r') as firstfile, open(filename2,'a') as secondfile:
        
      
        # read content from first file
        for line in firstfile:
            # write content to second file
            secondfile.write(line)
    

    
    
    phase_footer(phase_filename,evid)
    
    

    
def locate(model_name,station_filename,phase_filename,output_filename):
    import os
    
    #os.chdir("./source")
    filename=output_filename+".hyp"
    try:
        os.remove(filename)
    except:
        pass
    f=open(filename,'w')
    
    #f.write("./hyp1.40"+"/n")
    f.write("CRH 1 '{}.crh'".format(model_name))
    f.write("\n")
    f.write("STA '{}.sta'".format(station_filename))
    f.write("\n")
    f.write("PRT '{}.prt'".format(output_filename))
    f.write("\n")
    f.write("SUM '{}.sum'".format(output_filename))
    f.write("\n")
    f.write("PHS '{}.phs'".format(phase_filename))
    f.write("\n")
    f.write("FIL")
    f.write("\n")
    f.write("LOC")
    f.write("\n")
    f.write("STO")
    f.close()
    print("Open terminal in working directory run:")
    print("./hyp1.40" )
    print("Then run:")
    print("@{}".format(filename))
    
def export_located(output_filename):
    filename='{}.sum'.format(output_filename)
    file1 = open(filename, "r")
    Counter = 0


    f2=open("Located.csv",'w')
    s2=str('Year,Month,Day,hrs,m,sec,lat,long,depth,n_picked,rms,err_h,err_v')
    f2.write(s2)
    f2.write("\n")
    f2.close() 

# Reading from file
    Content = file1.read()
    CoList = Content.split("\n")
#print(CoList)
    for s in CoList:
        if s:
            Counter += 1
            Year=int(s[0:4])
            Month=int(s[4:6])
            Day=int(s[6:8])
            hrs=int(s[8:10])
            m=int(s[10:12])
            sec=int(s[12:16])/100.0
            latdeg=int(s[16:18])
            latmin=int(s[19:23])/10000.0
            lat=latdeg+latmin
            longdeg=int(s[24:26])
            longmin=int(s[27:31])/10000.0
            long=longdeg+longmin
            depth=int(s[31:36])/100.0
            n_picked=int(s[119:122])
            rms=int(s[48:52])/100
            err_h=int(s[85:89])/100
            err_v=int(s[89:93])/100
            f2=open("Located.csv",'a')
            s2=str('{},{},{},{},{},{},{},{},{},{},{},{},{}'.format(Year,Month,Day,hrs,m,sec,lat,long,depth,n_picked,rms,err_h,err_v))
            f2.write(s2)
            f2.write("\n")
            f2.close() 



    

    
    
 

    
    
    
    