#!/usr/local/bin/python3.6.2
import sys

def format(genome):
    numL=0
    numN=0
    numA=0
    numB=0
    numW=0
    numF=0
    numH=0
    
    i=0
    if genome[0] != "L":
        print("L_")
        numL+=1
        
    if genome[2] != "N":  
        print("\tN_")  
        numN+=1
        
    while i != len(genome):
        if genome[i] == "L":
            print("L_")
            numL+=1
            #increment 2 to account for _
            i+=2 
            if genome[i] != "N":
                print("\tN_")
                numN+=1
        elif genome[i] == "N":
            print("\tN_")
            numN+=1
            #increment 2 to account for _
            i+=2 
        else:    
            print("\t\t", end="")
            while(1):
                print(genome[i], end="")
                if genome[i] == "A":
                    numA+=1 
                if genome[i] == "B":
                    numB+=1
                if genome[i] == "W":
                    numW+=1
                if genome[i] == "F":
                    numF+=1
                if genome[i] == "H":
                    numH+=1
                i+=1
                if i == len(genome):
                    print("")     
                    print("Num L:"+str(numL))
                    print("Num N:"+str(numN))
                    print("Num A:"+str(numA))
                    print("Num B:"+str(numB))
                    print("Num W:"+str(numW))
                    print("Num F:"+str(numF))
                    print("Num H:"+str(numH))
                    return
                if genome[i] == "L" or genome[i] == "N":
                    print("")
                    break   
                          
  
format(sys.argv[1])    
