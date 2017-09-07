# frozen_string_literal: true

FactoryGirl.define do
  factory :user, class: User do
    email 'test@test.com'
    password '123456Qwerty'
    password_confirmation '123456Qwerty'
  end

  factory :regular_user, class: User do
    email 'regular_user@test.com'
    password 'password'
    password_confirmation 'password'
    role 'regular_user'
  end

  factory :admin, class: User do
    email 'admin@test.com'
    password 'password'
    password_confirmation 'password'
    role 'admin'
  end
end
