# VPC 생성
resource "aws_vpc" "guestbook_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "guestbook_vpc"
  }
}

# 퍼블릭 서브넷(Web 서버 및 NAT 인스턴스)
resource "aws_subnet" "guestbook_public_sn" {
  vpc_id                  = aws_vpc.guestbook_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2a"

  tags = {
    Name = "guestbook_public_subnet"
  }
}

# 프라이빗 서브넷 (WAS 서버 및 DB 서버)
resource "aws_subnet" "guestbook_private_sn" {
  vpc_id            = aws_vpc.guestbook_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "guestbook_private_subnet"
  }
}

# 인터넷 게이트웨이
resource "aws_internet_gateway" "guestbook_igw" {
  vpc_id = aws_vpc.guestbook_vpc.id

  tags = {
    Name = "guestbook_igw"
  }
}

# 퍼블릭 라우팅 테이블
resource "aws_route_table" "guestbook_public_rt" {
  vpc_id = aws_vpc.guestbook_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.guestbook_igw.id
  }

  tags = {
    Name = "guestbook_public_rt"
  }
}

# 퍼블릭 라우팅 테이블 연결
resource "aws_route_table_association" "guestbook_public_assoc" {
  subnet_id      = aws_subnet.guestbook_public_sn.id
  route_table_id = aws_route_table.guestbook_public_rt.id

}

# 프라이빗 라우팅 테이블
resource "aws_route_table" "guestbook_private_rt" {
  vpc_id = aws_vpc.guestbook_vpc.id
}
