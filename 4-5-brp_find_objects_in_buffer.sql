\connect electricity;

--drop function if exists brp_find_objects_in_buffer;

Create or Replace function brp_find_objects_in_buffer(a_table_name text, a_smid bigint, a_geom geometry, layers_to_check text[])
RETURNS brp_buffer_result
LANGUAGE 'plpgsql'
as $$
declare 
	interacting_layer text;
	a_thereshold  DOUBLE PRECISION;
	other_geom geometry;
	intersection_point geometry;
	all_points geometry[];
	other_smid bigint;
	a_brp_buffer_result brp_buffer_result;
	no_of_points integer;
BEGIN
a_thereshold = 0.1;
raise notice '[brp_find_objects_in_buffer] Busbar :  %[%]',a_table_name,a_smid;
foreach interacting_layer in array(layers_to_check)
loop 
	for other_geom,other_smid in 
							execute format('select %I,%I from %I other_record where 
											ST_DWithin(other_record.smgeometry,%L,%L) limit 1',
						   					'smgeometry','smid',interacting_layer,a_geom,a_thereshold)
	loop
		intersection_point = ST_Intersection(other_geom,a_geom);
		raise notice '	%[%] found connected,  intersection_point:%',interacting_layer,other_smid,intersection_point;
		a_brp_buffer_result.smids =  COALESCE(ARRAY[other_smid],a_brp_buffer_result.smids || other_smid::integer);		
		a_brp_buffer_result.table_names =  COALESCE(ARRAY[interacting_layer],a_brp_buffer_result.table_names || interacting_layer);
		a_brp_buffer_result.points =  COALESCE(ARRAY[intersection_point],a_brp_buffer_result.points || intersection_point);				
		if (interacting_layer = 'busbar' or 
			interacting_layer = 'lv_busbar' or 
			interacting_layer = 'mv_busbar')
		then 
			a_brp_buffer_result.busbar_class = interacting_layer;
			a_brp_buffer_result.busbar_smid = other_smid;
			a_brp_buffer_result.busbar_geom = other_geom;
		end if;
	end loop;
end loop;
if a_brp_buffer_result.points is null or array_length(a_brp_buffer_result.points,1) = 0
then 
	raise notice '	adding start/end points of a disconnected busbar';
	all_points = brp_get_points( a_geom );
	no_of_points = array_length(all_points,1);
	raise notice '		busbar has % points',no_of_points;
	a_brp_buffer_result.points =  COALESCE(a_brp_buffer_result.points || all_points[1]);
	a_brp_buffer_result.points =  COALESCE(a_brp_buffer_result.points || all_points[no_of_points]);	
	raise notice '		added % ',array_length(a_brp_buffer_result.points,1);
end if;
return a_brp_buffer_result;
END; $$ 
