#!/bin/bash
for i in {1300..1302}
do
wget "http://www.gutenberg.org/files/$i/$i.txt"
wget "http://www.gutenberg.org/files/$i/$i-0.txt"
done
