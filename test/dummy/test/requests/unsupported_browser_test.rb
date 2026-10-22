# frozen_string_literal: true

require "test_helper"

class UnsupportedBrowserTest < ActionDispatch::IntegrationTest
  OLD_CHROME = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36"

  test "an outdated Chrome gets the static 406 page" do
    get "/", headers: {"User-Agent" => OLD_CHROME}

    assert_response :not_acceptable
    assert_includes response.body, "Browser not supported"
    assert_not_includes response.body, "ArgumentError"
  end
end
