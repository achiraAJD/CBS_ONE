SELECT ora_database_name from dual;
select * from ALL_USERS; -- List all users that are visible to the current user:
SELECT * FROM user_users; -- Show the information of the current user:
SELECT sys_context('USERENV','SERVER_HOST') from dual; -- to get the host name/server name
SELECT  sys_context('userenv', 'SID') FROM DUAL; -- to get the sid number
select * from V$SERVICES;
select * from 