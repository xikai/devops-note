* https://zhuanlan.zhihu.com/p/371886710

* Kafka 中 Topic 被分成多个 Partition 分区，分布到集群节点上，提供水平扩展能力。
* Topic 是一个逻辑概念，Partition 是最小的存储单元，掌握着一个 Topic 的部分数据。每个 Partition 都是一个单独的 log 文件，每条记录都以追加的形式写入
* 当一条记录写入 Partition 的时候，它就被追加到 log 文件的末尾，并被分配一个序号，作为 Offset
* 一个 Topic 如果有多个 Partition 的话，那么从 Topic 这个层面来看，消息是无序的。但单独看 Partition 的话，Partition 内部消息是有序的。如果强制要求 Topic 整体有序，就只能让 Topic 只有一个 Partition