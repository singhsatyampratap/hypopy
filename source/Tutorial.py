#import hypopy
#import obspy


#hypopy.setup
#=[4.43,5.12,5.47,5.56,5.62,5.86,7.9]
#d=[0.0,1.5,3,4.25,6.0,8.00,21]
#hypopy.model('Gey Geyser',v,d)

#hypopy.add_station("Satya","CM01","XB","HHZ",22,44,243)
#st=obspy.read("")
#traceN=st[0]
#traceE=st[1]
#traceZ=st[2]
#start=traceN.stats.starttime
#hypopy.phase_header("Y2000",start,22.643,44.28)




#from obspy.signal.trigger import ar_pick
#df = traceN.stats.sampling_rate
#p_pick, s_pick = ar_pick(traceN.data, traceE.data, traceZ.data, df, 1.0, 20.0, 1.0, 0.1, 4.0, 1.0, 2, 8, 0.1, 0.2)
#t=traceN.stats.starttime
#p_arrival_time=t+p_pick
#s_arrival_time=t+s_pick
    
#station=traceN.stats.station
#net=traceN.stats.network
    
#hypopy.addpicks("Y2000",station,net,p_arrival_time,s_arrival_time)

#evid=20000001
#hypopy.phase_footer("Y2000",evid)

import hypopy 
#hypopy.locate("gey","allseed","testone","Satyam")
#hypopy.export_located("Satyam")


from obspy import UTCDateTime
from obspy.clients.fdsn import Client

client = Client("IRIS")
t = UTCDateTime("2011-03-11T05:46:23")  # Tohoku
inv = client.get_stations(network="II",station= "*",channel="*", starttime=t + 10 * 60, endtime=t + 30 * 60)
print(inv)
#st.plot()

network=inv[0]
n=len(network)
print("Total number of station in Network= {}".format(n))
from obspy import UTCDateTime
from obspy.clients.fdsn import Client

client = Client("IRIS")
t = UTCDateTime("2011-03-11T05:46:23")  # Tohoku
st = client.get_waveforms("II", "PFO", "*", "BH*",
                          t + 10 * 60, t + 30 * 60)
print(st)
st.plot()


#st=obspy.read("")
traceN=st[1]
traceE=st[2]
traceZ=st[0]





evid=20000001
initial_origintime=traceN.stats.starttime
initial_latitude=network[0].latitude
initial_longitude=network[0].longitude
hypopy.phase_header("Y2000",UTCDateTime('2011-03-11T05:46:23'),44,72)