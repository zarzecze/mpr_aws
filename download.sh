#!/bin/bash
for i in {1300..1480}
do
wget "http://www.gutenberg.org/files/$i/$i.txt"
wget "http://www.gutenberg.org/files/$i/$i-0.txt"
done
