#Proveedor de nube
provider "aws" { 
  region = "us-east-1"
}

#VPC 10.10.0.0/20
resource "aws_vpc" "vpc_act3" {
    cidr_block = "10.10.0.0/20"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
      Name = "VPC-Act3"
    }
}

#Subred Publica 10.10.0.0/24
resource "aws_subnet" "subred_publica" {
  vpc_id = aws_vpc.vpc_act3.id
  cidr_block = "10.10.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subred Publica"
  }
}

#Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc_act3.id
    tags = {
      Name = "IGW-Terraform"
    }
}

#Tabla de rutas
resource "aws_route_table" "tabla_rutas_publicas" {
  vpc_id = aws_vpc.vpc_act3.id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Tabla_Rutas_Publicas"
  }
}

#Asociar tabla de rutas a subred publica
resource "aws_route_table_association" "asociacion_rutas" {
  subnet_id = aws_subnet.subred_publica.id
  route_table_id = aws_route_table.tabla_rutas_publicas.id
}

#Grupo de seguridad para Linux Jumper Server
resource "aws_security_group" "SG-LinuxJumpServer" {
  vpc_id = aws_vpc.vpc_act3.id
  name = "SG-LinuxJumpServer"
  description = "Acceso a SSH desde el internet"

  #Permitir trafico SSH desde cualquier IP
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  #Permitir salida a todo el trafico
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  
  tags = {
    Name = "SG-LinuxJumpServer"
  }  
}

#Grupo de seguridad para Linux Web Server
resource "aws_security_group" "SG-LinuxWebServer" {
  vpc_id = aws_vpc.vpc_act3.id
  name = "SG-LinuxWebServer"
  description = "Acceso a HTTP a traves del internet y a SSH a traves Linux Jump"

  #Permitir trafico HTTP desde cualquier IP
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  
  #Permitir trafico SSH para Linux Jump
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [format("%s/32", aws_instance.instancia_LinuxJump.private_ip)]
  }

  #Permitir salida a todo el trafico
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "SG-LinuxWebServer"
  }  
}

#Instancias Linux Web con su grupo de seguridad
resource "aws_instance" "instancia_LinuxWeb1" {
  ami = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subred_publica.id #Subred 10.10.0.0/24
  key_name = "vockey" #Asignamos clave 
  
  vpc_security_group_ids = [aws_security_group.SG-LinuxWebServer.id] #Grupo de seguridad para Linux Web 1
  associate_public_ip_address = true #Se fuerza la asignación de subred publica

  tags = {
    Name = "Linux Web Server - Primera"
  }
}

resource "aws_instance" "instancia_LinuxWeb2" {
  ami = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subred_publica.id #Subred 10.10.0.0/24
  key_name = "vockey" #Asignamos clave 
  
  vpc_security_group_ids = [aws_security_group.SG-LinuxWebServer.id] #Grupo de seguridad para Linux Web 2
  associate_public_ip_address = true #Se fuerza la asignación de subred publica

  tags = {
    Name = "Linux Web Server - Segunda"
  }
}

resource "aws_instance" "instancia_LinuxWeb3" {
  ami = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subred_publica.id #Subred 10.10.0.0/24
  key_name = "vockey" #Asignamos clave 
  
  vpc_security_group_ids = [aws_security_group.SG-LinuxWebServer.id] #Grupo de seguridad para Linux Web 3
  associate_public_ip_address = true #Se fuerza la asignación de subred publica

  tags = {
    Name = "Linux Web Server - Tercera"
  }
}

resource "aws_instance" "instancia_LinuxWeb4" {
  ami = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subred_publica.id #Subred 10.10.0.0/24
  key_name = "vockey" #Asignamos clave 
  
  vpc_security_group_ids = [aws_security_group.SG-LinuxWebServer.id] #Grupo de seguridad para Linux Web 4
  associate_public_ip_address = true #Se fuerza la asignación de subred publica

  tags = {
    Name = "Linux Web Server - Cuarta"
  }
}

#Instancia de Linux Jumper con su grupo de seguridad
resource "aws_instance" "instancia_LinuxJump" {
  ami = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subred_publica.id #Subred 10.10.0.0/24
  key_name = "vockey" #Asignamos clave 
  
  vpc_security_group_ids = [aws_security_group.SG-LinuxJumpServer.id] #Grupo de seguridad para Linux Jumper
  associate_public_ip_address = true #Se fuerza la asignación de subred publica

  tags = {
    Name = "Linux Jump Server"
  }
}

#Muestra de información de las instancias
output "instancia-IP_Publica-LinuxJump" {
  description = "IP Publica de Linux Jump"
  value = aws_instance.instancia_LinuxJump.public_ip
}

output "instancia-IP_Publica-PrimeraLinuxWeb" {
  description = "IP Publica de Primera Linux Web "
  value = aws_instance.instancia_LinuxWeb1.public_ip
}

output "instancia-IP_Publica-SegundaLinuxWeb" {
  description = "IP Publica de Segunda Linux Web"
  value = aws_instance.instancia_LinuxWeb2.public_ip
}

output "instancia-IP_Publica-TerceraLinuxWeb" {
  description = "IP Publica de Tercera Linux Web "
  value = aws_instance.instancia_LinuxWeb3.public_ip
}

output "instancia-IP_Publica-CuartaLinuxWeb" {
  description = "IP Publica de Cuarta Linux Web"
  value = aws_instance.instancia_LinuxWeb4.public_ip
}