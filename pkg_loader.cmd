@echo off
Echo *************************************************************
Echo *                                                           *
Echo *                         SQL LOADER                        *
Echo *                                                           *
Echo * - Batch-Loading SQL files for Package Network Analysis    *
Echo *                                                           *
Echo * - Written by : Iman Hosseini Nia                          *
Echo *                                                           *
Echo * - (C) Copyright 2020, Behineh Rassam Pars Company.        *
Echo *                                                           *
Echo *                                                           *
Echo *************************************************************
Echo [SQL-LOADER][21/09/1399 20:47:01] Batch start initiated...
SET PGCLIENTENCODING=utf-8
chcp 65001
Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 1-1-setup .....
psql --username=postgres --no-password --file=1-1-setup.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 2-1-types .....
psql --username=postgres --no-password --file=2-1-types.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 3-2-brp_find_node_from_point .....
psql --username=postgres --no-password --file=3-2-brp_find_node_from_point.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 3-3-brp_get_points .....
psql --username=postgres --no-password --file=3-3-brp_get_points.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 4-2-get_brp_tree_node_by_node_id .....
psql --username=postgres --no-password --file=4-2-get_brp_tree_node_by_node_id.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 4-3-update_tree_add_sub_network .....
psql --username=postgres --no-password --file=4-3-update_tree_add_sub_network.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 4-4-brp_insert_or_update_brp_nodes_and_features .....
psql --username=postgres --no-password --file=4-4-brp_insert_or_update_brp_nodes_and_features.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 4-5-brp_find_objects_in_buffer .....
psql --username=postgres --no-password --file=4-5-brp_find_objects_in_buffer.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 4-6 brp_insert_busbar_nodes .....
psql --username=postgres --no-password --file=4-6-brp_insert_busbar_nodes.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 4-7-brp_update_tree_for_linears .....
psql --username=postgres --no-password --file=4-7-brp_update_tree_for_linears.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 4-8-brp_update_tree_for_points .....
psql --username=postgres --no-password --file=4-8-brp_update_tree_for_points.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 5-1-brp_update_tree_for_record .....
psql --username=postgres --no-password --file=5-1-brp_update_tree_for_record.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 5-2-closed_an_open_switch .....
psql --username=postgres --no-password --file=5-2-closed_an_open_switch.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 6-1-brp_delete_tree_for_line .....
psql --username=postgres --no-password --file=6-1-brp_delete_tree_for_line.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 6-2-brp_delete_tree_for_non_switch_point .....
psql --username=postgres --no-password --file=6-2-brp_delete_tree_for_non_switch_point.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 6-3-brp_feeder_tree_trigger .....
psql --username=postgres --no-password --file=6-3-brp_feeder_tree_trigger.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 7-1-delete_trigger .....
psql --username=postgres --no-password --file=7-1-delete_trigger.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 7-2-insert_trigger .....
psql --username=postgres --no-password --file=7-2-insert_trigger.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:01] Running 7-3-update_trigger .....
psql --username=postgres --no-password --file=7-3-update_trigger.sql

Echo  * 
Echo [SQL-LOADER][21/09/1399 20:47:02]  Package loaded, please run the tests.... 

pause