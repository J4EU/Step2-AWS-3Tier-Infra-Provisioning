> AWS EC2와 Terraform을 연습하기 위한 학습용 워크스페이스입니다.

원본 프로젝트: [Step1-Local-VM-3Tier-Guestbook](https://github.com/J4EU/Step1-Local-VM-3Tier-Guestbook)

## 개요

이 레포는 Step1에서 Rocky Linux VM으로 구성했던 Web/WAS/DB 구조를 참고해,
AWS EC2 환경에서는 비슷한 구조를 어떻게 나눠볼 수 있는지 실습해 본 공간입니다.

완성된 서비스나 포트폴리오 프로젝트가 아니라,
VPC, Subnet, Route Table, Security Group, EC2, NAT Instance, `user_data` 같은 기본 요소를 직접 만져보며 감을 잡기 위한 연습용 레포입니다.

## 실습한 내용

- VPC, Public/Private Subnet 구성
- Route Table, Internet Gateway 구성
- Web/WAS/DB 역할의 EC2 인스턴스 생성
- Security Group 구성
- NAT Instance 구성
- `user_data`를 통한 기본 패키지 설치

## 하지 않은 것

- 웹 정적 파일 배포
- WAS 애플리케이션 코드 배포 및 실행
- DB 스키마/데이터 초기화
- Web-WAS-DB 간 실제 요청/응답 흐름 구현

## 구성

```text
Internet
  │
  ▼
[IGW]
  │
  ├── Public Subnet (10.0.1.0/24)
  │     ├── Web EC2 (Nginx 패키지 설치)
  │     └── NAT Instance + EIP
  │
  └── Private Subnet (10.0.2.0/24)
        ├── WAS EC2 (Python 런타임 준비)
        └── DB EC2 (MariaDB 패키지 설치)

Private Subnet outbound route:
Private Subnet → NAT Instance → IGW → Internet
```

Private Subnet의 인스턴스가 외부 패키지 저장소에 접근할 수 있도록 NAT Instance를 구성했습니다.
개인 실습 환경이라 NAT Gateway 대신 NAT Instance를 사용했습니다.

## 파일 구조

```text
├── provider.tf          # AWS Provider 설정
├── vpc.tf               # VPC, Subnet, IGW, Route Table
├── nat.tf               # NAT Instance, EIP
├── security_groups.tf   # Web, WAS, DB, NAT Instance Security Group
├── web.tf               # Web EC2, Nginx 패키지 설치
├── was.tf               # WAS EC2, Python 런타임 준비
└── db.tf                # DB EC2, MariaDB 패키지 설치
```

## 실행

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```
