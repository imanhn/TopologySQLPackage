\connect electricity;
--drop function if exists brp_update_tree_for_linears;
Create or Replace function  brp_update_tree_for_linears(a_table_name text,is_connect boolean, a_brp_interaction_nodes brp_interaction_nodes)
returns void
LANGUAGE 'plpgsql'
as $$

DECLARE a_path ltree;
DECLARE tree_nodes brp_tree_node_type[];
DECLARE first_node_tree brp_tree_node_type;
DECLARE second_node_tree brp_tree_node_type;
DECLARE a_feature brp_feature_node_type;

BEGIN
	-- Cases that the geometry is a line
	raise notice 'we have a line case';
	if (array_length(a_brp_interaction_nodes.new_nodes,1) = 2) -- we need to add both tree_nodes as disjoints to tree_table
	then 
		raise notice ' updating tree, two new node !';
		a_path = (a_brp_interaction_nodes.new_nodes[1].node_id)::text::ltree;
		execute format('insert into brp_network_tree (node_id,path,root_type,node_type,is_connect) values(%L,%L,%L,%L,%L);',(a_brp_interaction_nodes.new_nodes[1].node_id),a_path,a_table_name,a_table_name,is_connect);

		a_path = ((a_brp_interaction_nodes.new_nodes[1].node_id)::text || '.' || (a_brp_interaction_nodes.new_nodes[2].node_id)::text)::ltree;
		if (is_connect) -- This is a line but we put this condition here in case we want to make jumpers linear
		then 
			execute format('insert into brp_network_tree (node_id,path,root_type,node_type,is_connect) values(%L,%L,%L,%L,%L);',(a_brp_interaction_nodes.new_nodes[2].node_id),a_path,a_table_name,a_table_name,is_connect);
		end if;
	elsif  (array_length(a_brp_interaction_nodes.new_nodes,1) = 1)  and (array_length(a_brp_interaction_nodes.existed_nodes,1) = 1) 
	then 
		--
		--  FIND THE PATH OF EXISTED NODE
		--
		raise notice ' updating tree one new side one existed';
		if a_brp_interaction_nodes.existed_nodes[1].is_connect is false 
		then 
			raise notice '*Node is_connect is false : %',a_brp_interaction_nodes.existed_nodes[1];
			return; 
		end if;
		
		raise notice ' Getting tree of existed node (existed is connected)  %',a_brp_interaction_nodes.existed_nodes[1].node_id;
		tree_nodes = get_brp_tree_node_by_node_id(a_brp_interaction_nodes.existed_nodes[1].node_id);
		
		
		raise notice ' check if tree_nodes = 1 ';
		if array_length(tree_nodes,1) = 1
		then 
			raise notice ' it is 1 Ok only one % in node_id column of brp_network_tree found ',a_brp_interaction_nodes.existed_nodes[1].node_id;
			a_path = tree_nodes[1].path;
			raise notice ' 			So the path is % ',a_path;
		elsif array_length(tree_nodes,1) = 0
		then
			raise notice ' it is 0 ';
			-- Correction!   there should be a path here,if not, we create it.
			raise notice '******  Error  Path = 0 ******';
			a_path = (a_brp_interaction_nodes.existed_nodes[1].node_id)::text::ltree;
			execute format('insert into brp_network_tree (node_id,path,root_type,node_type,is_connect) values(%L,%L,%L,%L,%L);',a_brp_interaction_nodes.existed_nodes[1].node_id,a_path,a_table_name,a_table_name,is_connect);
		elsif array_length(tree_nodes,1) > 1
		then 
			raise notice ' it is > 1 ';
			-- Correction!   there should be only one path here,if there are more, we delete the rest.
			raise notice '******  Warning  Path > 1 ******';
			raise notice '****** There should be only one path for % We have a ring!',a_brp_interaction_nodes.existed_nodes[1];
			--perform execute format('delete from brp_network_tree where node_id in (select node_id from brp_network_tree where node_id=%L and path_id != (select path_id from brp_network_tree where node_id = %L limit 1))',a_brp_interaction_nodes.existed_nodes[1],a_brp_interaction_nodes.existed_nodes[1]);
		end if;
		raise notice ' insert into tree with the new_node ';
		a_path = (a_path::text || '.' || (a_brp_interaction_nodes.new_nodes[1].node_id)::text)::ltree;
		execute format('insert into brp_network_tree (node_id,path,root_type,node_type,is_connect) values(%L,%L,%L,%L,%L);',a_brp_interaction_nodes.new_nodes[1].node_id,a_path,tree_nodes[1].root_type,a_table_name,is_connect);
	elsif (array_length(a_brp_interaction_nodes.existed_nodes,1) = 2) 
	then
		raise notice ' both side existed node_ids : % and %',a_brp_interaction_nodes.existed_nodes[1].node_id,a_brp_interaction_nodes.existed_nodes[2].node_id;
		
		first_node_tree = (get_brp_tree_node_by_node_id(a_brp_interaction_nodes.existed_nodes[1].node_id))[1];
		second_node_tree = (get_brp_tree_node_by_node_id(a_brp_interaction_nodes.existed_nodes[2].node_id))[1];
		
		raise notice ' first : %        second : % ',first_node_tree,second_node_tree;
		if first_node_tree.is_connect is false and second_node_tree.is_connect is false
		then 
			raise notice ' both side are open! no change is in need! ';
		elsif first_node_tree.is_connect is false and second_node_tree.is_connect is true
		then 
			-- node_id could have two tree if it is an open switch so we insert the new path the close side may have a feeder or something else root
			execute format('insert into brp_network_tree (node_id,path,root_type,node_type,is_connect) values(%L,%L,%L,%L,%L);',a_brp_interaction_nodes.existed_nodes[1].node_id,second_node_tree.path || a_brp_interaction_nodes.existed_nodes[1].node_id::text::ltree,
															'mv_feeder',first_node_tree.node_type,false);
		elsif second_node_tree.is_connect is false and first_node_tree.is_connect is true
		then
			execute format('insert into brp_network_tree (node_id,path,root_type,node_type,is_connect) values(%L,%L,%L,%L,%L);',a_brp_interaction_nodes.existed_nodes[2].node_id,first_node_tree.path || a_brp_interaction_nodes.existed_nodes[2].node_id::text::ltree,
															'mv_feeder',second_node_tree.node_type,false);
		elsif second_node_tree.root_type = 'mv_feeder' and first_node_tree.root_type <> 'mv_feeder'
		then			
			perform update_tree_add_sub_network(second_node_tree,first_node_tree);
		elsif second_node_tree.root_type <> 'mv_feeder' and first_node_tree.root_type = 'mv_feeder'
		then
			perform update_tree_add_sub_network(first_node_tree,second_node_tree);
		elsif first_node_tree.is_connect is false and second_node_tree.is_connect is false
		then 			
			-- ISOLATE SECTION    BOTH SIDE ARE OPEN!
			raise notice 'ISOLATE NETWORK DETECTED.....';
		else
			-- REMOVING FIX POLICY ( moved to 4-7-1-deprecated due to technical problem			
			if second_node_tree is null and first_node_tree is not null and first_node_tree.is_connect = true
			then
				-- FIX  when brp_node and brp_feature_node have value but there is not brp_network_tree respective record
				raise notice 'FIX NEEDED : second_node_tree is null and first_node_tree is not null and first_node_tree.is_connect = true';
			elsif second_node_tree is not null and first_node_tree is null and second_node_tree.is_connect = true
			then 
				-- FIX  when brp_node and brp_feature_node have value but there is not brp_network_tree respective record
				raise notice 'FIX NEEDED : second_node_tree is not null and first_node_tree is null and second_node_tree.is_connect = true';
			end if;

			-- R I N G     N E T W O R K
			--if subpath(first_node_tree.path,0,1) = subpath(second_node_tree.path,0,1)
			--then
			--	raise notice 'No change needed. feaders at both nodes are equal';
			--else
			--	raise notice 'Ring or Disconnected network detected.....';
			--end if;
		end if;
	end if;
	return;
END;
$$;
