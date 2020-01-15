CloudFormation do
  AWSTemplateFormatVersion("2010-09-09")

  Parameter("Instance1") do
    Type("String")
  end
  
  Parameter("Instance2") do
    Type("String")
  end
 # Elastic Load Balancing load balancer with a single listener, and no instances.
  Resource("MyLoadBalancer") do
    Type("AWS::ElasticLoadBalancing::LoadBalancer")
    Property("AvailabilityZones", [
  "us-east-1a"
])
    Property("Listeners", [
  {
    "InstancePort"     => "80",
    "LoadBalancerPort" => "80",
    "Protocol"         => "HTTP"
  }
])
  end

#  Elastic Load Balancing load balancer with two Amazon EC2 instances, a single listener and a health check.
  Resource("MyLoadBalancer2") do
    Type("AWS::ElasticLoadBalancing::LoadBalancer")
    Property("AvailabilityZones", [
  "us-east-1a"
])
    Property("Instances", [
  Ref("Instance1"),
  Ref("Instance2")
])
    Property("Listeners", [
  {
    "InstancePort"     => "80",
    "LoadBalancerPort" => "80",
    "Protocol"         => "HTTP"
  }
])
    Property("HealthCheck", {
  "HealthyThreshold"   => "3",
  "Interval"           => "30",
  "Target"             => "HTTP:80/",
  "Timeout"            => "5",
  "UnhealthyThreshold" => "5"
})
  end
end
