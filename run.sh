mkdir books1 # 100MB
mkdir books2 # 1GB
mkdir books3 # 5GB
mkdir books4 # 10GB

chmod +x download.sh
chmod +x mapper.sh
chmod +x reducer.sh
chmod +x sequential.sh

cd books1
../downloads.sh
cd ..

for i in {1..10}
do
    cp --backup=numbered ./books1/* ./books2
done

for i in {1..5}
do
    cp --backup=numbered ./books2/* ./books3
done

for i in {1..2}
do
    cp --backup=numbered ./books3/* ./books4
done

for i in {1..4}
do
    cd books$i
    hdfs dfs -mkdir books-input$i
    hdfs dfs -put *.txt* books-input$i
        for iteration in {1..3}
        do
            (time python3 ../sequential.py >> ../result$i.txt) &> ../measurements.txt
            rm ../result$i.txt
        done
    cd ..
    for iteration in {1..3}
        do
            (time hadoop jar /usr/lib/hadoop/hadoop-streaming.jar -files mapper.py,reducer.py -mapper mapper.py -reducer reducer.py -input books-input$i -output books-output$i) &> ../measurements.txt
            rm -r books-output$i
        done
done
