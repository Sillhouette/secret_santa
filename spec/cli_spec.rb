require 'cli'

describe Cli do
    before(:each) do
        Person.clear
    end

    describe '#welcome' do
        it 'prints the welcome message' do
            cli = generate_cli
            prompt = Cli::WELCOME

            expect(cli.output).to receive(:puts).with(prompt)
            
            cli.welcome
        end
    end

    describe '#prompt_user' do
        it 'prints the prompt' do
            cli = generate_cli("Hannah")
            prompt = "Do something: "

            expect(cli.output).to receive(:puts).with(prompt)
            
            cli.prompt_user(prompt)
        end

        it 'returns the user\'s input' do
            name = "Hannah"
            cli = generate_cli(name)
            prompt = "Do something: "
            
            result = cli.prompt_user(prompt)

            expect(result).to eq name
        end
    end

    describe '#print_participants' do
        it 'prints the list title and an empty array if no participants' do
            cli = generate_cli
            expect(cli.output).to receive(:puts).with(Cli::PARTICIPANT_LIST)
            expect(cli.output).to receive(:puts).with([])

            cli.print_participants
        end

        it 'prints one participant in the list' do
            cli = generate_cli

            name = "Garth"
            Person.create(name: name)

            expect(cli.output).to receive(:puts).with(Cli::PARTICIPANT_LIST)
            expect(cli.output).to receive(:puts).with([name])

            cli.print_participants
        end

        it 'prints multiple participants in the list' do
            cli = generate_cli

            names = ["Garth", "Jessica", "Hannah"]
            names.each {|name| Person.create(name: name) }

            expect(cli.output).to receive(:puts).with(Cli::PARTICIPANT_LIST)
            expect(cli.output).to receive(:puts).with(names)

            cli.print_participants
        end
    end

    describe '#print_matches' do
        it 'prints only the matches title if no people exist' do
            cli = generate_cli

            expect(cli.output).to receive(:puts).with(Cli::MATCH_LIST)

            cli.print_matches
        end

        it 'prints one participant and their match' do
            cli = generate_cli
            name = "Garth"
            match_name = "Dan"
            expected = "#{name} - #{match_name}"
            participant = Person.create(name: name)
            match = Person.create(name: match_name)

            participant.match = match

            expect(cli.output).to receive(:puts).with(Cli::MATCH_LIST)
            expect(cli.output).to receive(:puts).with(expected)

            cli.print_matches
        end

        it 'prints two participants and their matches' do
            cli = generate_cli
            names = ["Garth", "Dan"]
            names.each do |name|
                Person.create(name: name)
            end
            expected_1 = "#{names[0]} - #{names[1]}"
            expected_2 = "#{names[1]} - #{names[0]}"

            Person.all.first.match = Person.all[1]
            Person.all[1].match = Person.all.first

            expect(cli.output).to receive(:puts).with(Cli::MATCH_LIST)
            expect(cli.output).to receive(:puts).with(expected_1)
            expect(cli.output).to receive(:puts).with(expected_2)

            cli.print_matches
        end

        it 'prints complicated matches' do
            cli = generate_cli
            names = ["Garth", "Dan", "Hannah"]
            names.each do |name|
                Person.create(name: name)
            end
            expected_1 = "#{names[0]} - #{names[2]}"
            expected_2 = "#{names[1]} - #{names[0]}"
            expected_3 = "#{names[2]} - #{names[1]}"

            Person.all.first.match = Person.all[2]
            Person.all[1].match = Person.all.first
            Person.all[2].match = Person.all[1]

            expect(cli.output).to receive(:puts).with(Cli::MATCH_LIST)
            expect(cli.output).to receive(:puts).with(expected_1)
            expect(cli.output).to receive(:puts).with(expected_2)
            expect(cli.output).to receive(:puts).with(expected_3)

            cli.print_matches
        end
    end

    describe '#exit?' do
        it 'returns true if the response equals Cli::STOP' do
            cli = generate_cli
            response = Cli::STOP
            expected = true

            result = cli.exit?(response)

            expect(result).to eq expected
        end

        it 'returns false if the response does not equal Cli::STOP' do
            cli = generate_cli
            response = "Hannah"
            expected = false

            result = cli.exit?(response)

            expect(result).to eq expected
        end
    end

    describe '#validate_yes_no_response' do
        it 'returns true if the response is yes' do
            cli = generate_cli
            response = "yes"
            expected = true

            result = cli.validate_yes_no_response(response)
            
            expect(result).to eq expected
        end

        it 'returns true if the response is no' do
            cli = generate_cli
            response = "no"
            expected = true

            result = cli.validate_yes_no_response(response)
            
            expect(result).to eq expected
        end

        it 'returns true if the response is neither yes nor no' do
            cli = generate_cli
            response = "nonsense"
            expected = false

            result = cli.validate_yes_no_response(response)
            
            expect(result).to eq expected
        end
    end

    describe '#get_participant' do
        it 'prints Cli::PARTICIPANT_PROMPT and Cli::EXIT_INSTRUCTIONS' do
            cli = generate_cli
            prompt = Cli::PARTICIPANT_PROMPT + Cli::EXIT_INSTRUCTION

            expect(cli.output).to receive(:puts).with(prompt)
            
            cli.get_participant
        end

        it 'returns the string passed to input' do
            name = "Garth"
            cli = generate_cli(name)

            result = cli.get_participant

            expect(result).to eq(name)
        end
    end

    describe '#get_spouse' do
        it 'prints Cli::SPOUSE_PROMPT' do
            cli = generate_cli
            prompt = Cli::SPOUSE_NAME_PROMPT

            expect(cli.output).to receive(:puts).with(prompt)
            
            cli.get_spouse
        end

        it 'returns the string passed to input' do
            name = "Garth"
            cli = generate_cli(name)

            result = cli.get_spouse

            expect(result).to eq(name)
        end
    end

    describe '#has_spouse?' do
        it 'asks if the participant has a spouse' do
            response = Cli::YES_NO[:yes]
            cli = generate_cli(response)
            name = "Dan"
            prompt = "\nDoes #{name} have a spouse?"

            expect(cli.output).to receive(:puts).with(prompt)
            
            cli.has_spouse?(name)
        end

        it 'asks until it receives a proper response' do
            responses = ['gibberish', Cli::YES_NO[:no]]
            cli = generate_cli(*responses)
            name = "Dan"
            prompt = "\nDoes #{name} have a spouse?"

            expect(cli.output).to receive(:puts).twice.with(prompt)
            expect(cli.output).to receive(:puts).with(Cli::INVALID_INPUT)

            cli.has_spouse?(name)
        end

        it 'returns true if passed Cli::YES_NO[:yes] as the response' do
            response = Cli::YES_NO[:yes]
            expected = true
            cli = generate_cli(response)
            name = "Dan"

            result = cli.has_spouse?(name)

            expect(result).to eq expected
        end

        it 'returns false if passed Cli::YES_NO[:no] as the response' do
            response = Cli::YES_NO[:no]
            expected = false
            cli = generate_cli(response)
            name = "Hannah"

            result = cli.has_spouse?(name)

            expect(result).to eq expected
        end

        it 'asks until it receives a valid response' do
            responses = ['gibberish', 'hello', 'invalid', Cli::YES_NO[:no]]
            expected = false
            cli = generate_cli(*responses)
            name = "Hannah"
            prompt = "\nDoes #{name} have a spouse?"

            expect(cli.output).to receive(:puts).exactly(4).times.with(prompt)
            expect(cli.output).to receive(:puts).exactly(3).times.with(Cli::INVALID_INPUT)

            result = cli.has_spouse?(name)

            expect(result).to eq expected
        end
    end

    describe '#check_valid_response' do
        it 'outputs Cli::INVALID_INPUT if the response is not valid' do
            cli = generate_cli
            valid_responses = ["hello", "upsell", "nah"]
            response = "no"
            expected = false
            
            expect(cli.output).to receive(:puts).with(Cli::INVALID_INPUT)

            cli.check_valid_response(response, valid_responses)
        end

        it 'returns false if the response is not valid' do
            cli = generate_cli
            valid_responses = ["hello", "upsell", "nah"]
            response = "no"
            expected = false
            
            result = cli.check_valid_response(response, valid_responses)

            expect(result).to eq expected
        end

        it 'returns true if the response is valid' do
            cli = generate_cli
            valid_responses = ["hello", "upsell", "nah"]
            response = "nah"
            expected = true
            
            result = cli.check_valid_response(response, valid_responses)

            expect(result).to eq expected
        end
    end

    describe '#get_participant_data' do
        it 'returns an array of participant\'s data' do
            responses = ['Garth', Cli::YES_NO[:yes], 'Jessica', 'Hannah', Cli::YES_NO[:no], Cli::STOP]
            expected = [['Garth', 'Jessica'], ['Hannah', nil]]
            cli = generate_cli(*responses)

            result = cli.get_participant_data

            expect(result).to eq expected
        end
    end

    describe 'confirm_participants' do
        it 'returns true if passed Cli::YES_NO[:yes] as the response' do
            response = Cli::YES_NO[:yes]
            expected = true
            cli = generate_cli(response)

            result = cli.confirm_participants

            expect(result).to eq expected
        end

        it 'returns false if passed Cli::YES_NO[:no] as the response' do
            response = Cli::YES_NO[:no]
            expected = false
            cli = generate_cli(response)

            result = cli.confirm_participants

            expect(result).to eq expected
        end

        it 'prints invalid response error and asks again if answer not in Cli::YES_NO' do
            responses = ['hannah', Cli::YES_NO[:no]]
            expected = false
            cli = generate_cli(*responses)

            expect(cli.output).to receive(:puts).exactly(2).times.with(Cli::CONFIRM_PARTICIPANTS)
            expect(cli.output).to receive(:puts).exactly(1).times.with(Cli::INVALID_INPUT)

            cli.confirm_participants
        end
    end
  end