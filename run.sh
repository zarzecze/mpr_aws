mkdir books1
mkdir books2
mkdir books3
mkdir books4
chmod +x download.sh

cd books1
../downloads.sh
cd ..

for i in {1..10}
do
cp --backup=numbered ./books1/* ./books2
done

for i in {1..20}
do
cp --backup=numbered ./books1/* ./books3
done

for i in {1..30}
do
cp --backup=numbered ./books1/* ./books4
done

for i in {1..4}
do
cd books$i
hdfs dfs -mkdir books-input$i
hdfs dfs -put *.txt* books-input$i

time hadoop jar /usr/lib/hadoop/hadoop-streaming.jar -files mapper.py,reducer.py -mapper mapper.py -reducer reducer.py -input books-input$i -output books-output$i
time python3 ../sequential.py >> result.txt

cd ..
done
