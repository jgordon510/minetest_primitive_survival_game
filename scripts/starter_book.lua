local text = "Welcome to the server. You can't punch trees.  The first thing you'll want to do is collect as many flint nodes that you can.\n"
    text = text.. "To knap flint, you need two stones.  Sneak while clicking the ground and select the toolhead you want.\n"
    text = text.. "A hatchet will allow you to chop trees, but you'll need a stick to make one.  These can be gathered by punching leaves.\n"
    text = text.. "Chopping down a tree will fell the entire thing, giving you wood in the process.  The leaves will drop sticks as they decay.\n"
    text = text.. "You can chop logs by combining your axe with wood, resulting in tool wear on your axe.\n"
    text = text.. "You can also use your ax with logs to chop into sticks.\n"
    text = text.. "You'll next want to make a campfire.  You'll need to make a knife by knapping more flintstone and then use it to collect grass.\n"
    text = text.. "With grass, flint, and logs, you can make a campfire.  You'll need to make a bowdrill as well to light it.\n"
    text = text.. "Your campfire will keep the wolves from attacking at night.  You can also use it to light  your torches.\n"
    text = text.. "Torches are made with coal nodes which can be found on the ground like flint.\n"
    text = text.. "Torches can also be used to light other torches.  Torches will burn out over time.\n"
    text = text.. "To break rock, you'll need to explore the caves.  In them you can find copper and more coal.  Deeper down, tin, which can be combined with copper to make bronze.\n"
    text = text.. "I'm always adding new features. Please visit the github page github.com/jgordon510/minetest_primitive_survival_game to report any issues.\n"
minetest.register_on_newplayer(function(player)

    local written_book = ItemStack("default:book_written")
    written_book:get_meta():from_table({
        fields = {
            title = "Welcome",
            owner = "codeAtorium",
            description = "New Player Information",
            text = text,
            page = 1,
            page_max = math.ceil((#text:gsub("[^\n]", "") + 1) / 14),
        },
    })

    player:set_wielded_item(written_book)
    minetest.log("given book!")
end)
