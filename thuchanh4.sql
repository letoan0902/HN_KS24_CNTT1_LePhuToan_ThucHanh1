-- use StudentManagement;

-- cau 1: trigger tg_checkscore
delimiter //
create trigger tg_checkscore
before insert on grades
for each row
begin
    if new.score < 0 then
        set new.score = 0;
    elseif new.score > 10 then
        set new.score = 10;
    end if;
end //
delimiter ;

-- cau 2: transaction them sinh vien
start transaction;

-- them sinh vien
insert into students (studentid, fullname, totaldebt) 
values ('SV02', 'Ha Bich Ngoc', 0);

-- cap nhat no hoc phi
update students 
set totaldebt = 5000000 
where studentid = 'SV02';

-- xac nhan
commit;

-- cau 3: trigger tg_loggradeupdate
delimiter //
create trigger tg_loggradeupdate
after update on grades
for each row
begin
    if old.score <> new.score then
        insert into gradelog (studentid, oldscore, newscore)
        values (old.studentid, old.score, new.score);
    end if;
end //
delimiter ;

-- cau 4: procedure sp_paytuition
delimiter //
create procedure sp_paytuition()
begin
    declare v_debt decimal(10,2);
    
    start transaction;
    
    update students 
    set totaldebt = totaldebt - 2000000 
    where studentid = 'SV01';
    
    select totaldebt into v_debt from students where studentid = 'SV01';
    
    if v_debt < 0 then
        rollback;
    else
        commit;
    end if;
end //
delimiter ;

-- cau 5: trigger tg_preventpassupdate
delimiter //
create trigger tg_preventpassupdate
before update on grades
for each row
begin
    if old.score >= 4.0 then
        signal sqlstate '45000'
        set message_text = 'khong the cap nhat diem khi da qua mon';
    end if;
end //
delimiter ;

-- cau 6: procedure sp_deletestudentgrade
delimiter //
create procedure sp_deletestudentgrade(in p_studentid char(5), in p_subjectid char(5))
begin
    declare v_score decimal(4,2);
    declare v_rowcount int;
    
    start transaction;
    
    -- luu diem vao log
    select score into v_score 
    from grades 
    where studentid = p_studentid and subjectid = p_subjectid;
    
    insert into gradelog (studentid, oldscore, newscore)
    values (p_studentid, v_score, null);
    
    -- xoa du lieu
    delete from grades 
    where studentid = p_studentid and subjectid = p_subjectid;
    
    select row_count() into v_rowcount;
    
    if v_rowcount = 0 then
        rollback;
    else
        commit;
    end if;
end //
delimiter ;
