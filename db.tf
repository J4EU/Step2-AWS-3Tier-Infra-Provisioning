resource "aws_instance" "guestbook_db_server" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t3.micro"
  key_name      = "guestbook-web"

  subnet_id              = aws_subnet.guestbook_private_sn.id
  vpc_security_group_ids = [aws_security_group.guestbook_db_sg.id]

  tags = {
    Name = "guestbook-db-server"
  }
}
