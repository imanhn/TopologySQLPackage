\connect electricity;

--drop function if exists update_tree_add_sub_network;
Create or Replace function  update_tree_add_sub_network(feeder_node_tree brp_tree_node_type,sub_network_node_tree brp_tree_node_type)
returns void
LANGUAGE 'plpgsql'
as $$
DECLARE levels integer;
DECLARE i integer;
DECLARE current_node_path ltree;
DECLARE upstream_path ltree;
DECLARE back_traced_nodes ltree;
DECLARE feeder_path ltree;
DECLARE sub_network_path ltree;

BEGIN
	raise notice '[update_tree_add_sub_network] ';
	raise notice '	update_tree_add_sub_network .... mainpart : %     subnetwork : %', feeder_node_tree,sub_network_node_tree;
	feeder_path = feeder_node_tree.path;
	sub_network_path = sub_network_node_tree.path;
	levels = nlevel(sub_network_path);	
	--
	-- WE ARE BACK-TRACING sub_network_path and FIND DOWNSTREAM OF EACH NODE AND UPDATE THEM
	--
	back_traced_nodes = ''::ltree;
	FOR i IN REVERSE  levels..1
	LOOP	
		current_node_path = subpath(sub_network_path,0,i);	
		upstream_path = feeder_path || back_traced_nodes;
		raise notice '	Backtrace looping on level : %   current_node_path : %  and upstream_path : %',i,current_node_path,upstream_path;		
		raise notice '			Setting upstream+backtraced_nodes (downstream part of level)';
		execute format('update brp_network_tree set path = %L || subpath(path,%L) , root_type = %L  where path <@ %L ;',upstream_path,i-1,feeder_node_tree.root_type,current_node_path);
		back_traced_nodes = back_traced_nodes || subpath(sub_network_path,i-1,1);
	END LOOP;	
END;
$$;

