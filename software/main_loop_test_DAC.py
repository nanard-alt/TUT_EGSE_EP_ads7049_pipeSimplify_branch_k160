import ok
import time
import numpy as np
import math

import tkinter as tk
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import (FigureCanvasTkAgg, NavigationToolbar2Tk)
import os

import matplotlib.pyplot as plt

#################################### CLASS ######################################

number = 0


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


    def Close (self) :
        self.xem = ok.FrontPanel().Close()

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

    def setwire_TH_rise(self,TH_rise):

        self.xem.SetWireInValue(0x02, TH_rise)
        self.xem.UpdateWireIns()

    def setwire_TH_fall(self,TH_fall):

        self.xem.SetWireInValue(0x03, TH_fall)
        self.xem.UpdateWireIns()

    def setwire_gain_filtre0(self,gain_filtre0):

        self.xem.SetWireInValue(0x04, gain_filtre0)
        self.xem.UpdateWireIns()

    def setwire_gain_filtre1(self,gain_filtre1):

        self.xem.SetWireInValue(0x05, gain_filtre1)
        self.xem.UpdateWireIns()

    def setwire_DAC_setup(self, DAC_setup):

        self.xem.SetWireInValue(0x06, DAC_setup)
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

def tohex(val, nbits):
  return hex((val + (1 << nbits)) % (1 << nbits))


def Reset_unreset() :

    mode_adc = 0  # set to one if ADC use
    reset_ram = 1  # set to one if clear RAM spectrum
    continuous_ready = 1  # generally set to one set to zero if filter analysis
    start_capture = 0
    reset = 1
    print("RESET")
    des.ResetDES(param(mode_adc, reset_ram, continuous_ready, start_capture, reset))
    time.sleep(2)
    reset = 0
    print("unRESET")
    des.unResetDES(param(mode_adc, reset_ram, continuous_ready, start_capture, reset))
    start_capture = 1

def InitializeDevice() :
    print("------ DES Encrypt/Decrypt Tester in Python ------")

    if (False == des.InitializeDevice()):
        exit
    print("------------------------------------------------------------")

def close() :
    print("button Close")
    des.Close
    print("exit")

    print("\nNb de coups :\nFir1 = {}\nFir2 = {}\n ".format(sum(Spectre), sum(Spectre1)))

    save_signal_in_file(Spectre)
    #print(time.strftime())
    print(Spectre)
    print(Spectre1)
    racine.destroy()
    racine.quit()

# def clear_vect(Spectre):
    # Spectre = [0 for i in range(0, 1024)]
    # print("####################################################################################################")

#################################### param ######################################

def param(mode_adc, reset_ram, continuous_ready, start_capture,reset):
    param_vals = 2**31*mode_adc + 2**30*reset_ram + 2**29*continuous_ready + 2**1*start_capture + 2**0*reset

    return param_vals

#################################### Main code ######################################

print ("------ DES Encrypt/Decrypt Tester in Python ------")
des = DESTester()
if (False == des.InitializeDevice()):
    exit
print ("------------------------------------------------------------")
time.sleep(1)
################################## RESET #############################################

mode_adc = 0
reset_ram = 0
continuous_ready  = 1
start_capture  = 0
reset = 1

print ("RESET")
des.ResetDES(param(mode_adc, reset_ram, continuous_ready, start_capture, reset))

time.sleep(2)

################################## UNRESET #############################################

mode_adc = 0
reset_ram = 0
continuous_ready  = 1
start_capture  = 0
reset = 0



print ("unRESET")
des.unResetDES(param(mode_adc, reset_ram, continuous_ready, start_capture, reset))
########################################################################################################

while number < 2 ** 32 :

    print(f"Number is {number}!")
    number = number + 1
    time.sleep(1)
    DAC_setup = number
    des.setwire_DAC_setup(DAC_setup)
