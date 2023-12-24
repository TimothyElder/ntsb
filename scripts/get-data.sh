#!/bin/bash

cd data

# Download the file
curl -o avall.zip "https://data.ntsb.gov/avdata/FileDirectory/DownloadFile?fileID=C%3A%5Cavdata%5Cavall.zip"

unzip avall.zip