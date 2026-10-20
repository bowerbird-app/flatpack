# frozen_string_literal: true

class PageNavFlowController < ApplicationController
  include FlatPack::ReturnTo

  def show
  end

  def next_screen
  end

  def create
    redirect_to_return_to(fallback: demo_page_nav_path)
  end
end
