# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # ProfiledUser is included by RecordingStudioUser::Engine on boot.
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable
end
