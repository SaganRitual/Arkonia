#!/bin/sh
#! Note: we exclude the energy budget file from linting; see swiftlint.yml
if not exists ./EnergyBudget/Swift-Swift.csv; then
echo "Can't find energy budget input file ./EnergyBudget/Swift-Swift.csv"
exit -1
else
sed 's/[,"]//g' < ./EnergyBudget/Swift-Swift.csv > ./Arkon/Metabolism/EnergyBudget.swift
fi
