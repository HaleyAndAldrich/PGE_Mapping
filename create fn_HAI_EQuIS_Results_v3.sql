USE [EQuIS]
GO
/****** Object:  UserDefinedFunction [rpt].[fn_HAI_EQuIS_Results_v3_test]    Script Date: 8/16/2017 9:45:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER FUNCTION [rpt].[fn_HAI_EQuIS_Results_v3_test](
	 @facility_id int
	,@target_unit varchar(15)
	,@limit_type varchar (10)
	,@coord_type varchar(20)
	,@elev_datum varchar (20)
	,@matrix varchar (20)
	,@permissions varchar(20)
	)


	Returns Table
	As Return

	Select
		--s.facility_id,
		--fc.facility_code,
		--s.sample_id,
		--t.test_id,
		s.sys_sample_code,
		s.sample_name,
		t.lab_sample_id,
		--fs.field_sdg,
		--l.subfacility_code,
		sf.subfacility_name,
		coalesce(s.sys_loc_code,'none') as sys_loc_code,
		coalesce(l.loc_name,'none') as loc_name,
		case 
			when l.loc_type = 'soil boring' then 'Soil Boring, Other'
			when l.loc_type = 'soil boring, qc' then 'Soil Boring, QC'
			when l.loc_type = 'IDW' then 'IDW, Other'
			else lt.location_type_desc
		end as loc_type,
		s.sample_date,
		s.duration,
		s.duration_unit,
		s.matrix_code,
		case 
			when s.sample_type_code = 'n' then 'Primary'
			when s.sample_type_code = 'fd' then 'Field Duplicate'
			when s.sample_type_code = 'gpc' then 'GPC Check Standard'
			when s.sample_type_code = 'spl' then 'Split Sample'
			when s.sample_type_code = 'TB' then 'Trip Blank'
			else s.sample_type_code end as sample_type,
		--s.sample_class,
		--s.sample_desc,
		s.sample_source,
		coalesce(s.task_code,'none') as task_code,
		s.start_depth,
		s.end_depth,
		v.elev as reference_elevation,
		isnull(v.elev_reference_desc, 'not available') as reference_elevation_point,
		case when start_depth is not null and v.elev is not null then equis.significant_figures(cast(v.elev  as float) - cast( start_depth as float),equis.significant_figures_get(s.start_depth),default) end as start_elevation,
		case when end_depth is not null and v.elev is not null then equis.significant_figures(cast(v.elev  as float) - cast( end_depth as float),equis.significant_figures_get(s.end_depth),default) end as end_elevation,
		s.depth_unit,
		--s.medium_code,
		--s.custom_field_2 as remediation_status,
		--s.custom_field_3 as excavation_status,
		--s.custom_field_4 as geological_unit_code,
		--fs.sampling_reason,
		g.compound_group,
		--t.basis,
		t.analytic_method,
		t.prep_method,
		--t.leachate_method,
		t.dilution_factor ,
		case when t.fraction = 'N' then 'T' else t.fraction end as total_or_dissolved,
		--t.test_type,
		coalesce(t.lab_sdg,'No_SDG')as lab_sdg,
		company_name as lab_name,
		t.analysis_date,
		ra.chemical_name,
		r.cas_rn,
		--r.result_error_delta,
		case when r.detect_flag = 'N' then r.reporting_detection_limit else r.result_text end as lab_reported_result,
		r.result_unit as lab_reported_result_unit,
		r.detect_flag,
		r.reportable_result,
		r.result_type_code,
		r.lab_qualifiers,
		--r.validator_qualifiers,
		--r.interpreted_qualifiers,
		r.validated_yn,
		--approval_code,
		approval_a as validation_reason_code,
		case 
			when r.interpreted_qualifiers is not null then r.interpreted_qualifiers
			when r.detect_flag = 'N' then 'U' 
		end as qualifier,

		rpt.fn_HAI_result_qualifier ( --Recalc unit conversion in case default units are specified in method analyte group
		case 
			when r.detect_flag = 'N' and @limit_type = 'NONE' then '0'
			when r.detect_flag = 'N' and @limit_type IS NULL then  --default to RL and mdl next
				coalesce(
				equis.significant_figures(equis.unit_conversion_result(reporting_detection_limit, r.result_unit,
				coalesce(@target_unit, r.result_unit),default,null, null,  null,  r.cas_rn,null),
				equis.significant_figures_get(reporting_detection_limit ),default)
				,
				equis.significant_figures(equis.unit_conversion_result(method_detection_limit, r.result_unit,
				coalesce(@target_unit, r.result_unit),default,null, null,  null,  r.cas_rn,null),
				equis.significant_figures_get(method_Detection_limit ),default)
				)
			when r.detect_flag = 'N' and @limit_type = 'RL' then 
				equis.significant_figures(equis.unit_conversion_result(reporting_detection_limit, r.result_unit,
				coalesce(@target_unit, r.result_unit),default,null, null,  null,  r.cas_rn,null),
				equis.significant_figures_get(reporting_Detection_limit ),default)
			when r.detect_flag = 'N' and @limit_type = 'MDL' then 
				equis.significant_figures(equis.unit_conversion_result(method_detection_limit, r.result_unit,
				coalesce(@target_unit, r.result_unit),default,null, null,  null,  r.cas_rn,null),
				equis.significant_figures_get(method_Detection_limit ),default)
			when r.detect_flag = 'N' and @limit_type = 'PQL' then 
				equis.significant_figures(equis.unit_conversion_result(quantitation_limit, r.result_unit,
				coalesce(@target_unit, r.result_unit),default,null, null,  null,  
				r.cas_rn,null),equis.significant_figures_get(quantitation_limit ),default)
			when r.detect_flag = 'Y' then
				equis.significant_figures(equis.unit_conversion_result(r.result_numeric,r.result_unit,
				coalesce(@target_unit,r.result_unit), default,null, null,  null,  r.cas_rn,null),
				equis.significant_figures_get(coalesce(r.result_text,rpt.trim_zeros(cast(r.result_numeric as varchar)))),default) 
			end ,
			case 
				when detect_flag = 'N' then '<' 
				when detect_flag = 'Y' and charindex(validator_qualifiers, 'U') >0 then '<'
				when detect_flag = 'Y' and charindex(interpreted_qualifiers, 'U') >0 then '<'
				else null 
			end,
			case 
				when r.interpreted_qualifiers is not null then r.interpreted_qualifiers
				when charindex('j',r.lab_qualifiers)> 0 and r.interpreted_qualifiers is null then 'J'
				when charindex('j',r.lab_qualifiers)= 0 and r.interpreted_qualifiers is null and r.detect_flag = 'N' then 'U' 
			end,  --reporting qualifier
			interpreted_qualifiers,
			'< # Q') --how the user wants the result to look
			 
			as result_label,
		
		cast(
		case 
			when r.detect_flag = 'N' then '0'
			when r.detect_flag = 'Y' then
				equis.significant_figures(equis.unit_conversion_result(r.result_numeric,r.result_unit,
				coalesce(@target_unit,r.result_unit), default,null, null,  null,  r.cas_rn,null),
				equis.significant_figures_get(coalesce(r.result_text,rpt.trim_zeros(cast(r.result_numeric as varchar)))),default) 
			end as float)
		as result_value,

        cast(
				equis.significant_figures(equis.unit_conversion_result(method_detection_limit, r.result_unit,
				coalesce(@target_unit, r.result_unit),default,null, null,  null,  r.cas_rn,null),
				equis.significant_figures_get(method_Detection_limit ),default)
		as float) as method_detection_limit,


		cast(
				equis.significant_figures(equis.unit_conversion_result(reporting_detection_limit, r.result_unit,
				coalesce(@target_unit, r.result_unit),default,null, null,  null,  r.cas_rn,null),
				equis.significant_figures_get(reporting_detection_limit ),default)
		as float)
		as reporting_detection_limit,
		  
			coalesce(case when r.interpreted_qualifiers is not null and charindex(',',r.interpreted_qualifiers) >0 then  left(r.interpreted_qualifiers, charindex(',',r.interpreted_qualifiers)-1)
			when r.interpreted_qualifiers is not null then r.interpreted_qualifiers
			when r.validator_qualifiers is not null then r.validator_qualifiers
			when detect_flag = 'N' and interpreted_qualifiers is null then 'U' 
			when validated_yn = 'N' and charindex('J',lab_qualifiers) >0 then 'J'
			else ''
		end, '') 
		as reporting_qualifier,

		case when right(@target_unit,1) =  right(result_unit, 1) then
			coalesce(@target_unit, result_unit) 
		else
			result_unit 
		end as result_unit,
		case
			when @limit_type IS NULL then 
				case
					when reporting_detection_limit IS NOT NULL then 'RL'
					when reporting_detection_limit IS NULL then 'MDL'
				end
			when @limit_type IS NOT NULL then @limit_type
		end
		as detection_limit_type,
		c.coord_type_code,
		x_coord,
		y_coord,
		--eb.edd_date, 
		--eb.edd_user,
		--eb.edd_file ,
		rt_coord_type.SRID,
		lp.APN,
		tp.permission_type_code,
		cast(null as varchar(max)) as Sharepoint_URL
	From dbo.dt_sample s
		
		inner join dt_test t on s.facility_id = t.facility_id and  s.sample_id = t.sample_id
		inner join dt_result r on t.facility_id = r.facility_id and t.test_id = r.test_id
		inner join rt_analyte ra on r.cas_rn = ra.cas_rn
		inner join dt_location l on s.facility_id = l.facility_id and s.sys_loc_code = l.sys_loc_code
		inner join rt_company cmpy on t.lab_name_code = cmpy.company_code
		left join rt_location_type lt on l.loc_type = lt.location_type_code
		left join dt_subfacility sf on l.facility_Id = sf.facility_id and l.subfacility_code = sf.subfacility_code
		left join dt_field_sample fs on s.facility_id = fs.facility_id and s.sample_id = fs.sample_id
		left join st_edd_batch eb on r.ebatch = eb.ebatch
		/*Vertical Coordinates*/
		left join (select 
				  l.facility_id
				, l.sys_loc_code
				, ef.elev_reference_type_code
				, case when l.loc_type = 'monitoring well' then 'Top-of-casing' else ef.[desc] end as elev_reference_desc
				, case when l.loc_type = 'monitoring well' then 'NAVD88' else elev_datum_code end as elev_datum_code
				, case when l.loc_type = 'monitoring well' then w.top_casing_elev else ve.elev end as elev
				, case when l.loc_type = 'monitoring well' then w.depth_unit else ve.elev_unit_code end as elev_unit_code 
					from dt_hai_vertical_elevation ve
					inner join dt_location l on ve.facility_id = l.facility_id and ve.sys_loc_code = l.sys_loc_code
					inner join rt_hai_elev_reference ef on ve.elev_reference_type_code = ef.elev_reference_type_code
					left join dt_well w on l.facility_id = w.facility_id and w.sys_loc_code = l.sys_loc_code
					where ve.facility_id = @facility_id and isnull(elev_datum_code,@elev_datum) = @elev_datum) v
					on s.facility_id = v.facility_id and s.sys_loc_code = v.sys_loc_code
		/*Horizontal Coordinates*/
		left join (select facility_id, sys_loc_code, coord_type_code,x_coord, y_coord 
					from dt_coordinate 
					where facility_id in (select facility_id 
					from equis.facility_group_members(@facility_id)) and coord_type_code = @coord_type)c 
					on s.facility_id = c.facility_id and s.sys_loc_code = c.sys_loc_code
		inner join  (select facility_id, facility_code
					from equis.facility_group_members(@facility_id)) f 
				on s.facility_id = f.facility_id
		LEFT join rt_coord_type on c.coord_type_code = rt_coord_type.coord_type_code
		inner join dt_facility fc on fc.facility_id = s.facility_id 	
		left join (select member_code ,rgm.group_code as compound_group from rt_group_member rgm
				inner join rt_group rg on rgm.group_code = rg.group_code
				 where rg.group_type = 'compound_group')g
		on t.analytic_method = g.member_code
	    left join 
			(select facility_id, sys_loc_code ,permission_type_code, lp.apn from dt_hai_location_details lp
			inner join rt_hai_apn apn on lp.apn = apn.apn)lp
			on l.facility_id = lp.facility_id and l.sys_loc_code = lp.sys_loc_code
		left join dt_hai_task_permissions tp on s.facility_id = tp.facility_id and s.task_code = tp.task_code
	Where
		coalesce(tp.permission_type_code,'999') in (select cast(value as int) from fn_split(coalesce(@permissions,'999'))) and
		s.matrix_code in (select cast(value as varchar (10)) from fn_split (@matrix)) and
		result_type_code = 'trg' and   --remove field parameters and qc results
		 right(result_unit,1) = right(coalesce(@target_unit,result_unit),1) and --filter out non concentration results
		 (case  --filter out non-numeric values
		when result_text is not null then isnumeric(result_text) 
		when reporting_detection_limit is not null then isnumeric(reporting_detection_limit)
	    else -1
		 end) <> 0