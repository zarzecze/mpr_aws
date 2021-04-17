# $1 = cluster type
# $2 = cluster_size

mkdir books1 # 100MB
mkdir books2 # 500MB
mkdir books3 # 1GB

chmod +x download.sh
chmod +x mapper.sh
chmod +x reducer.sh
chmod +x sequential.sh

cd books1
../downloads.sh
cd ..

for i in {1..5}
do
    cp --backup=numbered ./books1/* ./books2
done

for i in {1..2}
do
    cp --backup=numbered ./books2/* ./books3
done

problem_sizes=("100MB" "500MB" "1GB")

for i in {1..3}
do
    cd books$i
    hdfs dfs -mkdir books-input$i
    hdfs dfs -put *.txt* books-input$i
        for iteration in {1..3}
        do
            echo -n "$1,$2,${problem_sizes[$i]}," >> ../measurements_seq.txt
            (time python3 ../sequential.py >> ../result$i.txt) 2>&1 >/dev/null | grep 'real' | awk '{ print $2 }' >> ../measurements.txt
            rm ../result$i.txt
        done
    cd ..
    for iteration in {1..3}
        do
            echo -n "$1,$2,${problem_sizes[$i]}," >> ../measurements.txt
            (time hadoop jar /usr/lib/hadoop/hadoop-streaming.jar -files mapper.py,reducer.py -mapper mapper.py -reducer reducer.py -input books-input$i -output books-output$i) 2>&1 >/dev/null | grep 'real' | awk '{ print $2 }' >> ../measurements.txt
            rm -r books-output$i
        done
done
