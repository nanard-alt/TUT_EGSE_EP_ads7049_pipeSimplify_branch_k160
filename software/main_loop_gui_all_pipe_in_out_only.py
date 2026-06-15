import ok
import time
import numpy as np
import math

import tkinter as tk
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import (FigureCanvasTkAgg, NavigationToolbar2Tk)
import os

import matplotlib.pyplot as plt

init_spectrum = False

def clr_graph() :
    global init_spectrum
    init_spectrum = True
    # tk.messagebox.showinfo("showinfo", "init_spectrum = {}".format(init_spectrum))


def save_signal_in_file (Signal_out) :

    trimester = time.strftime("%Y%m%d-%H%M%S")
    file_name = trimester + 'spectre.txt'  # file name
    dir_path = 'C:/temp/'
    path = dir_path + file_name
    #file_path = "C:/Users/Bernard BERTRAND/Desktop/{}".format(file_name)
    os.makedirs(os.path.dirname(path), exist_ok=True)

    file_name = open(path, "w")

    for elm in Signal_out:

        #fichier.write("{}\n".format(elm))
        file_name.write('%s\n' % elm)

    file_name.close()

    return


############################### classe OK

array_pipe_out = np.ones(4112).astype(int)
array_pipe_out_sd = np.ones(48).astype(int)
Detector_Number = 4
Spectrum_Depth = 1024
Spectrum_Block_Size = 1028
Spectres = [[0 for i in range(0, Spectrum_Depth)] for detector in range(0, Detector_Number)]
gain_detectors = [0 for detector in range(0, Detector_Number)]
gain_detectors_real = [1 for detector in range(0, Detector_Number)]



#################################### global setting ######################################

mode_adc = 1 # set to one if ADC use
enable_high_filter = 1 # set to one to use high frequency filter
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

    def setwire_TH_rise_high_frequency(self,TH_rise):

        self.xem.SetWireInValue(0x08, TH_rise)
        self.xem.UpdateWireIns()


    def setwire_TH_fall(self,TH_fall):

        self.xem.SetWireInValue(0x03, TH_fall)
        self.xem.UpdateWireIns()

    def setwire_TH_fall_high_frequency(self,TH_fall):

        self.xem.SetWireInValue(0x09, TH_fall)
        self.xem.UpdateWireIns()

    def setwire_TH_ADC(self, TH_ADC):

        self.xem.SetWireInValue(0x07, TH_ADC)
        self.xem.UpdateWireIns()

    def setwire_gain_filtre0(self,gain_filtre0):

        self.xem.SetWireInValue(0x04, gain_filtre0)
        self.xem.UpdateWireIns()

    def setwire_gain_high_frequency0(self,gain_high_frequency0):

        self.xem.SetWireInValue(0x0A, gain_high_frequency0)
        self.xem.UpdateWireIns()

    def setwire_gain_filtre1(self,gain_filtre1):

        self.xem.SetWireInValue(0x05, gain_filtre1)
        self.xem.UpdateWireIns()

    def setwire_gain_high_frequency1(self,gain_high_frequency1):

        self.xem.SetWireInValue(0x0B, gain_high_frequency1)
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


    def getpipeout_sd(self, adresse_pipe_out_read):
        self.xem.ReadFromPipeOut(adresse_pipe_out_read, array_pipe_out_sd)
        return (array_pipe_out)


def tohex(val, nbits):
  return hex((val + (1 << nbits)) % (1 << nbits))

def update_gain_values(formated_lines_coef):
    global gain_detectors
    global gain_detectors_real

    if enable_high_filter == 0:
        gain_detectors = [
            formated_lines_coef[263], # param 264
            formated_lines_coef[264], # param 265
            formated_lines_coef[265], # param 266
            formated_lines_coef[266], # param 267
        ]
    else:
        gain_detectors = [
            formated_lines_coef[267], # param 268
            formated_lines_coef[268], # param 269
            formated_lines_coef[269], # param 270
            formated_lines_coef[270], # param 271
        ]

    gain_detectors_real = [2 ** gain_detector for gain_detector in gain_detectors]

def spectrum_label(detector):
    max_value = max(Spectres[detector])
    max_x = Spectres[detector].index(max_value)
    return "detecteur {} - gain x{} (shift {}) - enable_high_filter={} - max {} @ x={}".format(
        detector,
        gain_detectors_real[detector],
        gain_detectors[detector],
        enable_high_filter,
        max_value,
        max_x
    )

def pathname1():
    i = tk.b4.winfo_id()
    print("identité", i)
    u = racine.winfo_pathname(i, False)
    print("pathname", u)

def delay_end(fig):

    global init_spectrum
    global Spectres

    racine.after(200, lambda:delay_end(fig))
    #print("delay_end")
    #print("############## read pointer spectrum filter 0 #####################")


    adress_wire_out_science = 0x21  # filter 0
    des.getwire(adress_wire_out_science)


    if get == 4112:
        #print("read pointer spectrum filter 0 : {}".format(get))
        # print("################################ READ FIFO  Pipe spectrum filter 0 #############################################")
        adresse_pipe_out_read = 0xA2  # filter1
        des.getpipeout(adresse_pipe_out_read)
        list_array_pipe_out = list(array_pipe_out)


        adress_wire_out_science = 0x26  # filter 0 SD
        des.getwire(adress_wire_out_science)

        if get == 48:

            print("read pointer spectrum filter 0 standard definition : {}".format(get))
            adresse_pipe_out_read = 0xA5  # filter0
            des.getpipeout_sd(adresse_pipe_out_read)
            list_array_pipe_out_standard_definition = list(array_pipe_out_sd)

            for element in list_array_pipe_out_standard_definition[0:11]:
                print("spectrum SD filter 0", tohex(element, 32))

            for element in list_array_pipe_out_standard_definition[11:23]:
                print("spectrum SD filter 1", tohex(element, 32))

            adress_wire_out_science = 0x28
            des.getwire(adress_wire_out_science)

            print("############################################")
            print("read counter pulse filter Standard definition detector 0 add=0x28 {}".format(get))
            print("############################################")

            adress_wire_out_science = 0x29
            des.getwire(adress_wire_out_science)

            print("############################################")
            print("read counter pulse filter Standard definition  detector 1 add=0x29 {}".format(get))
            print("############################################")


            #print("################################ DATA of spectrum by detector #############################################")
            for detector in range(0, Detector_Number):
                start_index = detector * Spectrum_Block_Size + 4
                end_index = (detector + 1) * Spectrum_Block_Size

                for elm in list_array_pipe_out[start_index:end_index]:
                    data = (elm & 0xFFFF)

                    if np.short(data) != 0:
                        add = int(((elm & 0xFFFF0000) / 2 ** 16))
                        if 0 <= add < Spectrum_Depth:
                            Spectres[detector][add] = Spectres[detector][add] + data

        # racine.bind("<BackSpace>",  clear_vect())

        if init_spectrum == True :

            Spectres = [[0 for i in range(0, Spectrum_Depth)] for detector in range(0, Detector_Number)]
            init_spectrum = False
            # tk.messagebox.showinfo("showinfo", "init_spectrum = {}".format(init_spectrum))

        min_spectrum = min(min(Spectre) for Spectre in Spectres)
        max_spectrum = max(max(Spectre) for Spectre in Spectres)


        fig.axes[0].set_ylim(((min_spectrum, max_spectrum)))
        for detector in range(0, Detector_Number):
            fig.axes[0].lines[detector].set_ydata(Spectres[detector])
            fig.axes[0].lines[detector].set_label(spectrum_label(detector))
        legend = fig.axes[0].get_legend()
        if legend:
            legend_texts = legend.get_texts()
            for detector in range(0, min(Detector_Number, len(legend_texts))):
                legend_texts[detector].set_text(spectrum_label(detector))
        #racine.update()
        canvas.draw_idle()

        adress_wire_out_science = 0x25
        des.getwire(adress_wire_out_science)

        print("############################################")
        print("read counter pulse filter 1 add=0x25 {}".format(get))
        print("############################################")

        adress_wire_out_science = 0x22
        des.getwire(adress_wire_out_science)

        print("############################################")
        print("read counter pulse filter 0 add=0x22 {}".format(get))
        print("############################################")

#################################### param ######################################

def param(mode_adc, enable_high_filter, continuous_ready, start_capture,reset):
    param_vals = 2**31*mode_adc + 2**30*enable_high_filter + 2**29*continuous_ready + 2**1*start_capture + 2**0*reset
    print(param_vals)
    return param_vals

def Reset_unreset() :

    mode_adc = 0  # set to one if ADC use
    continuous_ready = 1  # generally set to one set to zero if filter analysis
    start_capture = 0
    reset = 1
    print("RESET")
    des.ResetDES(param(mode_adc, enable_high_filter, continuous_ready, start_capture, reset))
    time.sleep(2)
    reset = 0
    print("unRESET")
    des.unResetDES(param(mode_adc, enable_high_filter, continuous_ready, start_capture, reset))
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

    print("\nNb de coups :")
    for detector in range(0, Detector_Number):
        print("detecteur {} = {}".format(detector, sum(Spectres[detector])))

    save_signal_in_file(Spectres[0])
    #print(time.strftime())
    print(Spectres)
    racine.destroy()
    racine.quit()

# def clear_vect(Spectre):
    # Spectre = [0 for i in range(0, 1024)]
    # print("####################################################################################################")



def Injection() :

    mode_adc = 0  # set to one if ADC use
    continuous_ready = 0  # generally set to zero set to one if filter analysis
    start_capture = 1

    print("injection")
    des.start_capture(param(mode_adc, enable_high_filter, continuous_ready, start_capture, reset))

    file_name = open('Signal_ADC_400keV.txt', "r")
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

    #################################### write formated_lines to pipe in INJECTION ##########################################

    print("############## INJection #####################")
    list_pipe_in_array = np.array(formated_lines)
    # print("list_pipe_in_array{}.format"(list_pipe_in_array))
    adresse = 0x80
    des.setpipein(list_pipe_in_array, adresse)

def ADC() :

    mode_adc = 1  # set to one if ADC use
    #continuous_ready = 0  # generally set to zero set to one if filter analysis
    #start_capture = 1

    print("ADC")
    des.start_capture(param(mode_adc, enable_high_filter, continuous_ready, start_capture, reset))

def get_entry_TH(event) :
    valeur = v.get()
    print("get_entry_TH:",valeur)
    TH_rise = int(valeur)*32
    des.setwire_TH_rise(TH_rise)
    print(TH_rise)

def get_entry_TL(event) :
    valeur = v1.get()
    print("get_entry_TL:",valeur)
    TH_fall = int(valeur)*32
    des.setwire_TH_fall(TH_fall)
    print(TH_fall)

def get_gain_filtre0(event) :

    print("Coef")
    file = open('coef_V2.txt', "r")
    lines_coef = file.readlines()
    formated_lines_coef = []
    for elm in lines_coef:
        formated_lines_coef.append(int(elm[:-1]))  ##la liste lines a des eleementr ascii dont on supprime\n avec :-1
        # formated_lines.append(elm[:-1])

    ###### Ecris la liste sur le port 0x81
    # print("la liste coef est \n {}".format(formated_lines_coef))
    valeur = v2.get()
    print("get_gain_filtre0:",valeur)
    gain_filtre0 = int(math.log2(int(valeur)))
    #list1 = formated_lines_coef[0:134]
    #list2 = formated_lines_coef[136:139]
    #formated_lines_coef = list1 + [gain_filtre0] + list2

    formated_lines_coef[135] = gain_filtre0

    for index, fruit in enumerate(formated_lines_coef):
        print(f"L'index {index} correspond à : {fruit}")


    print(formated_lines_coef)
    list_pipe_in_array = np.array(formated_lines_coef)
    # print("la liste coef est \n {}".format(formated_lines_coef))
    # print("le tableau coef est \n {}".format(list_pipe_in_array))
    adresse = 0x81  # PORT pour écrire toute la configuration
    des.setpipein(list_pipe_in_array, adresse)

def gain_high_frequency0(event) :

    print("Coef")
    file = open('coef_V2.txt', "r")
    lines_coef = file.readlines()
    formated_lines_coef = []
    for elm in lines_coef:
        formated_lines_coef.append(int(elm[:-1]))  ##la liste lines a des eleementr ascii dont on supprime\n avec :-1
        # formated_lines.append(elm[:-1])

    valeur = v2.get()
    print("gain_high_frequency0:",valeur)
    gain_filtre0 = int(math.log2(int(valeur)))

    formated_lines_coef[136] = gain_filtre0

    for index, fruit in enumerate(formated_lines_coef):
        print(f"L'index {index} correspond à : {fruit}")


    print(formated_lines_coef)
    list_pipe_in_array = np.array(formated_lines_coef)
    # print("la liste coef est \n {}".format(formated_lines_coef))
    # print("le tableau coef est \n {}".format(list_pipe_in_array))
    adresse = 0x81  # PORT pour écrire toute la configuration
    des.setpipein(list_pipe_in_array, adresse)





def get_gain_filtre1(event) :


    print("Coef")
    file = open('coef_V2.txt', "r")
    lines_coef = file.readlines()
    formated_lines_coef = []
    for elm in lines_coef:
        formated_lines_coef.append(int(elm[:-1]))  ##la liste lines a des eleementr ascii dont on supprime\n avec :-1
        # formated_lines.append(elm[:-1])

    ###### Ecris la liste sur le port 0x81
    # print("la liste coef est \n {}".format(formated_lines_coef))
    valeur = v3.get()
    print("get_gain_filtre1:",valeur)
    gain_filtre1 = int(math.log2(int(valeur)))
    des.setwire_gain_filtre1(gain_filtre1)
    print(gain_filtre1)

    formated_lines_coef[137] = gain_filtre1

    for index, fruit in enumerate(formated_lines_coef):
        print(f"L'index {index} correspond à : {fruit}")


    print(formated_lines_coef)
    list_pipe_in_array = np.array(formated_lines_coef)
    # print("la liste coef est \n {}".format(formated_lines_coef))
    # print("le tableau coef est \n {}".format(list_pipe_in_array))
    adresse = 0x81  # PORT pour écrire toute la configuration
    des.setpipein(list_pipe_in_array, adresse)



def gain_high_frequency1(event) :

    print("Coef")
    file = open('coef_V2.txt', "r")
    lines_coef = file.readlines()
    formated_lines_coef = []
    for elm in lines_coef:
        formated_lines_coef.append(int(elm[:-1]))  ##la liste lines a des eleementr ascii dont on supprime\n avec :-1
        # formated_lines.append(elm[:-1])

    valeur = v3.get()
    print("gain_high_frequency1:",valeur)
    gain_filtre1 = int(math.log2(int(valeur)))
    des.setwire_gain_high_frequency1(gain_filtre1)
    print(gain_filtre1)

    formated_lines_coef[138] = gain_filtre1

    for index, fruit in enumerate(formated_lines_coef):
        print(f"L'index {index} correspond à : {fruit}")


    print(formated_lines_coef)
    list_pipe_in_array = np.array(formated_lines_coef)
    # print("la liste coef est \n {}".format(formated_lines_coef))
    # print("le tableau coef est \n {}".format(list_pipe_in_array))
    adresse = 0x81  # PORT pour écrire toute la configuration
    des.setpipein(list_pipe_in_array, adresse)


racine = tk.Tk() #fait apparaitre fenetre principale

des = DESTester()


# the figure that will contain the plot
fig = Figure(figsize=(5, 5),dpi=100)

# adding the subplot
plot1 = fig.add_subplot(111)

# creating the Tkinter canvas
# containing the Matplotlib figure
canvas = FigureCanvasTkAgg(fig,master=racine)
canvas.draw()

# placing the canvas on the Tkinter window
canvas.get_tk_widget().pack()

# creating the Matplotlib toolbar
toolbar = NavigationToolbar2Tk(canvas,racine)

toolbar.update()

racine.geometry("600x600+500+500")
racine.pack_propagate(0)
racine.title("Main_Win_GSE_3UT")
label = tk.Label(racine, text="GSE GUI 3UT")
label.pack()

#b5 = Button(racine, text="RESET", command=Reset_unreset,name="b5") # BOUTON reset
b6 = tk.Button(racine, text="Injection", command=Injection,name="b6") # BOUTON Injection
b7 = tk.Button(racine, text="ADC", command=ADC,name="b7") # BOUTON Injection
#b8 = Button(racine, text="Close Opal Kelly", command=close,name="b8") # BOUTON Injection
#b5.pack()
b7.pack()
b6.pack()
#b8.pack()

label = tk.Label(racine, text="level pulse rising : 1->1024")
v = tk.Entry( racine, text="get_entry_TH", bd = 5 )
label.pack()
v.pack()  # pack l'ojb à gui
v.bind('<Return>', get_entry_TH)

label = tk.Label(racine, text="level pulse falling < level pulse rising  : 1->1024")
v1 = tk.Entry( racine, text="get_entry_TL", bd = 5 )
label.pack()
v1.pack()  # pack l'ojb à gui
v1.bind('<Return>', get_entry_TL)

label = tk.Label(racine, text="Gain FIR 1 : 1 -> ~32")
v2 = tk.Entry( racine, text="get_gain_filtre0", bd = 5 )
label.pack()
v2.pack()  # pack l'ojb à gui
v2.bind('<Return>', get_gain_filtre0)

label = tk.Label(racine, text="Gain FIR 2 : 1 -> ~32")
v3 = tk.Entry( racine, text="get_gain_filtre1", bd = 5 )
label.pack()
v3.pack()  # pack l'ojb à gui
v3.bind('<Return>', get_gain_filtre1)

############################### Init OK et Reset before GUI
InitializeDevice()
################################## RESET #############################################

reset  = 1

print ("RESET")
des.ResetDES(param(mode_adc, enable_high_filter, continuous_ready, start_capture, reset))
time.sleep(2)

################################## UNRESET #############################################

reset  = 0

print ("unRESET")
des.unResetDES(param(mode_adc, enable_high_filter, continuous_ready, start_capture, reset))
########################################################################################################


#################################  LOAD COEF  ###################################################
###### Ouvre la fichier et forme une liste

print ("Coef")
file = open('coef_V2.txt', "r")
lines_coef = file.readlines()
formated_lines_coef = []
for elm in lines_coef :
    formated_lines_coef.append(int(elm[:-1]))##la liste lines a des eleementr ascii dont on supprime\n avec :-1
    #formated_lines.append(elm[:-1])

###### Ecris la liste sur le port 0x81
#for index, fruit in enumerate(formated_lines_coef):
#    print(f"L'index {index} correspond à : {fruit}")
#print("la liste coef est \n {}".format(formated_lines_coef))
list_pipe_in_array = np.array(formated_lines_coef)
#print("le tableau coef est \n {}".format(list_pipe_in_array))
adresse=0x81  # PORT pour écrire toute la configuration
des.setpipein(list_pipe_in_array,adresse)

###################################  START CAPTURE  ###############################################

start_capture  = 1
update_gain_values(formated_lines_coef)

print ("start_capture")
des.start_capture(param(mode_adc, enable_high_filter, continuous_ready, start_capture, reset))

###################################  IRQ time  ###############################################

for detector in range(0, Detector_Number):
    fig.axes[0].plot(Spectres[detector], label = spectrum_label(detector))  #Axes class represents one (sub-)plot in a figure
plot1.legend(loc="upper left", fontsize=7, framealpha=0.75)
fig.supxlabel("raw")
fig.supylabel("Count number")

delay_end(fig)

##################################
######### Bouton quitter #########
##################################

racine.protocol(name="WM_DELETE_WINDOW", func = lambda : close())
racine.bind("<Escape>", lambda e : close())
racine.bind("<Delete>", lambda cl : clr_graph())
# racine.bind("<BackSpace>", lambda cl : clear_graph())
##################################  MAIN GUI ###################################################
racine.mainloop()
print("Affichage commandé après ARRET de mainloop")
