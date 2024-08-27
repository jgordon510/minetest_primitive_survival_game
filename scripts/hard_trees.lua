local TREE_DROP_RARITY = 2
--a table to register down below
local newNodes = {}
for i, node in pairs(minetest.registered_nodes) do
    --find all registered tree nodes
    --adjust their drop so that they give wood only 1/2 the time
    if string.match(node.name, "tree") then 
        minetest.override_item(node.name, {
            groups = {tree = 1, choppy = 14, flammable = 2},
            drop = {
                max_items = 1,
                items = {
                    {items = {node.name}, rarity = TREE_DROP_RARITY},
                }
            },
            
        })  
        --for each kind of tree add 10 internal hard versions with different hardness
        --the entire tree is converted to this type based on how many nodes are in the
        --tree's entire structure. More nodes results in a longer chopping time
        for i = 1, 10 do
            local def = table.copy(minetest.registered_nodes[node.name])
            def.description = node.description .. "_hard_" .. i
            def.groups = {tree = 1, choppy = 14-i, flammable = 2, not_in_creative_inventory = 1 }
            def.drop  = {
                max_items = 1,
                items = {
                    {items = {node.name}, rarity = TREE_DROP_RARITY},
                }
            }
            local shortName = (node.name):gsub("default:", "")
            local name = "primitive:" .. shortName .. "_hard_" .. i
            table.insert(newNodes, {name=name, def=def})
        end
    end
end



--add the nodes from the table we made up top
for i, node in pairs(newNodes) do
    minetest.register_node(node.name, node.def)
end