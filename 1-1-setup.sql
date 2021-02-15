-- Gin for NearestNeighbour search and 2D Geometry searches but i used Gist as I can not define Gin over geometry fields
-- btree for Primary key
-- gist for more than one key like Tree

\connect electricity;

DO $$ BEGIN
	CREATE extension ltree;
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;
	
DO $$ BEGIN	
	IF NOT EXISTS (SELECT 0 FROM pg_class where relname = 'brp_nodes_node_id_seq' )
	THEN
	  CREATE SEQUENCE public.brp_nodes_node_id_seq;
	END IF;	
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

DO $$ BEGIN
	ALTER SEQUENCE public.brp_nodes_node_id_seq OWNER TO postgres;
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

DO $$ BEGIN	
	DROP TABLE IF EXISTS public.brp_nodes;
	CREATE TABLE public.brp_nodes
	(
		node_id bigint NOT NULL DEFAULT nextval('brp_nodes_node_id_seq'::regclass),
		smgeometry geometry NOT NULL,
		is_connect boolean NOT NULL,
		node_type text COLLATE pg_catalog."default" NOT NULL,
		CONSTRAINT brp_nodes_pkey PRIMARY KEY (node_id)
	);
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

DO $$ BEGIN	
	DROP INDEX IF EXISTS  brp_nodes_smgeometry_gist_index;
	CREATE INDEX brp_nodes_smgeometry_gist_index
		ON public.brp_nodes USING gist (smgeometry);
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

DO $$ BEGIN	
	DROP INDEX IF EXISTS brp_nodes_node_id_btree_index;
	CREATE INDEX brp_nodes_node_id_btree_index
		ON public.brp_nodes USING btree (node_id ASC NULLS LAST);
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

DO $$ BEGIN	
	ALTER TABLE public.brp_nodes OWNER to postgres;	
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

DO $$ BEGIN	
	DROP TABLE IF EXISTS public.brp_feature_node;
	CREATE TABLE public.brp_feature_node
	(
		table_name character varying(25) COLLATE pg_catalog."default" NOT NULL,
		smid bigint NOT NULL,
		node_id bigint NOT NULL,
		is_connect boolean NOT NULL,
		CONSTRAINT brp_feature_node_pkey PRIMARY KEY (table_name, smid,node_id)
	);
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

DO $$ BEGIN	
	DROP INDEX IF EXISTS brp_feature_node_tablename_smid_btree_index;
	CREATE INDEX brp_feature_node_tablename_smid_btree_index
		ON public.brp_feature_node USING btree
		(table_name ASC NULLS LAST, smid ASC NULLS LAST)
		INCLUDE(table_name, smid);
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

DO $$ BEGIN	
	DROP INDEX IF EXISTS brp_feature_node_node_id_btree_index;
	CREATE INDEX brp_feature_node_node_id_btree_index
		ON public.brp_feature_node USING btree
		(node_id ASC NULLS LAST);
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

DO $$ BEGIN	
	ALTER TABLE public.brp_feature_node OWNER to postgres;
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

DO $$ BEGIN
	IF NOT EXISTS (SELECT 0 FROM pg_class where relname = 'brp_network_tree_path_id_seq' )
	THEN
	  CREATE SEQUENCE public.brp_network_tree_path_id_seq;
	END IF;	
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

DO $$ BEGIN	
	DROP TABLE IF EXISTS public.brp_network_tree;
	CREATE TABLE public.brp_network_tree
	(
		path_id bigint NOT NULL DEFAULT nextval('brp_network_tree_path_id_seq'::regclass),
		node_id bigint NOT NULL,
		path ltree NOT NULL,
		root_type text COLLATE pg_catalog."default",
		node_type text COLLATE pg_catalog."default",
		is_connect boolean,
		CONSTRAINT brp_network_tree_pkey PRIMARY KEY (path_id)
	);
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

DO $$ BEGIN	
	DROP INDEX IF EXISTS brp_network_tree_path_gist_index;
	CREATE INDEX brp_network_tree_path_gist_index
		ON public.brp_network_tree USING gist
		(path);
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

DO $$ BEGIN	
	DROP INDEX IF EXISTS brp_network_tree_node_id_btree_index;
	CREATE INDEX brp_network_tree_node_id_btree_index
		ON public.brp_network_tree USING btree
		(node_id ASC NULLS LAST);
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

DO $$ BEGIN		
	ALTER TABLE public.brp_network_tree
		OWNER to postgres;
EXCEPTION
	WHEN sqlstate '42710' THEN null;
END $$;

-- TODO
-- alter grants to all users
	