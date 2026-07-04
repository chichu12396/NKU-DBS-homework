/*==============================================================*/
/* DBMS name:      MySQL 5.0                                    */
/* Created on:     2026/3/31 21:10:22                           */
/*==============================================================*/


alter table Event 
   drop foreign key FK_EVENT_HOSTED_AT_VENUE;

alter table Event 
   drop foreign key FK_EVENT_ORGANIZE_ORGANIZE;

alter table Lecture 
   drop foreign key FK_LECTURE_INHERITAN_EVENT;

alter table Performances 
   drop foreign key FK_PERFORMA_INHERITAN_EVENT;

alter table Staff 
   drop foreign key FK_STAFF_INHERITAN_USER;

alter table Student 
   drop foreign key FK_STUDENT_INHERITAN_USER;

alter table Ticket 
   drop foreign key FK_TICKET_BUY_USER;

alter table Ticket 
   drop foreign key FK_TICKET_SELL_EVENT;


alter table Event 
   drop foreign key FK_EVENT_ORGANIZE_ORGANIZE;

alter table Event 
   drop foreign key FK_EVENT_HOSTED_AT_VENUE;

drop table if exists Event;


alter table Lecture 
   drop foreign key FK_LECTURE_INHERITAN_EVENT;

drop table if exists Lecture;

drop table if exists Organizers;


alter table Performances 
   drop foreign key FK_PERFORMA_INHERITAN_EVENT;

drop table if exists Performances;


alter table Staff 
   drop foreign key FK_STAFF_INHERITAN_USER;

drop table if exists Staff;


alter table Student 
   drop foreign key FK_STUDENT_INHERITAN_USER;

drop table if exists Student;


alter table Ticket 
   drop foreign key FK_TICKET_SELL_EVENT;

alter table Ticket 
   drop foreign key FK_TICKET_BUY_USER;

drop table if exists Ticket;

drop table if exists User;

drop table if exists Venue;

/*==============================================================*/
/* Table: Event                                                 */
/*==============================================================*/
create table Event
(
   EventID              int not null  comment '',
   OrganizerId          int not null  comment '',
   VenueID              int not null  comment '',
   Title                varchar(200) not null  comment '',
   StartTime            datetime not null  comment '',
   EndTime              datetime not null  comment '',
   TotalCapacity        int not null  comment '',
   AvailTix             int not null  comment '',
   EventType            varchar(20) not null  comment '',
   primary key (EventID)
);

/*==============================================================*/
/* Table: Lecture                                               */
/*==============================================================*/
create table Lecture
(
   EventID              int not null  comment '',
   Speaker              varchar(100)  comment '',
   CreditHours          decimal(3,1)  comment '',
   primary key (EventID)
);

/*==============================================================*/
/* Table: Organizers                                            */
/*==============================================================*/
create table Organizers
(
   OrganizerId          int not null  comment '',
   OrgName              varchar(100) not null  comment '',
   ContactPerson        varchar(50)  comment '',
   ContactPhone         varchar(20)  comment '',
   primary key (OrganizerId)
);

/*==============================================================*/
/* Table: Performances                                          */
/*==============================================================*/
create table Performances
(
   EventID              int not null  comment '',
   Troupe               varchar(100)  comment '',
   isSeated             bool not null  comment '',
   primary key (EventID)
);

/*==============================================================*/
/* Table: Staff                                                 */
/*==============================================================*/
create table Staff
(
   UserID               int not null  comment '',
   employeeID           varchar(20) not null  comment '',
   Department           varchar(100) not null  comment '',
   primary key (UserID)
);

/*==============================================================*/
/* Table: Student                                               */
/*==============================================================*/
create table Student
(
   UserID               int not null  comment '',
   studentID            varchar(20) not null  comment '',
   college              varchar(100)  comment '',
   primary key (UserID)
);

/*==============================================================*/
/* Table: Ticket                                                */
/*==============================================================*/
create table Ticket
(
   OrderID              int not null  comment '',
   EventID              int not null  comment '',
   UserID               int not null  comment '',
   OrderTime            datetime  comment '',
   SeatNumber           varchar(20)  comment '',
   OrderStatus          varchar(20) not null  comment '',
   primary key (OrderID)
);

/*==============================================================*/
/* Table: User                                                  */
/*==============================================================*/
create table User
(
   UserID               int not null  comment '',
   UserName             varchar(50) not null  comment '',
   Phone                char(11) not null  comment '',
   PasswordHash         char(255) not null  comment '',
   UserType             varchar(20) not null  comment '',
   primary key (UserID)
);

/*==============================================================*/
/* Table: Venue                                                 */
/*==============================================================*/
create table Venue
(
   VenueID              int not null  comment '',
   Venuename            varchar(100) not null  comment '',
   Location             varchar(255)  comment '',
   MaxCapacity          int not null  comment '',
   primary key (VenueID)
);

alter table Event add constraint FK_EVENT_HOSTED_AT_VENUE foreign key (VenueID)
      references Venue (VenueID) on delete restrict on update restrict;

alter table Event add constraint FK_EVENT_ORGANIZE_ORGANIZE foreign key (OrganizerId)
      references Organizers (OrganizerId) on delete restrict on update restrict;

alter table Lecture add constraint FK_LECTURE_INHERITAN_EVENT foreign key (EventID)
      references Event (EventID) on delete restrict on update restrict;

alter table Performances add constraint FK_PERFORMA_INHERITAN_EVENT foreign key (EventID)
      references Event (EventID) on delete restrict on update restrict;

alter table Staff add constraint FK_STAFF_INHERITAN_USER foreign key (UserID)
      references User (UserID) on delete restrict on update restrict;

alter table Student add constraint FK_STUDENT_INHERITAN_USER foreign key (UserID)
      references User (UserID) on delete restrict on update restrict;

alter table Ticket add constraint FK_TICKET_BUY_USER foreign key (UserID)
      references User (UserID) on delete restrict on update restrict;

alter table Ticket add constraint FK_TICKET_SELL_EVENT foreign key (EventID)
      references Event (EventID) on delete restrict on update restrict;

