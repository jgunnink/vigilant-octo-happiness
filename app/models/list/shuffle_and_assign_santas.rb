class List::ShuffleAndAssignSantas

  def initialize(list)
    @list = list
    @santas = @list.santas
  end

  def assign
    @recipient_list = @santas.to_a
    randomise_and_assign(@recipient_list, @recipient_list, [], [])
  end

private

  def randomise_and_assign(available_santas, unassigned_santas, assigned_santas, assigned_recipients)
    return if unassigned_santas.length == 0

    santa = (available_santas - assigned_santas).sample
    recipient = (available_santas - assigned_recipients - [santa]).sample

    assigned_santas << santa
    unassigned_santas = available_santas - assigned_santas
    assigned_recipients << recipient

    santa.giving_to = recipient.id
    puts "#{santa.name} is giving to #{recipient.name}"
    santa.save!

    randomise_and_assign(available_santas, unassigned_santas, assigned_santas, assigned_recipients)
  end

end
