package main

import (
	"encoding/json"
	"fmt"
)

type selang struct {
	ID    int
	Name  string
	grils []string
}

type qinshou struct {
	Name string
	Love string
}

//data to json
func main1() {
	xikai := selang{
		ID:    0,
		Name:  "selangxikai",
		grils: []string{"grilA", "grilB", "grilC"},
	}
	b, err := json.Marshal(xikai)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(string(b))
}

//json解码
func main() {
	var jsonbytes = []byte(`[
		{"Name":"xikai","Love":"fengjie"},
		{"Name":"qqd","Love":"furongjiejie"}
	]`)

	var qs []qinshou
	err := json.Unmarshal(jsonbytes, &qs)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Printf("%+v", qs)
}
