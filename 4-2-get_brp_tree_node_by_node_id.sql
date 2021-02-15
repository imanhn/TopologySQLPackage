\connect electricity;

--drop function if exists get_brp_tree_node_by_node_id;
Create or Replace function  get_brp_tree_node_by_node_id(a_node_id bigint)
returns brp_tree_node_type[]
LANGUAGE 'plpgsql'
as $$
DECLARE tree_nodes brp_tree_node_type[];
DECLARE a_node brp_tree_node_type;
BEGIN

	for a_node in (select * from brp_network_tree where node_id = a_node_id)
	loop
		tree_nodes = COALESCE(tree_nodes || array[a_node],array[a_node]);
	end loop;
	
	return tree_nodes;	
END;
$$;

