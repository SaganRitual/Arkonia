#!/usr/local/bin/python3.6.2
import sys

ssGenome = 0

tokenLookup = {
    "A" : 0, "B" : 0, "D" : 0, "H" : 0, "K" : 0, "L" : 0, "N" : 0, "P" : 0, "U" : 0
}

def realGene(token, tabs):
    global tokenLookup
    global ssGenome

    print(tabs + token + "_")
    tokenLookup[token] += 1; return ssGenome + 2

def virtualVoidGene(genome, token, tabs):
    global tokenLookup
    global ssGenome

    if genome[ssGenome] == token: return ssGenome + 2
    else:
        print(tabs + token + "_")
        tokenLookup[token] += 1; return ssGenome

def format(genome):
    global tokenLookup
    global ssGenome
    
    token = ""

    # print("a" + token, ssGenome)
    ssGenome = virtualVoidGene(genome, "L", "")
    # print("b" + token, ssGenome)
    ssGenome = virtualVoidGene(genome, "N", "  ")
    # print("q" + token, ssGenome)
        
    while ssGenome < len(genome):
        token = genome[ssGenome]

        # print("c" + token, ssGenome)
        if token not in tokenLookup.keys(): ssGenome += 1; continue
        # print("d" + token, ssGenome)
        
        if token == "L":
            # print("e" + token, ssGenome)
            ssGenome = realGene(token, "")
            # print("f" + token, ssGenome)
            ssGenome = virtualVoidGene(genome, "N", "  ")

        elif token == "N":
            ssGenome = realGene(token, " ")
            # print("g" + token, ssGenome)

        else:
            # print("h" + token, ssGenome)
            ssGenome = realGene(token, "    ")

                               
format(sys.argv[1])    
for key, value in tokenLookup.items(): print(str(key) + ": " + str(value) + "_")
