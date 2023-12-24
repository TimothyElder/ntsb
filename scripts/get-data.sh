#!/bin/bash

cd ../data

url="https://data.ntsb.gov/avdata/FileDirectory/DownloadFile?fileID=C%3A%5Cavdata%5Cavall.zip"

# Download the file
wget "$url"
unzip avall.zip