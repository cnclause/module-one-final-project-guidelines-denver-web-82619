require_relative 'cli.rb'

# Menu
def menu
    prompt = TTY::Prompt.new
    choice = prompt.select("Welcome to the DnD main menu!",("Start a Game"), ("Delete Users"), "Exit")
    if choice == "Exit"
        exit
    elsif choice == "Delete Users"
        user_names = User.all.map do |user|
            user.name
        end
        delete = prompt.select("Which user would you like to delete?", (user_names), "Delete all users", "Exit") 
        if delete == "Delete all users"
            Userweapon.destroy_all
            User.destroy_all 
            Weapon.destroy_all
            puts "You have successfull deleted all users"
            menu
        elsif delete == "Exit"
            exit
        else 
            delete_id = User.find_by(name: delete).id
            weaponid = Userweapon.find_by(user_id: delete_id).weapon_id
            Userweapon.find_by(user_id: delete_id).destroy
            User.find_by(id: delete_id).destroy
            Weapon.find_by(id: weaponid).destroy
            puts "You successfully deleted #{delete}"
            menu 
        end 
    end 
end


#Creating Class Methods
    def class_names
        response = RestClient.get('http://dnd5eapi.co/api/classes/')
        parsed = JSON.parse(response)
        parsed["results"].map do |prof|
            prof["name"]
        end
    end

    def class_choice
        prompt = TTY::Prompt.new
        choice = prompt.select("Choose your class", (class_names), "Exit")
    end

#Creating Race Methods
    def race_names
        response = RestClient.get('http://dnd5eapi.co/api/races/')
        parsed = JSON.parse(response)
        parsed["results"].map do |race|
            race["name"]
        end
    end

    def race_choice
        prompt = TTY::Prompt.new
        choice = prompt.select("Choose your race", (race_names), "Exit")
    end 

#Inventory Method
def inventory
    userweps = Userweapon.all.select do |userwep|
        userwep.user_id == User.all.last.id
    end
    ids = userweps.map do |weapons|
        weapons.weapon_id
    end
    Weapon.all.select do |weapon|
        weapon.id == ids[0] || weapon.id == ids[1]
    end.map do |item|
        item.name
    end
end 

#Finding User Items 
def add_inventory
    last_user_id = User.last.id
    user_weapons_id = Userweapon.where(user_id: last_user_id)
    weapon_id_array = user_weapons_id.map do |user_weapon| 
        user_weapon.weapon_id 
    end
    if user_weapons_id.count < 2 
        Weapon.create(name: "Short Sword", category: "Melee Weapon")
        Userweapon.create(user: User.all.last, weapon: Weapon.all.last)
        puts "You find an old Short Sword on the ground. You think it will come in handy so you add it to your inventory.".yellow
    end
end

#Combat methods
def fight_sequence 
    add_inventory
    player_hp = 20
    enemy_hp = 10
    enemy_attack_num = rand(1..5)
    player_attack_num = rand(3..9)
    prompt = TTY::Prompt.new
    fight_choice = prompt.select("You ready yourself for an attack.", "Attack with #{inventory[0]}", "Attack with #{inventory[1]}")
    if fight_choice == fight_choice
       diff_hp = enemy_hp - player_attack_num
       puts "You attacked the goblin and it has #{diff_hp} hp left".red
       fight_choice2 = prompt.select("The goblin is badly hurt and drops his branch writhing in pain.", "Attack with #{inventory[0]}", "Attack with #{inventory[1]}")
       if fight_choice2 == fight_choice2
            diff_hp2 = diff_hp - player_attack_num
            if diff_hp2 > 0 
                puts "You attacked the goblin and it has #{diff_hp2} hp left".red
                death = prompt.select("You can tell the goblin is breathing but it lies motionless on the forest floor", "Finish it off with your #{inventory[0]}", "Finish it off with your #{inventory[1]}")
                if death == death
                    puts "You beat the goblin to its last breath. As you finish it off, you return to town to warn the villagers of the looming goblin threat"
                end
            elsif diff_hp2 <= 0
            puts "You beat the goblin to its last breath. As you finish it off, you return to town to warn the villagers of the looming goblin threat"
            end
        end
    end
end

def run_sequence
    inventory.push("Short Sword")
    player_hp = 20
    enemy_hp = 10
    enemy_attack_num = rand(1..5)
    player_attack_num = rand(3..9)
    prompt = TTY::Prompt.new
    num = rand(1..20)
    case num 
    when 10..20
        puts "You rolled a #{num} and successfully ran from the Goblin".green
        puts "You ran back to town, telling the militia of the lingering goblin threat in the woods nearby."
    when 1..9
        puts "You rolled a #{num} and the goblin gets a free hit!".red
        new_hp = player_hp - enemy_attack_num
        puts "You now have #{new_hp}"
        enemy_fight_choice = prompt.select("You have been hit by the goblin.".red, "Fight", "Run")
        case enemy_fight_choice
        when "Fight"
            fight_sequence
        else
            puts "You ran back to town, telling the militia of the lingering goblin threat in the woods nearby."
        end
    end
end

def combat
    player_hp = 20
    enemy_hp = 10
    enemy_attack_num = rand(1..5)
    player_attack_num = rand(3..9)
    prompt = TTY::Prompt.new
    combat_choice = prompt.select("A goblin springs upon you as you follow the path! It's holding a thick branch made to look like a club.", "Fight", "Run")
    case combat_choice
    when "Fight"
        fight_sequence
    when "Run"
        run_sequence
    end
    case player_hp
    when -4..0
        puts "Tragically, the goblin strikes you down and delivers a savage finishing blow. Your adventure has ended"
    end
end 





def inspect_the_house
    prompt = TTY::Prompt.new
    puts `clear`
    puts "You circle the perimeter, eyeing the exterior you notice the windows are forced closed with wooden boards and rusted nails."
    puts "The door seems to be propped closed from the inside and the doorknob barely turns anymore. The door frame has a green sheen"
    puts "from the overgrown moss sprouting from the lush forest floor. As you come around the other side of the abandoned abode, you"
    puts "notice a potato sack that has something heavy inside."
    puts "Upon further inspection you find a mace!"
     new_weapon("Mace", "Melee")
    puts "You continue down the path into the confines of the thick spruce forest. As you stroll, you come to a fork in the road. "
    puts "To your left the path continues to a grassy clearing, and to your right the path leads deeper into the pine-bound forests of olde."
    path_house_choice = prompt.select("Where shall you go?", "Head left, to the clearing.", "Delve deeper into the sea of trees.", "Check inventory")
    if path_house_choice == "Head left, to the clearing."
        puts `clear`
        clearing_path
    elsif path_house_choice == "Delve deeper into the sea of trees."
        puts `clear`
        combat
    elsif path_house_choice == "Check inventory"
        puts `clear`
        check_inventory_on_path
    end
end 


def follow_path_into_forest
    prompt = TTY::Prompt.new
    puts "You continue down the path into the confines of the thick spruce forest. As you stroll, you come to a fork in the road. "
    puts "To your left the path continues to a grassy clearing, and to your right the path leads deeper into the pine-bound forests of olde."
    path_forest_choice = prompt.select("Where shall you go?", "Head left, into the clearing.", "Delve deeper into the sea of trees.", "Check inventory")
        case path_forest_choice
        when "Head left, into the clearing."
            puts `clear`
            clearing_path
        when "Delve deeper into the sea of trees."
            puts `clear`
             combat
        when "Check inventory"
            check_inventory_on_path
        end
end

def clearing_path
    prompt = TTY::Prompt.new
    #puts `clear`
    puts "You finally find the break in the woods as you come upon the clearing. You approach a river that looks to be about 20 feet across"
    puts "you check the water's temperature with your hand and find that it is ice cold. This river is likely flowing from the mountains of"
    puts "Galmoria. It is mid-summer and the river is not deep yet not shallow either, the water's flow is strong."
    clearing_choice = prompt.select("What would you like to do?","Roll and see if you can ford the river","Take the path back to town","Check inventory","Quit game")
        case clearing_choice
        when "Roll and see if you can ford the river"
            puts `clear`
            ford_river
        when "Take the path back to town"
            puts "You take the path back to town to get some rest"
        when "Check inventory"
            check_inventory_clearing
        when "Quit game"
            exit
        end
end



def ford_river
    roll = rand(1..20)
    case roll
    when 1..9
        puts "You roll a #{roll}. The river roars with intensity as a new wave of water teems toward you.".red
        puts "You leap back towards the confines of the thick forest. The wall of trees protects against"
        puts "the raging current. As you follow the path back to town you hear snickering above your head."
        puts "You roll your neck upwards and discover a creature amongst the web of branches!".red
        combat
    when 10..20
        puts "You roll a #{roll}. You successfully ford the river's frigid current.".green
        puts "You feel your legs being licked by the subterran flora. As you reach the opposing shore you come"
        puts "upon the gaping mouth of the cave. A cool wind carries the underground air, carressing your skin,"
        puts "still dripping from braving the river's waters."
        cave
    end
end


# Check Inventory


def check_inventory_on_path
    puts "You have #{inventory.join(", ")}".yellow
    follow_path_into_forest
end

def check_inventory_start_of_adv
    puts "You have a #{inventory.join()}".yellow
    start_adv_on_beaten_path
end 

def check_inventory_clearing
    puts "You have #{inventory.join(", ")}".yellow
    clearing_path
end


def start_adv_on_beaten_path
    prompt = TTY::Prompt.new
    # puts `clear`
        puts "You embark on the path leading out of town, few blades of grass litter the path that has been frequently travelled by various"
        puts "adventurers over the years. The air is warm and the area is humid as you are in the midst of mid-summer's heat. You observe an old,"
        puts "dilapidated house, the roof is partially caved in and the windows are boarded shut. To your left, you see a pervasive forest."
        puts "You can tell the woods are old as it has begun to encroach upon the town's surrounding lands and walls."
        path_choice = prompt.select("What would you like to do?", "Inspect the house", "Follow the path into the forest", "Check inventory")
        case path_choice 
        when "Inspect the house"
            puts `clear`
            inspect_the_house
        when "Follow the path into the forest"
            puts `clear`
            follow_path_into_forest 
        when "Check inventory"
            check_inventory_start_of_adv
        end
end 




def adventure_path1
    prompt = TTY::Prompt.new
    choice = prompt.select("What would you like to do first?", "Start your adventure on the beaten path!", "Quit Game") 
    case choice
    #when "Explore the town!"
        #add choice 
    when "Start your adventure on the beaten path!" 
        start_adv_on_beaten_path
    when "Quit Game"
        exit
    end

end 

def cave
    prompt = TTY::Prompt.new
    puts "Before you enter the cave you gaze into the gaping maw of the entrance of the undergound passage."
    puts "A strange air surrounds you as air blows from within the cave. Theres a distinct cold that gives you"
    puts "a slight feeling of dread. You shake it off as you peer into the cave."
    choice = prompt.select("What do you want to do?", "Continue exploring","Go back to town because I am too scared or tired")
        case choice
        when "Continue exploring"
            puts `clear`
             cave_exploring
        when "Go back to town because I am too scared or tired"
            puts "You end your adventure today by following the path back to town"
            exit
        end

end



def run_sequence_specter
    player_hp = 20
    enemy_hp = 10
    enemy_attack_num = rand(1..5)
    player_attack_num = rand(3..9)
    prompt = TTY::Prompt.new
    num = rand(1..20)
    case num 
    when 10..20
        puts "You rolled a #{num} and successfully ran from the spectre".green
        puts "You ran back to town, telling the militia of the spectre threat in the cave across the river."
    when 1..9
        puts "You rolled a #{num} and the spectre gets a free hit!".red
        new_hp = player_hp - enemy_attack_num
        puts "You now have #{new_hp}"
        enemy_fight_choice = prompt.select("You have been hit by the spectre.".red, "Fight", "Run")
        case enemy_fight_choice
        when "Fight"
            fight_sequence_spectre
        else
            puts "You ran back to town, telling the militia of the curse of the spectre dwelling within the cave."
        end
    end
end 

def fight_sequence_spectre
    add_inventory
    player_hp = 20
    enemy_hp = 10
    enemy_attack_num = rand(1..5)
    player_attack_num = rand(3..9)
    prompt = TTY::Prompt.new
    fight_choice = prompt.select("You ready yourself for an attack.", "Attack with #{inventory[0]}", "Attack with #{inventory[1]}")
    if fight_choice == fight_choice
       diff_hp = enemy_hp - player_attack_num
       puts "You attacked the spectre and it has #{diff_hp} hp left".red
       fight_choice2 = prompt.select("The spectre is badly hurt, howling a long, loud, piercing cry.", "Attack with #{inventory[0]}", "Attack with #{inventory[1]}")
       if fight_choice2 == fight_choice2
            diff_hp2 = diff_hp - player_attack_num
            if diff_hp2 > 0 
                puts "You attacked the spectre and it has #{diff_hp2} hp left".red
                death = prompt.select("You can tell the spectre is alive but the cold begins to wane as its visage diminishes", "Finish it off with your #{inventory[0]}", "Finish it off with your #{inventory[1]}")
                if death == death
                    puts "You defeat the spectre. You return to the village to tell the townsmen of the cave-bound curse."
                end
            elsif diff_hp2 <= 0
            puts "You defeat the spectre. You return to the village to tell the townsmen of the cave-bound curse."
            end
        end
    end
end



def cave_exploring
    player_hp = 20
    enemy_hp = 10
    enemy_attack_num = rand(1..5)
    player_attack_num = rand(3..9)
    prompt = TTY::Prompt.new
    puts "As you push on into the depths of the cave, the air becomes increasingly colder and you notice you feel a threatening"
    puts "presence permeating from deeper within the cave. You persevere and shrug the inherent sensation of doubt that"
    puts "accompanies the deepening feeling of dread. You begin to have second thoughts of exploring the cave."
    choice = prompt.select("Before you have the chance to retreat, a spectre materializes out of the unsuspecting shadows", "Fight","Run")
    case choice
    when "Fight"
        fight_sequence_spectre
    when "Run"
        run_sequence_specter
    end
    case player_hp
    when -4..0
        puts "Tragically, the spectre strikes you down and delivers a savage finishing blow. Your adventure has ended"
    end
end


