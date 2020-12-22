require 'secret_santa'

describe SecretSanta do
    before(:each) do
        @secret_santa = SecretSanta.new(cli: generate_cli)
        Person.clear
    end

    describe '#create_participants' do
        it 'can create a single participant with no spouse' do
            name = "Hannah"
            spouse = nil
            participant_data = [[name, spouse]]
            num_people = 1
    
            @secret_santa.create_participants(participant_data)
            participant = Person.find_by_name(name: name)
            result = Person.all.length
    
            expect(result).to eq num_people
            expect(participant.name).to eq name
            expect(participant.spouse).to be nil
        end

        it 'can create a single participant with a spouse' do
            name = "Garth"
            spouse = 'Jessica'
            participant_data = [[name, spouse]]
            num_people = 2
    
            @secret_santa.create_participants(participant_data)
            participant = Person.find_by_name(name: name)
            result = Person.all.length
    
            expect(result).to eq num_people
            expect(participant.name).to eq name
            expect(participant.spouse.name).to be spouse
        end

        it 'can create a multiple participants with and without spouses' do
            participant_1 = ["Garth", "Jessica"]
            participant_2 = ["Hannah", nil]
            participant_3 = ["Dan", "Mickie"]
            participant_data = [participant_1, participant_2, participant_3]
            num_people = 5
    
            @secret_santa.create_participants(participant_data)
            first_participant = Person.find_by_name(name: participant_1[0])
            second_participant = Person.find_by_name(name: participant_2[0])
            third_participant = Person.find_by_name(name: participant_3[0])
            result = Person.all.length
    
            expect(result).to eq num_people
            expect(first_participant.name).to eq participant_1[0]
            expect(first_participant.spouse.name).to be participant_1[1]
            expect(first_participant.spouse.spouse.name).to be participant_1[0]
            expect(second_participant.name).to eq participant_2[0]
            expect(second_participant.spouse).to be nil
            expect(third_participant.name).to eq participant_3[0]
            expect(third_participant.spouse.name).to be participant_3[1]
            expect(third_participant.spouse.spouse.name).to be participant_3[0]
        end
    end

    describe '#unmatched' do
        it 'returns an array containing an unmatched participant' do
            first_person = Person.create(name: 'Hannah')
            second_person = Person.create(name: 'Garth')

            first_person.match = second_person
            result = @secret_santa.unmatched

            expect(result).to include first_person
            expect(result).not_to include second_person
        end

        it 'returns an array of all unmatched participants' do
            first_person = Person.create(name: 'Hannah')
            second_person = Person.create(name: 'Garth')
            third_person = Person.create(name: 'Dan', spouse: 'Mickie')
            fourth_person = Person.find_by_name(name: 'Mickie')

            first_person.match = second_person
            result = @secret_santa.unmatched

            expect(result).to include first_person
            expect(result).to include third_person
            expect(result).to include fourth_person
            expect(result).not_to include second_person
        end

        it 'does not affect size of Person.all array' do
            first_person = Person.create(name: 'Hannah')
            second_person = Person.create(name: 'Garth')
            expected = 2

            first_person.match = second_person
            @secret_santa.unmatched
            result = Person.all.length

            expect(result).to eq expected
        end
    end

    describe '#match_participant' do
        it 'matches two participants together' do
            participant = Person.create(name: "Hannah")
            match = Person.create(name: 'Garth')

            @secret_santa.match_participant(participant)

            expect(participant.match).to eq match
        end

        it 'will not match spouses together' do
            participant = Person.create(name: 'Garth', spouse: 'Jessica')
            match = Person.create(name: "Hannah")

            @secret_santa.match_participant(participant)

            expect(participant.match).to eq match
        end

        it 'will not match spouses together if they are the only participants' do
            participant = Person.create(name: 'Garth', spouse: 'Jessica')
            spouse = Person.find_by_name(name: 'Jessica')

            @secret_santa.match_participant(participant)

            expect(participant.match).not_to eq spouse
        end

        it 'will not match spouses together if they are the only participants not already matched (pt 1)' do
            participant = Person.create(name: 'Garth', spouse: 'Jessica')
            participant_2 = Person.create(name: 'Hannah')
            spouse = Person.find_by_name(name: 'Jessica')

            participant_2.match = participant
            spouse.match = participant_2

            @secret_santa.match_participant(participant)

            expect(participant.match).not_to eq spouse
        end

        it 'will not match spouses together if they are the only participants not already matched (pt 2)' do
            participant = Person.create(name: 'Garth', spouse: 'Jessica')
            participant_2 = Person.create(name: 'Hannah')
            participant_3 = Person.create(name: 'Dan')
            spouse = Person.find_by_name(name: 'Jessica')

            participant_2.match = participant_3
            participant_3.match = participant_2

            @secret_santa.match_participant(participant)

            expect(participant.match).not_to eq spouse
        end

        it 'gracefully handles one match left with only choice being spouse' do
            participant = Person.create(name: 'Whitney', spouse: 'Allen')
            participant_2 = Person.create(name: 'Hannah')
            participant_3 = Person.create(name: 'Garth')
            spouse = Person.find_by_name(name: 'Allen')

            participant_2.match = participant_3
            participant_3.match = participant
            spouse.match = participant_2

            @secret_santa.match_participant(participant)

            expect(participant.match).not_to eq spouse
        end
    end

    describe '#match_participants' do
        it 'sucessfully matches everyone' do 
            Person.create(name: "Dan", spouse: "Mickie")
            Person.create(name: "Garth", spouse: "Jessica")
            Person.create(name: "Whitney", spouse: "Allen")
            Person.create(name: "Hannah")

            @secret_santa.match_participants

            expect(@secret_santa.unmatched.length).to eq 0
        end
    end

    describe '#start' do
        it 'Runs the game' do
            inputs = [
                "Hannah", 
                "no", 
                "Garth", 
                "yes", 
                "Jessica", 
                "Dan", 
                "yes", 
                "Mickie", 
                "Whitney", 
                "yes", 
                "Allen", 
                "end",
                "yes"
            ]
            cli = generate_cli(*inputs)
            @secret_santa.cli = cli
            expected = 0

            @secret_santa.start
            result = @secret_santa.unmatched.length

            Person.all.each do |person|
                expect(person.match).to_not eq person.spouse
            end
            
            expect(result).to eq expected
        end
    end
end