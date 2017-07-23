class CarModel < Category
  has_many :cars, foreign_key: :car_make_id, class_name: 'Product'
end
