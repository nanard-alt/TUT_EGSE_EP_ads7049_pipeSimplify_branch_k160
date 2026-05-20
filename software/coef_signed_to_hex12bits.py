import numpy as np
import math

import matplotlib.pyplot as plt
import numpy as np

def signed_int_to_hex_12bits (nb_int_16):

    # convertion en hexa signé
    if nb_int_16 > 4096-1 or nb_int_16 < -4096 :
        result_formated = "ERROR"
        print("ERROR")
        print(nb_int_16)
    else :
        if nb_int_16 >= 0 :
            #print(nb_int_16)
            result = hex(nb_int_16)

        if nb_int_16 < 0 :
            result = hex(0xFFF+nb_int_16+1)

        if len(result) == 3:
            result_formated = "00" + result[-1:]
            #print("len(result)\n {}".format(len(result)))
            #print("result\n {}".format(result))
            #print("result_formated\n {}".format(result_formated))

        elif len(result) == 4:

            result_formated = "0" + result[-2:]
            #print("len(result)\n {}".format(len(result)))
            #print("result\n {}".format(result))
            #print("result_formated\n {}".format(result_formated))

        elif len(result) == 5:

            result_formated = result[-3:]
            #print("len(result)\n {}".format(len(result)))
            #print("result\n {}".format(result))
            #print("result_formated\n {}".format(result_formated))

        elif len(result) == 6:

            result_formated = result[-4:]
            #print("len(result)\n {}".format(len(result)))
            #print("result\n {}".format(result))
            #print("result_formated\n {}".format(result_formated))


        elif len(result) == 7:

            result_formated = result[-5:]
            #print("len(result)\n {}".format(len(result)))
            #print("result\n {}".format(result))
            #print("result_formated\n {}".format(result_formated))

        else:
            result_formated = "ERROR"
            #print("len(result)\n {}".format(len(result)))


    return result_formated 

def signed_int_to_hex_16bits_opt (nb_int_16):

    # convertion en hexa signé
    if nb_int_16 > 2147483647 or nb_int_16 < - 2147483648 : result_formated = "ERROR"
    else : result_formated = print("{:08X}".format(np.uint32(nb_int_16)))

    return result_formated

indice_impaire = 1
indice_paire = 0

print ("int to hex")
file_name_out = f"Signal_ADC.txt"
file = open(file_name_out, "r")
lines = file.readlines()
indice_impaire = indice_impaire + 2
formated_lines_before = []
formated_lines_hex_before = []

for elm in lines :
    formated_lines_before.append((int(elm[:-1])))##la liste lines a des eleementr ascii dont on supprime\n avec :-1
    #print(formated_lines_before)

for elm in formated_lines_before :
    formated_lines_hex_before.append((signed_int_to_hex_12bits(round(elm/16))))
    #formated_lines_hex_before.append((signed_int_to_hex_12bits(round(elm))))
    #print(formated_lines_hex_before)

file_name_out = f"hex_in_file.txt"
file = open(file_name_out, "w")
for items in formated_lines_hex_before:
    file.write('%s\n' % items)
file.close()

plt.subplot(211)
plt.plot(formated_lines_before)
plt.title("Before filter")
plt.xlabel("temps")
plt.ylabel("amplitude")
plt.show()