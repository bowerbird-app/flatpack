# frozen_string_literal: true

class LocalTimeDemoController < ApplicationController
  def index
    @now = Time.current
  end
end
