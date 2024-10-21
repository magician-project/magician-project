# Framework Proposal

## Software infrastructure overview

As proposed by prof. Luigi Palopoli in the integration meeting (October the 15th, 2024) in Heraklion, Crete, the software infrastructure will mainly encompass 3 components, as highlighted in the following diagram.

```{mermaid}
graph TD
    ROS1[ROS2] --> XBOT[XBot2] 
    RT1[RT application] -->XBOT
    XBOT --> LNX1[Linux + Xenomai]

    RT2[RT application]
    ROS2[ROS2]
    LNX2[Linux + RT patch]
    RT2 --> LNX2
    ROS2 --> LNX2


    ROS3[ROS2]
    DB[Database]
    APP[Non-RT applications]

    ROS3 --> DB
    DB <--> APP
    %% LNX3 --> APP
    %% ROS2 <--> ROS1
    %% ROS2 --> ROS3

    subgraph "Non-RT Applications"
        ROS3
        DB
        APP
        %% LNX3
    end

    subgraph "RT Applications"
        ROS2
        RT2
        LNX2
    end
    
    subgraph "Robot Control"
        ROS1 
        XBOT
        RT1
        LNX1
    end
```

The low-level control of the robot will be based on the RT framework developed by IIT, [XBot2](https://advrhumanoids.github.io/xbot2/master/index.html).
To work, we will need surely a real-time patched Linux kernel, and maybe the [Xenomai](https://xenomai.org/) co-kernel for hard RT applications.

Other soft-RT applications can (potentially) live in another machine. 
In this category falls all motion and task-planning algorithms, as well as all the estimation methods.

We might also provide non-RT application for data monitoring, review, and post-processing. 
For this reason, a database will be needed to store all the data.

All these components will communicate through the [ROS2 Humble](https://index.ros.org/doc/ros2/) middleware.


## Intra-component communication

To properly separate all different services, we will heavily rely on the ROS2 middleware.
For this reason, the best way to establish a communication protocol is by means of **custom topic** and **service messages**.

To this extent, it has been created the repository [`magician_msgs`](https://github.com/magician-project/magician_msgs).
There, everyone can specify the expected input and output of each service/topic.
For a simple tutorial on how to create custom `msg` and `srv` files, please refer to [the official tutorial](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Custom-ROS2-Interfaces.html) on the ROS2 documentation.

The documentation of these messages/services is provided in the [`magician_msgs`](https://github.com/magician-project/magician_msgs) repository, under the `docs` folder.
The documentation is also be available as an [online website here](https://magician-project.github.io/magician_msgs/).
