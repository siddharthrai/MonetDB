-- A simple heartbeat continuous query.
set schema iot;
set optimizer='iot_pipe';

create table log(t timestamp,b integer);

create procedure cqlogger()
begin
	insert into log values(now(), iot.getheartbeat('iot','cqlogger'));
end;

call iot.query('iot','cqlogger');
call iot.heartbeat('iot','log',1000);

-- wait for 2 cycles in the scheduler
call iot.wait(2);

select 'RESULT';
select * from log;

select * from iot.errors();
call iot.stop();
drop procedure cqlogger;
drop table log;
