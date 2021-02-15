\connect electricity;
--drop function brp_delete_tree_for_non_switch_point;

Create or Replace function  brp_delete_tree_for_non_switch_point(a_table_name text,a_smid integer)
returns void
LANGUAGE 'plpgsql'
as $$


DECLARE feature_table_node_id integer;
DECLARE others_using_this_node integer;

BEGIN
	select node_id into feature_table_node_id from brp_feature_node where table_name = a_table_name and smid = a_smid;
	
	if feature_table_node_id is null
	then
		raise notice 'Feature node table have not any record for %[%]',a_table_name,a_smid;
	else 
		select count(node_id) into others_using_this_node from brp_feature_node where node_id = feature_table_node_id and (
									(table_name = a_table_name or smid != a_smid) or
									(table_name != a_table_name or smid = a_smid)									
									);

		if others_using_this_node = 0
		then
			-- Delete This node as no one is using it
			delete from brp_nodes where node_id = feature_table_node_id;
			-- Deleting this node path, as no one is using this path
			delete from brp_network_tree where node_id = feature_table_node_id;				
		end if;
		delete from brp_feature_node where table_name = a_table_name and smid = a_smid;	
	end if;
	return;
END;
$$;
