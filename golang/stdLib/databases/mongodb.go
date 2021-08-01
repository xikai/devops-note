package main

import (
	"context"
	"fmt"
	"log"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var client *mongo.Client

type Student struct {
	Name string
	Age  int
}

//初始化连接
func initMongo() (err error) {
	// 建立mongodb连接
	clientOptions := options.Client().ApplyURI("mongodb://root:gotestdb@localhost:27017")
	client, err = mongo.Connect(context.TODO(), clientOptions)
	if err != nil {
		return err
	}
	// 检查连接
	err = client.Ping(context.TODO(), nil)
	if err != nil {
		return err
	}
	return nil
}

func main() {
	// 初始化连接
	err := initMongo()
	if err != nil {
		fmt.Printf("init mongo failed,err:%v\n", err)
		return
	}

	// 指定获取要操作的数据集
	collection := client.Database("test").Collection("student")

	// 插入文档
	s1 := Student{"小红", 12}
	s2 := Student{"小兰", 10}
	s3 := Student{"小黄", 11}
	// collection.InsertOne()方法插入一条文档记录
	insertResult, err := collection.InsertOne(context.TODO(), s1)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Inserted a single document: ", insertResult.InsertedID)
	// collection.InsertMany()方法插入多条文档记录
	students := []interface{}{s2, s3}
	insertManyResult, err := collection.InsertMany(context.TODO(), students)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Inserted multiple documents: ", insertManyResult.InsertedIDs)

	// 更新文档
	filter := bson.D{{"name", "小兰"}}
	update := bson.D{
		{"$inc", bson.D{
			{"age", 1},
		}},
	}

	updateResult, err := collection.UpdateOne(context.TODO(), filter, update)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Matched %v documents and updated %v documents.\n", updateResult.MatchedCount, updateResult.ModifiedCount)

	// 查询单个文档
	var result Student // 创建一个Student变量用来接收查询的结果
	err = collection.FindOne(context.TODO(), filter).Decode(&result)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Found a single document: %+v\n", result)

	// 查询多个文档
	// 将选项传递给Find()
	findOptions := options.Find()
	findOptions.SetLimit(2)
	// 定义一个切片用来存储查询结果
	var results []*Student
	// 把bson.D{{}}作为一个filter来匹配所有文档
	cur, err := collection.Find(context.TODO(), bson.D{{}}, findOptions)
	if err != nil {
		log.Fatal(err)
	}
	// 查找多个文档返回一个光标
	// 遍历游标允许我们一次解码一个文档
	for cur.Next(context.TODO()) {
		// 创建一个值，将单个文档解码为该值
		var elem Student
		err := cur.Decode(&elem)
		if err != nil {
			log.Fatal(err)
		}
		results = append(results, &elem)
	}
	if err := cur.Err(); err != nil {
		log.Fatal(err)
	}
	// 完成后关闭游标
	cur.Close(context.TODO())
	fmt.Printf("Found multiple documents (array of pointers): %#v\n", results)

	//删除文档
	// 删除名字是小黄的那个
	deleteResult1, err := collection.DeleteOne(context.TODO(), bson.D{{"name", "小黄"}})
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Deleted %v documents in the trainers collection\n", deleteResult1.DeletedCount)
	// 删除所有
	deleteResult2, err := collection.DeleteMany(context.TODO(), bson.D{{}})
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Deleted %v documents in the trainers collection\n", deleteResult2.DeletedCount)
}
