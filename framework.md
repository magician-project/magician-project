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


# Components Functional Design and API specification

## Overview

By exploiting ROS2 functionalities, the final _MAGICIAN technological stack_ will consist of a **distributed network of ROS2 nodes that work interactively**. 
Still, we need to separate those node components in **packages** based on the node's semantic and functionality.
For this reason, we identify the following areas:

- `Estimation`: comprise all steps that, from the acquisition of the raw data, enable to retrieve a representation of the defect map of a single car.
- `TaskPlanning`: comprises all task-level planning nodes;
- `MotionPlanning`: comprises all motion-level planning utilities;
- `Controller`: comprises all low-level control utilities to interact with the robot;
- `HardwareInterface`: hardware abstraction layer;
- `Human`: deals with the acquisition of the human pose and the consequent motion forecasting;
- `ProcessAnalysis`, `ProcessOptimisation`, `ToolOptimisation`: contains, at different levels, all offline algorithms entitled to analyse the robot-provided data from the production floor in order to analyse and optimise the robot parameters, as well as to improve generalisation capabilities of the provided solution.

Within each package we expect that multiple nodes are running.
It also true that a single node implementation might span over multiple packages; an example is the XBot2 hardware interface that will most probably expose the `Controller` interfaces with a strict connection to the `HardwareInterface`.
From a high level perspective, this is the main interaction between the components:

```{plantuml}
:width: 700px
@startuml
[TaskPlanning] -down-> [MotionPlanning]: "Planning choice"
[MotionPlanning] -down-> [Controller]: "Setpoint"
[Controller] -down-> [HardwareInterface]
[Human] -left-> [MotionPlanning]: "Human motion forecast"
[Estimation] -left-> [TaskPlanning]: "Defect map"

[Human] ..> [Controller]: "Safe stop"

database "Database"
[TaskPlanning] ..> Database
[MotionPlanning] .left.> Database
[Controller] ..> Database

Database .left.> [ProcessAnalysis]
[ProcessAnalysis] -down-> [ProcessOptimisation]
[ProcessOptimisation] -down-> [ToolOptimisation]
[ToolOptimisation] -down-> "Set node parameters"


@enduml
```

## Packages

To properly achieve the functionalities of a _package_, multiple nodes are actually required.
Since the final architecture will consist of a distributed set of ROS2 nodes, we enforce in this document the **minimal set of requirements** that each node shall rely on to work, and the output that they will provide.

In the following you may find:
- _interfaces_ (letter `I` within a purple circle): represent an abstract interface with no actual implementation;
- _entities_ (letter `E` within a green circle): represent a concrete and unique implementation of a ROS2 node.

Within each component, there are multiple entries representing the implementation constraint; additionally to the provided sections, consider the following legend:
- red squares represent _inputs_ (both topics and services);
- green circles represent _outputs_ (topics);
- blue triangles represent _services_ that the node exports;

```{plantuml}
:width: 700px
@startuml
interface "Node Interface"
entity "Node Implementation" {
    - /input_topic: <message_type>
    + /output_topic: <message_type>
    ~ /service_server: <service_type>
}
@enduml
```

**Note:** _entities_ cam be regarded simply as ROS2 nodes that export the fixed input-output relationships, while _interfaces_ are used to express
- an _abstract component_ whose functionality is only envisioned to make the MAGICIAN technological stack functional, but there's not (yet) a proper well-thought implementation;
- the possibility of having different implementation to realise the same functionality.


### `Estimation` package

This package specifically deals with the sensing and the perception algorithms tight to the **car body analysis**, and not with the analysis of the human present (which is instead considered in the `Human` package).

```{plantuml}
:width: 700px
@startuml
package Estimation {

  interface Algorithm {
    .. in topics ..
    - /camera/result: camera/Result.msg
    - /tactile/result: tactile/Result.msg
    - /robot/position: geometry_msgs/PoseStamped.msg
    - /car/position: geometry_msgs/PoseStamped.msg
    .. out topics ..
    + /estimator/state: estimator/EstimationState.msg
    .. services ..
    ~ /estimator/get_defects: estimator/GetDefects.srv
  }

  entity CameraSensor {
    .. out topics ..
    + /camera/result: camera/Result.msg
  }

  entity TactileSensor {
    .. out topics ..
    + /tactile/result: tactile/Result.msg
  }

  interface Localiser {
    .. out topics ..
    + /<obj>/position: geometry_msgs/PoseStamped.msg
  }

}
@enduml
```
- `CameraSensor` and `TactileSensor` represent the nodes of the corresponding sensors; they collect the data, might perform internal pre-processing, and outputs the raw data in a ROS-friendly format;
- `Algorithm` is an interface component whose responsible to _glue together_ the various data coming from the camera/tactile sensor;
- `Localiser` is an interface for components that can provide the relative position of pieces within the robotic cell (e.g. to position the base-link frame of the robot w.r.t. the car body). 
  We envision multiple implementation of this interface (e.g. using motion capture system, or marker(less)-based vision system), depending on the availability of the testing facility (e.g. Trento might have a setup which is different from Genova, that is different from the one in TOFAS).

### `TaskPlanning` package

```{plantuml}
:width: 700px
@startuml
package TaskPlanning {

  entity StateMachine {
  }

  entity Orienteering {
    .. required services ..
    - /motion_planner/dmp/time_estimator: motion_planning/TimeEstimate.srv
    - /estimator/get_defects: estimator/GetDefects.srv
    .. services ..
    ~ /task_planner/orienteering: task_planning/Orienteering.srv
  }
  
}
@enduml
```

### `MotionPlanning` package

```{plantuml}
:width: 700px
@startuml
package MotionPlanning {

  entity Dmp {
    .. out topics ..
    + /controller/position: geometry_msgs/PoseStamped.msg
    .. services ..
    ~ /motion_planner/dmp/time_estimator: motion_planning/TimeEstimate.srv
    ~ /motion_planner/dmp/execute: motion_planning/Dmp.srv
  }

  entity ErgodicControl {
  }
  
}
@enduml
```

### `Controller` package

```{plantuml}
:width: 700px
@startuml
package Controller {

  interface CartesianController {
    .. in topics ..
    - /controller/position: geometry_msgs/PoseStamped.msg
    - /controller/velocity: geometry_msgs/TwistStamped.msg
  }

  entity ImpedanceController {
  }

  CartesianController --|> ImpedanceController 

}
@enduml
```

### `Human` package

```{plantuml}
:width: 700px
@startuml
package Human {

  interface SkeletonTracker {
    .. out topics ..
    + /human/tracked_humans: human/HumanSkeletons.msg
  }

  entity MotionForecaster {
    .. in topics ..
    - /human/tracked_humans: human/HumanSkeletons.msg
    .. out topics ..
    + /human/forecaster_motion: human/MotionForecasts.msg
  }

}
@enduml
```

## API Definition

The previous section outlined the interfaces that each node must implement to work in the system.
Here we expand on the details of the topics and services there reported.

Since our work will require the transfer of *non-standard* data types, we must rely on custom messages and services definitions.
To this extent, it has been created the repository [`magician_msgs`](https://github.com/magician-project/magician_msgs);
there, everyone can specify the expected input and output of each service/topic.
All messages shall be documented as reported in the [`README`](https://github.com/magician-project/magician_msgs/blob/main/README.md) of that repository; by doing so, one can refer to the [online documentation](https://magician-project.github.io/magician_msgs/) to have detailed information about the different types.

For a simple example on how to create custom `msg` and `srv` files, please refer to [the official tutorial](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Custom-ROS2-Interfaces.html) on the ROS2 documentation.

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


## Extra features

### Managed Nodes

At runtime, we expect that all aforementioned subcomponents (except `TaskManager`) will be [managed ROS2 nodes](http://design.ros2.org/articles/node_lifecycle.html).
According to such standard, each node internally have a finite state machine of 5 states: `unloaded`, `unconfigured`, `inactive`, `active`, `finalized`.
The following diagram, extracted from the ROS2 design documentation, shows the lifecycle of a node:

![](http://design.ros2.org/img/node_lifecycle/life_cycle_sm.png)
