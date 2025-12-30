create database library;

use library;

create table reader (
    reader_id int auto_increment primary key,
    reader_name varchar(100) not null,
    phone varchar(15) unique,
    register_date date default (date(current_timestamp))
);

create table book (
    book_id int primary key,
    book_title varchar(150) not null,
    author varchar(150),
    publish_year int check (publish_year >= 1900)
);

create table borrow (
    reader_id int,
    book_id int,
    borrow_date date default (date(current_timestamp)),
    return_date date,
    foreign key (reader_id) references reader(reader_id),
    foreign key (book_id) references book(book_id),
    check (return_date >= borrow_date)
);

insert into reader (reader_id, reader_name, phone, register_date) values
(1, 'nguyễn văn an', '0901234567', '2025-12-01'),
(2, 'trần thị bình', '0912345678', '2025-12-05'),
(3, 'lê minh châu', '0923456789', '2025-12-10');

insert into book (book_id, book_title, author, publish_year) values
(101, 'lập trình c căn bản', 'nguyễn văn a', 2018),
(102, 'cơ sở dữ liệu', 'trần thị b', 2020),
(103, 'lập trình java', 'lê minh c', 2019),
(104, 'hệ quản trị mysql', 'phạm văn d', 2021);

insert into borrow (reader_id, book_id, borrow_date, return_date) values
(1, 101, '2025-12-15', null),
(1, 102, '2025-12-15', '2025-12-25'),
(2, 103, '2025-12-18', null);

update borrow set return_date = '2025-12-30' where reader_id = 1;

update book set publish_year = 2023 where publish_year >= 2021 and book_id > 0;

delete from borrow where borrow_date < '2025-11-18' and book_id > 0;

select * from reader;

select * from book;

select * from borrow;