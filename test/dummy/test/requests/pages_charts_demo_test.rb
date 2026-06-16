# frozen_string_literal: true

require "test_helper"

class PagesChartsDemoTest < ActionDispatch::IntegrationTest
  test "charts page renders mini chart table row example" do
    get demo_charts_path

    assert_response :success
    assert_includes response.body, "Mini Chart in Table Row"
    assert_includes response.body, "flat-pack"
    assert_includes response.body, "data-flat-pack--chart-height-value=\"56\""
    assert_includes response.body, "sparkline"
    assert_includes response.body, "data-flat-pack--chart-type-value=\"bar\""
    assert_includes response.body, "&quot;isFunnel&quot;:true"
    assert_includes response.body, "&quot;distributed&quot;:true"
    assert_includes response.body, "&quot;colors&quot;:[&quot;#2563eb&quot;,&quot;#3b82f6&quot;,&quot;#60a5fa&quot;,&quot;#93c5fd&quot;,&quot;#bfdbfe&quot;,&quot;#dbeafe&quot;]"
  end
end
