class Cli
    attr_accessor :input, :output

    WELCOME = "Welcome to Secret Santa\n"
    PARTICIPANT_LIST = "\nParticipant list:"
    MATCH_LIST = "\nMatch list: "
    STOP = "end"
    PARTICIPANT_PROMPT = "\nPlease enter a participant's name: "
    EXIT_INSTRUCTION = "(Type \"#{STOP}\" to stop)"
    INVALID_INPUT = "\nThat response was invalid, try again."
    SPOUSE_NAME_PROMPT = "\nWhat is their name?"
    CONFIRM_PARTICIPANTS = "\nIs this all of the participants?"
    YES_NO = { yes: "yes", no: "no"}

    def initialize(input: $stdin, output: $stdout)
      @input = input
      @output = output
    end

    def welcome
        output.puts WELCOME
    end

    def prompt_user(prompt)
        output.puts prompt
        input.gets.strip
    end

    def print_participants
        output.puts PARTICIPANT_LIST
        output.puts Person.all.map(&:name)
    end

    def print_matches
        output.puts MATCH_LIST
        Person.all.each do |person|
            output.puts "#{person.name} - #{person.match.name}" if person.match
        end
    end

    def exit?(response)
        response == STOP
    end

    def validate_yes_no_response(response)
        YES_NO.values.include?(response)
    end

    def get_participant
        prompt_user(PARTICIPANT_PROMPT + EXIT_INSTRUCTION)
    end

    def get_spouse
        prompt_user(SPOUSE_NAME_PROMPT)
    end

    def has_spouse?(participant)
        spouse_prompt = "\nDoes #{participant} have a spouse?"
        response = prompt_user(spouse_prompt)

        if check_valid_response(response, YES_NO.values)
            return response == YES_NO[:yes]
        else
            has_spouse?(participant)
        end
    end

    def check_valid_response(response, valid_responses)
        if !valid_responses.include?(response)
            output.puts INVALID_INPUT
            return false
        end
        true
    end

    def get_participant_data
        participants = []
        spouse = nil
        participant = get_participant
        until exit?(participant)
            if has_spouse?(participant)
                spouse = get_spouse
            end
            participants.push([participant, spouse])
            spouse = nil
            participant = get_participant
        end
        participants
    end

    def confirm_participants
        response = prompt_user(CONFIRM_PARTICIPANTS)
        if check_valid_response(response, YES_NO.values)
            return response == YES_NO[:yes]
        end
        confirm_participants
    end
end