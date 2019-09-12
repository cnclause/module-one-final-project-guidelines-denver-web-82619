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

#Combat methods
def fight_sequence
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



# Adventure Methods 


def inspect_the_house
    prompt = TTY::Prompt.new
    puts `clear`
    puts "As you inspect the house, you notice that it is sealed shut. The windows are borded and the house is locked."
    puts "You continue walking around the house, and notice a sack with something inside."
    puts "Upon further inspection you find a mace!"
     new_weapon("Mace", "Melee")
    puts "You continue down the path into the confines of the thick spruce forest. As you stroll, you come to a fork in the road. "
    puts "To your left the path continues to a grassy clearing, and to your right the path leads deeper into the pine-bound forests of olde."
    path_house_choice = prompt.select("Where shall you go?", "Head left, to the clearing.", "Delve deeper into the sea of trees.", "Check inventory")
    if path_house_choice == "Head left, to the clearing."
        clearing_path
    elsif path_house_choice == "Delve deeper into the sea of trees."
        combat
    elsif path_house_choice == "Check inventory"
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
            clearing_path
        when "Delve deeper into the sea of trees."
             combat
        when "Check inventory"
            check_inventory_on_path
        end
end

def clearing_path
    prompt = TTY::Prompt.new
    #puts `clear`
    puts "When you enter the clearing you notice that the path has ended.\n"
    puts "You see a river ahead. It spans about 20 feet across, with rushing, ice, cold water that is about knee deep."
    puts "Across the river you notice a cave. The opening as large and dark as a megaladon's gullet"
    clearing_choice = prompt.select("What would you like to do?","Roll and see if you can ford the river","Take the path back to town","Check inventory","Quit game")
        case clearing_choice
        when "Roll and see if you can ford the river"
            ford_river
        when "Take path back to town"
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
        puts "You roll a #{roll}. The river roars with intensity as a new wave of water teems toward you."
        puts "You leap back towards the confines of the thick forest. The wall of trees protects against"
        puts "the raging current. As you follow the path back to town you hear snickering above your head."
        puts "You roll your neck upwards and discover a creature amongst the web of branches!".red
        combat
    when 10..20
        puts "You roll a #{roll}. You successfully ford the river's frigid current, you feel your legs being"
        puts "licked by the subterran flora. As you reach the opposing shore you come upon the gaping mouth"
        puts "of the cave. A cool wind carries the underground air, carressing your skin, still dripping from"
        puts "braving the river's waters."
        #Cave method here
    end
end


# Check Inventory


def check_inventory_on_path
     puts "You have #{inventory.join(", ")}".yellow
     #Impliment/search for way to loop back to the original prompt
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
        puts "As you walk the path, you notice a lush forest and an old, abandoned house."
        path_choice = prompt.select("Would you like to inspect the house or follow the path into the forest?", "Inspect the house", "Follow the path into the forest", "Check inventory")
        case path_choice 
        when "Inspect the house" 
            inspect_the_house
        when "Follow the path into the forest"
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



