resource "aws_instance" "guestbook_was_server" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t3.micro"
  key_name      = "guestbook-was"

  subnet_id = aws_subnet.guestbook_private_sn.id

  vpc_security_group_ids = [aws_security_group.guestbook_was_sg.id]

  associate_public_ip_address = false

  user_data = <<-EOF
    dnf install -y python3-pip
    sudo pip3 install fastapi uvicorn mysql-connector-python pydantic python-dotenv
    EOF


  tags = {
    Name = "guestbook-was-server"
  }
}
