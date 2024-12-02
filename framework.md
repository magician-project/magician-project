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

## Functional Design

In this section we provide a more in depth description of the proposed software architecture that we plan on using.

```{mermaid}
mindmap
    root((Station Manager))
        ((Estimation))
            Vision system
            Tactile system
            Positioning system
        ((Human Sensing))
        ((Planner))
            Task planners
            Motion planners
            Low-level controler configuration
        Low-Level Controller xBot2
```

A common aspect shared by all *managers* is that they don't perform the intended action by themselves, but rather orchestrate the algorithmic execution by using ROS2 lifecycle nodes. 
I.e., they are responsible to activate/deactivate different submodules, based on the status of the robotic cell.


### Station Manager

It implements the finite state machine to orchestrate the overall behavior of the cell.
It shall fill the gap between the ROS2 domain and the _external world_ (e.g. GUIs for the user that might specify some parameters, or the existing automated line). 

Here we provide the minimal interface connection with the XBot2 platform that provides the low-level control of the robot.

### Planners
The planner module is responsible to load, configure, and activate the different types of planning algorithm, like:

- ergodic control;
- orienteering problem;
- DMP motion execution;
- etc...

### Estimation
The estimation module must manage the sensing systems, and shall provide algorithms that put together such data in a data format that can be used by motion algorithm.

### Human sensing
This module takes data of the environment and is responsible to produce data describing the human involvement with the robotic cell.
This is the only module that can directly communicate with the low-level control for triggering reactive strategies for human collision avoidance.


## API Definition

### Topics
- `/camera/result` (type: `msg/camera/Scan.msg`): provides the prediction on of the defects from a single image;
- `/tactile/result` (type **`TBD`**);
- `/car/current_estimation_state` (type `msg/CarEstimate.msg`): provides the current inspection state of the car body (e.g. the map of the found defects, area that has been covered, variance of the estimation...);
- `/car/position` (type: `geometry_msgs/PoseStamped.msg`): position of the car body w.r.t. a common reference frame;
- `/robot/state` (type: `msg/RobotState.msg`): provides the current working state of the robot (e.g. sensing, reworking, standstill...);
- `/robot/position` (type: `geometry_msgs/PoseStamped.msg`): position of the robot base w.r.t. a common reference frame;
- `/robot/pos_setpoint` (type: `geometry_msgs/Pose.msg`): currently desired end-effector position;
- `/robot/vel_setpoint` (type: `geometry_msgs/Twist.msg`): currently desired end-effector velocity;
- `/robot/acc_setpoint` (type: `geometry_msgs/Twist.msg`): currently desired end-effector acceleration;
- `/human/predicted_motion` (type **`TBD`**);


### Services

- `/car/get_defects` (type `srv/GetDefects.srv`): retrieves the currently sensed defects;
- `/robot/set_planning_algorithm` (type **`TBD`**);
- `/robot/task_planning/orienteering` (type `srv/task_planning/Orienteering.srv`): solves the deterministic orienteering problem;
- `/robot/task_planning/ptp_time_estimator` (type `srv/task_planning/PtpTimeEstimator.srv`): builds an estimate of the time required to carry out a point-to-point motion;
- `/robot/homing` (type `std_msgs/Trigger.msg`);
- `/robot/stop` (type `std_msgs/Trigger.msg`);
- `/robot/safety_stop` (type `std_msgs/Trigger.msg`);


```{plantuml}
@startuml
Class01 <|-- Class02
Class03 --* Class04
@enduml
```

