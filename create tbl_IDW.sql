use equis_reporting
go

declare
	 @facility_id nvarchar(10) = 47
	,@SchemaName VARCHAR(20) ='s_36599E00'
	,@coord_zone nvarchar (20) ='N83SPCA III Ft'
	,@SRID varchar(10) = N'2227'
	,@elev_datum varchar (20)
	,@sample_table_name varchar (100) 
	,@URL_yn varchar(2) = 'y'



DECLARE	
	@SQL nvarchar(max),
	@return_value INT,
	@table_name varchar (200),
	@err_msg varchar (300),
	@schema_table_name varchar (100),
	@unit varchar (10),
	@matrix varchar (500),
	@table_list varchar (500),
	@parameters nvarchar(1000) ,
	@facility_id_text nvarchar (10) = cast(@facility_id as varchar (10)),
	@AllTablesSQL varchar (max),
	@row_id int


	SELECT @matrix =  ISNULL(@matrix,'') + matrix_code + '|' 
	from
	(SELECT DISTINCT  matrix_code 
	from equis.dbo.dt_location l
		inner join equis.dbo.dt_sample s on l.facility_id = s.facility_id and l.sys_loc_code = s.sys_loc_code
		left join equis.dbo.dt_hai_task_permissions tp on s.facility_id = tp.facility_id and s.task_code = tp.task_code
		where l.facility_id = 47
		and loc_type = 'idw'
		and tp.permission_type_code = '0'
		and l.subfacility_code in ('pge-ff','pge-nb','pge-bs'))z

	set @matrix = left(@matrix,len(@matrix) -1)
	select @matrix

--DROP TABLE s_36599E00.tbl_IDW
--select  * into s_36599E00.tbl_IDW FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v3]( @facility_id, @unit, null, @coord_zone, @elev_datum, @matrix)
Select  *  FROM [EQuIS].[rpt].[fn_HAI_EQUIS_Results_v3]( @facility_id, @unit, null, @coord_zone, @elev_datum, @matrix)
where loc_Type  like 'idw%'
And subfacility_NAME in ('Beach Street','Former Fillmore MGP','Former North Beach MGP')
AND PERMISSION_type_CODE = '0'
and x_coord is  null

--update s_36599E00.tbl_IDW
--Set Sharepoint_URL = equis_reporting.dbo.fn_PGE_sharepoint_address (subfacility_name, task_code, apn)

--select * from s_36599E00.tbl_IDW
--where x_coord is  not null

--exec [dbo].[Sp_AddSpatialElements] 's_36599E00.tbl_IDW', N'2227'