USE [VHCBSandbox]
GO


alter procedure [dbo].[GetVHCBUser]
as
begin
	select ui.userid,  (LNAME+', '+FNAME) as Name, ui.Username, ui.password, ui.email 
		from UserInfo ui(nolock)	where rowisactive = 1	
	 order by ui.Lname  
end

go

ALTER procedure [dbo].[GetUserSecurityGroup]
as
Begin
	select usergroupid, userGroupName  from UserSecurityGroup where rowisactive = 1
end
go

alter procedure AddUsersToSecurityGroup
(
	@userid int,
	@usergroupid int
)
as
Begin
	insert into UsersUserSecurityGroup (userid, usergroupid) 
		values (@userid, @usergroupid)
End
go

alter procedure GetUsersUserSecurityGroup
as
Begin

	select ui.userid,  (ui.LNAME+', '+ui.FNAME) as Name, usg.usergroupname, uus.usergroupid,uus.UsersUserSecurityGrpId
	from UserInfo ui join UsersUserSecurityGroup uus on uus.userid = ui.userid
	join UserSecurityGroup usg on uus.UserGroupId = usg.UserGroupId
	where ui.rowisactive = 1

end
go

create procedure DeleteUsersUserSecurityGroup
(
	@
)
as


select * from UsersUserSecurityGroup