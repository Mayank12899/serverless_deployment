# Cloud Provider
provider "aws" {
  region = "us-east-1"
}



# 1. Create vpc
resource "aws_vpc" "mock-project4-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "mock-project4-vpc"
  }
}



# 2.1 create security group for MySQL Aurora
resource "aws_security_group" "mock-project-4-sg-mysql" {
  name        = "mock-project-4-sg-mysql"
  description = "Allow the inbound traffic"
  vpc_id      = aws_vpc.mock-project4-vpc.id

  ingress {
      description      = "Allow port 3306 only"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
     # security_group_id = aws_security_group.mock-project-4-sg.id
    }

  egress  {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      #ipv6_cidr_blocks = ["::/0"]
     # security_group_id = aws_security_group.mock-project-4-sg.id
    }

  tags = {
    Name = "mock-project-group-4-sg-mysql"
    Group = 4
  }
}

# 2.2 create security group for Load Balancer
resource "aws_security_group" "mock-project-4-sg-lb" {
  name        = "mock-project-4-sg-lb"
  description = "Allow the inbound traffic"
  vpc_id      = aws_vpc.mock-project4-vpc.id

  ingress {
      description      = "Allow port 80 only"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
     # security_group_id = aws_security_group.mock-project-4-sg.id
    }

  egress  {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      #ipv6_cidr_blocks = ["::/0"]
     # security_group_id = aws_security_group.mock-project-4-sg.id
    }

  tags = {
    Name = "mock-project-group-4-sg-lb"
    Group = 4
  }
}


# 2.3 create security group for Lambda
resource "aws_security_group" "mock-project-4-sg-lambda" {
  name        = "mock-project-4-sg-lambda"
  description = "Allow the outbound traffic"
  vpc_id      = aws_vpc.mock-project4-vpc.id

 # ingress Not required for Lambda

  egress  {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      #ipv6_cidr_blocks = ["::/0"]
     # security_group_id = aws_security_group.mock-project-4-sg.id
    }

  tags = {
    Name = "mock-project-group-4-sg-lambda"
    Group = 4
  }
}


# 2.4 create security group for VM
resource "aws_security_group" "mock-project-4-sg-vm" {
  name        = "mock-project-4-sg-vm"
  description = "Allow the inbound traffic"
  vpc_id      = aws_vpc.mock-project4-vpc.id

  ingress {
      description      = "Allow all port"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
     # security_group_id = aws_security_group.mock-project-4-sg.id
    }

  egress  {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      #ipv6_cidr_blocks = ["::/0"]
     # security_group_id = aws_security_group.mock-project-4-sg.id
    }

  tags = {
    Name = "mock-project-group-4-sg-vm"
    Group = 4
  }
}


# 3. Create Internet Gateway
resource "aws_internet_gateway" "mock-project4-igw" {
  vpc_id = aws_vpc.mock-project4-vpc.id
}



# 4.1 Create a Public Subnet 1
resource "aws_subnet" "subnet-1-pub" {
  vpc_id            = aws_vpc.mock-project4-vpc.id
  cidr_block        = "10.0.1.0/28"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "mock-project-subnet-pub-1"
    Group = 4
  }
}

# 4.2 Create a Public Subnet 2 
resource "aws_subnet" "subnet-2-pub" {
  vpc_id            = aws_vpc.mock-project4-vpc.id
  cidr_block        = "10.0.1.48/28"
  availability_zone = "us-east-1b"

  tags = {
    Name = "mock-project-subnet-pub-2"
    Group = 4
  }
}

# 5.1 Create a Privat1 Subnet 
resource "aws_subnet" "subnet-1-pv" {
  vpc_id            = aws_vpc.mock-project4-vpc.id
  cidr_block        = "10.0.1.16/28"
  availability_zone = "us-east-1a"

  tags = {
    Name = "mock-project-subnet-pv1"
    Group = 4
  }
}


# 5.2 Create a PV2 Subnet 
resource "aws_subnet" "subnet-2-pv" {
  vpc_id            = aws_vpc.mock-project4-vpc.id
  cidr_block        = "10.0.1.32/28"
  availability_zone = "us-east-1b"

  tags = {
    Name = "mock-project-subnet-pv2"
    Group = 4
  }
}



# 6 Create Elastic IP
resource "aws_eip" "nat_eip" {
 #instance = aws_instance.web.id
  vpc      = true
  depends_on = [aws_internet_gateway.mock-project4-igw]
}



# 7 Create NAT Gateway
resource "aws_nat_gateway" "mock-project4-nat" {
  subnet_id     = aws_subnet.subnet-1-pub.id

  tags = {
    Name = "mock-project4-nat"
    Group = 4
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  allocation_id = aws_eip.nat_eip.id
  depends_on = [aws_internet_gateway.mock-project4-igw]
}



# 8 create Public route table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.mock-project4-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.mock-project4-igw.id
   }

  tags = {
    Name = "public-route-table-group-4"
  }
}


# 8.1 public Route Table Association with public subnet
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.subnet-1-pub.id
  route_table_id = aws_route_table.public-route-table.id
}

# 8.2 public Route Table Association with public subnet
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.subnet-2-pub.id
  route_table_id = aws_route_table.public-route-table.id
}


# create target group
resource "aws_lb_target_group" "group-4-tg" {
  health_check {
    interval = 10
    path = "/"
    protocol = "HTTP"
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
}

  name     = "mock-project-4-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mock-project4-vpc.id
}

# create load balancer 

resource "aws_lb" "group-4-lb" {
    name               = "mock-group-4-lb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.mock-project-4-sg-lb.id]
    #subnets           = aws_subnet.public.*.id
    subnets            = [aws_subnet.subnet-1-pub.id, aws_subnet.subnet-2-pub.id]
  
    #enable_deletion_protection = true
    ip_address_type = "ipv4" 
    tags = {
      Name = "mock-project-4-lb"
    }
  }


# create aws_lb_listener
  resource "aws_lb_listener" "group-4-lb-listener" {
    load_balancer_arn = aws_lb.group-4-lb.arn
    port              = "80"
    protocol          = "HTTP"
  
    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.group-4-tg.arn
    }
  }

#  resource "aws_lb_target_group_attachment" "test" {
#    target_group_arn = aws_lb_target_group.test.arn
#    target_id        = aws_instance.test.id
#    port             = 80
#  }

# create asg

resource "aws_autoscaling_group" "group4-asg" {
    vpc_zone_identifier  = [aws_subnet.subnet-1-pv.id, aws_subnet.subnet-2-pv.id]
    desired_capacity     = 2
    max_size             = 5
    min_size             = 2
    launch_template {
      id      = aws_launch_template.group4-template.id
      version = "1"
    }
    depends_on = [
      aws_launch_template.group4-template
]
  }

#attach lb to asg

  resource "aws_autoscaling_attachment" "asg_attachment" {
    autoscaling_group_name = aws_autoscaling_group.group4-asg.id
    elb                    = aws_lb.group-4-lb.id
  }


# 9 create Private route table
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.mock-project4-vpc.id

  route  {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.mock-project4-nat.id
    }

  tags = {
    Name = "private-route-table-group-4"
  }
}


# 9.1 Private Route Table Association with private subnet
resource "aws_route_table_association" "private-1" {
  subnet_id      = aws_subnet.subnet-1-pv.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_route_table_association" "private-2" {
  subnet_id      = aws_subnet.subnet-2-pv.id
  route_table_id = aws_route_table.private-route-table.id
}



# 10 Instance template
resource "aws_launch_template" "group4-template" {
  name = "group4-template"

   block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }

 # cpu_options {
 #   core_count       = 4
 #   threads_per_core = 2
 # }

  image_id = "ami-09e67e426f25ce0d7"

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t2.micro"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  #placement {
  #  availability_zone = "us-east-1a"
  #}

  vpc_security_group_ids = [aws_security_group.mock-project-4-sg-vm.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "group4-template"
    }
  }

  user_data = filebase64("install_apache.sh")
}
