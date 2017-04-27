use equis
go


Alter procedure hai.sp_hai_web_date_enterprise_report
	(
		 @facility_id int
		,@start_date datetime
		,@end_date datetime
	)
	as 
	begin

		select 
		 el1.etl_id
		,cast(el1.run_date as smalldatetime) rundate 
		,el1.schema_name
		,el1.table_name
		,el1.row_count
		,el1.status
		,el1.row_count - el2.row_count as row_count_change
	
		from ##etl_log el1
		left join ##etl_log el2 
		on el1.etl_id-1 = el2.etl_id and el1.table_name = el2.table_name
		order by el1.etl_id desc
	end
	