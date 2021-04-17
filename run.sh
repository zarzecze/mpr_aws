# $1 = cluster type
# $2 = cluster_size

rm -r books*
mkdir books0 # 100MB
mkdir books1 # 500MB
mkdir books2 # 1GB

chmod +x ./download.sh
chmod +x ./mapper.py
chmod +x ./reducer.py
chmod +x ./sequential.py

cd books0
../download.sh
cd ..

for i in {1..5}
do
    cp --backup=numbered ./books0/* ./books1
done

for i in {1..2}
do
    cp --backup=numbered ./books1/* ./books2
done

problem_sizes=("100MB" "500MB" "1GB")

for i in {0..2}
do
    cd books$i
    hdfs dfs -rm -r books-input$i
    hdfs dfs -mkdir books-input$i
    hdfs dfs -put *.txt* books-input$i
    
    for iteration in {1..3}
    do
        echo -n "$1,$2,${problem_sizes[$i]}," >> ../measurements_seq.txt
        (time python3 ../sequential.py >> ../result$i.txt) 2>&1 >/dev/null | grep 'real' | awk '{ print $2 }' >> ../measurements_seq.txt
        rm ../result$i.txt
    done

    cd ..

    for iteration in {1..3}
    do
        hdfs dfs -rm -r books-output$i
        echo -n "$1,$2,${problem_sizes[$i]}," >> ./measurements_par.txt
        (time hadoop jar /usr/lib/hadoop/hadoop-streaming.jar -files mapper.py,reducer.py -mapper mapper.py -reducer reducer.py -input books-input$i -output books-output$i) 2>&1 >./debug$i$iteration | grep 'real' | awk '{ print $2 }' >> ./measurements_par.txt
    done
done
