\connect electricity;

Create or Replace function brp_update_feeder_name_trigger() RETURNS trigger AS $$
begin	
	perform brp_update_feeder_name(NEW.path,NEW.root_type,NEW.node_type,NEW.is_connect);
	return new;
End; $$
LANGUAGE 'plpgsql';


Create or Replace function brp_update_feeder_name(a_path ltree,a_root_type text,a_node_type text,is_connect boolean)
returns void
LANGUAGE 'plpgsql'
as $$
DECLARE current_node_id integer;
DECLARE feeder_node_id integer;
DECLARE feeder_smid bigint;
DECLARE feeder_name text;
DECLARE feeder_color text;
DECLARE a_record record;
begin
--	if (a_node_type != 'oh_mv_line') and (a_node_type != 'oh_lv_line') and
--		(a_node_type != 'ug_mv_line') and (a_node_type != 'ug_lv_line') and
--		(a_node_type != 'sp_mv_cable') and (a_node_type != 'sp_lv_cable')
--	then 
--		raise notice '*** returning from brp_update_feeder_name_trigger as it is not a line % % % % ',a_path,a_root_type,a_node_type,is_connect;
--		return;
--	end if;

	if (a_root_type = 'mv_feeder')
	then
		feeder_node_id = subpath(a_path,0,1)::text::integer;
		raise notice 'Feeder node id : %',feeder_node_id;
		select smid into feeder_smid from brp_feature_node where node_id = feeder_node_id and table_name = 'mv_feeder';
		raise notice 'feeder id : %',feeder_smid;
		select name into feeder_name from mv_feeder where smid = feeder_smid;
		select color into feeder_color from mv_feeder where smid = feeder_smid;
	else
		raise notice 'Disconnected subnetwork found';
		feeder_name = 'بی برق';
		feeder_color = '0,0,0';
	end if;
	current_node_id = subpath(a_path,nlevel(a_path)-1,1)::text::integer;
	raise notice 'current node id : %',current_node_id;	
	raise notice 'Feeder name : %',feeder_name;
	for a_record in execute format('select * from brp_feature_node where node_id = %L',current_node_id)
	loop
		if (a_record.table_name = 'oh_mv_line')
		then 
			raise notice 'Updating feeder_name for oh_mv_line[%] with : % if its feeder_name is different',a_record.smid,feeder_name;
			execute format('update oh_mv_line set color = %L , feeder_name = %L where smid = %L and (feeder_name!=%L or feeder_name is null or color != %L)',feeder_color,feeder_name,a_record.smid,feeder_name,feeder_color);				
		elsif (a_record.table_name = 'ug_mv_line')
		then 
			raise notice 'Updating feeder_name for ug_mv_line[%] with : % if its feeder_name is different',a_record.smid,feeder_name;
			execute format('update ug_mv_line set color = %L , feeder_name = %L where smid = %L and (feeder_name!=%L or feeder_name is null or color != %L)',feeder_color,feeder_name,a_record.smid,feeder_name,feeder_color);				
		elsif (a_record.table_name = 'sp_mv_cable')
		then 
			raise notice 'Updating feeder_name for sp_mv_cable[%] with : % if its feeder_name is different',a_record.smid,feeder_name;
			execute format('update sp_mv_cable set color = %L , feeder_name = %L where smid = %L and (feeder_name!=%L or feeder_name is null or color != %L)',feeder_color,feeder_name,a_record.smid,feeder_name,feeder_color);				
		end if;
	end loop;
	
	return;
End; $$;

-- DROP TRIGGER IF EXISTS brp_insert_or_update_trigger ON brp_network_tree;
Create trigger brp_insert_or_update_trigger AFTER INSERT OR UPDATE on brp_network_tree 
FOR EACH ROW 
WHEN (pg_trigger_depth() < 2)
EXECUTE PROCEDURE brp_update_feeder_name_trigger();

