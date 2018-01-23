# Demand Side Management in Smart Grid using Particle Swarm Optimization

## Problems we are addressing
- High peak load demand

- High distribution cost at peak load

- Load scheduling with consumers’ consent

**_Solving these problems can be beneficial for both Distribution Companies(DISCOMs) and customers_**

## How Demand Side Management Solves Problem
Utilizing electricity tariffs, monetary incentives, and government regulations to :- 
- Mitigate the peak load demand
- Reduce overall distribution cost
- Maximize the use of renewable energy and battery storage

## Proposed Algorithm for Demand Side Management(DSM) using Particle Swarm Optimization(PSO)

- It is a population based stochastic optimization technique
- Each particle contains records of their best fitness value, P_best, and the best fitness value of the entire swarm, G_best
- At each iteration we calculate fitness value of a bird and then compare it with Global P_best and G_best to update them if required.
- The swarm will move towards best solutions by minimizing objective function

### Algorithm

![alt text](https://github.com/vinaychetnani/Particle-Swarm-Optimization/blob/master/algo.JPG "algorithm")

### Implementation of PSO:
#### Inputs:
- Day ahead load price

![alt text](https://github.com/vinaychetnani/Particle-Swarm-Optimization/blob/master/DaP.jpg "Day a head laod price")
- Forecasted Load data

![alt text](https://github.com/vinaychetnani/Particle-Swarm-Optimization/blob/master/load_pro_fore.jpg "Forecasted Load data")
- Optimisation Function : We take it to be inverse of Day a head load price

![alt text](https://github.com/vinaychetnani/Particle-Swarm-Optimization/blob/master/obj.jpg "Objective Function")

- PSO Parameters : velocity_clamping_factor, individual learning rate, social parameter, etc.

- User load preference data:

![alt text](https://github.com/vinaychetnani/Particle-Swarm-Optimization/blob/master/DSM_input.JPG "DSM input")

#### Outputs:

![alt text](https://github.com/vinaychetnani/Particle-Swarm-Optimization/blob/master/output%20of%20algorithm.JPG "output")


## Results : 

- For Residential load data

![alt text](https://github.com/vinaychetnani/Particle-Swarm-Optimization/blob/master/dataip_res.jpg "results for Residential data")

- For Commercial load data

![alt text](https://github.com/vinaychetnani/Particle-Swarm-Optimization/blob/master/data_com_res.jpg "results for Commercial data")

- For Industrial load data

![alt text](https://github.com/vinaychetnani/Particle-Swarm-Optimization/blob/master/data_indus_res.jpg "results for Industrial data")

## Analysis :
- Above results clearly show the reduction in peak load demand, total cost incurred
- The proﬁt obtained in industrial load DSM was more than that of commercial and residential load. This is due to large ratings devices used in industries. So, shift of even a single controllable device from peak, can result in high load getting shifted and more eﬀective and percent cost reduction is maximum in Industrial Loads
- When the data of end time was included along with start time. Hence, increasing the constraints on scheduling time. Due to these restrictions and enforcement’s on device to be scheduled, some sharp peaks were observed in the load proﬁle after DSM. Less cost reduction was observed in this case






