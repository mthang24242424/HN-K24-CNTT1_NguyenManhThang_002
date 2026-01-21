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
update insurance_packages
set base_premium = base_premium * 1.15
where max_limit > 500000000;

-- xóa các nhật ký bồi thường trước ngày
delete from claim_processing_log
where recorded_at < '2025-06-20 00:00:00';

-- phần 2
-- câu 1
select * from policies
where status = 'active' and end_date > '2025-12-31 23:59:59';

-- câu 2
select full_name, email from customers
where full_name like 'Hoang%' and join_date > '2025-01-01';

-- câu 3
select * from claims
order by claim_amount desc
limit 3 offset 1;
-- phần 3
-- câu 1 
select cus.full_name, i.package_name, p.start_date, c.claim_amount 
from policies p
join customers cus on cus.customer_id = p.customer_id
join insurance_packages i on i.package_id = p.package_id
join claims c on c.policy_id = p.policy_id;

-- câu 2
select * from claims c
where status = 'approved' and claim_amount > 50000000;

-- câu 3
select 
    ip.package_id,
    ip.package_name,
    count(p.policy_id) as soluongkhachhang
from insurance_packages ip
left join policies p on ip.package_id = p.package_id
group by ip.package_id, ip.package_name
order by soluongkhachhang desc
limit 1;

-- phần 4 
-- câu 1
create index idx_policy_status_date 
on policies(status, start_date);

-- câu 2
create view vw_customer_summary as
select 
    c.full_name,
    count(p.policy_id) as soluonghopdong,
    sum(ip.base_premium) as tongphibaohiemdinhky
from customers c
left join policies p on c.customer_id = p.customer_id
left join insurance_packages ip on p.package_id = ip.package_id
group by c.customer_id, c.full_name;

-- phần 5 
-- câu 1
delimiter //

create trigger trg_after_claim_approved
after update on claims
for each row
begin
    if new.status = 'approved' and (old.status is null or old.status != 'approved') then
        insert into claim_processing_log (
            log_id, 
            claim_id, 
            action_detail, 
            recorded_at, 
            processor
        )
        values (
concat('l', lpad((select count(*) + 1 from claim_processing_log), 3, '0')),
            new.claim_id,
            'payment processed to customer',
            now(),
            'system_auto'
        );
    end if;
end //

delimiter ;

-- câu 2
delimiter //

create trigger trg_before_delete_policy
before delete on policies
for each row
begin
    if old.status = 'active' then
        signal sqlstate '45000'
        set message_text = 'không thể xóa hợp đồng đang ở trạng thái active';
    end if;
end //

delimiter ;

-- phần 6 
-- câu 1
delimiter //

create procedure sp_check_claim_limit(
    in p_claim_id varchar(10),
    out p_message varchar(50)
)
begin
    declare v_claim_amount double;
    declare v_max_limit double;
    
    select 
        c.claim_amount,
        ip.max_limit
    into 
        v_claim_amount,
        v_max_limit
    from claims c
    join policies p on c.policy_id = p.policy_id
    join insurance_packages ip on p.package_id = ip.package_id
    where c.claim_id = p_claim_id;
    
    if v_claim_amount is null then
        set p_message = 'claim not found';
    elseif v_claim_amount > v_max_limit then
        set p_message = 'exceeded';
    else
        set p_message = 'valid';
    end if;
end //
delimiter ;
    select 'hủy hợp đồng thành công' as result;
end //
delimiter ;