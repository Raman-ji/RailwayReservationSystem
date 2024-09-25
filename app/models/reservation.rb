class Reservation < ApplicationRecord
  belongs_to :train_detail
  belongs_to :available

  with_options presence: true do
    validates :passenger_name, :age, :gender, :date_of_birth, :seat_numbers, :berth_class, :email, :phone_number
  end

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'must be a valid email address' }
  validates :phone_number, format: { with: /\A\d{10}\z/, message: 'must be a valide phone number ' }

  before_create :generate_pnr, :availability_check

  private

  def generate_pnr
    self.pnr = loop do
      number = Random.rand(1_000_000_000..9_999_999_999)
      break number unless Reservation.exist?(pnr: number)
    end
  end

  def availability_check
    if self.berth_class == '2AC'
      self.ticket_status = available._2AC_available.zero? ? 'Pending' : 'Done'

    elsif self.berth_class == '1AC'
      self.ticket_status = available._1AC_available.zero? ? 'Pending' : 'Done'

    else
      sself.ticket_status = available.general_available.zero? ? 'Pending' : 'Done'
    end
  end
end
