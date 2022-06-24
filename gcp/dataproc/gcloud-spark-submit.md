* 查看dataproc jobs
```
/opt/google-cloud-sdk/bin/gcloud dataproc jobs list --project vevor-sz-test --region us-west1
```

* 认证dataproc service-account服务帐户
```
/opt/google-cloud-sdk/bin/gcloud auth activate-service-account dataproc@vevor-sz-test.iam.gserviceaccount.com --key-file=/opt/sa-dataproc.json
```

* 提交示例job
```
/opt/google-cloud-sdk/bin/gcloud dataproc jobs submit spark --cluster dataproc-test \
    --project vevor-sz-test \
    --region=us-west1 \
    --class org.apache.spark.examples.SparkPi \
    --jars file:///usr/lib/spark/examples/jars/spark-examples.jar -- 1000
```

* ssh to dataproc master 
```
spark-submit --class org.apache.spark.examples.SparkPi \
    --master yarn \
    --deploy-mode cluster \
    examples/jars/spark-examples_2.12-3.1.3.jar \
    10 
```