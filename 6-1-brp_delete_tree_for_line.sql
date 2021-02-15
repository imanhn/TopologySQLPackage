\connect electricity;

--drop function brp_delete_tree_for_line;

Create or Replace function  brp_delete_tree_for_line(a_table_name text,a_smid integer)
returns void
LANGUAGE 'plpgsql'
as $$

DECLARE feature_table_node_id integer;
DECLARE others_using_this_node integer;
DECLARE tree_nodes brp_tree_node_type[];
DECLARE tree1 brp_tree_node_type;
DECLARE tree2 brp_tree_node_type;
DECLARE subpath_to_delete ltree;
DECLARE c integer;
BEGIN
	c = 1;
	for feature_table_node_id in (select node_id from brp_feature_node where table_name = a_table_name and smid = a_smid)
	Loop
		tree_nodes = get_brp_tree_node_by_node_id(feature_table_node_id);
		if array_length(tree_nodes,1) > 0
		then 
			if c = 1 
			then 				
				tree1 = tree_nodes[1];
				raise notice 'Setting tree1 %',tree1;
			elsif c = 2
			then 
				tree2 = tree_nodes[1];
				raise notice 'Setting tree2 %',tree2;				
			end if;
		end if;
		select count(node_id) into others_using_this_node from brp_feature_node where node_id = feature_table_node_id and (
									(table_name = a_table_name or smid != a_smid) or
									(table_name != a_table_name or smid = a_smid)									
									);
		if others_using_this_node = 0
		then
			raise notice 'Deleting brp_node record as no one is using it %',feature_table_node_id;				
			-- Delete This node as no one is using it
			delete from brp_nodes where node_id = feature_table_node_id;
			-- Deleting this node path, as no one is using this path
			raise notice 'Deleting brp_network_tree record as no one is using it %',feature_table_node_id;							
			delete from brp_network_tree where node_id = feature_table_node_id;				
		end if;
		if c = 1
		then 
			-- There is no need to do this twice, as the first time all brp_feature_nodes will be deleted.
			raise notice 'Deleting brp_feature_node record for %[%] ',a_table_name,a_smid;								
			delete from brp_feature_node where table_name = a_table_name and smid = a_smid;	
		end if;
		c = c + 1;
	end loop;
	
	if tree1 is not null and tree2 is not null
	then
		raise notice 'Tree1 & 2 were not null';								
		if subpath(tree1.path,0,1) =  subpath(tree2.path,0,1)
		then 
			raise notice 'Tree1 & 2 share the same root node';								
			if tree1.path > tree2.path
			then
				subpath_to_delete = tree1.path;
			else 
				subpath_to_delete = tree2.path;
			end if;
			raise notice 'Downstream node is : %  deleteing all paths downstream if it',subpath_to_delete;								
			-- Disconnect all subpath of downstream node by update brp_network_tree
			execute format('update brp_network_tree set path = subpath(path,%L),root_type = %L  where path <@ %L ;',nlevel(subpath_to_delete)-1,'DISCONNECTED',subpath_to_delete);
		end if;
		
	end if;
	return;
END;
$$;
