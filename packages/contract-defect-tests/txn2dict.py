import json
import math
import numpy as np
import matplotlib.mlab as mlab
import matplotlib.pyplot as plt
import scipy.stats as stats

def txnJSON2Dict(JSONstring):
	jdata = json.loads(JSONstring)
	
	contractBlock = jdata.pop(0)
	allowedGas = contractBlock["gas"]
	owner = contractBlock["from"]

	 
	totalGas = []
	uniqueAddresses = []
	totalValues = []
	addressStats = {}

	#{user:{gasUsed: ; txns: , }... construct dictionary of user statistics
	for txn in jdata:
		user = txn["from"]
		if user == owner: 
			continue
		value = int(txn["value"])
		isError = int(txn["isError"])
		gasUsed = int(txn["gasUsed"])
		outOfGas = 1 if (gasUsed==allowedGas and isError==1) else 0


		uniqueAddresses.append(user)
		totalGas.append(gasUsed)
		totalValues.append(value)


		if user in addressStats:
			addressStats[user]["numTxns"] = addressStats[user]["numTxns"] + 1
			addressStats[user]["value"] = addressStats[user]["value"] + value
			addressStats[user]["errors"] = addressStats[user]["errors"] + isError
			addressStats[user]["gasUsed"] = addressStats[user]["gasUsed"] + [gasUsed]
			addressStats[user]["outOfGas"] = addressStats[user]["outOfGas"] + outOfGas
			if (isError==1):
				addressStats[user]["badTxns"].append(txn["hash"])
		else:
			userStats= {"numTxns" : 1, "value" : value, "errors" : isError, "gasUsed" : [gasUsed], "outOfGas" : outOfGas, "badTxns" : []}
			if (isError):
				userStats["badTxns"].append(txn["hash"])
			addressStats[user] = userStats


	uniqueAddresses = list(set(uniqueAddresses))


	
	#Get standard deviation for gas used over all txns on contract from all users
	numTxns = len(jdata)

	totalAveGasPerTxn = float(sum(totalGas)) / numTxns
	variance = 0
	
	for gas in totalGas:
		variance += math.pow(gas - totalAveGasPerTxn, 2)
	
	variance = variance / numTxns
	stDevGas = math.sqrt(variance)

	totalAveValPerTxn = float(sum(totalValues)) / len(totalValues)
	valVariance = 0
	
	for value in totalValues:
		valVariance += math.pow(value - totalAveValPerTxn, 2)
	
	valVariance = valVariance / numTxns
	stDevValue = math.sqrt(valVariance)


	print "Average gas used per txn on contract: " + str(totalAveGasPerTxn)
	print "StDev gas used per txn on contract: " + str(stDevGas)
	print "Average value per txn on contract: " + str(totalAveValPerTxn)
	print "StDev gas used per txn on contract: " + str(stDevValue)
	print "Unique addresses: " + str(len(uniqueAddresses))
	print "total NumTxns: " + str(numTxns)


	#For each user, get the number stDevs away each gas usage is from the global mean, and number of devs for average usage
	naughtyBoys = []
	for address in addressStats:
		addressStats[address]["totalGas"] = sum(addressStats[address]["gasUsed"])
		addressStats[address]["aveGasPerTxn"] = addressStats[address]["totalGas"] / addressStats[address]["numTxns"]
		addressStats[address]["numDevsGasPerTxn"] = [(i - totalAveGasPerTxn) / stDevGas for i in addressStats[address]["gasUsed"]]
		if any(t > 2.0 for t in addressStats[address]["numDevsGasPerTxn"]):
			naughtyBoys.append(address)
			addressStats[address]["NAUGHTYBOY"] = "NAUGHTYBOY"
		addressStats[address]["averageNumDevsGasPerTxn"] = (addressStats[address]["aveGasPerTxn"] - totalAveGasPerTxn) / stDevGas

	print "NAUGHTY BOYS: " + str(len(naughtyBoys))

	

	# Compute histograms of average gas/value per txn per user

	numBuckets = 100.

	gasHistogram = [[] for i in range(0,100)]
	bucketSize = max(totalGas) / numBuckets

	valHistogram = [[] for i in range(0,100)]
	valBucketSize = max(totalValues) / numBuckets

	
	print "===========USERS BAD TXNS=========="
	for address in addressStats:
		
		avgUserGas = int(addressStats[address]["totalGas"] / float(addressStats[address]["numTxns"]))
		bucket = 0
		val = avgUserGas
		while (val >= bucketSize):
			val -= bucketSize
			val = val
			bucket += 1
		if bucket == numBuckets:
			bucket -= 1
		gasHistogram[bucket].append(address)


		avgUserVal = int(addressStats[address]["value"] / float(addressStats[address]["numTxns"]))
		bucket = 0
		val = avgUserVal
		while (val >= valBucketSize):
			val -= valBucketSize
			val = val
			bucket += 1
		if bucket == numBuckets:
			bucket -= 1
		valHistogram[bucket].append(address)

	
		#While we're at it, print erroneous txns
		if (addressStats[address]["errors"] > 0):
			print address
			print "Number tnxs: " + str(addressStats[address]["numTxns"])
			print "Num errors: " + str(addressStats[address]["errors"])
			print "averageNumDevsGasPerTxn: " + str(addressStats[address]["averageNumDevsGasPerTxn"])
			print "aveGasPerTxn: " + str(addressStats[address]["aveGasPerTxn"])
			print "Erroneous txns: " + str(addressStats[address]["badTxns"])
			print "==================================================================="

	print "===========END USERS WITH BAD TXNS=========="

	#######Print Histograms of average gas/value per user
	print "\n\n\n"
	print "=====GAS HISTOGRAM====="
	print [len(j) for j in gasHistogram]
	print "======================="
	print "~~~~VALUE HISTOGRAM~~~~"
	print [len(j) for j in valHistogram]
	print "======================="

	####plot gas histogram
	mu, sigma = totalAveGasPerTxn, stDevGas
	aveGasPerUserList = [addressStats[address]["aveGasPerTxn"] for address in addressStats]
	x = np.array(aveGasPerUserList)

	# the histogram of the data
	n, bins, patches = plt.hist(x, 25, facecolor='green', alpha=0.75)

	plt.ylabel('Number of users')
	plt.xlabel('Amount of gas spent (max allowed = ' + str(allowedGas) + ')')
	plt.title("Rouleth4.8: histogram of average gas per user per transaction")
	plt.axis([min(aveGasPerUserList), max(aveGasPerUserList), 0, 10])
	plt.grid(True)

	plt.show()

	####plot value histograms
	# mu2, sigma2 = totalAveGasPerTxn, stDevValue
	# aveValuePerUserList = [int(addressStats[address]["value"] / (10000000*addressStats[address]["numTxns"])) for address in addressStats]
	# x = np.array(aveValuePerUserList)

	# # the histogram of the data
	# n, bins, patches = plt.hist(x, 50, facecolor='green', alpha=0.75)

	# plt.xlabel('Average value per transaction (in 10^7 wei)')
	# plt.ylabel('Number of users')
	# plt.title("Rouleth4.8: histogram of average value per user per transaction")
	# plt.axis([0, max(aveValuePerUserList), 0, 30])
	# plt.grid(True)

	# plt.show()

files = ["./txndata/EthereumLottery.json", "./txndata/Etheroll.json", "./txndata/HonestDice.json", "./txndata/Rouleth3.5.json", "./txndata/Rouleth4.8.json"]

with open(files[4], 'r') as myfile:
	data=myfile.read()

txnJSON2Dict(data)

