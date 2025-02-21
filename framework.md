# Framework Proposal

## Software infrastructure overview

As proposed by prof. Luigi Palopoli in the integration meeting (October the 15th, 2024) in Heraklion, Crete, the software infrastructure will mainly encompass 3 components, as highlighted in the following diagram.

```{plantuml}
:width: 700px
@startuml
package "Robot Control" {
  [ROS2] -down-> [XBot2]
  [RT Application] -down-> [XBot2]
  [XBot2] -down-> [Linux + Xenomai]
}

package "RT Applications" {
  [RT Application ] -down-> [Linux + RT Patch]
  [ROS2 ] -down-> [Linux + RT Patch]
}

package "Non-RT Applications" {
  database "Database"
  [ ROS2] -down-> Database
  Database <-down-> [Non-RT Application]
}
@enduml
```

The low-level control of the robot will be based on the RT framework developed by IIT, [XBot2](https://advrhumanoids.github.io/xbot2/master/index.html).
To work, we will need surely a real-time patched Linux kernel, and maybe the [Xenomai](https://xenomai.org/) co-kernel for hard RT applications.

Other soft-RT applications can (potentially) live in another machine.
In this category falls all motion and task-planning algorithms, as well as all the estimation methods.

We might also provide non-RT application for data monitoring, review, and post-processing.
For this reason, a database will be needed to store all the data.

All these components will communicate through the [ROS2 Humble](https://index.ros.org/doc/ros2/) middleware.


# Components Functional Design and API specification

## Preliminary definitions

- ***Component***: an _entity_ that provide some specific functionalities; strictly connected to the implementation as a ROS2 node.
- ***Module***: a group of _components_ that provide an higher level functionality.
- ***Package***: intented as a _ROS2 package_, i.e. a software repositories containing source code for 1 or multiple _components_.



## Modules

By exploiting ROS2 functionalities, the final _MAGICIAN technological stack_ will consist of a **distributed network of ROS2 nodes that work interactively**. 
Still, to reason at a higher level, we separate different node components in **modules** based on the node's semantic and functionality.
For this reason, we identify the following areas:

- `Estimation`: comprise all steps that, from the acquisition of the raw data, enable to retrieve a representation of the defect map of a single car.
- `TaskPlanning`: comprises all task-level planning nodes;
- `MotionPlanning`: comprises all motion-level planning utilities;
- `Controller`: comprises all low-level control utilities to interact with the robot;
- `HardwareInterface`: hardware abstraction layer;
- `HumanEstimation`: deals with the acquisition of the human pose and the consequent motion forecasting;
- `OfflineOptimisation`: contains all offline algorithms entitled to analyse the robot-provided data from the production floor in order to analyse and optimise the robot parameters, as well as to improve generalisation capabilities of the provided solution.

Within each module, we expect multiple nodes (components) to exists and run.
It also true that a single component might implement features of multiple modules; an example is XBot2, that will most probably expose the `Controller` interfaces with a tight connection to the `HardwareInterface`.

From a high level perspective, this is the main interaction between the modules:

```{plantuml}
:width: 700px
@startuml
[TaskPlanning] -down-> [MotionPlanning]: "Planning choice"
[MotionPlanning] -down-> [Controller]: "Setpoint"
[Controller] -down-> [HardwareInterface]
[HumanEstimation] -left-> [MotionPlanning]: "Human motion forecast"
[Estimation] -left-> [TaskPlanning]: "Defect map"

[HumanEstimation] ..> [Controller]: "Safe stop"

database "Database"
[TaskPlanning] ..> Database
[MotionPlanning] .left.> Database
[Controller] ..> Database

Database .left.> [OfflineOptimisation]
[OfflineOptimisation] -down-> "Set node parameters"


@enduml
```

**Note:** To ease development, we don't enforce all components of a module to be implemented within the same package.
Rather, each partner is welcome to create, maintain, and document its own package, and specify there each executable node which interfaces it specifically implements.

## Components

To properly achieve the functionalities of a _module_, multiple components are required.
Since the final architecture will consist of a distributed set of ROS2 nodes, we enforce in this document the **minimal set of requirements** that each component shall rely on to work, and the output that they must provide to other nodes.

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


### `Estimation` module

This package specifically deals with the sensing and the perception algorithms tight to the **car body analysis**, and not with the analysis of the human present (which is instead considered in the `Human` module).

```{plantuml}
:width: 700px
@startuml
package Estimation {

  interface EstimationAlgorithm {
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

  entity WeldingInformation {
  }

  interface Localiser {
    .. out topics ..
    + /<obj>/position: geometry_msgs/PoseStamped.msg
  }

}
@enduml
```
- `CameraSensor` and `TactileSensor` represent the node components of the corresponding sensors; they collect the data, might perform internal pre-processing, and outputs the raw data in a ROS-friendly format;
- `EstimationAlgorithm` is an interface component whose responsible to _"glue together"_ the various data coming from the sensors;
- `Localiser` is an interface for components that can provide the relative position of pieces within the robotic cell (e.g. to position the base-link frame of the robot w.r.t. the car body). 
  We envision multiple implementation of this interface (e.g. using motion capture system, or marker(less)-based vision system), depending on the availability of the testing facility (e.g. Trento might have a setup which is different from Genova, that is different from the one in TOFAS).

### `TaskPlanning` module

```{plantuml}
:width: 700px
@startuml
package TaskPlanning {

  entity Supervisor {
  }

  entity OrienteeringSolver {
    .. required services ..
    - /motion_planner/dmp/time_estimator: motion_planning/TimeEstimate.srv
    - /estimator/get_defects: estimator/GetDefects.srv
    .. services ..
    ~ /task_planner/orienteering: task_planning/Orienteering.srv
  }

  
}
@enduml
```

- `Supervisor` implements the finite-state machine which will orchestrate, at runtime, the execution of the distributed network of nodes.

### `MotionPlanning` module

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

### `Controller` module

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

  CartesianController <|-- ImpedanceController 

}
@enduml
```

### `HardwareInterface` module

```{plantuml}
:width: 700px
@startuml
package HardwareInterface {

  interface HwInterface {
    .. out topics ..
    + /robot/joint_states: sensor_msgs/msg/JointState
  }

  HwInterface <|-- Simulator
  HwInterface <|-- RealHardware

}
@enduml
```

### `HumanEstimation` module

```{plantuml}
:width: 700px
@startuml
package HumanEstimation {

  interface SkeletonTracker {
    .. out topics ..
    + /human/tracked_humans: human/HumanSkeletons.msg
  }

  entity MotionForecaster {
    .. in topics ..
    - /human/tracked_humans: human/HumanSkeletons.msg
    .. out topics ..
    + /human/motion_forecast: human/MotionForecasts.msg
  }

}
@enduml
```

### `OfflineOptimisation` module

```{plantuml}
:width: 700px
@startuml
package OfflineOptimisation {
  entity ProcessAnalysis 
  entity ProcessOptimisation
  entity ToolOptimisation
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
- `/camera/result` (type: `magician_msg/camera/Result.msg`): provides the identified defects from a image of the vision-based system;
- `/tactile/result` (type: `magician_msg/tactile/Result.msg`): provides the outcome of the defect analysis through tactile sensing; 
- `/estimator/state` (type `magician_msgs/estimator/EstimationState.msg`): provides the current inspection state of the car body (e.g. the map of the found defects, area that has been covered, variance of the estimation...);
- `/car/position` (type: `geometry_msgs/PoseStamped.msg`): position of the car body w.r.t. a common reference frame;
- `/robot/position` (type: `geometry_msgs/PoseStamped.msg`): position of the robot base link w.r.t. a common reference frame;
- `/controller/position` (type: `geometry_msgs/PoseStamped.msg`): desired end-effector position;
- `/controller/velocity` (type: `geometry_msgs/TwistStamped.msg`): desired end-effector velocity;
- `/human/tracked_humans` (type: `magician_msgs/human/HumanSkeletons.msg`): list of all the skeleton data tracked;
- `/human/motion_forecast` (type: `magician_msgs/human/MotionForecast.msg`): reports the predicted motion of the humans;


### Services

- `/estimator/get_defects` (type `magician_msgs/estimator/GetDefects.srv`): retrieves the currently sensed defects;
- `/task_planner/orienteering` (type `magician_msgs/task_planning/Orienteeering.srv`): solves the standard orienteering problem;
- `/motion_planner/dmp/time_estimator` (type `magician_msgs/motion_planner/dmp/TimeEstimate.srv`): estimates the time to move within 2 (or multiple) points using DMPs;
- `/motion_planner/dmp/execute` (type `magician_msgs/motion_planner/dmp/Dmp.srv`): executes a DMP-based motion;


## Extra features

### Managed Nodes

To facilitate the overall orchestration of the distributed network of nodes, we might rely on [managed ROS2 nodes](http://design.ros2.org/articles/node_lifecycle.html).
According to such standard, each node internally have a finite state machine of 4 states: `unconfigured`, `inactive`, `active`, `finalized`.
The following diagram (extracted from the ROS2 design documentation) shows the lifecycle of a node, describing all possible transitions:

![](http://design.ros2.org/img/node_lifecycle/life_cycle_sm.png)

By exploiting this finite-state machine-like behavior for each node, it will make easier to enable-disable particular functionalities at runtime.
