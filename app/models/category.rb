class Category < ActiveRecord::Base
  extend FriendlyId
  update_index 'products#product', :products

  acts_as_ordered_taggable_on :child_category # TODO: get rid of this

  friendly_id :name_candidates, use: [:slugged, :finders, :history], slug_column: :code

  has_many :categorizations
  has_many :products, through: :categorizations, source: :product

  belongs_to :parent, primary_key: 'code', foreign_key: 'parent_code', polymorphic: true
  has_many :children, -> { ordered }, as: :parent, primary_key: 'code', foreign_key: 'parent_code', class_name: 'Category'

  scope :root, -> { where(parent: nil) }
  scope :ordered, -> { order(:order_position) }

  def to_s
    self.name
  end

  def name_candidates
    [
      [:parent_code, :name]
    ]
  end
end
