---DDL SCHEMA

CREATE SEQUENCE patient_seq START 1; --generates auto-incrementing patient ids starting with 1  

CREATE SEQUENCE visit_seq START 1; --generates auto-incrementing appointment ids starting with 1 

---#Patient Table
create table patient(
	patient_id		integer primary key not null default nextval('patient_seq'),
	first_name		varchar(20),
	last_name		varchar(30),
	contact_number	varchar(15),
	address			varchar(100),
	appt_number 	smallint,
	date_of_birth 	date,
	gender			varchar(6),
	email			varchar(100),
	created_by		varchar(30),
	modified_by		varchar(30)
);
	

---#appointment Table
create table visit(
	visit_id 		smallint primary key default nextval('visit_seq'),
	patient_id 			integer,
	financial_class_id 	integer,
	appt_nature       varchar(30),	
	appt_date		date,	
	appt_time		time,	
	status			varchar(10),
	foreign key (patient_id) references patient (patient_id)
);


---#financial_class Table
create table financial_class(
	invoice_id    integer primary key,
	payment_method 	varchar(10),
	payment_date 	date
);


---#department Table
create table department(
	dept_id		integer primary key,
	dept_name	varchar(15),
	location	varchar(20)
);

---#staff Table
create table staff(
	staff_id integer primary key not null,
	dept_id  integer,
	first_name 	varchar(20),
	last_name 	varchar(20),
	phone_number  varchar(12),	
	email        varchar(100),
	foreign key (dept_id) references department(dept_id)	
	);

---#appt_staff Table	
create table visit_staff(
	visit_id		smallint,	
	staff_id			integer,	
	role_at_appointment	varchar(15) NOT NULL CHECK (role_at_appointment IN ('Admin', 'Doctor','Nurse')),
	assigned_at			time,
	primary key (visit_id, staff_id),
	foreign key (visit_id) references visit(visit_id),	
	foreign key (staff_id) references staff(staff_id)
);

---#outpatient Table
create table outpatient_visit(
	visit_id int primary key,
	check_in_time 	time,	
	check_out_time 	time,
	foreign key (visit_id) references visit (visit_id)	
);

---#inpatient Table
create table inpatient_visit(
	visit_id 	int primary key,
	admit_time 		time,	
	room_number		smallint,	
	discharge_time 	time,
	admit_source 	varchar(25),	
	foreign key (visit_id) references visit (visit_id)	
);


---# admin Table
create table admin(
	staff_id	 integer primary key,	
	designation 	varchar(30),	
	foreign key (staff_id) references staff (staff_id)	
);
	
---# doctor Table
create table doctor (
	staff_id	 integer primary key,
	specialisation	varchar(30),
	foreign key (staff_id) references staff (staff_id)
);

---# nurse Table
create table nurse (
	staff_id	 integer primary key,
	license_level	varchar(10),
	shift_timing	time,
	foreign key (staff_id) references staff (staff_id)
);

create index IX_visit_patient_id			ON visit(patient_id);
create index IX_patient_last_first 			ON patient(last_name, first_name);
create index IX_patient_phone 				ON patient(contact_number);
create index IX_appstaff_appointment_id     ON visit_staff(visit_id);
create index IX_staff_last_first 			ON staff(last_name, first_name);


	
drop table visit;
drop table visit_staff;
drop table inpatient_visit;
drop table outpatient_visit;
drop table staff;
drop table department;
drop table admin;
drop table doctor;
drop table patient;
drop table nurse;
drop table financial_class;
drop table inpatient_visit;
drop table outpatient_visit;
	
