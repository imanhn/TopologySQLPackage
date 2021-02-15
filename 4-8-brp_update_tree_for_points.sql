\connect electricity;

--drop function if exists brp_update_tree_for_points;
Create or Replace function  brp_update_tree_for_points(a_table_name text,is_connect boolean, a_brp_interaction_nodes brp_interaction_nodes)
returns void
LANGUAGE 'plpgsql'
as $$

DECLARE a_path ltree;
DECLARE first_node_tree brp_tree_node_type;
DECLARE a_feature brp_feature_node_type;

BEGIN
	-- Cases that the geometry is a point
	raise notice '[brp_update_tree_for_points] we have a point case, ';		
	if (array_length(a_brp_interaction_nodes.new_nodes,1) = 1) -- if the node is new, so it does not exists in path
	then 
		raise notice '	its a new one node_id : %',a_brp_interaction_nodes.new_nodes[1].node_id;					
		a_path = (a_brp_interaction_nodes.new_nodes[1].node_id)::text::ltree;
		raise notice '	inserting a new feeder_tree path : %',a_path;					
		execute format('insert into brp_network_tree (node_id,path,root_type,node_type,is_connect) values(%L,%L,%L,%L,%L);',a_brp_interaction_nodes.new_nodes[1].node_id,a_path,a_table_name,a_table_name,is_connect);
	elsif (array_length(a_brp_interaction_nodes.existed_nodes,1) = 1) 
	then			
		raise notice '	it already existed node_id  %',a_brp_interaction_nodes.existed_nodes[1].node_id;		
		--first_node_tree = (get_brp_tree_node_by_node_id(a_brp_interaction_nodes.existed_nodes[1].node_id))[1];
		
		--for first_node_tree in (select ROW(ft.path_id,ft.node_id,ft.path,ft.root_type,ft.node_type,ft.is_connect) from brp_network_tree ft where node_id = a_brp_interaction_nodes.existed_nodes[1].node_id and root_type = 'mv_feeder')
		--for first_node_tree in (select * from brp_network_tree where node_id = a_brp_interaction_nodes.existed_nodes[1].node_id and root_type = 'mv_feeder' and node_type = a_table_name)
		for first_node_tree in (select * from brp_network_tree where node_id = a_brp_interaction_nodes.existed_nodes[1].node_id)
		loop 			
			raise notice '	Looping... found a record in brp_network_tree for node :  %', a_brp_interaction_nodes.existed_nodes[1].node_id;
			if first_node_tree.is_connect is true and is_connect is false
			then
				-- Disconnect all subpath of this node and update
				raise notice '	Updating tree to disconnect all subpaths of %, setting node_type and root_type to %',first_node_tree.path,a_table_name;
				execute format('update brp_network_tree set is_connect = %L  where node_id = %L',is_connect,a_brp_interaction_nodes.existed_nodes[1].node_id);
				execute format('update brp_network_tree set path = subpath(path,%L),root_type = %L  where path <@ %L  and path != %L ;',nlevel(first_node_tree.path),a_table_name,first_node_tree.path,first_node_tree.path);
			elsif first_node_tree.is_connect is false and is_connect is true
			then
				-- Connect all of the subpath to this node
				raise notice '	Updating tree to Connect all subpaths of %',first_node_tree.path;
				execute format('update brp_network_tree set is_connect = %L where node_id = %L',is_connect,a_brp_interaction_nodes.existed_nodes[1].node_id);
				
				perform closed_an_open_switch(first_node_tree , a_brp_interaction_nodes.existed_nodes[1].node_id);
				
			end if;
			raise notice '	End of loop over nodes in brp_network_tree if node_id : %',a_brp_interaction_nodes.existed_nodes[1].node_id;
			--return;
		end loop;
	end if;
			
	return;
END;
$$;
