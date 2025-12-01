---DDL SCHEMA
--/* Drop statements to clean up objects from previous run */

--Triggers
drop trigger trg_visit_status;
drop trigger  trg_patient_audit;

--Sequences
drop sequence patient_seq;
drop sequence visit_seq;

--Indices
drop index IX_visit_patient_id;	
drop index IX_patient_last_first; 
drop index IX_patient_phone;
drop index IX_appstaff_appointment_id;
drop index IX_staff_last_first; 
drop index IX_staff_department;
drop index IX_visit_financial_class;

-- Tables
drop table admin;
drop table doctor;
drop table nurse;
drop table financial_class; 
drop table inpatient_visit;  
drop table outpatient_visit;
drop table appt_staff;
drop table staff;
drop table department;
drop table visit;
drop table patient;

--/* Create statements to write tables to the schema */
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
	
---#visit Table
create table visit(
	visit_id 			smallint primary key default nextval('visit_seq'),
	patient_id 			integer,
	invoice_id 			integer,
	visit_nature       	varchar(30),	
	visit_date			date,	
	appt_time			time,	
	status				varchar(10),
	foreign key (patient_id) references patient (patient_id)
);

---#financial_class Table
create table financial_class(
	invoice_id    	integer primary key,
	payment_method 	varchar(10),
	payment_date 	date,
	staff_id		integer,
	visit_id		integer,
	foreign key (staff_id) references staff (staff_id),
	foreign key (visit_id) references visit (visit_id)
);

---#department Table
create table department(
	dept_id			integer primary key,
	dept_name		varchar(15),
	location		varchar(20),
	service_offered varchar(100),
	phone_ext		varchar(15)
);

---#staff Table
create table staff(
	staff_id 		integer primary key not null,
	dept_id  		integer,
	first_name 		varchar(20),
	last_name 		varchar(20),
	phone_number  	varchar(12),	
	email        	varchar(100),
	foreign key (dept_id) references department(dept_id)	
	);

---#appt_staff Table	
create table appt_staff(
	visit_id			smallint,	
	staff_id			integer,	
	role_at_appointment	varchar(15) NOT NULL CHECK (role_at_appointment IN ('Admin', 'Doctor','Nurse')),
	assigned_at			time,
	primary key (visit_id, staff_id),
	foreign key (visit_id) references visit(visit_id),	
	foreign key (staff_id) references staff(staff_id)
);

---#outpatient Table
create table outpatient_visit(
	visit_id 		int primary key,
	check_in_time 	time,	
	check_out_time 	time check (check_out_time > check_in_time);
	foreign key (visit_id) references visit (visit_id)	
);

---#inpatient Table
create table inpatient_visit(
	visit_id 		int primary key,
	admit_time 		time,	
	room_number		smallint,	
	discharge_time 	time,
	admit_source 	varchar(25),	
	foreign key (visit_id) references visit (visit_id)	
);

---# admin Table
create table admin(
	staff_id	 	integer primary key,	
	designation 	varchar(30),	
	foreign key (staff_id) references staff (staff_id)	
);
	
---# doctor Table
create table doctor (
	staff_id	 	integer primary key,
	specialisation	varchar(30),
	foreign key (staff_id) references staff (staff_id)
);

---# nurse Table
create table nurse (
	staff_id	 	integer primary key,
	license_level	varchar(10),
	shift_timing	time,
	foreign key (staff_id) references staff (staff_id)
);


--Alter Table visit
Alter table visit add(
	created_by 		varchar(50)
 	modified_by 	varchar(50)
);

--/* adding indices,sequences and triggers */
--create indices
--on Foreign Keys
create index IX_visit_patient_id			      on visit(patient_id);
create index IX_appstaff_appointment_id     on visit_staff(visit_id);
create index IX_visit_financial_class		    on visit (invoice_id);
create index IX_staff_department			      on staff (department_id);

--on frequenctly queried
create index IX_patient_last_first 			on patient(contact_number);
create index IX_staff_last_first 			  on staff(last_name, first_name);


--create sequence
create sequence patient_seq START 1;   
create sequence visit_seq START 1; 
	
--create trigger

--#Visit status  
CREATE OR REPLACE FUNCTION trg_visit_status()  

RETURNS TRIGGER AS $$ BEGIN NEW.status := COALESCE(NEW.status, 'Scheduled'); -- default if null NEW.modified_by := CURRENT_USER; RETURN NEW; END; $$ LANGUAGE plpgsql; 

-- Patient audit CREATE OR REPLACE FUNCTION trg_patient_audit() RETURNS TRIGGER AS $$ BEGIN IF TG_OP = 'INSERT' THEN NEW.created_by := CURRENT_USER; END IF; 

NEW.modified_by := CURRENT_USER; 
RETURN NEW; 
  

END; $$ LANGUAGE plpgsql; 

CREATE TRIGGER trg_visit_status BEFORE INSERT OR UPDATE ON visit FOR EACH ROW EXECUTE FUNCTION trg_visit_status();  

CREATE TRIGGER trg_patient_audit BEFORE INSERT OR UPDATE ON patient FOR EACH ROW EXECUTE FUNCTION trg_patient_audit(); 
