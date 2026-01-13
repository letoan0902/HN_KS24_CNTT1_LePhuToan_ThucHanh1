-- tao view view_studentbasic hien thi studentid, fullname, deptname
create or replace view view_studentbasic as
select s.studentid, s.fullname, d.deptname
from student s
join department d on s.deptid = d.deptid;

-- truy van toan bo view_studentbasic
select * from view_studentbasic;

-- tao regular index cho cot fullname cua bang student
create index idx_student_fullname on student(fullname);

-- cau 3: viet getstudentsit
delimiter //
create procedure getstudentsit()
begin
    select s.*, d.deptname
    from student s
    join department d on s.deptid = d.deptid
    where d.deptname = 'Information Technology';
end //
delimiter ;

call getstudentsit();

-- tao view view_studentcountbydept hien thi deptname, totalstudents
create or replace view view_studentcountbydept as
select d.deptname, count(s.studentid) as totalstudents
from department d
left join student s on d.deptid = s.deptid
group by d.deptid, d.deptname;

-- truy van hien thi khoa co nhieu sinh vien nhat
select deptname, totalstudents
from view_studentcountbydept
where totalstudents = (select max(totalstudents) from view_studentcountbydept);

-- viet stored procedure gettopscorestudent
delimiter //
create procedure gettopscorestudent(in p_courseid char(6))
begin
    select s.studentid, s.fullname, e.score, c.coursename
    from student s
    join enrollment e on s.studentid = e.studentid
    join course c on e.courseid = c.courseid
    where e.courseid = p_courseid
    and e.score = (
        select max(score) 
        from enrollment 
        where courseid = p_courseid
    );
end //
delimiter ;

-- goi thu tuc tim sinh vien co diem cao nhat mon database systems (c00001)
call gettopscorestudent('C00001');

-- tao view view_it_enrollment_db
create or replace view view_it_enrollment_db as
select e.studentid, e.courseid, e.score
from enrollment e
join student s on e.studentid = s.studentid
where s.deptid = 'IT' and e.courseid = 'C00001'
with check option;

-- xem view
select * from view_it_enrollment_db;

-- viet updatescore_it_db
delimiter //
create procedure updatescore_it_db(
    in p_studentid char(6),
    inout p_newscore float
)
begin
    -- neu diem > 10 thi gan lai = 10
    if p_newscore > 10 then
        set p_newscore = 10;
    end if;
    
    -- cap nhat diem thong qua view
    update view_it_enrollment_db
    set score = p_newscore
    where studentid = p_studentid;
end //
delimiter ;

set @new_score = 11.5;

-- goi thu tuc de cap nhat diem cho sinh vien s00001 (thuoc khoa it)
call updatescore_it_db('S00001', @new_score);

-- hien thi lai gia tri diem moi
select @new_score as adjusted_score;

-- kiem tra du lieu trong view 
select * from view_it_enrollment_db;

-- kiem tra du lieu trong bang enrollment
select e.*, s.fullname, d.deptname
from enrollment e
join student s on e.studentid = s.studentid
join department d on s.deptid = d.deptid
where e.courseid = 'C00001';