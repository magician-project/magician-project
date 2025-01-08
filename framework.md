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

By looking at the problem from a broader perspective, we can identify 5 main components that serve different purposes:

1. `EstimationAlgorithm`: deals with all the sensing and the perception of the system when inspecting the car body;
1. `MotionPlanning`: responsible for the planning of the robot behavior, from the task level all the way down to position control;
1. `LowLevelController`: the interface with the hardware that ensures the correct execution of the planned motion, and deals with the safety of the human-robot interaction and the interaction with the environment;
1. `HumanSensing`: the module dealing with the human presence in the cell, comprising its sensing and motion prediction;
1. `TaskManager`: the orchestrator of the whole system, that ensures the correct interaction between the above listed components.

These components are not strictly bound to a ROS2 node implementation, but rather to a logical separation of the functionalities that are required to accomplish the tasks of the robotic station.

These entities shall not be responsible to carry out the intended action by themselves, but rather orchestrate the algorithmic execution of the functionalities by using ROS2 lifecycle nodes.

From a high level perspective, this is the main interaction between the components:

```{plantuml}
:width: 700px
@startuml
CameraSystem .up.> [EstimationAlgorithm]: processed results
TactileSystem .up.> [EstimationAlgorithm]: processed results
LocalisationSystem .up.> [EstimationAlgorithm]: processed results
WeldingSystem .up.> [EstimationAlgorithm]: processed results

[EstimationAlgorithm] .up.> [MotionPlanner]: defect map
[EstimationAlgorithm] -up-> [TaskManager]
[MotionPlanner] -down-> [TaskManager]
[TaskManager] ..> [EstimationAlgorithm]: set sensor to use
[TaskManager] ..> [MotionPlanner]: set operating mode
[LowLevelController] <-- [MotionPlanner]
[HumanSensing] ..> [MotionPlanner]: human presence

}
@enduml
```

### Task Manager

It orchestrates the overall behavior of the cell, and serves as entry-point for the main application (by hosting a finite state machine or behavior trees).
It shall also fill the gap between the **ROS2 domain** and the **external world** (e.g. GUIs for the user that might specify some parameters, or the existing automated line).

### Motion Planner
The planner module is responsible to load, configure, and activate the different types of planning algorithm and modes; as of writing, we envision:

- **ergodic control** for the robot to explore the car body (in the sensing stage);
- solvers for **orienteering problems** to solve the task planning problem (to optimise order of defect to be reworked);
- **DMP** motion to plan point-to-point motion, as well as the rework trajectories.

### Low level Controller
The low level controller is responsible to prepare different types of control strategies (impedance, admittance, position, etc...) and to execute them on the robot hardware/simulator through the XBot2 framework.
The higher level inputs (e.g. desired position, velocity, acceleration) are provided by the motion planner.

### Estimation Algorithm
This module embeds (and orchestrate) different functionalities:

- `TactileSystem`: have a **tactile system** that can sense the car body and provide data on the defects using haptic feedback;
- `VisionSystem`: have a **vision system** that can sense the car body and provide data on the defects using image processing;
- `LocalisationSystem`: have a **localisation system** that can provide the positioning of different components (such as the robot, or the car body) w.r.t. a common reference frame;
- `WeldingSystem`: component that interfaces with the production floor, retrieve the status of the weld status, and provide some *conversions* for critical areas provided by the welder.
- provides **algorithms** that put together all these data in a coherent way that can be used by the motion planner.

### Human sensing
This module takes data of the environment and is responsible to produce data describing the human involvement with the robotic cell.
This is the only module that can directly communicate with the low-level control for triggering reactive strategies for human collision avoidance.

## Ownership diagram

At runtime, we expect that all aforementioned subcomponents (except `TaskManager`) will be [managed ROS2 nodes](http://design.ros2.org/articles/node_lifecycle.html).
According to such standard, each node internally have a finite state machine of 5 states: `unloaded`, `unconfigured`, `inactive`, `active`, `finalized`.
The following diagram, extracted from the ROS2 design documentation, shows the lifecycle of a node:

![](http://design.ros2.org/img/node_lifecycle/life_cycle_sm.png)

The following diagram shows the ownership/responsibility diagram of the different software components of the system.
For example, `A -> B` means that `A` is responsible to make sure that `B` is functioning as expected, and otherwise deal with the problem.

```{plantuml}
:width: 700px
@startuml
[UserInterface] <-down- [TaskManager]
[TaskManager] --> [EstimationAlgorithm]
[TaskManager] --> [LowLevelController]
[TaskManager] --> [MotionPlanning]
[TaskManager] --> [HumanSensing]

[EstimationAlgorithm] --> [VisionSystem]
[EstimationAlgorithm] --> [TactileSystem]
[EstimationAlgorithm] --> [LocalisationSystem]
[EstimationAlgorithm] --> [WeldingSystem]
@enduml
```
In practice, according to the ROS2 lifecycle node protocol, the following is a sample interaction between the `TaskManager` and the `EstimationAlgorithm` to activate the sensing system (and the required subsystems):

```{plantuml}
:width: 700px
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
:width: 700px
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

  interface WelderNode {
    .. input ..
    .. out topics ..
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
:width: 700px
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
