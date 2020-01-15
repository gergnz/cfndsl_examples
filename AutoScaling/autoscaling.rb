CloudFormation do
  AWSTemplateFormatVersion("2010-09-09")

  Parameter("myEC2SecurityGroup") do
    Description("Existing EC2 Security Group")
    Type("String")
  end

  Parameter("LB") do
    Description("Existing Load Balancer")
    Type("String")
  end

  Parameter("azList") do
    Description("List of Availability Zones")
    Type("List<AWS::EC2::AvailabilityZone::Name>")
  end

  Parameter("topic1") do
    Description("Existing SNS Topic")
    Type("String")
  end

# Auto Scaling Launch Configuration Resource
  Resource("SimpleConfig") do
    Type("AWS::AutoScaling::LaunchConfiguration")
    Property("ImageId", "ami-6411e20d")
    Property("SecurityGroups", [
  Ref("myEC2SecurityGroup"),
  "myExistingEC2SecurityGroup"
])
    Property("InstanceType", "m1.small")
    Property("BlockDeviceMappings", [
  {
    "DeviceName" => "/dev/sdk",
    "Ebs"        => {
      "VolumeSize" => "50"
    }
  },
  {
    "DeviceName"  => "/dev/sdc",
    "VirtualName" => "ephemeral0"
  }
])
  end

# Auto Scaling Group Resource
  Resource("MyServerGroup") do
    Type("AWS::AutoScaling::AutoScalingGroup")
    Property("AvailabilityZones", FnGetAZs(""))
    Property("LaunchConfigurationName", Ref("SimpleConfig"))
    Property("MinSize", "1")
    Property("MaxSize", "3")
    Property("LoadBalancerNames", [
  Ref("LB")
])
  end

# Auto Scaling Policy Triggered by CloudWatch Alarm
  Resource("ScaleUpPolicy") do
    Type("AWS::AutoScaling::ScalingPolicy")
    Property("AdjustmentType", "ChangeInCapacity")
    Property("AutoScalingGroupName", Ref("MyServerGroup"))
    Property("Cooldown", "1")
    Property("ScalingAdjustment", "1")
  end

  Resource("CPUAlarmHigh") do
    Type("AWS::CloudWatch::Alarm")
    Property("EvaluationPeriods", "1")
    Property("Statistic", "Average")
    Property("Threshold", "10")
    Property("AlarmDescription", "Alarm if CPU too high or metric disappears indicating instance is down")
    Property("Period", "60")
    Property("AlarmActions", [
  Ref("ScaleUpPolicy")
])
    Property("Namespace", "AWS/EC2")
    Property("Dimensions", [
  {
    "Name"  => "AutoScalingGroupName",
    "Value" => Ref("MyServerGroup")
  }
])
    Property("ComparisonOperator", "GreaterThanThreshold")
    Property("MetricName", "CPUUtilization")
  end

# Auto Scaling Group with Notifications
  Resource("MyAsGroupWithNotification") do
    Type("AWS::AutoScaling::AutoScalingGroup")
    Property("AvailabilityZones", Ref("azList"))
    Property("LaunchConfigurationName", Ref("SimpleConfig"))
    Property("MinSize", "0")
    Property("MaxSize", "2")
    Property("DesiredCapacity", "1")
    Property("NotificationConfiguration", {
  "NotificationTypes" => [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ],
  "TopicARN"          => Ref("topic1")
})
  end
end
