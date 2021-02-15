\connect electricity;

Create or Replace function  closed_an_open_switch(first_node_tree brp_tree_node_type, a_node_id bigint)
returns void
LANGUAGE 'plpgsql'
as $$
DECLARE levels integer;

DECLARE current_node_path ltree;
DECLARE upstream_path ltree;
DECLARE back_traced_nodes ltree;
DECLARE feeder_path ltree;
DECLARE sub_network_path ltree;

DECLARE other_side_node bigint;
--DECLARE first_node_tree brp_tree_node_type;
DECLARE second_node_tree brp_tree_node_type;
DECLARE a_feature_table_name text;
DECLARE a_feature_smid bigint;
DECLARE a_feature_node_id bigint;
DECLARE a_feature_is_connect boolean;
DECLARE a_feature brp_feature_node_type;
BEGIN
	-- Connect all of the subpath to this node
	raise notice 'closed_an_open_switch with % and node id : %',first_node_tree,a_node_id;
	for a_feature_table_name,a_feature_smid,a_feature_node_id,a_feature_is_connect in (select table_name,smid,node_id,is_connect from brp_feature_node where node_id = a_node_id)
	Loop
		if a_feature_table_name = 'ug_mv_line' or a_feature_table_name = 'ug_lv_line' or
			a_feature_table_name = 'oh_mv_line' or a_feature_table_name = 'oh_lv_line' or
			a_feature_table_name = 'sp_mv_cable' or a_feature_table_name = 'sp_lv_cable'
		then 
			-- GOAL :  subnetwork connected to the other node of this line must be added to this network.
			-- This will find the other side node of this line
			raise notice ' Finding otherside node...';
			select node_id into other_side_node from brp_feature_node where node_id != a_feature_node_id and smid = a_feature_smid and table_name = a_feature_table_name;							
			raise notice ' 		Found otherside node : %',other_side_node;
			second_node_tree = (get_brp_tree_node_by_node_id(other_side_node))[1];
			raise notice ' 		Otherside tree : %',second_node_tree;
			raise notice ' 		update_tree_add_sub_network  % TO-> % ',second_node_tree,first_node_tree;
			if second_node_tree is not null and first_node_tree is not null and subpath(first_node_tree.path,0,1) = subpath(second_node_tree.path,0,1)
			then
				raise notice ' 			Wrong side!!! Continuing...';
				continue;
			end if;
			perform update_tree_add_sub_network(first_node_tree,second_node_tree);
		end if;
	end loop;
END;
$$;



Create or Replace function  closed_an_open_switch(a_node_id bigint)
returns void
LANGUAGE 'plpgsql'
as $$
DECLARE levels integer;

DECLARE current_node_path ltree;
DECLARE upstream_path ltree;
DECLARE back_traced_nodes ltree;
DECLARE feeder_path ltree;
DECLARE sub_network_path ltree;

DECLARE other_side_node bigint;
DECLARE first_node_tree brp_tree_node_type;
DECLARE second_node_tree brp_tree_node_type;
DECLARE a_feature_table_name text;
DECLARE a_feature_smid bigint;
DECLARE a_feature_node_id bigint;
DECLARE a_feature_is_connect boolean;
DECLARE a_feature brp_feature_node_type;
BEGIN
	-- Connect all of the subpath to this node
	first_node_tree = (get_brp_tree_node_by_node_id(a_node_id))[1];
	for a_feature_table_name,a_feature_smid,a_feature_node_id,a_feature_is_connect in (select table_name,smid,node_id,is_connect from brp_feature_node where node_id = a_node_id)
	Loop
		if a_feature_table_name = 'ug_mv_line' or a_feature_table_name = 'ug_lv_line' or
			a_feature_table_name = 'oh_mv_line' or a_feature_table_name = 'oh_lv_line' or
			a_feature_table_name = 'sp_mv_cable' or a_feature_table_name = 'sp_lv_cable'
		then 
			-- GOAL :  subnetwork connected to the other node of this line must be added to this network.
			-- This will find the other side node of this line
			select node_id into other_side_node from brp_feature_node where node_id != a_feature_node_id and smid = a_feature_smid and table_name = a_feature_table_name;							
			second_node_tree = (get_brp_tree_node_by_node_id(other_side_node))[1];
			perform update_tree_add_sub_network(first_node_tree,second_node_tree);
		end if;
	end loop;
END;
$$;