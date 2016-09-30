#!/bin/bash
echo "
             \|/
            .-*-         
           / /|\         
          _L_            
        ,"   ".          
    (\ /  O O  \ /)      
     \|    _    |/       
       \  (_)  /         
       _/.___,\_         
      (_/     \_)         
"
echo "GET TO THE CHOPPA!!!"
ID=
ID=`aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, State.Name, InstanceId]' | grep -E 'running|pending' | awk '{print $3}'`
echo "Here are all running instances: " $ID
echo "Updating autoscaling group"
aws autoscaling update-auto-scaling-group --auto-scaling-group-name apache-auto --min-size 0 --max-size 0 --desired-capacity 0
ID=`aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, State.Name, InstanceId]' | grep -E 'running|pending' | awk '{print $3}'`
if [ "$ID" ]; then
	echo "Waiting till instances terminate"
	aws ec2 wait instance-terminated
else
	echo "Waiting till instances terminate"
	aws ec2 terminate-instances --instance-ids $ID
	aws ec2 wait instance-terminated
fi
echo "Detaching load balancer"
aws autoscaling detach-load-balancers --load-balancer-names apache-lb --auto-scaling-group-name apache-auto
echo "Lets Sleep for 30 Sec. just to be safe here"
sleep 30
echo "Deleting auto scaling group"
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name apache-auto
echo "Deleting launch configuration"
aws autoscaling delete-launch-configuration --launch-configuration-name apache-conf
echo "Deleting Load Balancer"
aws elb delete-load-balancer --load-balancer-name apache-lb
echo "If you didn't didn't get to the CHOPA by now its too late!!!"
echo "
                  ..-^~~~^-..
                .~           ~.
               (;:           :;)
                (:           :)
                  ':._   _.:'
                      | |
                    (=====)
                      | |
-O-                   | |
  \                   | |
  /\               ((/   \))"
#Art taken from: http://www.chris.com/ascii/index.php?art=objects/explosives

