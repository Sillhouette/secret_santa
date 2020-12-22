require 'pry'

class SecretSanta
    attr_accessor :cli

    def initialize(cli: Cli.new)
        @cli = cli
    end

    def start
        @cli.welcome
        finished = false
        until finished
            participant_data = @cli.get_participant_data
            create_participants(participant_data)
            @cli.print_participants
            finished = @cli.confirm_participants
        end
        match_participants
        @cli.print_matches
    end

    def create_participants(participants)
        participants.each do |participant_data|
            name, spouse = participant_data
            Person.create(name: name, spouse: spouse)
        end
    end

    def unmatched
        participants = Person.all.dup
        matched = participants.map do |person|
            person.match
        end
        matched.each do |match|
            participants.delete match
        end
        participants
    end

    def match_participants
        until unmatched.length == 0
            Person.all.each do |participant|
                match_participant(participant)
            end
        end
    end

    def match_participant(participant)
        match = unmatched.sample
        if match != participant && match != participant.spouse
            participant.match = match
        elsif 
            match == participant.spouse && ((unmatched.length == 2 && unmatched.include?(participant)) || unmatched.length == 1) || (match == participant && unmatched.length == 1) || unmatched.length == 0
        else
            match_participant(participant)
        end
    end
end