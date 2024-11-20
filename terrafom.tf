# Configuración del proveedor de AWS
provider "aws" {
  region = "us-west-2"  # Región donde se desplegará la instancia
}

# Crear un grupo de seguridad para la instancia
resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "Allow SSH and HTTP access"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite el acceso SSH desde cualquier IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite el acceso HTTP desde cualquier IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Permite la salida a cualquier IP
  }
}

# Crear una instancia EC2
resource "aws_instance" "my_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # Reemplaza con la AMI correcta para tu región
  instance_type = "t2.micro"               # Tipo de instancia (t2.micro es elegible para el nivel gratuito)
  key_name      = "my-ssh-key"             # Reemplaza con el nombre de tu par de llaves SSH
  security_groups = [aws_security_group.instance_sg.name]
  
  # Etiquetas opcionales
  tags = {
    Name = "MyInstance"
  }

  # Instalar un archivo de configuración o script al iniciar (opcional)
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
            EOF
}

# Crear una clave SSH para el acceso (si no tienes una)
resource "aws_key_pair" "my_key" {
  key_name   = "my-ssh-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Ruta a tu clave pública SSH
}

# Output de la dirección IP pública de la instancia
output "instance_ip" {
  value = aws_instance.my_instance.public_ip
}
