
provider "aws" {
  region = "eu-west-2" 
}


resource "aws_ecs_cluster" "nextpoc" {
  name = "nextpoc"
}


resource "aws_security_group" "ecs_sg" {
  name   = "nextpoc"
  vpc_id = "vpc-01a0cb45befe50f0b"  

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_ecs_task_definition" "my_task" {
  family                   = "my-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  
  memory                   = "512"  

  container_definitions = jsonencode([{
    name      = "nextjspoc"
    image     = ""  
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
      protocol      = "tcp"
    }]
  }])
}


resource "aws_ecs_service" "nextpoc_svc" {
  name            = "nextpoc_svc"
  cluster         = aws_ecs_cluster.nextpoc.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets         = ["subnet-0980118215d96e765", "subnet-0b64a78400aee6ca5"]  
    security_groups = [aws_security_group.nextpoc.id]
    assign_public_ip = true
  }
}
