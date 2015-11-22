class Product < ActiveRecord::Base
	has_many :line_items
	has_many :images
	accepts_nested_attributes_for :images, allow_destroy: true

	mount_uploader :image_url, ImageUploader

	before_destroy :ensure_not_referenced_by_any_line_item

	validates :title, :description, presence: true
	validates :price, numericality: {greater_than_or_equal_to: 0.01}
	validates :title, uniqueness: true
	validates :image_url, allow_blank: true, format: {
		with: %r{\.(gif|png|jpg)\Z}i,
		message: 'must be a URL for GIF, JPG or PNG image'
	}

	def add_to_cart(cart)
		line_item = line_items.find_by(cart_id: cart.id)
		if line_item
      line_item.quantity += 1
    else
      line_item = line_items.build(cart_id: cart.id)
    end
    line_item
	end

	private

	def ensure_not_referenced_by_any_line_item
		if line_items.empty?
			return true
		else
			errors.add(:base, 'существуют товарные позиции')
			return false
		end
	end

end
