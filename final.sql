create database baithi;
use baithi;
create table Customers(
	Customer_ID varchar(10) primary key,
	Full_Name varchar(50) not null,
	Phone_Number varchar(10) not null unique,
	Email varchar(50) not null unique,
	Join_Date date not null
);

create table Insurance_Packages(
	Package_ID varchar(10) primary key,
	Package_Name varchar(50) not null,
	Max_Limit double check (Max_Limit > 0),
	Base_Premium double
);

create table Policies(
	Policy_ID varchar(10) primary key,
	Customer_ID varchar(10) not null,
	Package_ID varchar(10) not null,
	Start_Date date,
	End_Date date, 
	Status enum ('Active', 'Expired', 'Cancelled'),
    foreign key (Customer_ID) references Customers(Customer_ID),
    foreign key (Package_ID) references Insurance_Packages(Package_ID)
); 

create table Claims (
	Claim_ID varchar(10) primary key,
	Policy_ID varchar(10) not null,
	Claim_Date date,
	Claim_Amount double,
	Status enum ('Pending', 'Approved', 'Rejected'),
    foreign key (Policy_ID) references Policies(Policy_ID)
);

create table Claim_Processing_Log (
	Log_ID varchar(10) primary key,
	Claim_ID varchar(10) not null,
	Action_Detail varchar(100) not null unique,
	Recorded_At datetime,
	Processor varchar(100) not null
);

insert into Customers(Customer_ID,Full_Name,Phone_Number,Email,Join_Date) values
('C001', 'Nguyen Hoang Long', '0901112223', 'long.nh@gmail.com', '2024-01-15'),
('C002', 'Tran Thi Kim Anh', '0988877766', 'anh.tk@yahoo.com', '2024-03-10'),
('C003', 'Le Hoang Nam', '0903334445', 'nam.lh@outlook.com', '2025-05-20'),
('C004', 'Pham Minh Duc', '0355556667', 'duc.pm@gmail.com', '2025-08-12'),
('C005', 'Hoang Thu Thao', '0779998881', 'thao.ht@gmail.com', '2026-01-01');

insert into Insurance_Packages(Package_ID, Package_Name, Max_Limit, Base_Premium) values
('PKG01', 'Bảo hiểm Sức khỏe Gold', 500000000, 5000000),
('PKG02', 'Bảo hiểm Ô tô Liberty', 1000000000, 15000000),
('PKG03', 'Bảo hiểm Nhân thọ An Bình', 2000000000, 25000000),
('PKG04', 'Bảo hiểm Du lịch Quốc tế', 100000000, 1000000),
('PKG05', 'Bảo hiểm Tai nạn 24/7', 200000000, 2500000);

insert into Policies(Policy_ID,Customer_ID,Package_ID,Start_Date,End_Date,Status) values
('POL101','C001','PKG01','2024-01-15','2025-01-15','Expired'),
('POL102','C002','PKG02','2024-03-10','2026-03-10','Active'),
('POL103','C003','PKG03','2025-05-20','2035-05-20','Active'),
('POL104','C004','PKG04','2025-08-12','2025-09-12','Expired'),
('POL105','C005','PKG01','2026-01-01','2027-01-01','Active');

insert into Claims(Claim_ID,Policy_ID,Claim_Date,Claim_Amount,Status) values
('CLM901','POL102','2024-06-15',12000000,'Approved'),
('CLM902','POL103','2025-10-20',50000000,'Pending'),
('CLM903','POL101','2024-11-05',5500000,'Approved'),
('CLM904','POL105','2026-01-15',2000000,'Rejected'),
('CLM905','POL102','2025-02-10',120000000,'Approved');

insert into Claim_Processing_Log(Log_ID,Claim_ID,Action_Detail,Recorded_At,Processor) values
('L001','CLM901','Đã nhận hồ sơ hiện trường','2024-06-15 09:00','Admin_01'),
('L002','CLM901','Chấp nhận bồi thường xe tai nạn','2024-06-20 14:30','Admin_01'),
('L003','CLM902','Đang thẩm định hồ sơ bệnh án','2025-10-21 10:00','Admin_02'),
('L004','CLM904','Từ chối do lỗi cố ý của khách hàng','2026-01-16 16:00','Admin_03'),
('L005','CLM905','Đã thanh toán qua chuyển khoản','2025-02-15 08:30','Accountant_01');

-- cập nhật tăng phí
update Insurance_Packages
set Base_Premium = Base_Premium * 1.15
where Max_Limit > 500000000;

-- xóa các nhật ký bồi thường trc ngày
delete from Claim_Processing_Log
where Recorded_At < '2025-06-20 00:00:00';

-- phần 2
-- câu 1
select * from Policies
where status = 'Active' and End_Date > '2025-12-31 23:59:59';

-- câu 2
select Full_Name,Email from Customers
where Full_Name like 'Hoang%' and Join_Date > '2025-01-01';

-- câu 3
select * from Claims
order by Claim_Amount DESC
limit 3 offset 1;

-- phần 3
-- câu 1 
select cus.Full_Name, i.Package_Name, p.Start_Date, c.Claim_Amount from Policies p
join Customers cus on cus.Customer_ID = p.Customer_ID
join Insurance_Packages i on i.Package_ID = p.Package_ID
join Claims c on c.Policy_ID = p.Policy_ID;

-- câu 2
select *from Claims c
where Status = 'Approved' and Claim_Amount > 50000000;

-- câu 3


-- phần 4
-- câu 1
create index idx_policy_status_date on Policies(Status,Start_Date);

-- câu 2

-- phần 5
-- câu 1

-- phần 6
-- câu 1
