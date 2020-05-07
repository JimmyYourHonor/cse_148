#!/usr/bin/python3

import sys
import math
import matplotlib.pyplot as plt

def parseResults(file, benchmark, optimization):

    testnumber = 0
    nanoseconds = 0.0

    with open(file) as f:
        for line in f:

            words = line.split()

            try:
                if words[1] != 'testbench.DUT.MIPS_CORE.ALU': continue
            except: continue

            try: testnumber = int(words[-1], 16)
            except: continue

            try: nanoseconds = float(words[2][1:])
            except:
                try: nanoseconds = float(words[3])
                except: continue

            #if testnumber < 100 or testnumber > 124:
             #   continue

            data['full'][benchmark][optimization][testnumber] = nanoseconds

    return (testnumber, nanoseconds)

def parseFastResults(file, benchmark, optimization):

    testnumber = 0
    nanoseconds = 0

    with open(file) as f:
        for line in f:

            words = line.split()

            try:
                if words[1] != 'fast_testbench.MIPS_CORE.ALU': continue
            except: continue

            try: testnumber = int(words[-1], 16)
            except: continue

            try: nanoseconds = int(words[3][:-1])
            except: continue

            data['fast'][benchmark][optimization][testnumber] = nanoseconds

    return (testnumber, nanoseconds)

if __name__ == "__main__":

    data = {}

    # read data from files
    for file in sys.argv[1:]:

        print('Parsing file', file + '...')
        testbenchVersion = file.split("_")[0]
        print('\t' + ('testbench.sv' if testbenchVersion == "full" else 'fast_testbench.sv'))
        benchmark = file.split("_")[1]
        print('\tBenchmark:\t', file.split("_")[1])
        optimization = file.split("_")[2].split(".")[0]
        print('\tOptimization:\t', file.split("_")[2].split(".")[0])

        if not testbenchVersion in data:
            data[testbenchVersion] = {}

        if not benchmark in data[testbenchVersion]:
            data[testbenchVersion][benchmark] = {}

        if not optimization in data[testbenchVersion][benchmark]:
            data[testbenchVersion][benchmark][optimization] = {}

        (numTests, totalTime) = (parseResults(file, benchmark, optimization) if (testbenchVersion == 'full') else parseFastResults(file, benchmark, optimization))

        print('\tTotal tests:\t', numTests)
        print('\tTotal time:\t', totalTime, 'ns')

    # display data in graph
    for testbenchVersion in data:
        for test in data[testbenchVersion]:

            fig=plt.figure()
            ax=fig.add_subplot(111)

            optimizations = data[testbenchVersion][test]
            for o in optimizations:
                x = [float(a) for a in optimizations[o].keys()]
                y = [float(a) / 100000 for a in optimizations[o].values()]
                ax.plot(x, y, label=o, linewidth=0.5)
            plt.legend(loc=2)
            #plt.show()
            plt.savefig(testbenchVersion + "_" + test + ".png")

            for o in optimizations:
                x = [float(a) for a in optimizations[o].keys()]
                y = [float(a) / 100000 for a in optimizations[o].values()]
                ax.plot(x, y, label=o, linewidth=0.5)