---
title: "基于树莓派的边缘计算终端"
description: 项目
date: 2023-10-27T03:11:06Z
image: golangxflinkxraspi.png
math: 
license: 
hidden: false
comments: true
categories:
    - IOT
---
## 背景

边缘计算终端为一块搭载微雪电子RS485 CAN HAT (B) 扩展板的树莓派4B型（Raspberry Pi 4 Model B），CPU架构为ARMv7，采用开源项目frp反向代理实现远程访问。树莓派具有低功耗、低成本、易于编程等优点，广泛应用于物联网、嵌入式系统、教育等领域，符合本次项目的需求。数据中继站作为传感器数据上云的桥梁，负责数据收集、分组、预处理、转发，并通过下发反向控制指令实现对终端设备的控制，实现云侧操作到端侧操作的转换。

## frp反向代理

由于校内网络下设备之间不能互通，在之前要连接上树莓派只能在实验室使用同一路由器下的网络，过于麻烦，借助一台有公网IP的云服务器作为反向代理，实现远程连接树莓派

https://github.com/fatedier/frp

![frp](/images/frp.png)
云服务器配置，记得开放端口

```ini
# frps.ini
# docker run --restart=always --network host -d -v /etc/frp/frps.ini:/etc/frp/frps.ini --name frps snowdreamtech/frps
[common]
bind_port = 7000
```

树莓派配置

```ini
# frpc.ini
[common]
server_addr = 124.223.97.5
server_port = 7000

[vnc]
type = tcp
local_ip = 127.0.0.1
local_port = 5900
remote_port = 5900

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 6000
```

## Golang数据收集

与传统C/C++实现不同，本项目采用Golang实现数据收集功能。相比于传统的C/C++，Golang代码简洁，格式统一，阅读方便；在保持较高性能的同时拥有较高的开发效率，支持内嵌C代码段；天生支持高并发的特性符合项目的需求。

该模块的工作流如下：

1. 数据收集模块中上流数据包括MQTT服务器下发的控制信息，RS485接口接收的Modbus格式的传感器数据，Zigbee无线传输的自定义协议格式的传感器数据。下流输出包括Kafka适配器，Flink套接字与标准输出用于调试。

2. 定义抽象接口Abstract Client，按照上流数据源的不同分为Zigbee Client，Modbus Client与MQTT Client，根据数据格式的不同来实现接口定义的方法，每个Client绑定一个协程（Goroutine），协程是Golang实现的轻量级用户态线程，不同协程间并发处理数据来加速数据的处理速度。

3. 主协程依赖于抽象接口，易于功能扩展，采用统一的数据处理流程，对上流数据进行协议解析，数据校验与错误处理。采用for-select循环监听处理子协程返回的错误信息，使用Zap高性能的日志记录包来实现日志记录，配置Prometheus客户端收集基本的运行时状态信息与指标。

![image-20231027105551271](/images/image-20231027105551271.png)

## Flink数据处理

本项目采用Flink实现对流数据的处理，Flink提供高吞吐量、低延迟的流数据引擎以及对事件时间处理和状态管理的支持满足项目的需求。该模块的工作流如下：

1. 解析套接字传递的流数据，对每条流数据绑定对应的时间戳，并使用无重叠的滚动事件时间窗口（Tumbling Event Time Windows）对流数据进行窗口分析。

​    2. 采用聚合函数（Aggregate Function）对窗口内的流数据进行平均值计算，采用继承抽象类窗口处理函数（Process Window Function）的自定义窗口检测函数（Detection Window Function）与窗口范围函数（Range Window Function）实现窗口内流数据的波动与异常检测。

​    3. 自定义MQTT Sink作为处理后流数据的下流接口，将数据实时投放至MQTT消息队列中，供后续云端消费。

 ![image-20231027105844502](/images/image-20231027105844502.png)

```java
//主要流程
public class SensorAnalysis {
    private static final long CALCULATE_TIME_WINDOW = 10L;
    private static final long DETECTION_TIME_WINDOW = 1L;


    public static void main(String[] args) throws Exception {
        // 注册默认的JVM指标
        DefaultExports.initialize();
        // 启动一个HTTP服务，用于导出指标
        
        MqttPublisher.getInstance().init();
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        //env.setMaxParallelism(4);
        env.setStreamTimeCharacteristic(TimeCharacteristic.EventTime);
        
        DataStreamSource<String> socketStream = env.socketTextStream("127.0.0.1", 8888);
        
        DataStream<SensorEvent> sensorEventStream = socketStream.map((socketText) -> {
            String[] fields = socketText.split("[:,\n]");
            return new SensorEvent(fields[0], Long.parseLong(fields[1]), Long.parseLong(fields[2]));
        });

        // create windowedStream for future calculate
        WindowedStream<SensorEvent, String, TimeWindow> windowedStream = sensorEventStream
                .assignTimestampsAndWatermarks(new MyWatermarkAssigner())
                .keyBy(SensorEvent::getSensorType)
                .window(TumblingEventTimeWindows.of(Time.seconds(CALCULATE_TIME_WINDOW)));

        //calculate the average value for each key
        DataStream<SensorMessage> averageStream = windowedStream
                .aggregate(new AverageAggregate());

        //calculate the range value for each key
        DataStream<SensorMessage> rangeStream = windowedStream
                .process(new RangeWindowFunction());

        //detection whether value offense limits
        DataStream<SensorMessage> detectionStream = windowedStream
                .process(new DetectionWindowFunction());

        averageStream.addSink(new MyMqttSink());
        rangeStream.addSink(new MyMqttSink());
        detectionStream.addSink(new MyMqttSink());

        env.execute("Socket Streaming");
    }
}
```

```java
//AverageAggregate具体实现
public class AverageAggregate implements AggregateFunction<SensorEvent, Tuple3<String, Long, Long>, SensorMessage> {

    @Override
    public Tuple3<String, Long, Long> createAccumulator() {
        return Tuple3.of("", 0L, 0L);
    }

    @Override
    public Tuple3<String, Long, Long> add(SensorEvent event, Tuple3<String, Long, Long> accumulator) {
        return Tuple3.of(event.getSensorType(), accumulator.f1 + event.getSensorValue(), accumulator.f2 + 1L);
    }

    @Override
    public Tuple3<String, Long, Long> merge(Tuple3<String, Long, Long> a, Tuple3<String, Long, Long> b) {
        return Tuple3.of(a.f0, a.f1 + b.f1, a.f2 + b.f2);
    }

    @Override
    public SensorMessage getResult(Tuple3<String, Long, Long> accumulator) {
        return new SensorMessage(accumulator.f0,Double.toString((double) accumulator.f1 / (double) accumulator.f2));
    }
}
```



