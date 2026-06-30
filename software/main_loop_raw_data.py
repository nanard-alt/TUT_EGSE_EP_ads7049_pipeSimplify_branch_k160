import ok
import time
import array as arr

import math
import matplotlib.pyplot as plt
import numpy as np

count = 0
count_data = 0
ligne = 0
i = 0
indice=0
lignes = []
list_array_pipe_out_detector_MSB = [[] for _ in range(7)]
list_array_pipe_out_detector_LSB = [[] for _ in range(7)]
param_vals=0

raw_detector_endpoints = [
    {"wire": 0x20, "pipe": 0xA1},
    {"wire": 0x23, "pipe": 0xA3},
    {"wire": 0x30, "pipe": 0xA6},
    {"wire": 0x31, "pipe": 0xA7},
    {"wire": 0x32, "pipe": 0xA8},
    {"wire": 0x33, "pipe": 0xA9},
    {"wire": 0x34, "pipe": 0xAA},
]


file_names = ['Signal_ADC_20keV.txt','Signal_ADC_100keV.txt','Signal_ADC_400keV.txt',
              'Signal_ADC_20keV.txt','Signal_ADC_100keV.txt','Signal_ADC_400keV.txt',
              'Signal_ADC_20keV.txt','Signal_ADC_100keV.txt','Signal_ADC_400keV.txt',
              'Signal_ADC_20keV.txt','Signal_ADC_100keV.txt','Signal_ADC_400keV.txt']

#list_pipe_in_array = np.ones(2048).astype(int)

#list_pipe_in = np.linspace(0,511,512).astype(int)
#list_pipe_in_array = np.array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 ,14 ,15 ,16 ,15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1,0,-1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13 ,-14 ,-15 ,-16 ,-15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1,0])


array_pipe_out = np.ones(128).astype(int)
list_pipe_in_array = np.ones(128).astype(int)

#################################################
#list_pipe_in = np.array(ma_liste)
#ma_list = list(mon_tab)
###############################################

#################################### global setting ######################################

mode_adc = 0 # set to one if ADC use
enable_high_freq = 1
continuous_ready  = 1 # generally set to one set to zero if filter analysis
start_capture  = 0

#################################### CLASS ######################################

class DESTester:
    def __init__(self):
        return

    def InitializeDevice(self):
        # Open the first device we find.
        self.xem = ok.FrontPanelDevices().Open()
        if not self.xem:
            print ("A device could not be opened.  Is one connected?")
        else:
            print ("A device is opened")

        # Get some general information about the device.
        self.devInfo = ok.okTDeviceInfo()
        if (self.xem.NoError != self.xem.GetDeviceInfo(self.devInfo)):
            print ("Unable to retrieve device information.")
            return(False)
        print("         Product: " + self.devInfo.productName)
        print("Firmware version: %d.%d" % (self.devInfo.deviceMajorVersion, self.devInfo.deviceMinorVersion))
        print("   Serial Number: %s" % self.devInfo.serialNumber)
        print("       Device ID: %s" % self.devInfo.deviceID)

        # Download the configuration file.
        #if (self.xem.NoError != self.xem.ConfigureFPGA("C:\XEM7310-A75-bitfile\Counters.bit")):
            #print ("FPGA configuration failed.")
        #else:
            #print("FPGA configuration done.")


        # Check for FrontPanel support in the FPGA configuration.
        if (False == self.xem.IsFrontPanelEnabled()):
            print ("FrontPanel support is not available.")
        else:
            print("FrontPanel support is available.")
            return(False)

        print ("FrontPanel support is available.")
        return(True)

    def ResetDES(self,param_vals):
        self.xem.SetWireInValue(0x00, param_vals)# ADC mode disable , clear RAM spectre disable, continuous mode disable, reset enable
        self.xem.UpdateWireIns()

    def unResetDES(self,param_vals):
        self.xem.SetWireInValue(0x00, param_vals)# ADC mode disable , clear RAM spectre disable, continuous mode disable, reset disable
        self.xem.UpdateWireIns()

    def start_capture(self,param_vals):
        self.xem.SetWireInValue(0x00, param_vals)# ADC mode disable , clear RAM spectre disable, continuous mode disable, capture start,  reset enable
        self.xem.UpdateWireIns()

    def setwire(self):

        self.xem.SetWireInValue(0x01, level_trig)
        self.xem.UpdateWireIns()

    def setwire_TH_rise(self):

        self.xem.SetWireInValue(0x02, TH_rise)
        self.xem.UpdateWireIns()

    def setwire_TH_fall(self):

        self.xem.SetWireInValue(0x03, TH_fall)
        self.xem.UpdateWireIns()

    def getwire(self,adress_wire_out_science):
        global get
        self.xem.UpdateWireOuts();
        get = self.xem.GetWireOutValue(adress_wire_out_science)

    def setpipein(self,list_pipe_in,adresse):
        self.xem.WriteToPipeIn(adresse, list_pipe_in)

    def getpipeout(self,adresse_pipe_out_read):
        self.xem.ReadFromPipeOut(adresse_pipe_out_read,array_pipe_out)
        return(array_pipe_out)

#################################### param ######################################

def param(mode_adc, enable_high_freq, continuous_ready, start_capture,reset):
    param_vals = 2**31*mode_adc + 2**30*enable_high_freq + 2**29*continuous_ready + 2**1*start_capture + 2**0*reset

    return param_vals



#################################### Main code ######################################

print ("------ DES Encrypt/Decrypt Tester in Python ------")
des = DESTester()
if (False == des.InitializeDevice()):
    exit
print ("------------------------------------------------------------")
time.sleep(1)
################################## RESET #############################################

reset  = 1
continuous_ready = 1

print ("RESET")
des.ResetDES(param(mode_adc, enable_high_freq, continuous_ready, start_capture, reset))

time.sleep(3)

################################## UNRESET #############################################

reset  = 0
continuous_ready = 1

print ("unRESET")
des.unResetDES(param(mode_adc, enable_high_freq, continuous_ready, start_capture, reset))

#################################  LOAD COEF and  SET LEVEL TRIGG  ###################################################
print ("Coef")
file = open('coef_V2.txt', "r")
lines_coef = file.readlines()
formated_lines_coef = []
for elm in lines_coef :
    formated_lines_coef.append(int(elm[:-1]))##la liste lines a des eleementr ascii dont on supprime\n avec :-1
    #formated_lines.append(elm[:-1])

#print("la liste coef est \n {}".format(formated_lines_coef))
list_pipe_in_array = np.array(formated_lines_coef)
#print("le tableau coef est \n {}".format(list_pipe_in_array))
gain_base_index = 455 if enable_high_freq == 0 else 462
gain_detector = [formated_lines_coef[gain_base_index + detector] for detector in range(7)]
gain_detector_real = [2 ** gain for gain in gain_detector]
adresse=0x81  # filter0
des.setpipein(list_pipe_in_array,adresse)

###################################  START CAPTURE  ###############################################

reset  = 0
continuous_ready = 1
start_capture = 1
print("start_capture")
des.unResetDES(param(mode_adc, enable_high_freq, continuous_ready, start_capture, reset))


for file_name in file_names:
#################################### read file from list name ##########################################

    # start_capture = 1
    # print("start_capture")
    # des.unResetDES(param(mode_adc, enable_high_freq, continuous_ready, start_capture, reset))


    file_name = open(file_name, "r")
    lines = file_name.readlines()
    formated_lines = []
    for elm in lines:
        formated_lines.append(int(elm[:-1]))
    print("############################################")
    print("file name fichier injecté {}".format(file_name))
    #print("print formated lines {}".format(formated_lines)) #### print liste ONE file
    print("min ", min(formated_lines))
    print("max ", max(formated_lines))
    print("max-min", max(formated_lines)-min(formated_lines))

#################################### write formated_lines to pipe in injection ##########################################
    list_pipe_in_array = np.array(formated_lines)
    #print("list_pipe_in_array{}".format(list_pipe_in_array))
    adresse = 0x80
    des.setpipein(list_pipe_in_array, adresse)

    list_array_pipe_out_detector = []
    for detector, endpoints in enumerate(raw_detector_endpoints):
        adress_wire_out_science = endpoints["wire"]
        des.getwire(adress_wire_out_science)
        while (get != 128):
            print("read pointer detector {} {}".format(detector, get))
            des.getwire(adress_wire_out_science)

        print("############################################")
        print("read pointer detector {} 0x{:02X} {}".format(detector, adress_wire_out_science, get))
        print("############################################")

        array_pipe_out = np.ones(get).astype(int)
        adresse_pipe_out_read = endpoints["pipe"]
        des.getpipeout(adresse_pipe_out_read)
        list_array_pipe_out_detector.append(list(array_pipe_out))







###################################################################################################################################

################### SPLITE 32 bit Science from Pipe out ##########################################################

    for detector, detector_pipe_out in enumerate(list_array_pipe_out_detector):
        for elm in detector_pipe_out:
            list_array_pipe_out_detector_MSB[detector].append(np.short((elm & 0xFFFF0000)/2**16))
            list_array_pipe_out_detector_LSB[detector].append(np.short(elm & 0xFFFF))

############################ write "list_array_pipe_out file" in file indice name  ##########################################
    file_name_out = f"{indice}.txt"
    file = open(file_name_out, "w")
    for items in list_array_pipe_out_detector_MSB[1]:
        file.write('%s\n' % items)
    file.close()
    indice+=1

    plt.figure(figsize=(12, 9))
    plt.suptitle("enable_high_freq = {}".format(enable_high_freq), fontsize=12)
    for detector, endpoints in enumerate(raw_detector_endpoints):
        plt.subplot(4, 2, detector + 1)
        plt.plot(list_array_pipe_out_detector_LSB[detector])
        plt.plot(list_array_pipe_out_detector_MSB[detector])
        plt.title("0x{:02X} - detecteur {} - gain x{} (shift {})".format(endpoints["pipe"], detector, gain_detector_real[detector], gain_detector[detector]), fontsize=10)
        plt.xlabel("temps")
        plt.ylabel("amplitude")
    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.show()

print("script done")
