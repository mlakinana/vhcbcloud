

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

alter procedure DeleteUsersUserSecurityGroup
(
	@UsersUserSecurityGrpId int
)
as
Begin
	Delete from UsersUserSecurityGroup where UsersUserSecurityGrpId = @UsersUserSecurityGrpId
End
go


alter procedure GetPageSecurityBySelection
(
	@recordId int
)
as
Begin
	select typeid, description from lookupvalues 
	where lookuptype = @recordid
End
go

alter procedure AddUserPageSecurity
(
	@userid int,
	@pageid int,
	@fieldid int,
	@actionid int
)
as 
Begin
	insert into UserPageSecurity(userid,pageid,fieldid,actionid)
	values (@userid, @pageid, @fieldid, @actionid)
end
go

alter procedure GetuserPageSecurity
(
	@userid int
)
as
Begin
	select ui.userid,  (ui.LNAME+', '+ui.FNAME) as username, ups.pagesecurityid,
	case when lv.lookuptype = 193 then lv.Description else '' end 'PageDescription',
	case when lv.lookuptype = 194 then lv.Description else '' end 'FieldDescription',
	case when lv.lookuptype = 195 then lv.Description else '' end 'ActionDescription'
	from UserInfo ui join UserPageSecurity ups on ups.Userid = ui.UserId
	left join LookupValues lv on lv.lookuptype in (193, 194, 195)
End
go

alter procedure DeletePageSecurity
(
	@pagesecurityid int
)
as
Begin
	Delete from UserPageSecurity where pagesecurityid = @pagesecurityid
End