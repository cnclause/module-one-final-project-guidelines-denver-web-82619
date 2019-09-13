require 'colorize'
require_relative 'methods.rb'

class Cli 
    attr_reader :user

    def initialize(user)
        @user = user
    end

    # def menu
    #     prompt = TTY::Prompt.new
    #     choice = prompt.select("Welcome to the DnD main menu!",("Start a game"), ("Manage users"), "Exit")
    # end

    def start
        puts "Hello, #{@user}. Lets choose a character!"
        choice = race_choice 
        if choice == "Exit"
            puts "Bye"
            exit
        else 
            choice_2 = class_choice 
            if choice_2 == "Exit"
                puts "Bye"
                exit
            end
        end
        created_user = User.create(name: @user, race: choice, profession: choice_2)

        puts `clear`

        def new_weapon(name, category)
            Weapon.create(name: name, category: "#{category} Weapon")
            Userweapon.create(user: User.all.last, weapon: Weapon.all.last)
            # puts `clear`
            puts "#{name} was added to your inventory.".yellow.blink
        end
        def item (choice)
            items_array = ["Assassin's Dagger", "Club", "Fiery Power Staff", "Quarterstaff", "Rustblade", "Warlock’s Scepter", "Crossbow", "Spear"]
            if choice == "Barbarian" || choice == "Fighter"
                given_weapon = Weapon.create(name: items_array[1], category: "Melee Weapon")
                puts "You have been given the #{items_array[1]}".yellow.blink
        
            elsif choice == "Bard" || choice == "Paladin" || choice == "Monk"
                given_weapon = Weapon.create(name: items_array[7], category: "Melee Weapon")
                puts "You have been given the #{items_array[7]}".yellow.blink
        
            elsif choice == "Ranger" || choice == "Rogue" || choice == "Druid"
                given_weapon = Weapon.create(name: items_array[6], category: "Melee Weapon")
                puts "You have been given the #{items_array[6]}".yellow.blink
        
            elsif choice == "Sorcerer" || choice == "Warlock" || choice == "Wizard" || choice == "Cleric"
                given_weapon = Weapon.create(name: items_array[3], category: "Melee Weapon")
                puts "You have been given the #{items_array[3]}".yellow.blink
            end
            
        end

        puts item(choice_2)
        Userweapon.create(user: created_user, weapon: Weapon.all.last)
        puts "Welcome to town, #{choice.downcase}!"

        adventure_path1
       # binding.pry

      





    end
end 