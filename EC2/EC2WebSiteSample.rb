CloudFormation do
  Description("AWS CloudFormation Sample Template EC2WebSiteSample: Create an Amazon EC2 instance running a simple Apache webserver. The Apache web server is installed on the EC2 instance along with some simple content using the CloudFormation application bootstrap features of the Amazon Linux AMI. This example creates an EC2 security group for the instance to give you SSH access and an Elastic IP to access the instance. **WARNING** This template creates an Amazon EC2 instance. You will be billed for the AWS resources used if you create a stack from this template.")
  AWSTemplateFormatVersion("2010-09-09")

  Parameter("InstanceType") do
    Description("WebServer EC2 instance type")
    Type("String")
    Default("m1.small")
    AllowedValues([
  "t1.micro",
  "m1.small",
  "m1.medium",
  "m1.large",
  "m1.xlarge",
  "m2.xlarge",
  "m2.2xlarge",
  "m2.4xlarge",
  "m3.xlarge",
  "m3.2xlarge",
  "c1.medium",
  "c1.xlarge",
  "cc1.4xlarge",
  "cc2.8xlarge",
  "cg1.4xlarge"
])
    ConstraintDescription("must be a valid EC2 instance type.")
  end

  Parameter("KeyName") do
    Description("Name of an existing EC2 KeyPair to enable SSH access to the instance")
    Type("String")
  end

  Parameter("SSHLocation") do
    Description("The IP address range that can be used to SSH to the EC2 instances")
    Type("String")
    Default("0.0.0.0/0")
    AllowedPattern("(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})")
    MaxLength(18)
    MinLength(9)
    ConstraintDescription("must be a valid IP CIDR range of the form x.x.x.x/x.")
  end

  Mapping("AWSInstanceType2Arch", {
  "c1.medium"   => {
    "Arch" => "64"
  },
  "c1.xlarge"   => {
    "Arch" => "64"
  },
  "cc1.4xlarge" => {
    "Arch" => "64HVM"
  },
  "cc2.8xlarge" => {
    "Arch" => "64HVM"
  },
  "cg1.4xlarge" => {
    "Arch" => "64HVM"
  },
  "m1.large"    => {
    "Arch" => "64"
  },
  "m1.medium"   => {
    "Arch" => "64"
  },
  "m1.small"    => {
    "Arch" => "64"
  },
  "m1.xlarge"   => {
    "Arch" => "64"
  },
  "m2.2xlarge"  => {
    "Arch" => "64"
  },
  "m2.4xlarge"  => {
    "Arch" => "64"
  },
  "m2.xlarge"   => {
    "Arch" => "64"
  },
  "m3.2xlarge"  => {
    "Arch" => "64"
  },
  "m3.xlarge"   => {
    "Arch" => "64"
  },
  "t1.micro"    => {
    "Arch" => "64"
  }
})

  Mapping("AWSRegionArch2AMI", {
  "ap-northeast-1" => {
    "32"    => "ami-0644f007",
    "64"    => "ami-0a44f00b",
    "64HVM" => "NOT_YET_SUPPORTED"
  },
  "ap-southeast-1" => {
    "32"    => "ami-b4b0cae6",
    "64"    => "ami-beb0caec",
    "64HVM" => "NOT_YET_SUPPORTED"
  },
  "ap-southeast-2" => {
    "32"    => "ami-b3990e89",
    "64"    => "ami-bd990e87",
    "64HVM" => "NOT_YET_SUPPORTED"
  },
  "eu-west-1"      => {
    "32"    => "ami-973b06e3",
    "64"    => "ami-953b06e1",
    "64HVM" => "NOT_YET_SUPPORTED"
  },
  "sa-east-1"      => {
    "32"    => "ami-3e3be423",
    "64"    => "ami-3c3be421",
    "64HVM" => "NOT_YET_SUPPORTED"
  },
  "us-east-1"      => {
    "32"    => "ami-31814f58",
    "64"    => "ami-1b814f72",
    "64HVM" => "ami-0da96764"
  },
  "us-west-1"      => {
    "32"    => "ami-11d68a54",
    "64"    => "ami-1bd68a5e",
    "64HVM" => "NOT_YET_SUPPORTED"
  },
  "us-west-2"      => {
    "32"    => "ami-38fe7308",
    "64"    => "ami-30fe7300",
    "64HVM" => "NOT_YET_SUPPORTED"
  }
})

  Resource("Ec2Instance") do
    Type("AWS::EC2::Instance")
    Metadata("AWS::CloudFormation::Init": {
  "config" => {
    "packages" => {
      "yum" => {
        "httpd" => [],
        "php"   => []
      }
    },
    "services" => {
      "sysvinit" => {
        "httpd" => {
          "enabled"       => "true",
          "ensureRunning" => "true"
        }
      }
    },
    "sources"  => {
      "/var/www/html" => "https://s3.amazonaws.com/cloudformation-examples/CloudFormationGettingStarted.tar.gz"
    }
  }
})
    Property("SecurityGroups", [
  Ref("InstanceSecurityGroup")
])
    Property("KeyName", Ref("KeyName"))
    Property("ImageId", FnFindInMap("AWSRegionArch2AMI", Ref("AWS::Region"), FnFindInMap("AWSInstanceType2Arch", Ref("InstanceType"), "Arch")))
    Property("UserData", FnBase64(FnJoin("", [
  "#!/bin/bash\n",
  "yum update -y aws-cfn-bootstrap\n",
  "/opt/aws/bin/cfn-init -s ",
  Ref("AWS::StackId"),
  " -r Ec2Instance ",
  "         --region ",
  Ref("AWS::Region"),
  "\n",
  "/opt/aws/bin/cfn-signal -e $? '",
  Ref("WaitHandle"),
  "'\n"
])))
  end

  Resource("WaitHandle") do
    Type("AWS::CloudFormation::WaitConditionHandle")
  end

  Resource("WaitCondition") do
    Type("AWS::CloudFormation::WaitCondition")
    DependsOn("Ec2Instance")
    Property("Handle", Ref("WaitHandle"))
    Property("Timeout", "300")
  end

  Resource("InstanceSecurityGroup") do
    Type("AWS::EC2::SecurityGroup")
    Property("GroupDescription", "Enable SSH access and HTTP access on the inbound port")
    Property("SecurityGroupIngress", [
  {
    "CidrIp"     => Ref("SSHLocation"),
    "FromPort"   => "22",
    "IpProtocol" => "tcp",
    "ToPort"     => "22"
  },
  {
    "CidrIp"     => "0.0.0.0/0",
    "FromPort"   => "80",
    "IpProtocol" => "tcp",
    "ToPort"     => "80"
  }
])
  end

  Resource("EIP") do
    Type("AWS::EC2::EIP")
    Property("InstanceId", Ref("Ec2Instance"))
  end

  Output("InstanceId") do
    Description("InstanceId of the newly created EC2 instance")
    Value(Ref("Ec2Instance"))
  end

  Output("AZ") do
    Description("Availability Zone of the newly created EC2 instance")
    Value(FnGetAtt("Ec2Instance", "AvailabilityZone"))
  end

  Output("URL") do
    Description("URL of the sample website")
    Value(FnJoin("", [
  "http://",
  Ref("EIP")
]))
  end
end
