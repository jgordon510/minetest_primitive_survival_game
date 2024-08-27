minetest.unregister_item("default:flint")
minetest.unregister_item("fire:flint_and_steel")
minetest.unregister_item("default:pick_wood")
minetest.unregister_item("default:pick_stone")
minetest.unregister_item("default:shovel_wood")
minetest.unregister_item("default:shovel_stone")
minetest.unregister_item("default:axe_wood")
minetest.unregister_item("default:axe_stone")
minetest.unregister_item("default:sword_wood")
minetest.unregister_item("default:sword_stone")
minetest.unregister_item('default:sword_bronze')
minetest.unregister_item("default:sword_steel")
minetest.unregister_item("default:sword_mese")
minetest.unregister_item("default:sword_diamond")
--temporary: remove all plank recipes
for i, node in pairs(minetest.registered_nodes) do
    if node.groups.wood then
        minetest.clear_craft({
            output = node.name
        })
    end
end