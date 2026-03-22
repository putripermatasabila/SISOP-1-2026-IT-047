#!/bin/bash

awk 'BEGIN {FS=","} /node_001|node_003/ {total_lat+=$3;total_long+=$4} 
END {print "Koordinat pusat:";
print total_long/2","total_lat/2}' titik-penting.txt | tee posisipusaka.txt
