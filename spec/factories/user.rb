FactoryGirl.define do
  factory :user, class: User do
    email 'test@test.com'
    password '123456Qwerty'
    password_confirmation '123456Qwerty'
  end
end
