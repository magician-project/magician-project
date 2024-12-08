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


## Components Functional Design

In this section we provide a description of the proposed software architecture that we plan on using. 

<!-- 
```{mermaid}
mindmap
    root((Task Manager))
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
``` -->

### Components interaction
There are totally five *minimal* components that can accomplish the defect detection and removal task, that is: Task manager, motion planner, low-lvel controller, estimation algorithm, and human sensing algorithm. 

A common aspect shared by all **managers** (Task manager and estimation algorithm in this case) is that they don't perform the intended action by themselves, but rather orchestrate the algorithmic execution by using ROS2 lifecycle nodes. 
I.e., they are responsible to activate/deactivate different submodules, based on the status of the robotic cell. 

```{plantuml}
:width: 800px
@startuml
CameraSystem .up.> [EstimationAlgorithm]: processed results
TactileSystem .up.> [EstimationAlgorithm]: processed results
LocalisationSystem .up.> [EstimationAlgorithm]: processed results

[EstimationAlgorithm] ..> [MotionPlanner]: defect map
[EstimationAlgorithm] -> [TaskManager]
[MotionPlanner] -> [TaskManager]
[TaskManager] ..> [EstimationAlgorithm]: set sensor to use
[TaskManager] ..> [MotionPlanner]: set operating mode

}
@enduml
```

### Task Manager

It orchestrates the overall behavior of the cell.
It shall fill the gap between the ROS2 domain and the _external world_ (e.g. GUIs for the user that might specify some parameters, or the existing automated line). 

Here we provide the minimal interface connection with other compenents.
<!-- the XBot2 platform that provides the low-level control of the robot. -->

### Motion Planner
The planner module is responsible to load, configure, and activate the different types of planning algorithm, like:

- ergodic control;
- orienteering problem;
- DMP motion execution;
- etc...

### Low level Controller
The low level cotnroller is responsible to load, configure, and activate all the different types of controller, like:

- Impedance control;
- Admittance control;
- Position control;
- etc...

### Estimation Algorithm
The estimation module must **manage** the defect sensing systems, and shall provide algorithms that put together such data in a data format that can be used by motion algorithm.

### Human sensing
This module takes data of the environment and is responsible to produce data describing the human involvement with the robotic cell.
This is the only module that can directly communicate with the low-level control for triggering reactive strategies for human collision avoidance.

## Ownership diagram

The following describes the ownership hierarchy of the different components.
For example, `A -> B` it means that `A` is responsible to make sure that `B` is functioning as expected, and otherwise deal with the problem.

```{plantuml}
:width: 800px
@startuml
[UserInterface] <-down- [TaskManager]
[TaskManager] --> [EstimationAlgorithm]
[TaskManager] --> [LowLevelController]
[TaskManager] --> [MotionPlanning]
[TaskManager] --> [HumanSensing]

[EstimationAlgorithm] --> [VisionSystem]
[EstimationAlgorithm] --> [TactileSystem]
[EstimationAlgorithm] --> [LocalisationSystem]
@enduml
```


In particular, this is an overview on the hierarchy management. 
The `TaskManager` is responsible to configure and activate (based on the [ROS2 lifecycle node protocol](https://design.ros2.org/articles/node_lifecycle.html)) the `EstimationAlgorithm` that, in turn, to be configured/activated, must ensure that the subsystems are working.
```{plantuml}
:width: 800px
@startuml

actor TaskManager
participant EstimationAlgorithm
entity CameraSystem
entity TactileSystem
entity LocalisationSystem

TaskManager -> EstimationAlgorithm: on_configure()
EstimationAlgorithm ->  CameraSystem: on_configure()
EstimationAlgorithm <-- CameraSystem
EstimationAlgorithm ->  TactileSystem: on_configure()
EstimationAlgorithm <-- TactileSystem
EstimationAlgorithm ->  LocalisationSystem: on_configure()
EstimationAlgorithm <-- LocalisationSystem
TaskManager <-- EstimationAlgorithm

TaskManager -> EstimationAlgorithm: on_activate()
EstimationAlgorithm ->  CameraSystem: on_activate()
EstimationAlgorithm <-- CameraSystem
EstimationAlgorithm ->  TactileSystem: on_activate()
EstimationAlgorithm <-- TactileSystem
EstimationAlgorithm ->  LocalisationSystem: on_activate()
EstimationAlgorithm <-- LocalisationSystem

TaskManager <-- EstimationAlgorithm
@enduml
```


## Nodes interfaces

Each ROS2 Node interface exposes:

- the minimal set of **inputs** that are required by the given node to work (red squares);
- the minimal set of **output topics** that the node must export (green circles);
- the minimal set of **services** that the node must serve as server (blue triangles).

These are the interfaces associated to the sensing systems, the car surface estimator, and the human sensing:
```{plantuml}
:width: 800px
@startuml
package Sensing {
  interface CameraNode {
    - {abstract}  camera stream
    .. out topics ..
    + /camera/result: camera/Result.msg
    .. services ..
    ~ camera/set_rate: TBD
  }
  
  interface TactileNode {
    - {abstract}  tactile data stream
    .. out topics ..
    + /tactile/result: TBD
  }
  
  interface LocalisationNode {
    - {abstract}  object to track
    - {abstract}  data source
    .. out topics ..
    + /<obj>/position: geometry_msgs/PoseStamped.msg
  }
  
  interface EstimationAlgorithm {
    .. in topics ..
    - /camera/result
    - /tactile/result
    - /robot/position
    - /car/position
    .. out topics ..
    + /estimator/state
    .. services ..
    ~ /estimator/get_defects: estimator/GetDefects.srv
  }
  
  interface HumanSensing {
    .. out topics ..
    + /humans/humans_state: TBD
    .. service ..
    ~ /humans/safety_stop: std_msgs/Trigger.msg
  }

}
@enduml
```

These are the interfaces for the algorithms that are required to plan the motion of the robot:
```{plantuml}
:width: 800px
@startuml
package Planning {
  interface MotionPlanner {
    .. in topics ..
    - /robot/state: robot/RobotState.msg
    .. out topics ..
    + /robot/running_planner: std_msgs/String.msg
    .. services ..
    ~ /robot/set_operating_mode: robot/RobotMode.srv
  }

  interface TravelTimeEstimatorNode {
    .. services ..
    ~ /robot/time_estimator/<algorithm>: task_planning/TimeEstimate.srv
  }
  
  interface OrienteeringSolverNode {
    .. required services ..
    - /robot/time_estimator/<algorithm>: task_planning/TimeEstimate.srv
    .. services ..
    ~ /robot/orienteering/<algorithm>: task_planning/Orienteering.srv
  }
  
}
@enduml
```

```{startuml}
@startuml
interface LowLevelController {
  .. in topics ..
  - /robot/desired_position: geometry_msgs/PoseStamped.msg
  - /robot/desired_velocity: geometry_msgs/TwistStamped.msg
  - /robot/desired_acceleration: geometry_msgs/TwistStamped.msg
}
@enduml
```




### Intra-component communication / API Definition

To properly separate all different services, we will heavily rely on the ROS2 middleware.
For this reason, the best way to establish a communication protocol is by means of **custom topic** and **service messages**.


#### Topics
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


#### Services

- `/car/get_defects` (type `srv/GetDefects.srv`): retrieves the currently sensed defects;
- `/robot/set_planning_algorithm` (type **`TBD`**);
- `/robot/task_planning/orienteering` (type `srv/task_planning/Orienteering.srv`): solves the deterministic orienteering problem;
- `/robot/task_planning/ptp_time_estimator` (type `srv/task_planning/PtpTimeEstimator.srv`): builds an estimate of the time required to carry out a point-to-point motion;
- `/robot/homing` (type `std_msgs/Trigger.msg`);
- `/robot/stop` (type `std_msgs/Trigger.msg`);
- `/robot/safety_stop` (type `std_msgs/Trigger.msg`);

#### magician_msgs
To this extent, it has been created the repository [`magician_msgs`](https://github.com/magician-project/magician_msgs).
There, everyone can specify the expected input and output of each service/topic.
For a simple tutorial on how to create custom `msg` and `srv` files, please refer to [the official tutorial](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Custom-ROS2-Interfaces.html) on the ROS2 documentation.

The documentation of these messages/services is provided in the [`magician_msgs`](https://github.com/magician-project/magician_msgs) repository, under the `docs` folder.
The documentation is also be available as an [online website here](https://magician-project.github.io/magician_msgs/).