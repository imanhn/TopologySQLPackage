\connect electricity;
--drop function if exists brp_update_tree_for_record;
Create or Replace function  brp_update_tree_for_record(a_table_name text,a_smid integer,a_geom geometry,is_connect boolean)
returns void
LANGUAGE 'plpgsql'
as $$

DECLARE a_brp_interaction_nodes brp_interaction_nodes;

BEGIN
	
	a_brp_interaction_nodes = brp_insert_or_update_brp_nodes_and_features(a_table_name,a_smid,a_geom,is_connect);
	
	raise notice 'number_of_points = %',a_brp_interaction_nodes.number_of_points;
	if (a_brp_interaction_nodes.number_of_points = 2)
	then
		raise notice 'calling brp_update_tree_for_linears % % %',a_table_name,is_connect, a_brp_interaction_nodes;
		perform brp_update_tree_for_linears(a_table_name,is_connect, a_brp_interaction_nodes);
	else
		raise notice 'calling brp_update_tree_for_points % % %',a_table_name,is_connect, a_brp_interaction_nodes;
		perform brp_update_tree_for_points(a_table_name,is_connect, a_brp_interaction_nodes);
	end if;
		
	return;
END;
$$;
