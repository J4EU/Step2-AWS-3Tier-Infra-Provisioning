# AWS 3-Tier Guestbook Project (Infrastructure)

> Rocky Linux 3-Tier Guestbook을 AWS로 마이그레이션한 **인프라 프로비저닝 실습**

원본 프로젝트: [Rocky-3Tier-Guestbook-Project](https://github.com/J4EU/Rocky-3Tier-Guestbook-Project)

## 프로젝트 범위

이 프로젝트는 **애플리케이션 배포가 아닌 인프라 구성**에만 초점을 맞췄습니다.

**제외된 내용:**
- 웹 정적 파일 배포 (`index.html`)
- WAS 애플리케이션 코드 배포 및 실행
- DB 스키마/데이터 초기화

**포함된 내용:**
- VPC, Subnet, 라우팅 설계
- EC2 인스턴스 프로비저닝
- NAT Instance 프로비저닝
- 역할별 기본 런타임 설치 (`user_data`)


## 아키텍처
```
Internet
  │
  ▼
[IGW] ── Public Subnet (10.0.1.0/24)
          ├── Web EC2 (Nginx 준비)
          └── NAT Instance ── EIP
                   │
                   └─────── Private Subnet (10.0.2.0/24) ← 아웃바운드
                             ├── WAS EC2 (Python 런타임)
                             └── DB EC2 (MariaDB 준비)
```

## 핵심 마이그레이션 포인트

| 구성요소 | Rocky Linux (전 프로젝트) | AWS (이 프로젝트) |
|---|---|---|
| **Web** | Nginx 설치 | EC2 + Nginx 패키지 설치 |
| **WAS** | Python + systemd | EC2 + Python 런타임 준비 |
| **DB** | MariaDB 설치 | EC2 + MariaDB 패키지 설치 |
| **네트워크** | 고정 IP 수동 설정 | VPC / Subnet / Route Table |
| **보안** | SELinux | Security Group |
| **Private 아웃바운드** | - | **NAT Instance** |
| **인프라 관리** | Shell Script | **Terraform (IaC)** |

---

## NAT Instance 비용 최적화
**NAT Gateway** 시간당 ~$0.059(서울 리전) 고정 비용 - 개인 실습에서 부담되기 때문에 NAT Instance 사용

**NAT Instance 핵심 설정:**
- `source_dest_check = false`
- `iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE`
- `net.ipv4.ip_forward=1`
- Private Route Table → NAT Instance ENI

## 기술 스택
```
IaC: Terraform
Cloud: AWS (VPC, EC2, IGW, Security Group, EIP)
OS: Amazon Linux 2023
```

## 파일 구조
```
├── provider.tf # AWS 프로바이더
├── vpc.tf # VPC, Public/Private Subnet, IGW, Route Table
├── nat.tf # NAT Instance + EIP
├── security_groups.tf # 3-Tier 보안 그룹 및 NAT 인스턴스 보안 그룹
├── web.tf # Web EC2 + Nginx 설치
├── was.tf # WAS EC2 + Python 런타임
└── db.tf # DB EC2 + MariaDB 설치
```

## 배포 방법

```bash
# 1. 초기화
terraform init

# 2. 계획 확인
terraform plan

# 3. 인프라 생성
terraform apply

# 4. 인프라 삭제
terraform destroy
```

## 배포 이후 다음 단계 (별도 처리)

1. **Web**: `/usr/share/nginx/html/`에 정적 파일 배포
2. **WAS**: Python 애플리케이션 코드 배포 + `uvicorn` 실행
3. **DB**: 스키마 생성, 사용자/권한 설정
4. **연결**: WAS → DB, Web → WAS 네트워크 연결 테스트