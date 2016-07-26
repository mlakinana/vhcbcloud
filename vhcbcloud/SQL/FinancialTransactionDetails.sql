alter procedure getCommittedProjectslist  
as
begin

	select distinct p.projectid, proj_num, max(rtrim(ltrim(lpn.description))) description,  convert(varchar(25), p.projectid) +'|' + max(rtrim(ltrim(lpn.description))) as project_id_name
	,round(sum(tr.TransAmt),2) as availFund
	from project p(nolock)
	join projectname pn(nolock) on p.projectid = pn.projectid
	join lookupvalues lpn on lpn.typeid = pn.lkprojectname
	join trans tr on tr.projectid = p.projectid
	where tr.lkstatus = 262--and tr.LkTransaction = 238	
	and tr.RowIsActive=1 and pn.defname=1
	and p.ProjectId not in (select distinct p.projectid 
							from project p(nolock)
							join projectname pn(nolock) on p.projectid = pn.projectid	
							join trans tr on tr.projectid = p.projectid
							where tr.lkstatus = 261
							and tr.RowIsActive=1 and pn.defname=1)
	group by p.projectid, proj_num
	order by proj_num 
end
go

alter procedure getCommittedPendingProjectslist  
as
begin

	select distinct p.projectid, proj_num, max(rtrim(ltrim(lpn.description))) description,  convert(varchar(25), p.projectid) +'|' + max(rtrim(ltrim(lpn.description))) as project_id_name
	,round(sum(tr.TransAmt),2) as availFund
	from project p(nolock)
	join projectname pn(nolock) on p.projectid = pn.projectid
	join lookupvalues lpn on lpn.typeid = pn.lkprojectname
	join trans tr on tr.projectid = p.projectid
	where defname = 1 and tr.lkstatus = 261
	and tr.RowIsActive=1 and pn.defname=1
	group by p.projectid, proj_num
	order by proj_num 
end
go


alter procedure GetReallocationFinancialFundDetailsByProjectId
(
	@projectid int,
	@isReallocation bit
)
as
begin
	
	declare @temp table 
	(
		transid int,
		ProjId int
	)

	insert into @temp (transid, ProjId)
	select FromTransID, ToProjectId from ReallocateLink where FromProjectId = @projectid
	insert into @temp (transid, ProjId)
	select ToTransID, ToProjectId from ReallocateLink  where FromProjectId = @projectid

	declare @tempFundCommit table (
	[projectid] [int] NULL,
	[fundid] [int] NULL,
	account nvarchar (10) null,
	[lktranstype] [int] NULL,
	[FundType] [nvarchar](50) NULL,
	[FundName] nvarchar(35) null,
	[Projnum] [nvarchar](12) NULL,
	[ProjectName] [nvarchar](80) NULL,	
	[ProjectCheckReqID] [int] NULL,
	[FundAbbrv] [nvarchar](25) NULL,
	[commitmentamount] [money] NULL,
	[lkstatus] varchar(20) null,
	pendingamount money null ,
	[Date] [date] NULL	
	)
	
	declare @tempfundExpend table (
	[projectid] [int] NULL,
	[fundid] [int] NULL,
	account nvarchar (10) null,
	[lktranstype] [int] NULL,
	[FundType] [nvarchar](50) NULL,
	[FundName] nvarchar(35) null,
	[Projnum] [nvarchar](12) NULL,
	[ProjectName] [nvarchar](80) NULL,	
	[ProjectCheckReqID] [int] NULL,
	[FundAbbrv] [nvarchar](25) NULL,
	[expendedamount] [money] NULL default 0,
	pendingamount money null ,
	[lkstatus] varchar(20) null,
	[Date] [date] NULL	
	)

	insert into @tempFundCommit (projectid, fundid, account, lktranstype, FundType, FundName, Projnum, ProjectName, ProjectCheckReqID, 
	FundAbbrv, commitmentamount, lkstatus, pendingamount ,[Date])
	select  p.projectid, 
			det.FundId, 
			f.account,
			det.lktranstype, 
			ttv.description as FundType,
			f.name,
			p.proj_num, 
			lv.Description as projectname, 			
			tr.ProjectCheckReqID,
			f.abbrv,
			sum(det.Amount) as CommitmentAmount, 
			case 
				when tr.lkstatus = 261 then 'Pending'
				when tr.lkstatus = 262 then 'Final'
			 end as lkStatus, 
			 case
				when tr.lkstatus = 261 then sum(det.amount)
			 end as PendingAmount,
			 max(tr.date) as TransDate
			from Project p 
	join ProjectName pn on pn.ProjectID = p.ProjectId	
	join LookupValues lv on lv.TypeID = pn.LkProjectname	
	join Trans tr on tr.ProjectID = p.ProjectId
	join Detail det on det.TransId = tr.TransId	
	join fund f on f.FundId = det.FundId
	left join ReallocateLink(nolock) on fromProjectId = p.ProjectId
	left join LkTransType_v ttv(nolock) on det.lktranstype = ttv.typeid
	where tr.LkTransaction in (238,239,240) --and  tr.TransId in(select distinct transid from @temp)
	and tr.RowIsActive=1 and pn.DefName =1 and det.rowisactive = 1
	group by det.FundId, det.LkTransType ,  p.ProjectId, p.Proj_num, lv.Description,  ProjectCheckReqID, f.name, 
	f.abbrv, tr.lkstatus, ttv.description, f.account
	order by p.Proj_num

	insert into @tempfundExpend (projectid, fundid, account, lktranstype, FundType, FundName, Projnum, ProjectName, ProjectCheckReqID, FundAbbrv, expendedamount,lkstatus, pendingamount, [Date])
	select  p.projectid, det.FundId, f.account,det.lktranstype, 
			ttv.description as FundType,
			f.name,
			p.proj_num, lv.Description as projectname, tr.ProjectCheckReqID,
			 f.abbrv,sum(det.Amount) as CommitmentAmount, 
			 case 
				when tr.lkstatus = 261 then 'Pending'
				when tr.lkstatus = 262 then 'Final'
			 end as lkStatus,
			 case
				when tr.lkstatus = 261 then sum(det.amount)
			 end as PendingAmount,
			 max(tr.date) as TransDate
			from Project p 
	join ProjectName pn on pn.ProjectID = p.ProjectId	
	join LookupValues lv on lv.TypeID = pn.LkProjectname	
	join Trans tr on tr.ProjectID = p.ProjectId
	join Detail det on det.TransId = tr.TransId	
	join fund f on f.FundId = det.FundId
	left join LkTransType_v ttv(nolock) on det.lktranstype = ttv.typeid
	where tr.LkTransaction in (236, 237)  and  tr.TransId in(select distinct transid from @temp)
	and tr.RowIsActive=1 and pn.DefName =1 and det.rowisactive = 1
	group by det.FundId, det.LkTransType ,  p.ProjectId, p.Proj_num, lv.Description, tr.ProjectCheckReqID, f.name,
	f.abbrv,f.account, tr.lkstatus, ttv.description
	order by p.Proj_num


	select  tc.projectid, tc.fundid, tc.account, tc.lktranstype,tc.FundType, tc.FundName, tc.FundAbbrv, tc.Projnum, tc.ProjectName, 
		   tc.ProjectCheckReqID, tc.commitmentamount, ISNULL( te.expendedamount,0) as expendedamount, (tc.commitmentamount - (ISNULL( te.expendedamount, 0))) as balance,
		   isnull(tc.pendingamount, 0) as pendingamount, tc.lkstatus, tc.Date 
	from @tempFundCommit tc 
	left outer join @tempfundExpend te on tc.projectid = te.projectid 
			and tc.fundid = te.fundid 
			and tc.lktranstype = te.lktranstype
	
	select  p.projectid, 
				det.FundId,
				f.account, 
				det.lktranstype, 
				--case
				--	when det.lktranstype = 241 then 'Grant'
				--	when det.lktranstype = 242 then 'Loan' 
				--	when det.lktranstype = 243 then 'Contract'
				--	else convert(varchar(5), det.lktranstype)
				
				--end as FundType, 
				ttv.description as FundType,
				case 
					when tr.LkTransaction = 236 then 'Cash Disbursement'
					when tr.LkTransaction = 237 then 'Cash Refund'
					when tr.LkTransaction = 238 then 'Board Commitment'
					when tr.LkTransaction = 239 then 'Board Decommitment'
					when tr.LkTransaction = 240 then 'Board Reallocation'
				end as 'Transaction',
				f.name,
				p.proj_num, 
				lv.Description as projectname, 				
				tr.ProjectCheckReqID,
				f.abbrv,
				det.Amount as detail, 
				case 
					when tr.lkstatus = 261 then 'Pending'
					when tr.lkstatus = 262 then 'Final'
				 end as lkStatus, 			 
				tr.date as TransDate
				from Project p 
		join ProjectName pn on pn.ProjectID = p.ProjectId		
		join LookupValues lv on lv.TypeID = pn.LkProjectname	
		join Trans tr on tr.ProjectID = p.ProjectId
		join Detail det on det.TransId = tr.TransId	
		join fund f on f.FundId = det.FundId and det.rowisactive = 1
		left join LkTransType_v ttv(nolock) on det.lktranstype = ttv.typeid
		where tr.LkTransaction in (238,239,240, 236, 237) and pn.DefName =1 
		and tr.RowIsActive=1 and det.RowIsActive=1 and p.projectid = @projectid
		order by p.Proj_num

end
go

alter procedure [dbo].[GetFinancialFundDetailsByProjectId]
(
	@projectid int,
	@isReallocation bit
)
as
Begin
	--exec GetFinancialFundDetailsByProjectId 6624, 0

	if(@isReallocation = 0)
	begin
		declare @tempFundCommit table (
		[projectid] [int] NULL,
		[fundid] [int] NULL,
		account nvarchar (10)null,
		[lktranstype] [int] NULL,
		[FundType] [nvarchar](50) NULL,
		[FundName] nvarchar(35) null,
		[Projnum] [nvarchar](12) NULL,
		[ProjectName] [nvarchar](80) NULL,
		[ProjectCheckReqID] [int] NULL,
		[FundAbbrv] [nvarchar](25) NULL,
		[commitmentamount] [money] NULL,
		[lkstatus] varchar(20) null,
		pendingamount money null ,
		[Date] [date] NULL	
		)
	
		declare @tempfundExpend table (
		[projectid] [int] NULL,
		[fundid] [int] NULL,
		account nvarchar (10) null,
		[lktranstype] [int] NULL,
		[FundType] [nvarchar](50) NULL,
		[FundName] nvarchar(35) null,
		[Projnum] [nvarchar](12) NULL,
		[ProjectName] [nvarchar](80) NULL,
		[ProjectCheckReqID] [int] NULL,
		[FundAbbrv] [nvarchar](25) NULL,
		[expendedamount] [money] NULL default 0,
		pendingamount money null ,
		[lkstatus] varchar(20) null,
		[Date] [date] NULL	
		)

		insert into @tempFundCommit (projectid, fundid, account, lktranstype, FundType, FundName, Projnum, ProjectName, ProjectCheckReqID, 
		FundAbbrv, commitmentamount, lkstatus, pendingamount ,[Date])
	
		select   p.projectid, 
			det.FundId,
			f.account, 
			det.lktranstype, 
	
			ttv.description as FundType,
			f.name,
			p.proj_num, 
			lv.Description as projectname, 
			tr.ProjectCheckReqID,
			f.abbrv,det.amount as CommitmentAmount, 
			case 
				when tr.lkstatus = 261 then 'Pending'
				when tr.lkstatus = 262 then 'Final'
				end as lkStatus,
			case
				when tr.lkstatus = 261 then det.amount
				end as PendingAmount,
				max(tr.date) as TransDate
			from Project p 
	join ProjectName pn on pn.ProjectID = p.ProjectId		
	join LookupValues lv on lv.TypeID = pn.LkProjectname	
	join Trans tr on tr.ProjectID = p.ProjectId
	join Detail det on det.TransId = tr.TransId	
	join fund f on f.FundId = det.FundId
	left join ReallocateLink(nolock) on fromProjectId = p.ProjectId
	left join LkTransType_v ttv(nolock) on det.lktranstype = ttv.typeid
	where tr.LkTransaction in (238,239,240) and tr.ProjectID = @projectid and
	tr.RowIsActive=1 and pn.DefName =1 and det.rowisactive = 1
	group by det.FundId, det.LkTransType ,  p.ProjectId, p.Proj_num, lv.Description, ProjectCheckReqID, f.name, 
	f.abbrv, tr.lkstatus, ttv.description, f.account, det.Amount
	order by p.Proj_num


		insert into @tempfundExpend (projectid, fundid, account, lktranstype, FundType, FundName, Projnum, ProjectName, ProjectCheckReqID, FundAbbrv, expendedamount,lkstatus, pendingamount, [Date])
	
		select  p.projectid, det.FundId, f.account, det.lktranstype, 
				--case
				--	when det.lktranstype = 241 then 'Grant'
				--	when det.lktranstype = 242 then 'Loan' 
				--	when det.lktranstype = 243 then 'Contract'
				--end as FundType, 
				ttv.description as FundType,
				f.name,
				p.proj_num, lv.Description as projectname, tr.ProjectCheckReqID,
				 f.abbrv,sum(det.Amount) as CommitmentAmount, 
				 case 
					when tr.lkstatus = 261 then 'Pending'
					when tr.lkstatus = 262 then 'Final'
				 end as lkStatus,
				 case
					when tr.lkstatus = 261 then sum(det.amount)
				 end as PendingAmount,
				 max(tr.date) as TransDate
				from Project p 
		join ProjectName pn on pn.ProjectID = p.ProjectId		
		join LookupValues lv on lv.TypeID = pn.LkProjectname	
		join Trans tr on tr.ProjectID = p.ProjectId
		join Detail det on det.TransId = tr.TransId	
		join fund f on f.FundId = det.FundId
		left join LkTransType_v ttv(nolock) on det.lktranstype = ttv.typeid
		where tr.LkTransaction in (236, 237) 
		and tr.RowIsActive=1 and pn.DefName =1 and det.rowisactive = 1
		group by det.FundId, det.LkTransType ,  p.ProjectId, p.Proj_num, lv.Description, tr.ProjectCheckReqID, f.name,
		f.abbrv, tr.lkstatus, ttv.description, f.account
		order by p.Proj_num
	
		select tc.projectid, tc.fundid,tc.account, tc.lktranstype,tc.FundType, tc.FundName, tc.FundAbbrv, tc.Projnum, tc.ProjectName, 
			   tc.ProjectCheckReqID, tc.commitmentamount, ISNULL( te.expendedamount,0) as expendedamount, (tc.commitmentamount - (ISNULL( te.expendedamount, 0))) as balance,
			   isnull(tc.pendingamount, 0) as pendingamount, tc.lkstatus, tc.Date 
		from @tempFundCommit tc 
		left outer join @tempfundExpend te on tc.projectid = te.projectid 
				and tc.fundid = te.fundid 
				and tc.lktranstype = te.lktranstype
		where tc.projectid = @projectid

		select  p.projectid, 
				det.FundId, f.account,
				det.lktranstype, 
				--case
				--	when det.lktranstype = 241 then 'Grant'
				--	when det.lktranstype = 242 then 'Loan' 
				--	when det.lktranstype = 243 then 'Contract'
				--	else convert(varchar(5), det.lktranstype)
				
				--end as FundType, 
				ttv.description as FundType,
				case 
					when tr.LkTransaction = 236 then 'Cash Disbursement'
					when tr.LkTransaction = 237 then 'Cash Refund'
					when tr.LkTransaction = 238 then 'Board Commitment'
					when tr.LkTransaction = 239 then 'Board Decommitment'
					when tr.LkTransaction = 240 then 'Board Reallocation'
				end as 'Transaction',
				f.name,
				p.proj_num, 
				lv.Description as projectname,				
				tr.ProjectCheckReqID,
				f.abbrv,
				det.Amount as detail, 
				case 
					when tr.lkstatus = 261 then 'Pending'
					when tr.lkstatus = 262 then 'Final'
				 end as lkStatus, 			 
				tr.date as TransDate
				from Project p 
		join ProjectName pn on pn.ProjectID = p.ProjectId		
		join LookupValues lv on lv.TypeID = pn.LkProjectname	
		join Trans tr on tr.ProjectID = p.ProjectId
		join Detail det on det.TransId = tr.TransId	
		join fund f on f.FundId = det.FundId
		left join LkTransType_v ttv(nolock) on det.lktranstype = ttv.typeid
		where tr.LkTransaction in (238,239,240, 236, 237)and pn.DefName =1 
		and tr.RowIsActive=1 and det.RowIsActive=1 and p.projectid = @projectid
		order by p.Proj_num
	end
	else
	begin
		exec  [dbo].[GetReallocationFinancialFundDetailsByProjectId] @projectid, @isReallocation
	end
End

go

alter procedure [dbo].[GetCommittedFundDetailsByFundId]
(
	@projectid int,
	@fundId int
)
as
Begin
	select p.projectid, det.FundId, det.lktranstype, ttv.description as FundType,
				f.name, f.account, p.proj_num, lv.Description as projectname, 
				tr.ProjectCheckReqID, f.abbrv,
				sum(det.Amount) as CommitmentAmount, 
				case 
					when tr.lkstatus = 261 then 'Pending'
					when tr.lkstatus = 262 then 'Final'
				 end as lkStatus, 
				 case
					when tr.lkstatus = 261 then sum(det.amount)
				 end as PendingAmount,
				 max(tr.date) as TransDate from Project p 
		join ProjectName pn on pn.ProjectID = p.ProjectId
		join LookupValues lv on lv.TypeID = pn.LkProjectname	
		join Trans tr on tr.ProjectID = p.ProjectId
		join Detail det on det.TransId = tr.TransId	
		join fund f on f.FundId = det.FundId
		left join ReallocateLink(nolock) on fromProjectId = p.ProjectId
		left join LkTransType_v ttv(nolock) on det.lktranstype = ttv.typeid
		where tr.LkTransaction in (236,237,238,239,240)
		and  f.RowIsActive=1 and p.ProjectId = @projectid
		and tr.RowIsActive=1 and pn.DefName =1 and det.rowisactive = 1
		group by  det.FundId, det.LkTransType ,  p.ProjectId, p.Proj_num, lv.Description,  ProjectCheckReqID, f.name, 
		f.abbrv, tr.lkstatus, ttv.description, f.account
		order by f.name

End

go

alter procedure [dbo].[GetCommittedFundAccounts]
(
	@projectid int
)
as
Begin
		select distinct  det.FundId, f.name , f.account, --ttv.description as FundType, lv.Description as projectname,tr.ProjectCheckReqID,det.lktranstype, 
				 p.proj_num, p.projectid,  f.abbrv
				from Project p 
		join ProjectName pn on pn.ProjectID = p.ProjectId
		join LookupValues lv on lv.TypeID = pn.LkProjectname	
		join Trans tr on tr.ProjectID = p.ProjectId
		join Detail det on det.TransId = tr.TransId	
		join fund f on f.FundId = det.FundId
		left join ReallocateLink(nolock) on fromProjectId = p.ProjectId
		left join LkTransType_v ttv(nolock) on det.lktranstype = ttv.typeid
		where p.projectid = @projectid and f.RowIsActive = 1
			and tr.RowIsActive=1 and pn.DefName =1 
		order by f.account
End

go

alter procedure [dbo].[GetCommittedFundNames]
(
	@projectid int
)
as
Begin
	select distinct  det.FundId, f.name , f.account, --ttv.description as FundType, lv.Description as projectname,tr.ProjectCheckReqID,det.lktranstype, 
				 p.proj_num, p.projectid,  f.abbrv
				from Project p 
		join ProjectName pn on pn.ProjectID = p.ProjectId
		join LookupValues lv on lv.TypeID = pn.LkProjectname	
		join Trans tr on tr.ProjectID = p.ProjectId
		join Detail det on det.TransId = tr.TransId	
		join fund f on f.FundId = det.FundId
		left join ReallocateLink(nolock) on fromProjectId = p.ProjectId
		left join LkTransType_v ttv(nolock) on det.lktranstype = ttv.typeid
		where p.projectid = @projectid and f.RowIsActive = 1
			and tr.RowIsActive=1 and pn.DefName =1 
		order by f.name
End

go


alter procedure [dbo].[GetCommittedCRFundAccounts]
(
	@projectid int
)
as
Begin
		select distinct  det.FundId, f.name , f.account, --ttv.description as FundType, lv.Description as projectname,tr.ProjectCheckReqID,det.lktranstype, 
				 p.proj_num, p.projectid,  f.abbrv
				from Project p 
		join ProjectName pn on pn.ProjectID = p.ProjectId
		join LookupValues lv on lv.TypeID = pn.LkProjectname	
		join Trans tr on tr.ProjectID = p.ProjectId
		join Detail det on det.TransId = tr.TransId	
		join fund f on f.FundId = det.FundId
		left join ReallocateLink(nolock) on fromProjectId = p.ProjectId
		left join LkTransType_v ttv(nolock) on det.lktranstype = ttv.typeid
		where p.projectid = @projectid and f.RowIsActive = 1
			and tr.RowIsActive=1 and pn.DefName =1 and tr.LkTransaction = 236
		order by f.account
End

go

alter procedure [dbo].[GetCommittedCRFundNames]
(
	@projectid int
)
as
Begin
		select distinct  det.FundId, f.name , f.account, --ttv.description as FundType, lv.Description as projectname,tr.ProjectCheckReqID,det.lktranstype, 
				 p.proj_num, p.projectid,  f.abbrv
				from Project p 
		join ProjectName pn on pn.ProjectID = p.ProjectId
		join LookupValues lv on lv.TypeID = pn.LkProjectname	
		join Trans tr on tr.ProjectID = p.ProjectId
		join Detail det on det.TransId = tr.TransId	
		join fund f on f.FundId = det.FundId
		left join ReallocateLink(nolock) on fromProjectId = p.ProjectId
		left join LkTransType_v ttv(nolock) on det.lktranstype = ttv.typeid
		where p.projectid = @projectid and f.RowIsActive = 1
			and tr.RowIsActive=1 and pn.DefName =1 and tr.LkTransaction = 236
		order by f.name
End

go

alter procedure GetFinancialTransByTransId
(
	@transId int,
	@activeOnly int
)
as
Begin

	if  (@activeOnly=1)
	Begin
		select tr.TransId, p.projectid, p.Proj_num, tr.Date, format(tr.TransAmt, 'N2') as TransAmt, tr.LkStatus, lv.description, tr.PayeeApplicant, tr.LkTransaction from Project p 		
			join Trans tr on tr.ProjectID = p.ProjectId				
			join LookupValues lv on lv.TypeID = tr.LkStatus
		Where  tr.RowIsActive= @activeOnly 	and tr.TransId = @transId and lv.TypeID= 261
	end
	else
	Begin
		select tr.TransId, p.projectid, p.Proj_num, tr.Date, format(tr.TransAmt, 'N2') as TransAmt, tr.LkStatus, lv.description, tr.PayeeApplicant, tr.LkTransaction from Project p 		
			join Trans tr on tr.ProjectID = p.ProjectId			
			join LookupValues lv on lv.TypeID = tr.LkStatus
		Where  tr.TransId = @transId and lv.TypeID= 261
	End
end

go

alter procedure GetFinancialTransByProjId
(
	@projId int,
	@activeOnly int,
	@transType int
)
as
Begin
-- exec GetFinancialTransByProjId 6622, 1
	if  (@activeOnly=1)
	Begin
		select tr.TransId, p.projectid, p.Proj_num, tr.Date, format(tr.TransAmt, 'N2') as TransAmt, tr.LkStatus, lv.description, tr.PayeeApplicant, tr.LkTransaction from Project p 		
			join Trans tr on tr.ProjectID = p.ProjectId				
			join LookupValues lv on lv.TypeID = tr.LkStatus
		Where  tr.RowIsActive= @activeOnly 	and tr.ProjectID = @projId and lv.TypeID= 261 and tr.LkTransaction = @transType
		order by tr.date desc
	end
	else
	Begin
		select tr.TransId, p.projectid, p.Proj_num, tr.Date, format(tr.TransAmt, 'N2') as TransAmt, tr.LkStatus, lv.TypeID ,lv.description, tr.PayeeApplicant, tr.LkTransaction from Project p 		
			join Trans tr on tr.ProjectID = p.ProjectId			
			join LookupValues lv on lv.TypeID = tr.LkStatus
		Where  tr.ProjectID = @projId and lv.TypeID= 261 and tr.LkTransaction = @transType
		order by tr.date desc
	End
end

go


alter procedure ActivateFinancialTransByTransId
(
	@transId int
)
as
begin transaction

	begin try

	update Trans set RowIsActive=1 Where TransId = @transId; 
	update detail set RowIsActive=1 Where TransId = @transId; 

end try
	begin catch
		if @@trancount > 0
		rollback transaction;

		DECLARE @msg nvarchar(4000) = error_message()
      RAISERROR (@msg, 16, 1)
		return 1  
	end catch

	if @@trancount > 0
		commit transaction;
go
				
alter procedure InactivateFinancialTransByTransId
(
	@transId int
)
as
begin transaction

	begin try

	update Trans set RowIsActive=0 Where TransId = @transId; 
	update detail set RowIsActive=0 Where TransId = @transId; 

end try
	begin catch
		if @@trancount > 0
		rollback transaction;

		DECLARE @msg nvarchar(4000) = error_message()
      RAISERROR (@msg, 16, 1)
		return 1  
	end catch

	if @@trancount > 0
		commit transaction;
go

alter procedure [dbo].[GetCommitmentFundDetailsByProjectId]
(	
	@transId int,
	@commitmentType int,
	@activeOnly int
)
as
Begin
-- exec dbo.GetCommitmentFundDetailsByProjectId 409, 239,1
if @activeOnly = 1
	Begin
	if @commitmentType = 238
		Begin
			Select t.projectid, d.detailid, f.FundId, f.account, f.name, format(d.Amount, 'N2') as amount, lv.Description, 
				d.LkTransType, t.LkTransaction, t.TransId
			from Fund f 
				join Detail d on d.FundId = f.FundId
				join Trans t on t.TransId = d.TransId
				join LookupValues lv on lv.TypeID = d.LkTransType
			Where     f.RowIsActive=1 and d.RowIsActive=1 and t.LkTransaction = @commitmentType
			and t.TransId = @transId and t.RowIsActive=1 
		end
	Else if (@commitmentType = 239 or @commitmentType = 237) -- Decommitment or Cash refund
		Begin
			Select t.projectid, d.detailid, f.FundId, f.account, f.name, format(-d.Amount, 'N2') as amount, lv.Description, 
				d.LkTransType, t.LkTransaction, t.TransId 
			from Fund f 
				join Detail d on d.FundId = f.FundId
				join Trans t on t.TransId = d.TransId
				join LookupValues lv on lv.TypeID = d.LkTransType
			Where     f.RowIsActive=1 and d.RowIsActive=1 and t.LkTransaction = @commitmentType
			and t.TransId = @transId and t.RowIsActive=1 
		End
	End
else
	Begin
	if @commitmentType = 238
		Begin
			Select t.projectid, d.detailid, f.FundId, f.account, f.name, format(d.Amount, 'N2') as amount, lv.Description, 
				d.LkTransType, t.LkTransaction  
			from Fund f 
				join Detail d on d.FundId = f.FundId
				join Trans t on t.TransId = d.TransId
				join LookupValues lv on lv.TypeID = d.LkTransType
			Where     f.RowIsActive=1 and t.LkTransaction = @commitmentType
			and t.TransId = @transId 
		end
	Else if (@commitmentType = 239 or @commitmentType = 237) -- Decommitment or Cash refund
		Begin
			Select t.projectid, d.detailid, f.FundId, f.account, f.name, format(-d.Amount, 'N2') as amount, lv.Description, 
				d.LkTransType, t.LkTransaction  
			from Fund f 
				join Detail d on d.FundId = f.FundId
				join Trans t on t.TransId = d.TransId
				join LookupValues lv on lv.TypeID = d.LkTransType
			Where     f.RowIsActive=1 and t.LkTransaction = @commitmentType
			and t.TransId = @transId 
		End
	End
End
go

alter procedure InactivateFinancialDetailByDetailId
(
	@detailId int
)
as
begin transaction

	begin try
	
	update detail set RowIsActive=0 Where DetailID = @detailId 

end try
	begin catch
		if @@trancount > 0
		rollback transaction;

		DECLARE @msg nvarchar(4000) = error_message()
      RAISERROR (@msg, 16, 1)
		return 1  
	end catch

	if @@trancount > 0
		commit transaction;
go

alter procedure GetGranteeByProject
(
	@projectId int
)
as
Begin
	select p.projectid, 
		p.Proj_num, lv.Description, a.applicantid, an.Applicantname from Project p 
		join ProjectName pn on pn.ProjectID = p.ProjectId
		join ProjectApplicant pa on pa.ProjectId = p.ProjectID	
		join Applicant a on a.ApplicantId = pa.ApplicantId	
		join ApplicantAppName aan on aan.ApplicantID = pa.ApplicantId
		join AppName an on an.AppNameID = aan.AppNameID 
		join LookupValues lv on lv.TypeID = pa.LkApplicantRole		
	Where  pa.finlegal=1 and p.ProjectId = @projectId
	and pn.defname = 1 and lv.typeid = 358
End

go

alter procedure [dbo].[AddBoardFinancialTransaction]
(
	@projectId int,
	@transDate datetime,
	@transAmt money,
	@payeeApplicant int = null,
	@commitmentType varchar(50),
	@lkStatus int
)
as
Begin
	declare @recordId int
	declare @transTypeId int

	select @recordId = RecordID from LkLookups where Tablename = 'LkTransAction'
	select @transTypeId = TypeID from LookupValues where LookupType = @recordId and Description = @commitmentType
	
	insert into Trans (ProjectID, date, TransAmt, PayeeApplicant, LkTransaction, LkStatus)
		values (@projectId, @transDate, @transAmt, @payeeApplicant, @transTypeId, @lkStatus)

	select tr.TransId, p.projectid, p.Proj_num, tr.Date, format(tr.TransAmt, 'N2') as TransAmt, tr.LkStatus, lv.description, tr.PayeeApplicant, tr.LkTransaction from Project p 		
		join Trans tr on tr.ProjectID = p.ProjectId	
		join LookupValues lv on lv.TypeID = tr.LkStatus
	Where  tr.RowIsActive=1 	and tr.TransId = @@IDENTITY; 

end
go

alter procedure [dbo].[updateLookups]
(
	@typeId int,
	@description varchar(50),
	@lookupTypeid int,	
	@isActive bit
)
as
--exec updatelookups 97, 'Prime soils', 272, 1
begin transaction

	begin try
		update LookupValues set Description = @description, RowIsActive=@isActive where TypeID = @typeId;
		--update LkLookups set  RowIsActive=@isActive where RecordID = @lookupTypeid;
	end try
	begin catch
		if @@trancount > 0
		rollback transaction;

		DECLARE @msg nvarchar(4000) = error_message()
      RAISERROR (@msg, 16, 1)
		return 1  
	end catch

	if @@trancount > 0
		commit transaction;
go

alter procedure [dbo].[GetLkLookupDetails]
 @recordId int
as
begin
	if (@recordId = 0)
	begin
		select lv.TypeID, lk.RecordID, lk.Tablename, lk.Viewname, lk.lkDescription, lv.Description, lk.Standard, lv.RowIsActive
		from LkLookups lk join LookupValues lv on lv.LookupType = lk.RecordID	
		order by lk.Viewname asc, lv.Description asc
	end
	else
	Begin
		select lv.TypeID, lk.RecordID, lk.Tablename, lk.Viewname, lk.lkDescription, lv.Description, lk.Standard, lv.RowIsActive
		from LkLookups lk join LookupValues lv on lv.LookupType = lk.RecordID	
		where lk.RecordID = @recordId
		order by   lv.Description asc
	end
end

go

alter procedure IsDuplicateFundDetailPerTransaction 
(
	@transid int,
	@fundid int,	
	@fundtranstype int

)
as
Begin
	select * from Detail where TransId = @transid and FundId = @fundid and LkTransType = @fundtranstype and RowIsActive = 1
End
go

alter procedure IsDuplicateFundDetail 
(
	@detailId int,
	@fundid int,	
	@fundtranstype int

)
as
Begin
	select * from Detail where FundId = @fundid and LkTransType = @fundtranstype and DetailID = @detailId
End
go

alter procedure GetFinancialTransactionDetailDetails
(
	@transId							int
	
)
as
--exec GetFinancialTransactionDetailDetails 1574

begin

	select   
		det.DetailID, det.FundId,fund.name, det.LkTransType, transtype.description, det.Amount
	from Trans trans(nolock)
		join detail det(nolock) on trans.TransId = det.TransId
		join fund fund(nolock) on det.fundid = fund.fundid
		join project_v p(nolock) on trans.Projectid = p.project_id
		join transtype_v transtype(nolock) on det.LKTransType = transtype.typeid
	where trans.TransId = @transId and  p.defname = 1 and trans.RowIsActive=1 and det.RowIsActive = 1
end
go

alter procedure GetFinancialTransactionDetails
(
	@project_id							int,
	@financial_transaction_action_id	int,
	@tran_start_date					datetime,
	@tran_end_date						datetime
	
)
as
--exec GetFinancialTransactionDetails 6622, 238, '05/01/2016', '05/16/2016' 
--exec GetFinancialTransactionDetails 5615, 239, '01/01/2016', '02/01/2016'--DeCommit
--exec GetFinancialTransactionDetails 5615, -1, '01/01/2016', '02/01/2016'--All
--exec GetFinancialTransactionDetails -1, -1, '01/01/2016', '02/07/2016'--All
begin

	select trans.TransId, pv.project_name ProjectName, pv.proj_num ProjectNumber, trans.Date as TransactionDate, trans.TransAmt, v.description as LkTransactionDesc--, trans.LkTransaction, v.*
	from Trans trans(nolock)
	left join project_v  pv(nolock) on pv.project_id = trans.ProjectID
	left join TransAction_v v(nolock) on v.typeid = trans.LkTransaction
	where trans.TransId in (
		select t.TransId from (
		select trans.TransId as TransId, trans.TransAmt,
				sum(det.Amount) amount, trans.TransAmt - sum(det.Amount) bal
			from Trans trans(nolock)
				join detail det(nolock) on trans.TransId = det.TransId
			where trans.Date >= @tran_start_date 
				and trans. Date <= @tran_end_date 
				and trans.LKStatus = 261
				and (trans.projectid = @project_id or (@project_id = -1 and trans.projectid is not null))
				and (trans.LkTransaction = @financial_transaction_action_id or (@financial_transaction_action_id = -1 and trans.LkTransaction is not null))
		group by trans.TransId, trans.TransAmt)t
		where t.bal = 0 and pv.defname = 1
	) order by pv.proj_num

	--select t.TransId from (
	--select trans.TransId as TransId, trans.TransAmt,
	--			sum(det.Amount) amount, trans.TransAmt - sum(det.Amount) bal
	--		from Trans trans(nolock)
	--			join detail det(nolock) on trans.TransId = det.TransId
	--		where trans.Date >= '01/01/2016' 
	--			and trans. Date <= '02/07/2016'  
	--			and trans.LKStatus = 261
	--			and trans.projectid is not null
	--			and trans.LkTransaction is not null
	--	group by trans.TransId, trans.TransAmt)t
	--	where t.bal = 0


end
go


alter procedure [dbo].[GetProjectsByFilter]
(
	@filter varchar(20)
)
as
Begin
	declare @recordId int
	select @recordId = RecordID from LkLookups where Tablename = 'LkProjectName' 	
	select	distinct			
			top 35 CONVERT(varchar(20), p.Proj_num) as proj_num
	from Project p 
			join ProjectName pn on p.ProjectId = pn.ProjectID
			join ProjectApplicant pa on pa.ProjectId = p.ProjectId
			join LookupValues lpn on lpn.TypeID = pn.LkProjectname
			join ApplicantAppName aan on aan.ApplicantId = pa.ApplicantId
			join AppName an on aan.AppNameID = an.appnameid
	where pn.DefName = 1 and lpn.LookupType = @recordId and p.Proj_num like @filter +'%'
	order by Proj_num asc
	--select top 20 proj_num from project p where p.Proj_num like @filter +'%'

end
go

alter procedure getCommittedProjectslistByFilter 
(
	@filter varchar(20)
) 
as
begin

	select distinct proj_num
	from project p(nolock)
	join projectname pn(nolock) on p.projectid = pn.projectid
	join lookupvalues lpn on lpn.typeid = pn.lkprojectname
	join trans tr on tr.projectid = p.projectid
	where defname = 1 and tr.lkstatus != 261--and tr.LkTransaction = 238
	and tr.RowIsActive=1 and pn.defname=1	and p.Proj_num like @filter +'%'	
	order by proj_num 
end
go

alter procedure getCommittedCashRefundProjectslistByFilter 
(
	@filter varchar(20)
) 
as
begin

	select distinct proj_num
	from project p(nolock)
	join projectname pn(nolock) on p.projectid = pn.projectid
	join lookupvalues lpn on lpn.typeid = pn.lkprojectname
	join trans tr on tr.projectid = p.projectid
	where defname = 1 and tr.lkstatus != 261 and tr.LkTransaction = 236
	and tr.RowIsActive=1 and pn.defname=1	and p.Proj_num like @filter +'%'	
	order by proj_num 
end
go

alter procedure getCommittedPendingProjectslistByFilter 
(
	@filter varchar(20)
)
as
begin

	select distinct  top 35 p.Proj_num
	from project p(nolock)
	join projectname pn(nolock) on p.projectid = pn.projectid
	join lookupvalues lpn on lpn.typeid = pn.lkprojectname
	join trans tr on tr.projectid = p.projectid
	where pn.defname = 1 and tr.lkstatus = 261 and tr.LkTransaction = 238
		and tr.RowIsActive=1 and p.Proj_num like @filter +'%'	
	order by p.proj_num 
end
go

alter procedure getCommittedPendingDecommitmentProjectslistByFilter 
(
	@filter varchar(20)
)
as
begin

	select distinct  top 35 p.Proj_num
	from project p(nolock)
	join projectname pn(nolock) on p.projectid = pn.projectid
	join lookupvalues lpn on lpn.typeid = pn.lkprojectname
	join trans tr on tr.projectid = p.projectid
	where pn.defname = 1 and tr.lkstatus = 261 and tr.LkTransaction = 239
		and tr.RowIsActive=1 and p.Proj_num like @filter +'%'	
	order by p.proj_num 
end
go

alter procedure getCommittedPendingReallocationProjectslistByFilter 
(
	@filter varchar(20)
)
as
begin

	select distinct  top 35 p.Proj_num
	from project p(nolock)
	join projectname pn(nolock) on p.projectid = pn.projectid
	join lookupvalues lpn on lpn.typeid = pn.lkprojectname
	join trans tr on tr.projectid = p.projectid
	where pn.defname = 1 and tr.lkstatus = 261 and tr.LkTransaction = 240
		and tr.RowIsActive=1 and p.Proj_num like @filter +'%'	
	order by p.proj_num 
end
go

alter procedure getCommittedPendingCashRefundProjectslistByFilter 
(
	@filter varchar(20)
)
as
begin

	select distinct  top 35 p.Proj_num
	from project p(nolock)
	join projectname pn(nolock) on p.projectid = pn.projectid
	join lookupvalues lpn on lpn.typeid = pn.lkprojectname
	join trans tr on tr.projectid = p.projectid
	where pn.defname = 1 and tr.lkstatus = 261 and tr.LkTransaction = 237
		and tr.RowIsActive=1 and p.Proj_num like @filter +'%'	
	order by p.proj_num 
end
go

alter procedure GetProjectIdByProjNum
(
	@filter varchar(20)
)
as
Begin
	select projectId from project where proj_num = @filter
End
go

alter procedure [dbo].[GetFundAccounts]
as
Begin
	select fundid, account, name from Fund 
	where  RowIsActive = 1 
	order by account asc
End
go


alter procedure [dbo].[GetFundNames]
as
Begin
	select fundid, account, name from Fund 
	where  RowIsActive = 1 
	order by name asc
End
go

alter procedure [dbo].[GetFinancialPendingTransactionFundDetails]
as
Begin
	
		declare @tempFundCommit table (
		[projectid] [int] NULL,
		[fundid] [int] NULL,
		account nvarchar (10)null,
		[lktranstype] [int] NULL,
		[FundType] [nvarchar](50) NULL,
		[FundName] nvarchar(35) null,
		[Projnum] [nvarchar](12) NULL,
		[ProjectName] [nvarchar](80) NULL,
		[ProjectCheckReqID] [int] NULL,
		[FundAbbrv] [nvarchar](25) NULL,
		[commitmentamount] [money] NULL,
		[lkstatus] varchar(20) null,
		pendingamount money null ,
		[Date] [date] NULL	
		)
	
		declare @tempfundExpend table (
		[projectid] [int] NULL,
		[fundid] [int] NULL,
		account nvarchar (10) null,
		[lktranstype] [int] NULL,
		[FundType] [nvarchar](50) NULL,
		[FundName] nvarchar(35) null,
		[Projnum] [nvarchar](12) NULL,
		[ProjectName] [nvarchar](80) NULL,
		[ProjectCheckReqID] [int] NULL,
		[FundAbbrv] [nvarchar](25) NULL,
		[expendedamount] [money] NULL default 0,
		pendingamount money null ,
		[lkstatus] varchar(20) null,
		[Date] [date] NULL	
		)

		insert into @tempFundCommit (projectid, fundid, account, lktranstype, FundType, FundName, Projnum, ProjectName, ProjectCheckReqID, 
		FundAbbrv, commitmentamount, lkstatus, pendingamount ,[Date])
	
		select  p.projectid, 
				det.FundId,
				f.account, 
				det.lktranstype,
				ttv.description as FundType,
				f.name,
				p.proj_num, 
				lv.Description as projectname, 
				tr.ProjectCheckReqID,
				f.abbrv,
				sum(det.Amount) as CommitmentAmount, 
				case 
					when tr.lkstatus = 261 then 'Pending'
					when tr.lkstatus = 262 then 'Final'
				 end as lkStatus, 
				 case
					when tr.lkstatus = 261 then sum(det.amount)
				 end as PendingAmount,
				 max(tr.date) as TransDate
				from Project p 
		join ProjectName pn on pn.ProjectID = p.ProjectId		
		join LookupValues lv on lv.TypeID = pn.LkProjectname	
		join Trans tr on tr.ProjectID = p.ProjectId
		join Detail det on det.TransId = tr.TransId	
		join fund f on f.FundId = det.FundId
		left join ReallocateLink(nolock) on fromProjectId = p.ProjectId
		left join LkTransType_v ttv(nolock) on det.lktranstype = ttv.typeid
		where tr.LkTransaction in (238,239,240) and
		tr.RowIsActive=1 and pn.DefName =1 and det.rowisactive = 1
		group by det.FundId, det.LkTransType ,  p.ProjectId, p.Proj_num, lv.Description, ProjectCheckReqID, f.name, 
		f.abbrv, tr.lkstatus, ttv.description, f.account
		order by p.Proj_num


		insert into @tempfundExpend (projectid, fundid, account, lktranstype, FundType, FundName, Projnum, ProjectName, ProjectCheckReqID, FundAbbrv, expendedamount,lkstatus, pendingamount, [Date])
	
		select  p.projectid, det.FundId, f.account, det.lktranstype, 
				--case
				--	when det.lktranstype = 241 then 'Grant'
				--	when det.lktranstype = 242 then 'Loan' 
				--	when det.lktranstype = 243 then 'Contract'
				--end as FundType, 
				ttv.description as FundType,
				f.name,
				p.proj_num, lv.Description as projectname, tr.ProjectCheckReqID,
				 f.abbrv,sum(det.Amount) as CommitmentAmount, 
				 case 
					when tr.lkstatus = 261 then 'Pending'
					when tr.lkstatus = 262 then 'Final'
				 end as lkStatus,
				 case
					when tr.lkstatus = 261 then sum(det.amount)
				 end as PendingAmount,
				 max(tr.date) as TransDate
				from Project p 
		join ProjectName pn on pn.ProjectID = p.ProjectId		
		join LookupValues lv on lv.TypeID = pn.LkProjectname	
		join Trans tr on tr.ProjectID = p.ProjectId
		join Detail det on det.TransId = tr.TransId	
		join fund f on f.FundId = det.FundId
		left join LkTransType_v ttv(nolock) on det.lktranstype = ttv.typeid
		where tr.LkTransaction in (236, 237) 
		and tr.RowIsActive=1 and pn.DefName =1 and det.rowisactive = 1
		group by det.FundId, det.LkTransType ,  p.ProjectId, p.Proj_num, lv.Description, tr.ProjectCheckReqID, f.name,
		f.abbrv, tr.lkstatus, ttv.description, f.account
		order by p.Proj_num
	
		select tc.projectid, tc.fundid,tc.account, tc.lktranstype,tc.FundType, tc.FundName, tc.FundAbbrv, tc.Projnum, tc.ProjectName, 
			   tc.ProjectCheckReqID, tc.commitmentamount, ISNULL( te.expendedamount,0) as expendedamount, (tc.commitmentamount - (ISNULL( te.expendedamount, 0))) as balance,
			   isnull(tc.pendingamount, 0) as pendingamount, tc.lkstatus, tc.Date 
		from @tempFundCommit tc 
		left outer join @tempfundExpend te on tc.projectid = te.projectid 
				and tc.fundid = te.fundid 
				and tc.lktranstype = te.lktranstype
		where tc.lkstatus='pending'
end
go

alter procedure GetLandUsePermit
as
 Begin
	select UsePermit, Act250FarmId from Act250Farm where RowIsActive=1
 end
go

alter procedure [dbo].[AddProjectFundDetails]
(	
	@transid int,
	@fundid int,	
	@fundtranstype int,
	@fundamount money
)
as

BEGIN 
	insert into Detail (TransId, FundId, LkTransType, Amount)	values
		(@transid,@fundid , @fundtranstype, @fundamount)
END 
go

alter procedure [dbo].AddProjectFundDetailsWithLandPermit
(	
	@transid int,
	@fundid int,	
	@fundtranstype int,
	@fundamount money,
	@LandUsePermit nvarchar(15)
)
as

BEGIN 
	insert into Detail (TransId, FundId, LkTransType, Amount, LandUsePermit)	values
		(@transid,@fundid , @fundtranstype, @fundamount, @LandUsePermit)
END 
go

alter procedure GetVHCBProgram
as
Begin
	select typeid, description from LookupValues 
	where lookuptype = 34 and RowIsActive = 1
end
go

alter procedure UpdateUserInfo
(
	@userid		int,
	@Fname		varchar(40), 
	@Lname		varchar(50), 
	@password	varchar(40), 
	@email		varchar(150),
	@DfltPrg	int
)
as
begin

	declare @Username	varchar(100)

	set @Username = lower(left(@Fname, 1) + @Lname)

	update UserInfo set Fname = @Fname, Lname = @Lname, Username = @Username, email = @email, password = @password, DfltPrg = @DfltPrg 
	where userid = @userid
	
end 
go

alter procedure AddUserInfo
(
	@Fname		varchar(40), 
	@Lname		varchar(50), 
	@password	varchar(40), 
	@email		varchar(150),
	@DfltPrg	int
)
as
begin

	declare @Username	varchar(100)

	set @Username = lower(left(@Fname, 1) + @Lname)

	insert into UserInfo(usergroupid, Fname, Lname, Username, password, email, DfltPrg) values 
			(0, @Fname, @Lname, @Username, @password, @email, @DfltPrg)
end
go

alter procedure GetUserInfo
as
begin
--exec GetUserInfo
	select ui.userid, ui.Fname, ui.Lname, ui.Username, ui.password, ui.email, lv.typeid, ui.DfltPrg, lv.description
		from UserInfo ui(nolock)
		left outer join LookupValues lv on lv.typeid = ui.DfltPrg
	 order by ui.DateModified desc 
end
go


alter view vw_FinancialDetailSummary
as
	select  p.projectid, 
				det.FundId, f.account,
				det.lktranstype, 
				ttv.typeid,				
				ttv.description as FundType,
				case 
					when tr.LkTransaction = 236 then 'Cash Disbursement'
					when tr.LkTransaction = 237 then 'Cash Refund'
					when tr.LkTransaction = 238 then 'Board Commitment'
					when tr.LkTransaction = 239 then 'Board Decommitment'
					when tr.LkTransaction = 240 then 'Board Reallocation'
				end as 'Transaction',
				f.name,
				p.proj_num, 
				lv.Description as projectname,				
				tr.ProjectCheckReqID,
				f.abbrv,
				det.Amount as detail, 
				case 
					when tr.lkstatus = 261 then 'Pending'
					when tr.lkstatus = 262 then 'Final'
				 end as lkStatus, 			 
				tr.date as TransDate
				from Project p 
		join ProjectName pn on pn.ProjectID = p.ProjectId		
		join LookupValues lv on lv.TypeID = pn.LkProjectname	
		join Trans tr on tr.ProjectID = p.ProjectId
		join Detail det on det.TransId = tr.TransId	
		join fund f on f.FundId = det.FundId
		left join LkTransType_v ttv(nolock) on det.lktranstype = ttv.typeid
		where tr.LkTransaction in (238,239,240, 236, 237)and pn.DefName =1 
		and tr.RowIsActive=1 and det.RowIsActive=1 --and p.projectid = @projectid
		
go

alter procedure GetAvailableTransTypesPerProjAcct
(
	@account varchar(20),
	@projectid int
)
as
Begin
	select distinct projectid,fundid,account,typeid,fundtype,name, proj_num,projectname,sum(detail) as availFunds
	from vw_FinancialDetailSummary where account = @account and projectid = @projectid
	group by projectid,fundid,account,typeid,fundtype,name, proj_num,projectname
end
go

alter procedure GetAvailableTransTypesPerProjFundId
(
	@fundId int,
	@projectid int
)
as
Begin
	select distinct projectid,fundid,account,typeid,fundtype,name, proj_num,projectname,sum(detail) as availFunds
	from vw_FinancialDetailSummary where fundid = @fundId and projectid = @projectid
	group by projectid,fundid,account,typeid,fundtype,name, proj_num,projectname
end
go


alter procedure GetCommittedFundPerProject
(
	@proj_num varchar(20)
)
as
Begin
	select distinct projectid, proj_num,projectname, sum(detail) as availFunds  from vw_FinancialDetailSummary where proj_num = @proj_num
	group by projectid,proj_num,projectname
end
go

alter procedure GetAvailableFundsPerProjAcctFundtype
(
	@account varchar(20),
	@projectid int,
	@fundtypeId int
)
as
Begin
	select distinct projectid,fundid,account,typeid,fundtype,name, proj_num,projectname,sum(detail) as availFunds
	from vw_FinancialDetailSummary where account = @account and projectid = @projectid and typeid = @fundtypeId
	group by projectid,fundid,account,typeid,fundtype,name, proj_num,projectname
end
go

alter procedure [dbo].[GetFundByProject]
(
	@projId int
)
as
Begin
	select distinct f.FundId, f.name, p.projectid  from Fund f 
			join detail det on det.FundId = f.FundId
			join Trans tr on tr.TransId = det.TransId
			join Project p on p.ProjectID  = tr.ProjectID
	where p.projectid = @projId
	order by f.name
end
go

alter procedure [dbo].[GetExistingCommittedFundByProject]
(
	@projId int
)
as
Begin
	select distinct f.FundId, f.name, p.projectid, -sum(det.Amount) as amount from Fund f 
			join detail det on det.FundId = f.FundId
			join Trans tr on tr.TransId = det.TransId
			join Project p on p.ProjectID  = tr.ProjectID
	where p.projectid = @projId and tr.LkTransaction = 240
	group by f.FundId, f.name, p.ProjectId
end
go

alter procedure UpdateFinancialTransactionStatus
(
	@transId int
	
)
as
--exec UpdateFinancialTransactionStatus 2958
begin
	
	declare @toProjId int
	declare @lkTrans int

	select @lkTrans = LkTransaction from trans where TransId = @transId
	
	if (@lkTrans = 240)
	Begin

		declare  @ProjIdTable table(projIds int)
		declare  @transIdTable table(transIds int)

		select @toProjId= toprojectid from reallocatelink where totransid = @transid

		insert into @ProjIdTable(projIds) select toprojectid from reallocatelink where fromprojectid = @toProjId
		insert into @transIdTable(transIds)  select fromtransid from reallocatelink where toprojectid in (select projids from @ProjIdTable)
		insert into @transIdTable(transIds)  select totransid from reallocatelink where toprojectid in (select projids from @ProjIdTable)
	

		update trans set LKStatus = 262		
		where TransId in (select distinct transIds from @transIdTable) 
	end
	else 
	Begin
		update trans set LKStatus = 262		
		where TransId = @transId
	end
end
go

alter procedure PCR_ApplicantName
(
	@ProjectID int
)
as
begin

	select an.Applicantname 
	from [dbo].[AppName] an(nolock)
	join [dbo].[ApplicantAppName] aan(nolock) on an.AppNameID = aan.AppNameID
	join Applicant a on a.ApplicantId = aan.ApplicantID
	join ProjectApplicant pa on pa.ApplicantID = a.ApplicantID
	where aan.DefName = 1 and pa.LkApplicantRole=358 and projectID = @ProjectID
	order by an.Applicantname
end
go


alter procedure dbo.GetProjectFinLegalApplicant
(
	@ProjectId int
) 
as
begin 
	select pa.ProjectApplicantID, 			
			isnull(pa.IsApplicant, 0) as IsApplicant, 
			isnull(pa.FinLegal, 0) as FinLegal,			
			a.ApplicantId, a.Individual, 
			an.applicantname,			
			aan.appnameid, aan.defname
		from ProjectApplicant pa(nolock)
		join applicantappname aan(nolock) on pa.ApplicantId = aan.ApplicantID
		join appname an(nolock) on aan.appnameid = an.appnameid
		join applicant a(nolock) on a.applicantid = aan.applicantid
		left join applicantcontact ac(nolock) on a.ApplicantID = ac.ApplicantID
		left join contact c(nolock) on c.ContactID = ac.ContactID
		left join LookupValues lv(nolock) on lv.TypeID = pa.LkApplicantRole
		where pa.ProjectId = @ProjectId
			and pa.RowIsActive = 1 and pa.finlegal = 1
		order by pa.IsApplicant desc, pa.FinLegal desc, pa.DateModified desc
	end 
go

alter procedure GetDefaultPCRQuestions
(
@IsLegal bit = 0,
@ProjectCheckReqID	int
)
as
begin
--Always include LkPCRQuestions.def=1 If any disbursement from  ProjectCheckReq.Legalreview=1 (entered above), then include LkPCRQuestions.TypeID=7

	select pcrq.ProjectCheckReqQuestionID, q.Description, pcrq.LkPCRQuestionsID, pcrq.Approved, pcrq.Date, --ui.fname+', '+ui.Lname   as staffid ,
	case when pcrq.Approved != 1 then ''
		else ui.fname+' '+ui.Lname  end as staffid 
	from ProjectCheckReqQuestions pcrq(nolock) 
	left join  LkPCRQuestions q(nolock) on pcrq.LkPCRQuestionsID = q.TypeID 
	left join UserInfo ui on pcrq.StaffID = ui.UserId
	where   q.RowIsActive=1 and ProjectCheckReqID = @ProjectCheckReqID
	
end

