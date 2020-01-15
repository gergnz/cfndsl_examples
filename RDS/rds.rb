CloudFormation do
  AWSTemplateFormatVersion("2010-09-09")

  Parameter("MyDbSecurityByEC2SecurityGroup") do
    Type("String")
  end

  Parameter("DBName") do
    Type("String")
  end

  Parameter("DBUsername") do
    Type("String")
  end

  Parameter("DBClass") do
    Type("String")
  end

  Parameter("DBAllocatedStorage") do
    Type("String")
  end

  Parameter("DBPassword") do
    Type("String")
  end

  Parameter("MyDBName") do
    Type("String")
  end

  Parameter("MyDBSubnetGroup") do
    Type("String")
  end

  Parameter("MultiAZDatabase") do
    Type("String")
  end

  Parameter("DBUser") do
    Type("String")
  end

# Amazon RDS DB Instance Resource
  Resource("MyDB") do
    Type("AWS::RDS::DBInstance")
    DeletionPolicy("Snapshot")
    Property("DBSecurityGroups", [
  Ref("MyDbSecurityByEC2SecurityGroup"),
  Ref("MyDbSecurityByCIDRIPGroup")
])
    Property("AllocatedStorage", "5")
    Property("DBInstanceClass", "db.m1.small")
    Property("Engine", "MySQL")
    Property("MasterUsername", "MyName")
    Property("MasterUserPassword", "MyPassword")
  end

# Amazon RDS Oracle Database DB Instance Resource
  Resource("MyDB2") do
    Type("AWS::RDS::DBInstance")
    DeletionPolicy("Snapshot")
    Property("DBSecurityGroups", [
  Ref("MyDbSecurityByEC2SecurityGroup"),
  Ref("MyDbSecurityByCIDRIPGroup")
])
    Property("AllocatedStorage", "5")
    Property("DBInstanceClass", "db.m1.small")
    Property("Engine", "oracle-ee")
    Property("LicenseModel", "bring-your-own-license")
    Property("MasterUsername", "master")
    Property("MasterUserPassword", "SecretPassword01")
  end

# Amazon RDS DBSecurityGroup Resource for CIDR Range
  Resource("MyDbSecurityByCIDRIPGroup") do
    Type("AWS::RDS::DBSecurityGroup")
    Property("GroupDescription", "Ingress for CIDRIP")
    Property("DBSecurityGroupIngress", {
  "CIDRIP" => "192.168.0.0/32"
})
  end

# Amazon RDS DBSecurityGroup with an Amazon EC2 security group
  Resource("DBInstance") do
    Type("AWS::RDS::DBInstance")
    Property("DBName", Ref("DBName"))
    Property("Engine", "MySQL")
    Property("MasterUsername", Ref("DBUsername"))
    Property("DBInstanceClass", Ref("DBClass"))
    Property("DBSecurityGroups", [
  Ref("DBSecurityGroup")
])
    Property("AllocatedStorage", Ref("DBAllocatedStorage"))
    Property("MasterUserPassword", Ref("DBPassword"))
  end

  Resource("DBSecurityGroup") do
    Type("AWS::RDS::DBSecurityGroup")
    Property("DBSecurityGroupIngress", {
  "EC2SecurityGroupName" => Ref("WebServerSecurityGroup")
})
    Property("GroupDescription", "Frontend Access")
  end

  Resource("WebServerSecurityGroup") do
    Type("AWS::EC2::SecurityGroup")
    Property("GroupDescription", "Enable HTTP access via port 80 and SSH access")
    Property("SecurityGroupIngress", [
  {
    "CidrIp"     => "0.0.0.0/0",
    "FromPort"   => "80",
    "IpProtocol" => "tcp",
    "ToPort"     => "80"
  },
  {
    "CidrIp"     => "0.0.0.0/0",
    "FromPort"   => "22",
    "IpProtocol" => "tcp",
    "ToPort"     => "22"
  }
])
  end

# Multiple VPC security groups
  Resource("DBinstance2") do
    Type("AWS::RDS::DBInstance")
    DeletionPolicy("Snapshot")
    Property("AllocatedStorage", "5")
    Property("DBInstanceClass", "db.m1.small")
    Property("DBName", Ref("MyDBName"))
    Property("DBSecurityGroups", [
  Ref("DbSecurityByEC2SecurityGroup")
])
    Property("DBSubnetGroupName", Ref("MyDBSubnetGroup"))
    Property("Engine", "MySQL")
    Property("MasterUserPassword", "MyDBPassword")
    Property("MasterUsername", "MyDBUsername")
  end

# Amazon RDS Database Instance in a VPC Security Group
  Resource("DbSecurityByEC2SecurityGroup") do
    Type("AWS::RDS::DBSecurityGroup")
    Property("GroupDescription", "Ingress for Amazon EC2 security group")
    Property("EC2VpcId", "MyVPC")
    Property("DBSecurityGroupIngress", [
  {
    "EC2SecurityGroupId"      => "sg-b0ff1111",
    "EC2SecurityGroupOwnerId" => "111122223333"
  },
  {
    "EC2SecurityGroupId"      => "sg-ffd722222",
    "EC2SecurityGroupOwnerId" => "111122223333"
  }
])
  end

  Resource("DBEC2SecurityGroup") do
    Type("AWS::EC2::SecurityGroup")
    Property("GroupDescription", "Open database for access")
    Property("SecurityGroupIngress", [
  {
    "FromPort"                => "3306",
    "IpProtocol"              => "tcp",
    "SourceSecurityGroupName" => Ref("WebServerSecurityGroup"),
    "ToPort"                  => "3306"
  }
])
  end

  Resource("DBInstance3") do
    Type("AWS::RDS::DBInstance")
    Property("DBName", Ref("DBName"))
    Property("Engine", "MySQL")
    Property("MultiAZ", Ref("MultiAZDatabase"))
    Property("MasterUsername", Ref("DBUser"))
    Property("DBInstanceClass", Ref("DBClass"))
    Property("AllocatedStorage", Ref("DBAllocatedStorage"))
    Property("MasterUserPassword", Ref("DBPassword"))
    Property("VPCSecurityGroups", [
  FnGetAtt("DBEC2SecurityGroup", "GroupId")
])
  end
end
